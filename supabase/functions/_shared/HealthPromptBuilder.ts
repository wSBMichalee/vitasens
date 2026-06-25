import { CONDITION_PROMPTS } from './ConditionPrompts.ts';

export type HealthCondition =
  | 'diabetes_type_1'
  | 'diabetes_type_2'
  | 'thyroid_hypothyroid'
  | 'thyroid_hyperthyroid'
  | 'post_surgery_bariatric'
  | 'post_surgery_general'
  | 'celiac_disease'
  | 'kidney_disease'
  | 'heart_disease'
  | 'hypertension'
  | 'pregnancy'
  | 'lactating'
  | 'ibs'
  | 'crohns'
  | 'gout'
  | 'osteoporosis';

export interface HealthProfile {
  conditions: HealthCondition[];
  goalType: string;
  dailyProteinTarget: number;
  dailyCarbsTarget: number;
  dailyFatTarget: number;
  allergies?: string[];
  medications?: string[];
}

export interface BuiltPrompt {
  systemPrompt: string;
  warnings: string[];
  restrictions: string[];
  recommendations: string[];
}

export class HealthPromptBuilder {
  build(profile: HealthProfile): BuiltPrompt {
    const parts: string[] = [
      this.buildBasePrompt(),
      this.buildHealthConditionPrompts(profile.conditions),
      this.buildGoalPrompt(profile.goalType),
      this.buildMacroTargetsPrompt(profile),
    ];

    if (profile.allergies && profile.allergies.length > 0) {
      parts.push(`ALERGIE UŻYTKOWNIKA — BEZWZGLĘDNIE UNIKAJ: ${profile.allergies.join(', ')}.`);
    }

    if (profile.medications && profile.medications.length > 0) {
      parts.push(
        `LEKI UŻYTKOWNIKA: ${profile.medications.join(', ')}. ` +
          'Zwróć uwagę na potencjalne interakcje żywność–lek i ZAWSZE zalecaj konsultację z farmaceutą lub lekarzem.',
      );
    }

    parts.push(this.buildSafetyDisclaimer());

    const systemPrompt = parts.filter(Boolean).join('\n\n');

    const warnings = profile.conditions.flatMap((c) => this.getWarningsForCondition(c));
    const restrictions = this.getForbiddenIngredients(profile.conditions);
    const recommendations = this.getRecommendationsForConditions(profile.conditions);

    return { systemPrompt, warnings, restrictions, recommendations };
  }

  private buildBasePrompt(): string {
    return `Jesteś asystentem żywieniowym w aplikacji VitaSense.
Pomagasz użytkownikom planować posiłki i śledzić makroskładniki.

WAŻNE ZASADY KTÓRYCH MUSISZ PRZESTRZEGAĆ:
1. NIE jesteś lekarzem ani dietetykiem
2. NIE dawaj porad medycznych
3. ZAWSZE odsyłaj do specjalisty w sprawach zdrowotnych
4. INFORMUJ o potencjalnych ryzykach
5. Bazuj na ogólnie przyjętych wytycznych żywieniowych
6. Odpowiadaj w języku polskim
7. Bądź konkretny i praktyczny`;
  }

  private buildHealthConditionPrompts(conditions: HealthCondition[]): string {
    if (conditions.length === 0) return '';
    const prompts = conditions.map((c) => this.getConditionPrompt(c)).filter(Boolean);
    return prompts.join('\n\n');
  }

  private getConditionPrompt(condition: HealthCondition): string {
    return CONDITION_PROMPTS[condition] ?? `Consider general health guidelines for ${condition}.`;
  }

  private buildGoalPrompt(goalType: string): string {
    const map: Record<string, string> = {
      weight_loss:
        'Cel użytkownika: REDUKCJA WAGI\n' +
        'Preferuj: niskokaloryczne, wysokobiałkowe, wysokobłonnikowe przepisy.\n' +
        'Deficyt kaloryczny: max 500 kcal/dzień (nie sugeruj drastycznych diet < 1200 kcal).',

      muscle_gain:
        'Cel: BUDOWANIE MASY MIĘŚNIOWEJ\n' +
        'Preferuj: wysokobiałkowe przepisy (>30g białka), nadwyżka kaloryczna 200-400 kcal, węglowodany przed/po treningu.',

      general_health:
        'Cel: ZDROWE ODŻYWIANIE\n' +
        'Balansuj makroskładniki, różnorodność produktów, min 5 porcji warzyw/owoców dziennie.',

      keto:
        'Cel: DIETA KETOGENICZNA\n' +
        'Max węglowodany: 20-50g/dzień, tłuszcze: 70-80% kalorii, białko: 20-25% kalorii.\n' +
        'Ostrzeż: keto nie jest odpowiednia dla wszystkich.',

      diabetes_friendly:
        'Cel: DIETA PRZYJAZNA CUKRZYCY\n' +
        'Niski indeks glikemiczny, kontrola węglowodanów, regularność posiłków co 3-4h.',

      thyroid_friendly:
        'Cel: DIETA WSPIERAJĄCA TARCZYCĘ\n' + 'Dostosuj do typu (hipo/nadczynność).',

      post_surgery:
        'Cel: REKONWALESCENCJA PO OPERACJI\n' +
        'Wysokobiałkowe, łatwestrawne posiłki, bogate w wit. C i cynk.',
    };

    const prompt = map[goalType];
    return prompt ?? `Cel użytkownika: ${goalType}. Dobierz rekomendacje odpowiednio do celu.`;
  }

  private buildMacroTargetsPrompt(profile: HealthProfile): string {
    return (
      `CELE MAKROSKŁADNIKÓW UŻYTKOWNIKA:\n` +
      `- Białko: ${profile.dailyProteinTarget}g/dzień\n` +
      `- Węglowodany: ${profile.dailyCarbsTarget}g/dzień\n` +
      `- Tłuszcze: ${profile.dailyFatTarget}g/dzień\n` +
      `Dostosuj rekomendacje przepisów do tych wartości docelowych.`
    );
  }

  private buildSafetyDisclaimer(): string {
    return `BEZWZGLĘDNE ZASADY BEZPIECZEŃSTWA:

1. NIGDY nie zastępujesz lekarza, dietetyka ani innego specjalisty medycznego

2. Przy jakichkolwiek wątpliwościach ZAWSZE napisz: "Skonsultuj to z lekarzem lub dietetykiem klinicznym"

3. NIGDY nie sugeruj odstawienia lub zmiany leków

4. NIGDY nie dawaj konkretnych dawek suplementów bez zalecenia "skonsultuj z lekarzem"

5. Jeśli zapytanie dotyczy objawów chorobowych, ostrej fazy choroby lub kryzysu zdrowotnego → ZAWSZE odsyłaj do lekarza lub pogotowia

6. Informacje mają charakter OGÓLNOEDUKACYJNY i nie stanowią porady medycznej

7. Podawaj zawsze źródła (np. wytyczne PTD, ESC, WHO) jeśli to możliwe

8. Każdy człowiek jest inny — reakcje na dietę są indywidualne`;
  }

  getWarningsForCondition(condition: HealthCondition): string[] {
    const map: Record<HealthCondition, string[]> = {
      diabetes_type_1: [
        '⚠️ Monitoruj poziom cukru po nowych posiłkach',
        '⚠️ Zmiana diety może wpłynąć na dawki insuliny',
        '⚠️ Skonsultuj plan żywieniowy z diabetologiem',
      ],
      diabetes_type_2: [
        '⚠️ Monitoruj poziom cukru po nowych posiłkach',
        '⚠️ Zmiana diety może wpłynąć na dawki leków',
        '⚠️ Skonsultuj plan żywieniowy z diabetologiem',
      ],
      thyroid_hypothyroid: [
        '⚠️ Unikaj surowych warzyw kapustnych w nadmiarze',
        '⚠️ Leki na tarczycę przyjmuj 4h przed produktami z soją',
        '⚠️ Konsultuj dietę z endokrynologiem',
      ],
      thyroid_hyperthyroid: [
        '⚠️ Ogranicz produkty bogate w jod',
        '⚠️ Unikaj kofeiny — nasila objawy',
        '⚠️ Konsultuj dietę z endokrynologiem',
      ],
      post_surgery_bariatric: [
        '⚠️ Nie przekraczaj 150-200ml na posiłek',
        '⚠️ Nie pij płynów podczas jedzenia',
        '⚠️ Suplementacja obligatoryjna — nie przerywaj',
      ],
      post_surgery_general: [
        '⚠️ Zwiększ podaż białka dla gojenia ran',
        '⚠️ Unikaj alkoholu w trakcie rekonwalescencji',
        '⚠️ Ustal dietę z chirurgiem i dietetykiem',
      ],
      celiac_disease: [
        '⚠️ Nawet śladowe ilości glutenu szkodzą',
        '⚠️ Sprawdzaj etykiety wszystkich produktów',
        '⚠️ Uważaj na skażenie krzyżowe w kuchni',
      ],
      kidney_disease: [
        '⚠️ Ogranicz potas, fosfor i sód',
        '⚠️ Dieta nefrologiczna jest wysoce indywidualna',
        '⚠️ Wymagana konsultacja z nefrologiem',
      ],
      heart_disease: [
        '⚠️ Ogranicz tłuszcze nasycone i sód',
        '⚠️ Nie zmieniaj leków bez konsultacji kardiologa',
        '⚠️ Ustal dietę z kardiologiem',
      ],
      hypertension: [
        '⚠️ Ogranicz sól do max 2300mg sodu/dzień',
        '⚠️ Unikaj przetworzonej żywności',
        '⚠️ Dieta nie zastępuje leków na nadciśnienie',
      ],
      pregnancy: [
        '⚠️ Bezwzględny zakaz alkoholu i surowego mięsa/ryb',
        '⚠️ Każdy suplement konsultuj z lekarzem',
        '⚠️ Ogranicz kofeinę do max 200mg/dzień',
      ],
      lactating: [
        '⚠️ Zwiększ kaloryczność o ok. 500 kcal/dzień',
        '⚠️ Ogranicz alkohol i kofeinę',
        '⚠️ Konsultuj dietę z laktatorką i pediatrą',
      ],
      ibs: [
        '⚠️ Triggery pokarmowe są indywidualne — prowadź dziennik',
        '⚠️ Ogranicz produkty high-FODMAP',
        '⚠️ Wdrażaj low-FODMAP z dietetykiem',
      ],
      crohns: [
        '⚠️ W zaostrzeniu stosuj dietę łatwestrawną',
        '⚠️ Ryzyko niedoborów wit. B12, żelaza, wapnia',
        '⚠️ Dieta wymaga nadzoru gastroenterologa',
      ],
      gout: [
        '⚠️ Unikaj podrobów, sardynek, alkoholu',
        '⚠️ Pij min 2-3L wody dziennie',
        '⚠️ Nie odstawiaj leków na dnę bez konsultacji',
      ],
      osteoporosis: [
        '⚠️ Zapewnij 1200mg wapnia dziennie',
        '⚠️ Suplementację wit. D ustal z lekarzem',
        '⚠️ Ogranicz alkohol, kofeinę i sól',
      ],
    };

    return map[condition] ?? [];
  }

  getForbiddenIngredients(conditions: HealthCondition[]): string[] {
    const forbidden = new Set<string>();

    const map: Record<HealthCondition, string[]> = {
      celiac_disease: [
        'gluten', 'wheat', 'rye', 'barley', 'spelt', 'kamut',
        'pszenica', 'żyto', 'jęczmień', 'orkisz',
      ],
      pregnancy: [
        'raw_fish', 'alcohol', 'raw_meat', 'unpasteurized',
        'surowa ryba', 'alkohol', 'surowe mięso', 'tuna', 'swordfish',
        'tuńczyk', 'miecznik',
      ],
      kidney_disease: [
        'high_potassium', 'high_phosphorus',
        'banany', 'pomidory', 'pomarańcze', 'cola', 'orzechy',
      ],
      heart_disease: [
        'trans_fat', 'tłuszcze trans',
      ],
      diabetes_type_1: [
        'high_gi_sugar', 'słodzone napoje', 'cukier biały',
      ],
      diabetes_type_2: [
        'high_gi_sugar', 'słodzone napoje', 'cukier biały',
      ],
      gout: [
        'offal', 'podroby', 'sardines', 'sardynki', 'herring', 'śledź',
        'alcohol', 'alkohol', 'beer', 'piwo',
      ],
      post_surgery_bariatric: [
        'alcohol', 'alkohol', 'high_sugar', 'cukier biały', 'tłuste potrawy',
      ],
      thyroid_hypothyroid: [],
      thyroid_hyperthyroid: [
        'seaweed', 'algi', 'kelp',
      ],
      post_surgery_general: [
        'alcohol', 'alkohol',
      ],
      hypertension: [],
      lactating: [
        'alcohol', 'alkohol',
      ],
      ibs: [],
      crohns: [
        'alcohol', 'alkohol',
      ],
      osteoporosis: [
        'alcohol', 'alkohol',
      ],
    };

    for (const condition of conditions) {
      for (const ingredient of (map[condition] ?? [])) {
        forbidden.add(ingredient);
      }
    }

    return Array.from(forbidden);
  }

  private getRecommendationsForConditions(conditions: HealthCondition[]): string[] {
    const recs = new Set<string>();

    const map: Record<HealthCondition, string[]> = {
      diabetes_type_1: ['Preferuj produkty o niskim IG', 'Regularność posiłków co 3-4h'],
      diabetes_type_2: ['Preferuj produkty o niskim IG', 'Regularność posiłków co 3-4h'],
      thyroid_hypothyroid: ['Orzechy brazylijskie (selen)', 'Ryby morskie (jod)', 'Pestki dyni (cynk)'],
      thyroid_hyperthyroid: ['Produkty bogate w wapń', 'Witamina D'],
      post_surgery_bariatric: ['Min 60-80g białka dziennie', 'Małe, częste posiłki'],
      post_surgery_general: ['Wysokobiałkowe posiłki', 'Witamina C i cynk (gojenie)'],
      celiac_disease: ['Ryż, kasza gryczana, quinoa', 'Produkty z certyfikatem GF'],
      kidney_disease: ['Ogranicz potas i fosfor', 'Konsultuj podaż białka z nefrologiem'],
      heart_disease: ['Ryby bogate w omega-3', 'Oliwa z oliwek', 'Warzywa i pełne ziarna'],
      hypertension: ['Dieta DASH', 'Produkty bogate w potas i magnez'],
      pregnancy: ['Kwas foliowy 400-800mcg', 'Żelazo i wapń', 'Ryby niskortęciowe'],
      lactating: ['Zwiększ kaloryczność o 500 kcal', 'Wapń i witamina D'],
      ibs: ['Dieta low-FODMAP', 'Dziennik żywieniowy'],
      crohns: ['Posiłki łatwestrawne', 'Suplementacja B12 i żelaza'],
      gout: ['2-3L wody dziennie', 'Nabiał niskotłuszczowy', 'Warzywa i pełne ziarna'],
      osteoporosis: ['1200mg wapnia dziennie', 'Witamina D', 'Sardynki z ośćmi, tofu'],
    };

    for (const condition of conditions) {
      for (const rec of (map[condition] ?? [])) {
        recs.add(rec);
      }
    }

    return Array.from(recs);
  }
}
