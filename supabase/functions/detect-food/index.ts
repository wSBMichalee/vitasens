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

    const prompt = "Analyze this food image and return ONLY a valid JSON object with these exact fields: foodName (string, the name of the food or dish), calories (number, estimated calories for the portion shown), protein (number, grams of protein), carbs (number, grams of carbohydrates), fat (number, grams of fat), portionSize (string, estimated portion e.g. '1 cup', '200g'). Return only the JSON, no other text.";

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
        calories: parsed.calories,
        protein: parsed.protein,
        carbs: parsed.carbs,
        fat: parsed.fat,
        portionSize: parsed.portionSize
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
