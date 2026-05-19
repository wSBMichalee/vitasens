export interface ParsedSpeech {
  rawText: string;
  cleanedText: string;
  language: 'pl' | 'en';
  confidence: number;
}

const PL_FILLERS = /\b(eee+|yyy+|no|właśnie|czyli)\b/gi;
const EN_FILLERS = /\b(um+|uh+|like|you know)\b/gi;

const PL_NUMBERS: Record<string, number> = {
  jeden: 1, jedna: 1, jedno: 1,
  dwa: 2, dwie: 2, dwoje: 2,
  trzy: 3, cztery: 4, pięć: 5, sześć: 6,
  siedem: 7, osiem: 8, dziewięć: 9, dziesięć: 10,
  dwadzieścia: 20, trzydzieści: 30, czterdzieści: 40,
  pięćdziesiąt: 50, sto: 100, dwieście: 200, trzysta: 300,
  pół: 0.5, połowa: 0.5,
};

const UNIT_NORMALIZATIONS: Array<[RegExp, string]> = [
  [/\b(gramów|gramy|gram)\b/gi, 'g'],
  [/\b(kilogramów|kilogramy|kilogram|kilo)\b/gi, 'kg'],
  [/\b(mililitrów|mililitry|mililitr|ml)\b/gi, 'ml'],
  [/\b(litrów|litry|litr)\b/gi, 'l'],
  [/\b(szklanek|szklanki|szklanka)\b/gi, 'cup'],
  [/\b(łyżek|łyżki|łyżka)\b/gi, 'tbsp'],
  [/\b(łyżeczek|łyżeczki|łyżeczka)\b/gi, 'tsp'],
  [/\b(kawałków|kawałki|kawałek|sztuk|sztuki|sztuka)\b/gi, 'piece'],
];

export class SpeechParser {
  parse(rawText: string): ParsedSpeech {
    const language = this.detectLanguage(rawText);
    let cleaned = rawText.trim();

    cleaned = cleaned.replace(language === 'pl' ? PL_FILLERS : EN_FILLERS, ' ');
    cleaned = this.normalizeNumbers(cleaned);
    cleaned = this.normalizeUnits(cleaned);
    cleaned = cleaned.replace(/\s{2,}/g, ' ').trim();

    const confidence = this.estimateConfidence(cleaned);

    return { rawText, cleanedText: cleaned, language, confidence };
  }

  extractPortionHint(text: string): 'small' | 'medium' | 'large' {
    const lower = text.toLowerCase();
    if (/mały|małe|trochę|small|little/.test(lower)) return 'small';
    if (/duży|duże|dużo|large|big|extra/.test(lower)) return 'large';
    return 'medium';
  }

  private detectLanguage(text: string): 'pl' | 'en' {
    return /[ąćęłńóśźżĄĆĘŁŃÓŚŹŻ]/.test(text) ? 'pl' : 'en';
  }

  private normalizeNumbers(text: string): string {
    let result = text;
    for (const [word, value] of Object.entries(PL_NUMBERS)) {
      result = result.replace(new RegExp(`\\b${word}\\b`, 'gi'), String(value));
    }
    return result;
  }

  private normalizeUnits(text: string): string {
    let result = text;
    for (const [pattern, replacement] of UNIT_NORMALIZATIONS) {
      result = result.replace(pattern, replacement);
    }
    return result;
  }

  private estimateConfidence(text: string): number {
    if (text.length < 3) return 0;
    const wordCount = text.split(/\s+/).length;
    if (wordCount < 2) return 40;
    const hasNumber = /\d+(\.\d+)?/.test(text);
    const hasUnit = /\b(g|kg|ml|l|cup|tbsp|tsp|piece)\b/.test(text);
    let score = 60;
    if (hasNumber) score += 20;
    if (hasUnit) score += 20;
    return Math.min(score, 100);
  }
}
