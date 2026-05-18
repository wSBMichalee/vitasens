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
    const map: Record<HealthCondition, string> = {
      diabetes_type_1: `CUKRZYCA TYPU 1 — ZASADY BEZPIECZEŃSTWA:
- Priorytet: kontrola glikemii przez indeks glikemiczny
- UNIKAJ: produktów o wysokim IG (>70): biały chleb, słodycze, słodzone napoje, biały ryż
- PREFERUJ: produkty o niskim IG (<55): warzywa, pełne ziarna, rośliny strączkowe
- Węglowodany max: 45-60g na posiłek (ogólna wytyczna)
- OSTRZEŻ: każda zmiana diety przy cukrzycy wymaga konsultacji z diabetologiem i może wpłynąć na dawkowanie insuliny
- NIGDY nie sugeruj zmiany leków`,

      diabetes_type_2: `CUKRZYCA TYPU 2 — ZASADY BEZPIECZEŃSTWA:
- Priorytet: kontrola glikemii przez indeks glikemiczny
- UNIKAJ: produktów o wysokim IG (>70): biały chleb, słodycze, słodzone napoje, biały ryż
- PREFERUJ: produkty o niskim IG (<55): warzywa, pełne ziarna, rośliny strączkowe
- Węglowodany max: 45-60g na posiłek (ogólna wytyczna)
- OSTRZEŻ: każda zmiana diety przy cukrzycy wymaga konsultacji z diabetologiem i może wpłynąć na dawkowanie insuliny
- NIGDY nie sugeruj zmiany leków`,

      thyroid_hypothyroid: `NIEDOCZYNNOŚĆ TARCZYCY — ZASADY:
- UNIKAJ goitrogenów w nadmiarze (surowych): kapusta, brokuły, kalafior, soja, brukselka (gotowane są bezpieczne)
- WSPIERAJ: produkty bogate w selen (orzechy brazylijskie, ryby), jod (ryby morskie, algi — z umiarem), cynk (pestki dyni, mięso)
- UNIKAJ: nadmiaru soi, prosa
- OSTRZEŻ: dieta nie zastępuje leczenia hormonalnego. Konsultuj zmiany diety z endokrynologiem
- Leki na tarczycę przyjmuj na czczo, czekaj 4h przed produktami z soją/wapniem`,

      thyroid_hyperthyroid: `NADCZYNNOŚĆ TARCZYCY — ZASADY:
- OGRANICZ: jod (ryby morskie, algi, sól jodowana)
- UNIKAJ: kofeiny (nasila objawy)
- WSPIERAJ: produkty bogate w wapń i wit. D (ryzyko osteoporozy)
- OSTRZEŻ: dieta nie zastępuje leczenia. Konsultuj z endokrynologiem`,

      post_surgery_bariatric: `PO OPERACJI BARIATRYCZNEJ — ZASADY:
- PRIORYTET: białko minimum 60-80g dziennie
- MAŁE PORCJE: max 150-200ml na posiłek
- NIE PIJ podczas jedzenia (30 min przed/po)
- UNIKAJ: cukru prostego (ryzyko dumping syndrome), alkoholu, tłustych potraw
- SUPLEMENTY: obligatoryjne (wit. B12, żelazo, wapń, wit. D) — nie sugeruj ich odstawienia
- OSTRZEŻ: dieta bariatryczna wymaga ścisłej kontroli bariatry i dietetyka`,

      post_surgery_general: `PO OPERACJI — ZASADY OGÓLNE:
- PRIORYTET: białko (gojenie ran) min 1.2-1.5g/kg
- WSPIERAJ: wit. C (gojenie), cynk, żelazo
- UNIKAJ: alkoholu, potencjalnie drażniących pokarmów
- OSTRZEŻ: plan żywienia po operacji ustal z chirurgiem i dietetykiem klinicznym`,

      celiac_disease: `CELIAKIA — ZASADY BEZPIECZEŃSTWA:
- BEZWZGLĘDNY zakaz: gluten (pszenica, żyto, jęczmień, orkisz, kamut)
- RYZYKO SKAŻENIA: owies (chyba że certyfikowany GF), produkty z linii produkcyjnych z glutenem
- BEZPIECZNE: ryż, kukurydza, ziemniaki, quinoa, kasza gryczana, amarantus
- OSTRZEŻ: nawet śladowe ilości glutenu szkodzą. Sprawdzaj etykiety wszystkich produktów
- SUPLEMENTUJ: żelazo, wit. B12, kwas foliowy, wapń (jeśli zalecił lekarz)`,

      kidney_disease: `CHOROBA NEREK — ZASADY BEZPIECZEŃSTWA:
- OGRANICZ: potas (banany, pomidory, ziemniaki, pomarańcze), fosfor (nabiał, orzechy, cola), sód (sól, przetworzone produkty)
- BIAŁKO: ogranicz do zaleceń nefrologa (zazwyczaj 0.6-0.8g/kg przy CKD)
- PŁYNY: ogranicz jeśli zalecił nefrolog
- OSTRZEŻ: dieta nefrologiczna jest WYSOCE indywidualna. Wymagana konsultacja z nefrologiem i dietetykiem nerkowym. Podane wartości są OGÓLNE`,

      heart_disease: `CHOROBY SERCA — ZASADY:
- OGRANICZ: tłuszcze nasycone (<7% kalorii), tłuszcze trans (0), sód (<2300mg/dzień), cholesterol (<200mg/dzień)
- UNIKAJ: tłustych mięs, pełnotłustego nabiału, fast food, słonych przekąsek
- PREFERUJ: ryby (omega-3), oliwa z oliwek, orzechy, warzywa, pełne ziarna
- OSTRZEŻ: dieta kardiologiczna wymaga ustalenia z kardiologiem. Nie zmieniaj leków bez konsultacji`,

      hypertension: `NADCIŚNIENIE — ZASADY (dieta DASH):
- OGRANICZ: sód < 1500-2300mg/dzień (unikaj soli, przetworzonej żywności)
- PREFERUJ: potas (banany, ziemniaki, warzywa), magnez (orzechy, nasiona), wapń (nabiał)
- UNIKAJ: alkoholu, kofeiny w nadmiarze, przetworzonego mięsa (wysokosodowe)
- OSTRZEŻ: dieta wspomaga leczenie ale nie zastępuje leków. Konsultuj z lekarzem`,

      pregnancy: `CIĄŻA — ZASADY BEZPIECZEŃSTWA:
- BEZWZGLĘDNY zakaz: surowe mięso/ryby/jajka, niepasteryzowane produkty, alkohol, surowe kiełki, duże ryby (tuńczyk, miecznik — rtęć)
- PRIORYTET: kwas foliowy (400-800mcg), żelazo, wapń, wit. D, jod
- OGRANICZ: kofeinę < 200mg/dzień
- OSTRZEŻ: dieta w ciąży wymaga nadzoru ginekologa i położnej. Każdy suplement skonsultuj z lekarzem`,

      lactating: `KARMIENIE PIERSIĄ — ZASADY:
- ZWIĘKSZ kaloryczność o ~500 kcal/dzień
- PRIORYTET: wapń, wit. D, jod, kwasy omega-3
- OGRANICZ: alkohol, kofeinę
- UNIKAJ: dużych ryb (rtęć)
- OSTRZEŻ: karmienie piersią wymaga konsultacji z laktatorką i pediatrą`,

      ibs: `ZESPÓŁ JELITA DRAŻLIWEGO — ZASADY (low FODMAP):
- OGRANICZ high-FODMAP: czosnek, cebula, pszenica, rośliny strączkowe, jabłka, gruszki, mleko
- PREFERUJ low-FODMAP: ryż, ziemniaki, marchew, ogórek, truskawki, mleko bez laktozy
- PROWADŹ dziennik żywieniowy (triggery są indywidualne)
- OSTRZEŻ: dieta low-FODMAP jest kompleksowa. Wdrażaj z dietetykiem specjalizującym się w IBS`,

      crohns: `CHOROBA CROHNA — ZASADY:
- W ZAOSTRZENIU: dieta łatwestrawna, płynna lub półpłynna, unikaj błonnika nierozpuszczalnego
- UNIKAJ: surowych warzyw, orzechów, nasion, alkoholu, tłustych potraw, ostrych przypraw
- PREFERUJ: gotowane warzywa, ryż, ziemniaki, chude mięso, ryby
- SUPLEMENTUJ: wit. B12, żelazo, wapń, wit. D, cynk (niedobory częste)
- OSTRZEŻ: dieta w chorobie Crohna wymaga ścisłego nadzoru gastroenterologa i dietetyka klinicznego`,

      gout: `DNAМOCZANOWA — ZASADY:
- UNIKAJ wysokopurynowych: podroby, sardynki, śledzie, małże, alkohol (szczególnie piwo)
- OGRANICZ: czerwone mięso, owoce morza
- PREFERUJ: warzywa, pełne ziarna, nabiał niskotłuszczowy
- HYDRATACJA: 2-3L wody dziennie
- OSTRZEŻ: dieta wspomaga leczenie. Nie odstawiaj leków na dnę bez konsultacji z reumatologiem`,

      osteoporosis: `OSTEOPOROZA — ZASADY:
- PRIORYTET: wapń (1200mg/dzień): nabiał, sardynki z ośćmi, tofu, zielone warzywa
- PRIORYTET: wit. D (słońce + suplementacja jeśli zalecił lekarz)
- UNIKAJ: nadmiaru alkoholu, kofeiny, soli (wypłukują wapń), palenia
- OSTRZEŻ: suplementację wapnia i wit. D ustal z lekarzem. Nie przekraczaj zalecanych dawek`,
    };

    return map[condition] ?? '';
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
