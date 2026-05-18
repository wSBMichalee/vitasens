import { ExternalAPIError, ValidationError } from '../_shared/errorHandler.ts';
import { HealthPromptBuilder, HealthProfile } from '../_shared/HealthPromptBuilder.ts';

export interface ExtractedRecipeResult {
  recipe: ExtractedRecipe;
  warnings: string[];
}

export interface ExtractedRecipe {
  title: string;
  description: string;
  servings: number;
  cookTimeMinutes: number;
  ingredients: Array<{
    name: string;
    amount: number;
    unit: string;
  }>;
  steps: Array<{
    number: number;
    instruction: string;
  }>;
  estimatedMacros: {
    proteinG: number;
    carbsG: number;
    fatG: number;
    calories: number;
  };
  sourceUrl: string;
  sourcePlatform: string;
}

interface ClaudeMessage {
  role: 'user' | 'assistant';
  content: string;
}

interface ClaudeResponse {
  content: Array<{
    type: string;
    text: string;
  }>;
}

export class RecipeExtractor {
  private readonly apiKey: string;
  private readonly apiUrl: string;
  private readonly model: string;

  constructor() {
    const key = Deno.env.get('GEMINI_API_KEY');
    if (!key) {
      throw new ExternalAPIError('Brak klucza Anthropic API.');
    }
    this.apiKey = key;
    this.apiUrl = 'https://api.anthropic.com/v1/messages';
    this.model = 'claude-sonnet-4-20250514';
  }

  async extract(
    transcript: string,
    sourceUrl: string,
    sourcePlatform: string,
    healthProfile?: HealthProfile,
  ): Promise<ExtractedRecipeResult> {
    try {
      console.log('Extracting recipe from transcript, length:', transcript.length);

      const { raw, warnings } = await this.callClaude(transcript, healthProfile);
      const partial = this.parseResponse(raw);

      const recipe: ExtractedRecipe = {
        title: partial.title ?? '',
        description: partial.description ?? '',
        servings: partial.servings ?? 1,
        cookTimeMinutes: partial.cookTimeMinutes ?? 30,
        ingredients: partial.ingredients ?? [],
        steps: partial.steps ?? [],
        estimatedMacros: partial.estimatedMacros ?? {
          proteinG: 0,
          carbsG: 0,
          fatG: 0,
          calories: 0,
        },
        sourceUrl,
        sourcePlatform,
      };

      return { recipe, warnings };
    } catch (err) {
      if (err instanceof ExternalAPIError || err instanceof ValidationError) throw err;
      throw new ExternalAPIError('Błąd podczas ekstrakcji przepisu przez AI.');
    }
  }

  private async callClaude(
    transcript: string,
    healthProfile?: HealthProfile,
  ): Promise<{ raw: string; warnings: string[] }> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 30_000);

    const messages: ClaudeMessage[] = [
      { role: 'user', content: this.buildPrompt(transcript) },
    ];

    let systemPrompt = `Jesteś ekspertem od przepisów kulinarnych.
Przeanalizuj tekst i wyciągnij przepis kulinarny.
Odpowiedz TYLKO w formacie JSON bez markdown, bez backticks, bez dodatkowego tekstu.
Jeśli nie ma przepisu w tekście zwróć:
{"error": "Brak przepisu w podanym materiale"}`;

    let warnings: string[] = [];

    if (healthProfile) {
      const builder = new HealthPromptBuilder();
      const builtPrompt = builder.build(healthProfile);
      systemPrompt = builtPrompt.systemPrompt +
        '\n\nDodatkowo: odpowiedz TYLKO w formacie JSON bez markdown, bez backticks, bez dodatkowego tekstu. ' +
        'Jeśli nie ma przepisu w tekście zwróć: {"error": "Brak przepisu w podanym materiale"}';
      warnings = builtPrompt.warnings;
    }

    try {
      const response = await fetch(this.apiUrl, {
        method: 'POST',
        signal: controller.signal,
        headers: {
          'x-api-key': this.apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          model: this.model,
          max_tokens: 2000,
          system: systemPrompt,
          messages,
        }),
      });

      if (!response.ok) {
        throw new ExternalAPIError(
          `Claude API zwróciło błąd: ${response.status} ${response.statusText}`,
        );
      }

      const data: ClaudeResponse = await response.json();
      return { raw: data.content[0]?.text ?? '', warnings };
    } catch (err) {
      if (err instanceof ExternalAPIError) throw err;
      throw new ExternalAPIError('Przekroczono limit czasu lub błąd połączenia z Claude API.');
    } finally {
      clearTimeout(timeoutId);
    }
  }

  private buildPrompt(transcript: string): string {
    const truncated = transcript.slice(0, 3000);

    return `Wyciągnij przepis z tego tekstu i odpowiedz JSON:

TEKST: ${truncated}

FORMAT JSON:
{
  "title": "nazwa przepisu",
  "description": "krótki opis",
  "servings": liczba_porcji,
  "cookTimeMinutes": czas_w_minutach,
  "ingredients": [
    {"name": "składnik", "amount": ilość, "unit": "jednostka"}
  ],
  "steps": [
    {"number": 1, "instruction": "krok"}
  ],
  "estimatedMacros": {
    "proteinG": białko,
    "carbsG": węglowodany,
    "fatG": tłuszcze,
    "calories": kalorie
  }
}`;
  }

  private parseResponse(text: string): Partial<ExtractedRecipe> {
    try {
      const cleaned = text
        .replace(/^```(?:json)?\s*/i, '')
        .replace(/\s*```$/i, '')
        .trim();

      const parsed: Record<string, unknown> = JSON.parse(cleaned);

      if (typeof parsed['error'] === 'string') {
        throw new ValidationError(parsed['error']);
      }

      if (!parsed['title'] || typeof parsed['title'] !== 'string' || !parsed['title'].trim()) {
        throw new ValidationError('AI nie znalazł przepisu.');
      }

      return parsed as Partial<ExtractedRecipe>;
    } catch (err) {
      if (err instanceof ValidationError) throw err;
      throw new ValidationError('Nie udało się sparsować odpowiedzi AI jako JSON.');
    }
  }
}
