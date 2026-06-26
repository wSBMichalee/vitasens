import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { getUserId, getSupabaseAdmin } from '../_shared/supabaseClient.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') || '');
    const { imageBase64, mode } = await req.json(); // mode: 'fridge' | 'receipt'

    const apiKey = Deno.env.get('GEMINI_API_KEY');
    if (!apiKey) throw new Error('GEMINI_API_KEY not set');

    const fridgePrompt = `You are analyzing a photo of a fridge or food storage. Extract ALL visible food products and ingredients.
Return ONLY a valid JSON array (no markdown, no backticks):
[
  {
    "name": "string - product name in English",
    "namePl": "string - product name in Polish",
    "category": "dairy|meat|vegetables|fruits|grains|drinks|condiments|other",
    "estimatedQuantity": number,
    "unit": "g|kg|ml|l|szt|pcs",
    "estimatedExpiryDays": number - estimated days until expiry based on typical shelf life,
    "calories100g": number - estimated calories per 100g,
    "protein100g": number,
    "carbs100g": number,
    "fat100g": number
  }
]
Be thorough - identify every visible product. If quantity is unclear, estimate conservatively.`;

    const receiptPrompt = `You are analyzing a shopping receipt photo. Extract ALL purchased food products.
Return ONLY a valid JSON array (no markdown, no backticks):
[
  {
    "name": "string - product name in English",
    "namePl": "string - product name in Polish or as on receipt",
    "category": "dairy|meat|vegetables|fruits|grains|drinks|condiments|other",
    "estimatedQuantity": number,
    "unit": "g|kg|ml|l|szt|pcs",
    "estimatedExpiryDays": number,
    "priceAmount": number - price if visible,
    "calories100g": number,
    "protein100g": number,
    "carbs100g": number,
    "fat100g": number
  }
]
Extract every food item from the receipt. Skip non-food items.`;

    const prompt = mode === 'receipt' ? receiptPrompt : fridgePrompt;
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;

    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{
          parts: [
            { text: prompt },
            { inlineData: { mimeType: 'image/jpeg', data: imageBase64 } }
          ]
        }],
        generationConfig: { temperature: 0.1 }
      })
    });

    const data = await response.json();
    let text = data.candidates?.[0]?.content?.parts?.[0]?.text || '[]';
    text = text.replace(/```json/g, '').replace(/```/g, '').trim();

    let products = [];
    try { products = JSON.parse(text); } catch { products = []; }

    return new Response(JSON.stringify({ success: true, products, mode }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  } catch (e: any) {
    return new Response(JSON.stringify({ success: false, error: e.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500
    });
  }
});
