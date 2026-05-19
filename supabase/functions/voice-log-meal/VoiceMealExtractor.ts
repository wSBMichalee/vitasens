import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { ExternalAPIError, ValidationError } from '../_shared/errorHandler.ts';
import type { ParsedSpeech } from './SpeechParser.ts';

export interface VoiceMealResult {
  foodItems: Array<{
    name: string;
    quantity: number;
    unit: string;
    portionSize: 'small' | 'medium' | 'large';
  }>;
  rawText: string;
  confidence: number;
}

export interface LoggedMealFromVoice {
  userId: string;
  mealDate: string;
  mealTime: 'breakfast' | 'lunch' | 'dinner' | 'snack';
  foodName: string;
  proteinG: number;
  carbsG: number;
  fatG: number;
  calories: number;
  source: 'voice';
  rawVoiceText: string;
}

interface GeminiResponse {
  candidates: Array<{
    content: { parts: Array<{ text: string }> };
  }>;
}

export class VoiceMealExtractor {
  private readonly apiKey: string;
  private readonly apiUrl: string;

  constructor() {
    const key = Deno.env.get('GEMINI_API_KEY');
    if (!key) throw new ExternalAPIError('Brak GEMINI_API_KEY.');
    this.apiKey = key;
    this.apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  }

  async extract(parsedSpeech: ParsedSpeech): Promise<VoiceMealResult> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 15_000);

    const body = {
      systemInstruction: {
        parts: [{
          text: 'Jesteś asystentem który wyciąga informacje o jedzeniu z tekstu mówionego. Odpowiadaj TYLKO w formacie JSON.',
        }],
      },
      contents: [{
        role: 'user',
        parts: [{
          text: `Wyciągnij produkty spożywcze z tekstu:\n"${parsedSpeech.cleanedText}"\n\nOdpowiedz JSON:\n{\n  "foodItems": [\n    {\n      "name": "nazwa po polsku",\n      "quantity": liczba,\n      "unit": "g/ml/piece/cup/tbsp",\n      "portionSize": "small/medium/large"\n    }\n  ],\n  "confidence": 0-100\n}\n\nJeśli brak jedzenia → { "foodItems": [], "confidence": 0 }`,
        }],
      }],
      generationConfig: {
        temperature: 0,
        maxOutputTokens: 500,
        responseMimeType: 'application/json',
      },
    };

    try {
      const response = await fetch(`${this.apiUrl}?key=${this.apiKey}`, {
        method: 'POST',
        signal: controller.signal,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });

      if (!response.ok) {
        throw new ExternalAPIError(`Gemini API błąd: ${response.status} ${response.statusText}`);
      }

      const data: GeminiResponse = await response.json();
      const text = data.candidates?.[0]?.content?.parts?.[0]?.text ?? '';

      let parsed: { foodItems: VoiceMealResult['foodItems']; confidence: number };
      try {
        parsed = JSON.parse(text);
      } catch {
        throw new ValidationError('Nie udało się sparsować odpowiedzi Gemini.');
      }

      return {
        foodItems: parsed.foodItems ?? [],
        rawText: parsedSpeech.rawText,
        confidence: parsed.confidence ?? 0,
      };
    } catch (err) {
      if (err instanceof ExternalAPIError || err instanceof ValidationError) throw err;
      throw new ExternalAPIError('Przekroczono limit czasu lub błąd połączenia z Gemini.');
    } finally {
      clearTimeout(timeoutId);
    }
  }

  async logToDatabase(
    result: VoiceMealResult,
    userId: string,
    mealTime: string,
    mealDate: string,
    nutritionData: Array<{
      name: string;
      proteinG: number;
      carbsG: number;
      fatG: number;
      calories: number;
    }>,
  ): Promise<LoggedMealFromVoice> {
    const totalProtein = nutritionData.reduce((s, n) => s + n.proteinG, 0);
    const totalCarbs = nutritionData.reduce((s, n) => s + n.carbsG, 0);
    const totalFat = nutritionData.reduce((s, n) => s + n.fatG, 0);
    const totalCalories = nutritionData.reduce((s, n) => s + n.calories, 0);
    const foodName = result.foodItems.map((f) => f.name).join(' + ');

    const supabase = getSupabaseAdmin();
    const { error } = await supabase.from('meals').insert({
      user_id: userId,
      meal_date: mealDate,
      meal_time: mealTime,
      food_name: foodName,
      protein_g: Math.round(totalProtein * 10) / 10,
      carbs_g: Math.round(totalCarbs * 10) / 10,
      fat_g: Math.round(totalFat * 10) / 10,
      calories: Math.round(totalCalories),
      source: 'manual',
      log_source: 'voice',
      raw_voice_text: result.rawText,
    });

    if (error) throw new ExternalAPIError(`Błąd zapisu do bazy: ${error.message}`);

    return {
      userId,
      mealDate,
      mealTime: mealTime as LoggedMealFromVoice['mealTime'],
      foodName,
      proteinG: Math.round(totalProtein * 10) / 10,
      carbsG: Math.round(totalCarbs * 10) / 10,
      fatG: Math.round(totalFat * 10) / 10,
      calories: Math.round(totalCalories),
      source: 'voice',
      rawVoiceText: result.rawText,
    };
  }
}
