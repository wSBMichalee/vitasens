// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'VitaSense';

  @override
  String get getStarted => 'Rozpocznij';

  @override
  String get alreadyHaveAccount => 'Masz już konto?';

  @override
  String get signIn => 'Zaloguj się';

  @override
  String get signUp => 'Zarejestruj się';

  @override
  String get welcomeBack => 'Witaj z powrotem';

  @override
  String get signInToContinue => 'Zaloguj się, by kontynuować';

  @override
  String get emailAddress => 'Adres email';

  @override
  String get password => 'Hasło';

  @override
  String get forgotPassword => 'Zapomniałeś hasła?';

  @override
  String get signInButton => 'Zaloguj się';

  @override
  String get orContinueWith => 'lub kontynuuj przez';

  @override
  String get continueWithApple => 'Kontynuuj przez Apple';

  @override
  String get continueWithGoogle => 'Kontynuuj przez Google';

  @override
  String get dontHaveAccount => 'Nie masz konta?';

  @override
  String get home => 'Główna';

  @override
  String get pantry => 'Spiżarnia';

  @override
  String get aiMeals => 'Posiłki AI';

  @override
  String get shop => 'Sklep';

  @override
  String get profile => 'Profil';

  @override
  String get todaysProgress => 'Dzisiejszy postęp';

  @override
  String get hello => 'Cześć';

  @override
  String get todaysMeals => 'Dzisiejsze posiłki';

  @override
  String get noMealsAdded => 'Brak dodanych posiłków';

  @override
  String get breakfast => 'Śniadanie';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Kolacja';

  @override
  String get snack => 'Przekąska';

  @override
  String get fridge => 'Lodówka';

  @override
  String get freezer => 'Zamrażarka';

  @override
  String get pantryStorage => 'Spiżarnia';

  @override
  String get addIngredient => 'Dodaj składnik';

  @override
  String get searchIngredients => 'Szukaj składników...';

  @override
  String get scanFridge => 'Skanuj lodówkę';

  @override
  String get scanReceipt => 'Skanuj paragon';

  @override
  String get generateMeals => 'Generuj posiłki';

  @override
  String get cookFromIngredients => 'Gotuj z tego, co masz';

  @override
  String get noIngredients => 'Brak składników';

  @override
  String get addIngredientsToPantry =>
      'Dodaj składniki do spiżarni, by zobaczyć przepisy';

  @override
  String get noResults => 'Brak wyników';

  @override
  String get clearFilters => 'Wyczyść filtry';

  @override
  String get filters => 'Filtry';

  @override
  String get mealType => 'Typ posiłku';

  @override
  String get cookTime => 'Czas gotowania';

  @override
  String get calories => 'Kalorie';

  @override
  String get cuisine => 'Kuchnia';

  @override
  String get startCooking => 'Zacznij gotować';

  @override
  String ingredientsInPantry(int count, int missing) {
    return '$count w spiżarni · $missing brakuje';
  }

  @override
  String get shoppingList => 'Lista zakupów';

  @override
  String get history => 'Historia';

  @override
  String get today => 'Dzisiaj';

  @override
  String get yesterday => 'Wczoraj';

  @override
  String get noPurchaseHistory => 'Brak historii zakupów';

  @override
  String get quickAddItem => 'Szybko dodaj produkt...';

  @override
  String get addItem => 'Dodaj produkt';

  @override
  String get itemName => 'Nazwa produktu';

  @override
  String get quantity => 'Ilość';

  @override
  String get addToList => 'Dodaj do listy';

  @override
  String get myGoals => 'Moje cele';

  @override
  String get goal => 'Cel';

  @override
  String get pace => 'Tempo';

  @override
  String get activity => 'Aktywność';

  @override
  String get weight => 'Waga';

  @override
  String get notSet => 'Nie ustawiono';

  @override
  String get personalInfo => 'Dane osobowe';

  @override
  String get allergies => 'Alergie';

  @override
  String get healthConditions => 'Stan zdrowia';

  @override
  String get dietaryPreferences => 'Preferencje dietetyczne';

  @override
  String get notifications => 'Powiadomienia';

  @override
  String get helpSupport => 'Pomoc i wsparcie';

  @override
  String get privacyPolicy => 'Polityka prywatności';

  @override
  String get termsOfService => 'Regulamin';

  @override
  String get signOut => 'Wyloguj się';

  @override
  String get deleteAccount => 'Usuń konto';

  @override
  String get changePassword => 'Zmień hasło';

  @override
  String get save => 'Zapisz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get delete => 'Usuń';

  @override
  String get confirm => 'Potwierdź';

  @override
  String get edit => 'EDYTUJ';

  @override
  String get done => 'Gotowe';

  @override
  String get tryAgain => 'Spróbuj ponownie';

  @override
  String get noConnection => 'Brak połączenia';

  @override
  String get checkConnection =>
      'Sprawdź połączenie z internetem.\nApka odświeży się automatycznie.';

  @override
  String get refresh => 'Odśwież';

  @override
  String get connectionWillRestore => 'Połączenie wróci automatycznie';

  @override
  String get moveTo => 'Przenieś do:';

  @override
  String get removeItem => 'Usuń produkt';

  @override
  String get removeFromStorage => 'Usuń ze spiżarni';

  @override
  String get whereDoYouStore => 'GDZIE PRZECHOWUJESZ?';

  @override
  String get cantFindIt => 'Nie znalazłeś? Dodaj ręcznie';

  @override
  String get addToMeal => 'Dodaj do posiłku';

  @override
  String get addToPantry => 'Dodaj do spiżarni';

  @override
  String get servingG => 'Porcja (g)';

  @override
  String get addedToDiary => 'Dodano do dziennika';

  @override
  String get enjoyMeal => 'Smacznego! 🍽️ Spiżarnia zaktualizowana.';

  @override
  String get noMeals => 'Brak posiłków';

  @override
  String get savedRecipes => 'Zapisane przepisy';

  @override
  String get yourCollection => 'Twoja kolekcja';

  @override
  String get noSavedRecipes => 'Nie masz jeszcze zapisanych przepisów.';

  @override
  String get addFavoriteRecipes =>
      'Dodaj ulubione przepisy klikając ❤️ w Posiłkach AI.';

  @override
  String get browseAiMeals => 'Przeglądaj Posiłki AI';

  @override
  String get eaten => 'Zjedzone';

  @override
  String get change => 'Zmień';

  @override
  String get suggestion => 'SUGESTIA';

  @override
  String get myRecipes => 'Moje przepisy';

  @override
  String get createRecipe => 'Utwórz przepis';

  @override
  String get publish => 'Opublikuj';

  @override
  String get draft => 'SZKIC';

  @override
  String get public => 'PUBLICZNY';

  @override
  String get saveRecipe => 'Zapisz przepis';

  @override
  String get vitaSensePro => 'VitaSense Pro';

  @override
  String get upgradeToPro => 'Przejdź na Pro';

  @override
  String get upgrade => 'Ulepsz';

  @override
  String get monthlyTargets => 'CELE MIESIĘCZNE';

  @override
  String get yourNutritionThisMonth => 'Twoje odżywianie w tym miesiącu';

  @override
  String get protein => 'Białko';

  @override
  String get carbs => 'Węglowodany';

  @override
  String get fat => 'Tłuszcze';

  @override
  String get kcal => 'kcal';

  @override
  String get min => 'min';

  @override
  String get low => 'niskie';

  @override
  String get scanFood => 'Skanuj jedzenie';

  @override
  String get logMeal => 'Zaloguj posiłek';

  @override
  String get scanRecipeLabel => 'Skanuj przepis';

  @override
  String get permissionRequired => 'Wymagane uprawnienie';

  @override
  String get openSettings => 'Otwórz ustawienia';

  @override
  String get tryAgainButton => 'Spróbuj ponownie';

  @override
  String get processing => 'Przetwarzanie...';

  @override
  String get listening => 'Słucham...';

  @override
  String get speakNow => 'Mów teraz';

  @override
  String get tapToStart => 'Dotknij, by rozpocząć';

  @override
  String get detectedMeal => 'Wykryty posiłek';

  @override
  String get logThisMeal => 'Zaloguj ten posiłek';

  @override
  String get logAnother => 'Zaloguj kolejny';

  @override
  String get logged => 'Zapisano! 🎉';

  @override
  String get familyPlan => 'Plan rodzinny';

  @override
  String get sharedPantry => 'Wspólna spiżarnia';

  @override
  String get createFamilyGroup => 'Utwórz grupę rodzinną';

  @override
  String get joinFamilyGroup => 'Dołącz do grupy rodzinnej';

  @override
  String get leaveFamilyGroup => 'Opuścić grupę rodzinną?';

  @override
  String get deleteFamilyGroup => 'Usunąć grupę rodzinną?';

  @override
  String get leave => 'Opuść';

  @override
  String get join => 'Dołącz';

  @override
  String get open => 'Otwórz';

  @override
  String get keepPlan => 'Zachowaj plan';

  @override
  String get resetLinkSent => 'Link resetujący wysłany!';

  @override
  String get sendResetLink => 'Wyślij link resetujący';

  @override
  String get checkEmailForReset => 'Sprawdź email, by zresetować hasło.';

  @override
  String get editGoal => 'Edytuj cel';

  @override
  String get editPace => 'Edytuj tempo';

  @override
  String get editActivity => 'Edytuj aktywność';

  @override
  String get editWeight => 'Edytuj wagę';

  @override
  String get successStreak => 'Świetna konsekwencja w realizacji celu';

  @override
  String streakDays(int days) {
    return '$days dni z rzędu';
  }

  @override
  String get lowProteinToday => 'Mało białka dzisiaj';

  @override
  String get addHighProteinMeal =>
      'Dodaj posiłek bogaty w białko, by osiągnąć dzienny cel.';

  @override
  String get connectHealth => 'Połącz z Zdrowiem';

  @override
  String get tapToSyncSteps => 'Dotknij, by zsynchronizować kroki i kalorie';

  @override
  String get hydration => 'Nawodnienie';

  @override
  String get noRecipesYet => 'Brak przepisów';

  @override
  String get createFirstRecipe => 'Utwórz pierwszy przepis poniżej';

  @override
  String get ingredients => 'Składniki';

  @override
  String get steps => 'Kroki';

  @override
  String get instructions => 'Instrukcje';

  @override
  String get howToPrepare => 'Jak przygotować';

  @override
  String get difficulty => 'Trudność';

  @override
  String get nutritionPerServing => 'Wartości odżywcze na porcję';

  @override
  String get addedToShoppingList => 'Dodano do listy zakupów ✓';

  @override
  String addMissingIngredients(int count) {
    return 'Dodaj $count brakujących składników';
  }

  @override
  String get recipeNotFound => 'Przepis nie znaleziony — odśwież listę.';

  @override
  String get cannotCookRecipe =>
      'Nie można ugotować tego przepisu — spróbuj ponownie.';

  @override
  String get deleteRecipe => 'Usunąć przepis?';

  @override
  String get areYouSureDeleteRecipe =>
      'Czy na pewno chcesz usunąć ten przepis?';

  @override
  String get selectCuisine => 'Wybierz kuchnię';

  @override
  String get dietTags => 'TAGI DIETY';

  @override
  String get recipeBASICS => 'PODSTAWY PRZEPISU';

  @override
  String get addStep => 'Dodaj krok';

  @override
  String get stepByStepNotAvailable =>
      'Instrukcje krok po kroku niedostępne. Spróbuj ponownie po synchronizacji.';

  @override
  String get failedToLoad => 'Błąd ładowania.';

  @override
  String get noIngredientsFound => 'Nie znaleziono składników.';

  @override
  String get noInstructionsFound => 'Nie znaleziono instrukcji.';

  @override
  String get cancelSubscription => 'Anulować subskrypcję?';

  @override
  String get subscriptionCancelled =>
      'Subskrypcja anulowana. Dostęp do końca okresu.';

  @override
  String get typeDeleteToConfirm => 'Wpisz DELETE, by potwierdzić';

  @override
  String get deleteMyAccount => 'Usuń moje konto';

  @override
  String get thisActionPermanent =>
      'Ta akcja jest nieodwracalna. Wszystkie dane zostaną usunięte.';

  @override
  String get eatSmarter => 'Jedz mądrzej.';

  @override
  String get liveBetter => 'Żyj lepiej.';

  @override
  String get personalizedMealPlan =>
      'Spersonalizowany plan żywieniowy oparty na tym, co masz w lodówce.';

  @override
  String get knowWhatToEat => 'Wiedz, co jeść. Każdego dnia.';

  @override
  String get aboutThreePercent => '~30 min';

  @override
  String get servings => 'porcji';

  @override
  String get openInBrowser => 'Otwórz w przeglądarce';

  @override
  String get progressHistory => 'Historia postępów';

  @override
  String get activityToday => 'Aktywność dzisiaj';

  @override
  String get about => 'O aplikacji';

  @override
  String get comingSoon => 'wkrótce';

  @override
  String get notificationsComingSoon => 'Powiadomienia wkrótce';

  @override
  String addedProductsToPantry(int count) {
    return 'Dodano $count produktów do spiżarni ✓';
  }
}
