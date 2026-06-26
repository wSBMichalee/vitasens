import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { imageBase64, mealType, photoBase64 } = await req.json();
    const base64 = imageBase64 || photoBase64;

    if (!base64) {
      return new Response(JSON.stringify({ success: false, error: 'No image provided' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400
      });
    }

    const apiKey = Deno.env.get('GEMINI_API_KEY');
    if (!apiKey) {
      return new Response(JSON.stringify({ success: false, error: 'GEMINI_API_KEY not set' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500
      });
    }

    const prompt = `You are a professional nutritionist and food recognition AI, similar to CalAI. Analyze this food image and return ONLY a valid JSON object with NO markdown, no backticks, no explanation.

Return this exact JSON structure:
{
  "foodName": "string - specific name of the dish or food item",
  "confidence": "high|medium|low - how confident you are in the identification",
  "portionSize": "string - estimated portion size e.g. '1 plate (350g)' or '1 cup (240ml)'",
  "portionGrams": 0,
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "fiber": 0,
  "sugar": 0,
  "sodium": 0,
  "ingredients": [
    {"name": "string", "estimatedGrams": 0, "calories": 0}
  ],
  "mealType": "breakfast|lunch|dinner|snack - most likely meal type for this food",
  "cuisineType": "string - e.g. Italian, Polish, Asian, American etc.",
  "healthScore": 5,
  "tags": ["array of strings like vegetarian, high-protein, low-carb, gluten-free if applicable"],
  "alternativeNames": ["other names this dish might be called"],
  "notes": "string - any important nutritional notes or warnings, max 1 sentence"
}

Be specific and accurate. For mixed dishes, estimate ingredient portions. If the image is unclear, still provide your best estimate with confidence: "low".`;

    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;
    
    const body = {
      contents: [{
        parts: [
          { text: prompt },
          { inlineData: { mimeType: "image/jpeg", data: base64 } }
        ]
      }]
    };

    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    });

    if (!response.ok) {
      const errTxt = await response.text();
      return new Response(JSON.stringify({ success: false, error: `Gemini API error: ${errTxt}` }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500
      });
    }

    const data = await response.json();
    let textResult = data.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!textResult) {
      return new Response(JSON.stringify({ success: false, error: 'Could not analyze image' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Clean markdown formatting if present
    textResult = textResult.replace(/```json/g, '').replace(/```/g, '').trim();

    try {
      const parsed = JSON.parse(textResult);
      return new Response(JSON.stringify({
        success: true,
        foodName: parsed.foodName,
        confidence: parsed.confidence || 'medium',
        portionSize: parsed.portionSize,
        portionGrams: parsed.portionGrams || 0,
        calories: parsed.calories || 0,
        protein: parsed.protein || 0,
        carbs: parsed.carbs || 0,
        fat: parsed.fat || 0,
        fiber: parsed.fiber || 0,
        sugar: parsed.sugar || 0,
        sodium: parsed.sodium || 0,
        ingredients: parsed.ingredients || [],
        mealType: parsed.mealType || 'snack',
        cuisineType: parsed.cuisineType || '',
        healthScore: parsed.healthScore || 5,
        tags: parsed.tags || [],
        alternativeNames: parsed.alternativeNames || [],
        notes: parsed.notes || '',
      }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    } catch (parseError) {
      return new Response(JSON.stringify({ success: false, error: 'Could not analyze image' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

  } catch (error) {
    return new Response(JSON.stringify({ success: false, error: error instanceof Error ? error.message : 'Unknown error' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500
    });
  }
});
