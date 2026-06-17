import { Recipe } from './RecipeRepository.ts';
import { UserProfile } from '../calculate-daily-macros/ProfileRepository.ts';

export class GeminiPersonalizer {
  static async rankRecipes(recipes: any[], profile: UserProfile): Promise<Array<{id: string, reason: string}>> {
    if (!recipes) return [];
    console.log('GeminiPersonalizer.rankRecipes called, recipes count:', recipes.length);
    const geminiKey = Deno.env.get('GEMINI_API_KEY') ?? '';
    console.log('GEMINI_API_KEY present:', !!geminiKey);
    if (!geminiKey) {
      console.log('GeminiPersonalizer fallback — returning original order');
      return recipes.map(r => ({ id: r.id, reason: '' }));
    }

    const recipesArray = recipes.map(r => ({
      id: r.id,
      title: r.title,
      ingredients: r.ingredients.map((i: any) => i.name).join(', '),
      macros: `Białko: ${r.proteinG}g, Węglowodany: ${r.carbsG}g, Tłuszcz: ${r.fatG}g`,
      dietTags: r.dietTags?.join(', ') || ''
    }));

    const systemPrompt = "Jesteś asystentem dietetycznym. Masz listę przepisów i profil użytkownika. Zwróć TYLKO JSON array obiektów {id, reason} posortowany od najbardziej do najmniej rekomendowanego. Filtruj przepisy sprzeczne z alergiami i dietary_preferences. Uwzględnij cel użytkownika (goal_type), makra docelowe i warunki zdrowotne.";
    
    const userPrompt = `Profil: cel=${profile.goalType}, białko=${profile.dailyProteinTarget}g, węglowodany=${profile.dailyCarbsTarget}g, tłuszcz=${profile.dailyFatTarget}g, alergie=${profile.allergies.join(',')}, preferencje=${profile.dietaryPreferences.join(',')}, choroby=${profile.healthConditions.join(',')}\n\nPrzepisy do oceny: ${JSON.stringify(recipesArray)}\n\nOdpowiedz TYLKO tablicą JSON [{id: "uuid", reason: "krótki powód po polsku"}]. Bez markdown, bez tekstu poza JSON.`;

    const requestBody = {
      contents: [{
        role: "user",
        parts: [{ text: userPrompt }]
      }],
      systemInstruction: {
        role: "user",
        parts: [{ text: systemPrompt }]
      },
      generationConfig: {
        response_mime_type: "application/json",
      }
    };

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 12000);

      const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiKey}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(requestBody),
        signal: controller.signal
      });
      clearTimeout(timeoutId);

      if (!response.ok) {
        console.error("Gemini API error", await response.text());
        console.log('GeminiPersonalizer fallback — returning original order');
        return recipes.map(r => ({ id: r.id, reason: '' }));
      }

      const data = await response.json();
      const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
      
      if (!text) {
        console.log('GeminiPersonalizer fallback — returning original order');
        return recipes.map(r => ({ id: r.id, reason: '' }));
      }

      let parsed;
      try {
        parsed = JSON.parse(text);
      } catch (e) {
        console.log('GeminiPersonalizer fallback — returning original order');
        return recipes.map(r => ({ id: r.id, reason: '' }));
      }

      if (Array.isArray(parsed) && parsed.every(item => item.id && typeof item.reason === 'string')) {
        console.log('GeminiPersonalizer success — ranked:', parsed.length);
        return parsed as Array<{id: string, reason: string}>;
      }

      console.log('GeminiPersonalizer fallback — returning original order');
      return recipes.map(r => ({ id: r.id, reason: '' }));
    } catch (e) {
      console.error("Gemini request failed", e);
      console.log('GeminiPersonalizer fallback — returning original order');
      return recipes.map(r => ({ id: r.id, reason: '' }));
    }
  }
}
