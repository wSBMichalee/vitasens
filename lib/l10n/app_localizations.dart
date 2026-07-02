import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'VitaSense'**
  String get appName;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey'**
  String get signInToContinue;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @pantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get pantry;

  /// No description provided for @aiMeals.
  ///
  /// In en, this message translates to:
  /// **'AI Meals'**
  String get aiMeals;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @todaysProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get todaysProgress;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @todaysMeals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get todaysMeals;

  /// No description provided for @noMealsAdded.
  ///
  /// In en, this message translates to:
  /// **'No meals added yet'**
  String get noMealsAdded;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @fridge.
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get fridge;

  /// No description provided for @freezer.
  ///
  /// In en, this message translates to:
  /// **'Freezer'**
  String get freezer;

  /// No description provided for @pantryStorage.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get pantryStorage;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// No description provided for @searchIngredients.
  ///
  /// In en, this message translates to:
  /// **'Search ingredients...'**
  String get searchIngredients;

  /// No description provided for @scanFridge.
  ///
  /// In en, this message translates to:
  /// **'Scan Fridge'**
  String get scanFridge;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// No description provided for @generateMeals.
  ///
  /// In en, this message translates to:
  /// **'Generate Meals'**
  String get generateMeals;

  /// No description provided for @cookFromIngredients.
  ///
  /// In en, this message translates to:
  /// **'Cook from your ingredients'**
  String get cookFromIngredients;

  /// No description provided for @noIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients'**
  String get noIngredients;

  /// No description provided for @addIngredientsToPantry.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients to your pantry to see matching recipes'**
  String get addIngredientsToPantry;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// No description provided for @cookTime.
  ///
  /// In en, this message translates to:
  /// **'Cook Time'**
  String get cookTime;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @cuisine.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get cuisine;

  /// No description provided for @startCooking.
  ///
  /// In en, this message translates to:
  /// **'Start cooking now'**
  String get startCooking;

  /// No description provided for @ingredientsInPantry.
  ///
  /// In en, this message translates to:
  /// **'{count} in pantry · {missing} missing'**
  String ingredientsInPantry(int count, int missing);

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingList;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noPurchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'No purchase history yet'**
  String get noPurchaseHistory;

  /// No description provided for @quickAddItem.
  ///
  /// In en, this message translates to:
  /// **'Quick add item...'**
  String get quickAddItem;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @addToList.
  ///
  /// In en, this message translates to:
  /// **'Add to List'**
  String get addToList;

  /// No description provided for @myGoals.
  ///
  /// In en, this message translates to:
  /// **'My Goals'**
  String get myGoals;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @pace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get pace;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @healthConditions.
  ///
  /// In en, this message translates to:
  /// **'Health Conditions'**
  String get healthConditions;

  /// No description provided for @dietaryPreferences.
  ///
  /// In en, this message translates to:
  /// **'Dietary Preferences'**
  String get dietaryPreferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No Connection'**
  String get noConnection;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection.\nThe app will refresh automatically.'**
  String get checkConnection;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @connectionWillRestore.
  ///
  /// In en, this message translates to:
  /// **'Connection will restore automatically'**
  String get connectionWillRestore;

  /// No description provided for @moveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to:'**
  String get moveTo;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get removeItem;

  /// No description provided for @removeFromStorage.
  ///
  /// In en, this message translates to:
  /// **'Remove from storage'**
  String get removeFromStorage;

  /// No description provided for @whereDoYouStore.
  ///
  /// In en, this message translates to:
  /// **'WHERE DO YOU STORE IT?'**
  String get whereDoYouStore;

  /// No description provided for @cantFindIt.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find it? Add manually'**
  String get cantFindIt;

  /// No description provided for @addToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add to meal'**
  String get addToMeal;

  /// No description provided for @addToPantry.
  ///
  /// In en, this message translates to:
  /// **'Add to pantry'**
  String get addToPantry;

  /// No description provided for @servingG.
  ///
  /// In en, this message translates to:
  /// **'Serving (g)'**
  String get servingG;

  /// No description provided for @addedToDiary.
  ///
  /// In en, this message translates to:
  /// **'Added to diary'**
  String get addedToDiary;

  /// No description provided for @enjoyMeal.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your meal! 🍽️ Pantry updated.'**
  String get enjoyMeal;

  /// No description provided for @noMeals.
  ///
  /// In en, this message translates to:
  /// **'No meals added'**
  String get noMeals;

  /// No description provided for @savedRecipes.
  ///
  /// In en, this message translates to:
  /// **'Saved Recipes'**
  String get savedRecipes;

  /// No description provided for @yourCollection.
  ///
  /// In en, this message translates to:
  /// **'Your collection'**
  String get yourCollection;

  /// No description provided for @noSavedRecipes.
  ///
  /// In en, this message translates to:
  /// **'No saved recipes yet.'**
  String get noSavedRecipes;

  /// No description provided for @addFavoriteRecipes.
  ///
  /// In en, this message translates to:
  /// **'Add your favorite recipes by tapping ❤️ in AI Meals.'**
  String get addFavoriteRecipes;

  /// No description provided for @browseAiMeals.
  ///
  /// In en, this message translates to:
  /// **'Browse AI Meals'**
  String get browseAiMeals;

  /// No description provided for @eaten.
  ///
  /// In en, this message translates to:
  /// **'Eaten'**
  String get eaten;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @suggestion.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTION'**
  String get suggestion;

  /// No description provided for @myRecipes.
  ///
  /// In en, this message translates to:
  /// **'My Recipes'**
  String get myRecipes;

  /// No description provided for @createRecipe.
  ///
  /// In en, this message translates to:
  /// **'Create Recipe'**
  String get createRecipe;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'DRAFT'**
  String get draft;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'PUBLIC'**
  String get public;

  /// No description provided for @saveRecipe.
  ///
  /// In en, this message translates to:
  /// **'Save Recipe'**
  String get saveRecipe;

  /// No description provided for @vitaSensePro.
  ///
  /// In en, this message translates to:
  /// **'VitaSense Pro'**
  String get vitaSensePro;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @monthlyTargets.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY TARGETS'**
  String get monthlyTargets;

  /// No description provided for @yourNutritionThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Your nutrition this month'**
  String get yourNutritionThisMonth;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'low'**
  String get low;

  /// No description provided for @scanFood.
  ///
  /// In en, this message translates to:
  /// **'Scan Food'**
  String get scanFood;

  /// No description provided for @logMeal.
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get logMeal;

  /// No description provided for @scanRecipeLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan Recipe'**
  String get scanRecipeLabel;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @speakNow.
  ///
  /// In en, this message translates to:
  /// **'Speak now'**
  String get speakNow;

  /// No description provided for @tapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get tapToStart;

  /// No description provided for @detectedMeal.
  ///
  /// In en, this message translates to:
  /// **'Detected Meal'**
  String get detectedMeal;

  /// No description provided for @logThisMeal.
  ///
  /// In en, this message translates to:
  /// **'Log This Meal'**
  String get logThisMeal;

  /// No description provided for @logAnother.
  ///
  /// In en, this message translates to:
  /// **'Log Another'**
  String get logAnother;

  /// No description provided for @logged.
  ///
  /// In en, this message translates to:
  /// **'Logged! 🎉'**
  String get logged;

  /// No description provided for @familyPlan.
  ///
  /// In en, this message translates to:
  /// **'Family Plan'**
  String get familyPlan;

  /// No description provided for @sharedPantry.
  ///
  /// In en, this message translates to:
  /// **'Shared Pantry'**
  String get sharedPantry;

  /// No description provided for @createFamilyGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Family Group'**
  String get createFamilyGroup;

  /// No description provided for @joinFamilyGroup.
  ///
  /// In en, this message translates to:
  /// **'Join Family Group'**
  String get joinFamilyGroup;

  /// No description provided for @leaveFamilyGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Family Group?'**
  String get leaveFamilyGroup;

  /// No description provided for @deleteFamilyGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Family Group?'**
  String get deleteFamilyGroup;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @keepPlan.
  ///
  /// In en, this message translates to:
  /// **'Keep Plan'**
  String get keepPlan;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent!'**
  String get resetLinkSent;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @checkEmailForReset.
  ///
  /// In en, this message translates to:
  /// **'Check your email for a password reset link.'**
  String get checkEmailForReset;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// No description provided for @editPace.
  ///
  /// In en, this message translates to:
  /// **'Edit Pace'**
  String get editPace;

  /// No description provided for @editActivity.
  ///
  /// In en, this message translates to:
  /// **'Edit Activity'**
  String get editActivity;

  /// No description provided for @editWeight.
  ///
  /// In en, this message translates to:
  /// **'Edit Weight'**
  String get editWeight;

  /// No description provided for @successStreak.
  ///
  /// In en, this message translates to:
  /// **'Great consistency towards your goal'**
  String get successStreak;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak'**
  String streakDays(int days);

  /// No description provided for @lowProteinToday.
  ///
  /// In en, this message translates to:
  /// **'Low protein today'**
  String get lowProteinToday;

  /// No description provided for @addHighProteinMeal.
  ///
  /// In en, this message translates to:
  /// **'Add a high-protein meal to reach your daily goal.'**
  String get addHighProteinMeal;

  /// No description provided for @connectHealth.
  ///
  /// In en, this message translates to:
  /// **'Connect Health'**
  String get connectHealth;

  /// No description provided for @tapToSyncSteps.
  ///
  /// In en, this message translates to:
  /// **'Tap to sync steps & calories'**
  String get tapToSyncSteps;

  /// No description provided for @hydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get hydration;

  /// No description provided for @noRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipesYet;

  /// No description provided for @createFirstRecipe.
  ///
  /// In en, this message translates to:
  /// **'Create your first recipe below'**
  String get createFirstRecipe;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @howToPrepare.
  ///
  /// In en, this message translates to:
  /// **'How to prepare'**
  String get howToPrepare;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @nutritionPerServing.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per serving'**
  String get nutritionPerServing;

  /// No description provided for @addedToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Added to shopping list ✓'**
  String get addedToShoppingList;

  /// No description provided for @addMissingIngredients.
  ///
  /// In en, this message translates to:
  /// **'Add {count} missing ingredients'**
  String addMissingIngredients(int count);

  /// No description provided for @recipeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recipe not found — refresh the list.'**
  String get recipeNotFound;

  /// No description provided for @cannotCookRecipe.
  ///
  /// In en, this message translates to:
  /// **'Cannot cook this recipe — try re-loading it.'**
  String get cannotCookRecipe;

  /// No description provided for @deleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe?'**
  String get deleteRecipe;

  /// No description provided for @areYouSureDeleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recipe?'**
  String get areYouSureDeleteRecipe;

  /// No description provided for @selectCuisine.
  ///
  /// In en, this message translates to:
  /// **'Select Cuisine'**
  String get selectCuisine;

  /// No description provided for @dietTags.
  ///
  /// In en, this message translates to:
  /// **'DIET TAGS'**
  String get dietTags;

  /// No description provided for @recipeBASICS.
  ///
  /// In en, this message translates to:
  /// **'RECIPE BASICS'**
  String get recipeBASICS;

  /// No description provided for @addStep.
  ///
  /// In en, this message translates to:
  /// **'Add Step'**
  String get addStep;

  /// No description provided for @stepByStepNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step instructions not available yet. Try cooking this recipe after re-syncing.'**
  String get stepByStepNotAvailable;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load.'**
  String get failedToLoad;

  /// No description provided for @noIngredientsFound.
  ///
  /// In en, this message translates to:
  /// **'No ingredients found.'**
  String get noIngredientsFound;

  /// No description provided for @noInstructionsFound.
  ///
  /// In en, this message translates to:
  /// **'No instructions found.'**
  String get noInstructionsFound;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription?'**
  String get cancelSubscription;

  /// No description provided for @subscriptionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled. Access until end of period.'**
  String get subscriptionCancelled;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get typeDeleteToConfirm;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No description provided for @thisActionPermanent.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your data will be deleted.'**
  String get thisActionPermanent;

  /// No description provided for @eatSmarter.
  ///
  /// In en, this message translates to:
  /// **'Eat smarter.'**
  String get eatSmarter;

  /// No description provided for @liveBetter.
  ///
  /// In en, this message translates to:
  /// **'Live better.'**
  String get liveBetter;

  /// No description provided for @personalizedMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Your personalized meal plan based on what\'s in your fridge.'**
  String get personalizedMealPlan;

  /// No description provided for @knowWhatToEat.
  ///
  /// In en, this message translates to:
  /// **'Know what to eat. Every day.'**
  String get knowWhatToEat;

  /// No description provided for @aboutThreePercent.
  ///
  /// In en, this message translates to:
  /// **'~30 min'**
  String get aboutThreePercent;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'servings'**
  String get servings;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get openInBrowser;

  /// No description provided for @progressHistory.
  ///
  /// In en, this message translates to:
  /// **'Progress History'**
  String get progressHistory;

  /// No description provided for @activityToday.
  ///
  /// In en, this message translates to:
  /// **'Activity Today'**
  String get activityToday;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'coming soon'**
  String get comingSoon;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications coming soon'**
  String get notificationsComingSoon;

  /// No description provided for @addedProductsToPantry.
  ///
  /// In en, this message translates to:
  /// **'Added {count} products to pantry ✓'**
  String addedProductsToPantry(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
