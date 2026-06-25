// Mapa warunków zdrowotnych → prompty dla Gemini
export const CONDITION_PROMPTS: Record<string, string> = {
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
