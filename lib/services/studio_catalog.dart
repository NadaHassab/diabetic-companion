import 'package:diabetic_companion/models/studio_models.dart';

// --- Evidence sources ---
const _tdna = 'tDNA-Middle East consensus, Frontiers in Nutrition 2022';
const _uaeGi = 'UAE GI study, Br J Nutr 2017';
const _giTables = '2008 International GI Tables (WHO)';
const _hummusGi = 'Hummus GI study, Nutrition Journal 2016';
const _datesGi = 'Alkaabi dates study 2011';
const _recipeCalc = 'published recipe analysis (Tier B)';
const _riceGi = 'Rice GI values, Asia Pac J Clin Nutr 2011';
const _lentilGi = 'Lentil GI, J Nutrition 2005';

// ─── Swaps ────────────────────────────────────────────────────────────────────

const studioSwaps = <Swap>[
  Swap(
    id: 'sw-basmati',
    role: IngredientRole.starchCore,
    fromAr: 'أرز أبيض',
    fromEn: 'white rice',
    toAr: 'أرز بسمتي',
    toEn: 'basmati rice',
    effect: 'GI ~84 → ~55-58; slower glucose rise',
    source: _riceGi,
    tier: EvidenceTier.measuredA,
  ),
  Swap(
    id: 'sw-freekeh',
    role: IngredientRole.starchCore,
    fromAr: 'أرز أبيض',
    fromEn: 'white rice',
    toAr: 'فريك',
    toEn: 'freekeh',
    effect: 'lower GI whole grain; higher fiber',
    source: _tdna,
    tier: EvidenceTier.measuredA,
  ),
  Swap(
    id: 'sw-burghul',
    role: IngredientRole.starchCore,
    fromAr: 'أرز أبيض',
    fromEn: 'white rice',
    toAr: 'برغل',
    toEn: 'burghul (bulgur)',
    effect: 'GI ~48 vs white rice; higher fiber',
    source: _giTables,
    tier: EvidenceTier.measuredA,
  ),
  Swap(
    id: 'sw-halfcauli',
    role: IngredientRole.starchCore,
    fromAr: 'الأرز كامل',
    fromEn: 'full rice portion',
    toAr: 'نصف أرز + نصف قرنبيط',
    toEn: 'half rice + half cauliflower rice',
    effect: '~halves carb grams of the core (48g→16g in mahshi analysis)',
    source: _recipeCalc,
    tier: EvidenceTier.calculatedB,
  ),
  Swap(
    id: 'sw-lentils',
    role: IngredientRole.protein,
    fromAr: 'شعيرية بالأرز',
    fromEn: 'vermicelli-heavy rice mix',
    toAr: 'عدس بنسبة متساوية مع الأرز',
    toEn: 'equal lentils-to-rice ratio',
    effect: 'lentil GI ~29 dilutes the starch response (koshari rule)',
    source: _lentilGi,
    tier: EvidenceTier.measuredA,
  ),
  Swap(
    id: 'sw-baking',
    role: IngredientRole.fatCrunch,
    fromAr: 'مقلي',
    fromEn: 'fried',
    toAr: 'مشوي أو بالفرن/القلاية الهوائية',
    toEn: 'baked or air-fried',
    effect: 'less fat; no GI change but easier portions and digestion',
    source: _tdna,
    tier: EvidenceTier.calculatedB,
  ),
  Swap(
    id: 'sw-oliveoil',
    role: IngredientRole.fatCrunch,
    fromAr: 'سمن بلدي',
    fromEn: 'ghee',
    toAr: 'زيت زيتون',
    toEn: 'olive oil',
    effect: 'better fat profile; modest glucose benefit',
    source: _tdna,
    tier: EvidenceTier.calculatedB,
  ),
  Swap(
    id: 'sw-datepuree',
    role: IngredientRole.sauce,
    fromAr: 'سكر مضاف',
    fromEn: 'added sugar',
    toAr: 'معجون تمر خلاص',
    toEn: 'khalas date purée',
    effect: 'date GI ~36 vs sucrose ~65; adds fiber',
    source: _datesGi,
    tier: EvidenceTier.measuredA,
  ),
  Swap(
    id: 'sw-wholemeal',
    role: IngredientRole.starchCore,
    fromAr: 'دقيق أبيض',
    fromEn: 'white flour',
    toAr: 'دقيق أسمر أو حمص',
    toEn: 'wholemeal or chickpea flour',
    effect: 'lower GI dough; more fiber',
    source: _tdna,
    tier: EvidenceTier.calculatedB,
  ),
  Swap(
    id: 'sw-wholecouscous',
    role: IngredientRole.starchCore,
    fromAr: 'كسكسي أبيض (سميد ناعم)',
    fromEn: 'white semolina couscous',
    toAr: 'كسكسي أسمر أو كينوا',
    toEn: 'whole wheat couscous or quinoa',
    effect: 'lower GI; higher fiber; steadier glucose',
    source: _tdna,
    tier: EvidenceTier.calculatedB,
  ),
  Swap(
    id: 'sw-yogurt',
    role: IngredientRole.sauce,
    fromAr: 'قشطة أو كريمة',
    fromEn: 'cream',
    toAr: 'زبادي يوناني أو قريش',
    toEn: 'Greek yogurt or cottage cheese',
    effect: 'less saturated fat; adds protein; lower glycemic impact',
    source: _tdna,
    tier: EvidenceTier.calculatedB,
  ),
  Swap(
    id: 'sw-chickpeaflour',
    role: IngredientRole.starchCore,
    fromAr: 'دقيق أبيض',
    fromEn: 'white flour (pancakes)',
    toAr: 'دقيق حمص + دقيق أسمر',
    toEn: 'chickpea flour + whole wheat',
    effect: 'chickpea flour GI ~35 vs white flour ~75',
    source: _giTables,
    tier: EvidenceTier.measuredA,
  ),
  Swap(
    id: 'sw-sweetener',
    role: IngredientRole.sauce,
    fromAr: 'سكر مضاف',
    fromEn: 'added sugar (desserts)',
    toAr: 'شراب стевيا أو تمر',
    toEn: 'stevia syrup or date paste',
    effect: 'reduces added sugar GI impact',
    source: _tdna,
    tier: EvidenceTier.calculatedB,
  ),
];

// ─── Method Questions ─────────────────────────────────────────────────────────

const studioMethodQuestions = <MethodQuestion>[
  MethodQuestion(
    id: 'q-fry',
    questionAr: 'مقلي أم بالفرن؟',
    questionEn: 'Fried or baked?',
    options: [
      MethodOption(id: 'fried', labelAr: 'مقلي', labelEn: 'Fried', swapId: 'sw-baking'),
      MethodOption(id: 'baked', labelAr: 'بالفرن', labelEn: 'Baked / air-fried'),
    ],
  ),
  MethodQuestion(
    id: 'q-rice',
    questionAr: 'الأرز طري جداً أم حبة محافظة؟',
    questionEn: 'Rice very soft or firmer grains?',
    options: [
      MethodOption(id: 'soft', labelAr: 'طري جداً', labelEn: 'Very soft'),
      MethodOption(id: 'firm', labelAr: 'حبة محافظة', labelEn: 'Firmer grains'),
    ],
  ),
  MethodQuestion(
    id: 'q-chill',
    questionAr: 'مبرد وسخّنته أم طازج؟',
    questionEn: 'Chilled then reheated, or fresh?',
    options: [
      MethodOption(id: 'chilled', labelAr: 'مبرد ثم سُخّن', labelEn: 'Chilled & reheated'),
      MethodOption(id: 'fresh', labelAr: 'طازج', labelEn: 'Fresh'),
    ],
  ),
  MethodQuestion(
    id: 'q-fat',
    questionAr: 'سمن بلدي أم زيت؟',
    questionEn: 'Ghee or oil?',
    options: [
      MethodOption(id: 'ghee', labelAr: 'سمن بلدي', labelEn: 'Ghee', swapId: 'sw-oliveoil'),
      MethodOption(id: 'oil', labelAr: 'زيت', labelEn: 'Oil'),
    ],
  ),
  MethodQuestion(
    id: 'q-sugar',
    questionAr: 'سكر مضاف؟',
    questionEn: 'Added sugar?',
    options: [
      MethodOption(id: 'sugar', labelAr: 'سكر', labelEn: 'Sugar', swapId: 'sw-sweetener'),
      MethodOption(id: 'nosugar', labelAr: 'بدون سكر', labelEn: 'No sugar'),
    ],
  ),
  MethodQuestion(
    id: 'q-cream',
    questionAr: 'قشطة أم زبادي؟',
    questionEn: 'Cream or yogurt?',
    options: [
      MethodOption(id: 'cream', labelAr: 'قشطة', labelEn: 'Cream', swapId: 'sw-yogurt'),
      MethodOption(id: 'yogurt', labelAr: 'زبادي', labelEn: 'Yogurt'),
    ],
  ),
];

// ─── Dish Catalog ─────────────────────────────────────────────────────────────
// Organized by category, then region.

const studioDishes = <StudioDish>[

  // ════════════════════════════════════════════════════════════════════════════
  //  BREAKFAST (فطور)
  // ════════════════════════════════════════════════════════════════════════════

  // Egypt
  StudioDish(
    id: 'd-ful',
    nameAr: 'فول مدمس',
    nameEn: 'Ful medames',
    region: 'Egypt',
    category: DishCategory.breakfast,
    giEstimate: 50,
    giSource: _giTables,
    roles: {
      IngredientRole.protein: 'fava beans',
      IngredientRole.sauce: 'lemon, cumin, olive oil',
      IngredientRole.starchCore: 'baladi bread',
    },
    defaultSwapIds: ['sw-oliveoil'],
  ),
  StudioDish(
    id: 'd-taameya',
    nameAr: 'طعمية',
    nameEn: "Ta'ameya (Egyptian falafel)",
    region: 'Egypt',
    category: DishCategory.breakfast,
    giEstimate: 55,
    giSource: _tdna,
    roles: {
      IngredientRole.starchCore: 'fava bean + herb patty',
      IngredientRole.fatCrunch: 'fried (traditionally)',
      IngredientRole.vegShell: 'salad + pickles',
    },
    defaultSwapIds: ['sw-baking'],
  ),
  StudioDish(
    id: 'd-eggs-bread',
    nameAr: 'بيض وعيش بلدي',
    nameEn: 'Eggs with baladi bread',
    region: 'Egypt',
    category: DishCategory.breakfast,
    giEstimate: 30,
    giSource: _giTables,
    roles: {
      IngredientRole.protein: 'eggs (any style)',
      IngredientRole.starchCore: 'baladi bread',
      IngredientRole.vegShell: 'tomato, cucumber',
    },
  ),

  // Levant
  StudioDish(
    id: 'd-labneh',
    nameAr: 'لبنة بالخضار',
    nameEn: 'Labneh with vegetables',
    region: 'Levant',
    category: DishCategory.breakfast,
    giEstimate: 15,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'strained yogurt (labneh)',
      IngredientRole.vegShell: 'cucumber, tomato, mint, olive oil',
      IngredientRole.starchCore: 'Arabic bread',
    },
    defaultSwapIds: ['sw-wholemeal'],
  ),
  StudioDish(
    id: 'd-manakish',
    nameAr: 'مناقيش زعتر',
    nameEn: 'Manakish with zaatar',
    region: 'Levant',
    category: DishCategory.breakfast,
    giEstimate: 57,
    giSource: _tdna,
    roles: {
      IngredientRole.starchCore: 'white flour dough',
      IngredientRole.sauce: 'zaatar + olive oil',
      IngredientRole.vegShell: 'optional tomato + cucumber on the side',
    },
    defaultSwapIds: ['sw-wholemeal'],
  ),
  StudioDish(
    id: 'd-fattet-hummus',
    nameAr: 'فتة حمص',
    nameEn: 'Fatteh hummus',
    region: 'Levant',
    category: DishCategory.breakfast,
    giEstimate: 38,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'chickpeas + yogurt',
      IngredientRole.starchCore: 'toasted bread pieces',
      IngredientRole.fatCrunch: 'pine nuts + butter',
    },
    defaultSwapIds: ['sw-baking', 'sw-yogurt'],
  ),

  // Gulf
  StudioDish(
    id: 'd-balaleet',
    nameAr: 'بلليط',
    nameEn: 'Balaleet (vermicelli with egg)',
    region: 'Gulf',
    category: DishCategory.breakfast,
    giEstimate: 60,
    giSource: _uaeGi,
    roles: {
      IngredientRole.starchCore: 'vermicelli noodles',
      IngredientRole.protein: 'fried egg on top',
      IngredientRole.sauce: 'cardamom, saffron, sugar',
    },
    defaultSwapIds: ['sw-sweetener'],
  ),
  StudioDish(
    id: 'd-chabab',
    nameAr: 'خبز شباب',
    nameEn: 'Chabab bread (spiced pancakes)',
    region: 'Gulf',
    category: DishCategory.breakfast,
    giEstimate: 55,
    giSource: _uaeGi,
    roles: {
      IngredientRole.starchCore: 'flour batter (saffron, cardamom)',
      IngredientRole.fatCrunch: 'lightly fried in ghee',
      IngredientRole.vegShell: 'cheese or date syrup on side',
    },
    defaultSwapIds: ['sw-chickpeaflour', 'sw-baking'],
  ),
  StudioDish(
    id: 'd-chebab',
    nameAr: 'جبنة وخضار',
    nameEn: 'Cheese and vegetables plate',
    region: 'Gulf',
    category: DishCategory.breakfast,
    giEstimate: 10,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'nabulsi or halloumi cheese',
      IngredientRole.vegShell: 'cucumber, tomato, mint',
      IngredientRole.fatCrunch: 'olive oil',
    },
  ),

  // Maghreb
  StudioDish(
    id: 'd-baghrir',
    nameAr: 'بغرير',
    nameEn: 'Baghrir (semolina pancake)',
    region: 'Maghreb',
    category: DishCategory.breakfast,
    giEstimate: 60,
    giSource: _tdna,
    roles: {
      IngredientRole.starchCore: 'semolina flour batter',
      IngredientRole.sauce: 'honey or date syrup',
    },
    defaultSwapIds: ['sw-chickpeaflour', 'sw-datepuree'],
  ),
  StudioDish(
    id: 'd-bissara',
    nameAr: 'بصارة',
    nameEn: 'Bissara (fava bean dip)',
    region: 'Maghreb',
    category: DishCategory.breakfast,
    giEstimate: 35,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'dried fava beans',
      IngredientRole.sauce: 'cumin, olive oil, garlic',
      IngredientRole.starchCore: 'khobz bread',
    },
    defaultSwapIds: ['sw-wholemeal', 'sw-oliveoil'],
  ),

  // ════════════════════════════════════════════════════════════════════════════
  //  LUNCH (غداء)
  // ════════════════════════════════════════════════════════════════════════════

  // Egypt
  StudioDish(
    id: 'd-koshari',
    nameAr: 'كشري',
    nameEn: 'Koshari',
    region: 'Egypt',
    category: DishCategory.lunch,
    giEstimate: 75,
    giSource: _giTables,
    roles: {
      IngredientRole.starchCore: 'rice + vermicelli + macaroni',
      IngredientRole.protein: 'lentils (GI 29)',
      IngredientRole.fatCrunch: 'fried onions',
      IngredientRole.sauce: 'tomato sauce + vinegar',
    },
    defaultSwapIds: ['sw-lentils'],
  ),
  StudioDish(
    id: 'd-mahshi',
    nameAr: 'محشي ورق عنب',
    nameEn: 'Stuffed grape leaves',
    region: 'Egypt',
    category: DishCategory.lunch,
    giEstimate: 60,
    giSource: _tdna,
    roles: {
      IngredientRole.starchCore: 'rice filling',
      IngredientRole.protein: 'optional minced meat',
      IngredientRole.vegShell: 'grape leaves (fiber bonus)',
    },
    defaultSwapIds: ['sw-halfcauli'],
  ),
  StudioDish(
    id: 'd-molokhia',
    nameAr: 'ملوخية',
    nameEn: 'Molokhia with rice',
    region: 'Egypt',
    category: DishCategory.lunch,
    giEstimate: 55,
    giSource: _tdna,
    roles: {
      IngredientRole.starchCore: 'white rice',
      IngredientRole.protein: 'molokhia leaves in broth',
      IngredientRole.sauce: 'tahmia (garlic-coriander in ghee)',
    },
    defaultSwapIds: ['sw-basmati'],
  ),
  StudioDish(
    id: 'd-fattah',
    nameAr: 'فتة باللحم',
    nameEn: 'Fattah with beef',
    region: 'Egypt',
    category: DishCategory.lunch,
    giEstimate: 70,
    giSource: _tdna,
    roles: {
      IngredientRole.starchCore: 'rice + crispy bread',
      IngredientRole.protein: 'beef',
      IngredientRole.sauce: 'garlic-tomato-vinegar sauce',
    },
    defaultSwapIds: ['sw-basmati'],
  ),
  StudioDish(
    id: 'd-hawawshi',
    nameAr: 'حواوشي',
    nameEn: 'Hawawshi (stuffed bread)',
    region: 'Egypt',
    category: DishCategory.lunch,
    giEstimate: 58,
    giSource: _tdna,
    roles: {
      IngredientRole.starchCore: 'pita bread',
      IngredientRole.protein: 'minced spiced beef + peppers + onion',
      IngredientRole.fatCrunch: 'baked in its own fat',
    },
    defaultSwapIds: ['sw-wholemeal', 'sw-baking'],
  ),

  // Levant
  StudioDish(
    id: 'd-mjadara',
    nameAr: 'مجدرة',
    nameEn: 'Mjadara',
    region: 'Levant',
    category: DishCategory.lunch,
    giEstimate: 24,
    giSource: _lentilGi,
    roles: {
      IngredientRole.starchCore: 'rice or burghul',
      IngredientRole.protein: 'red lentils (GI ~29)',
      IngredientRole.fatCrunch: 'caramelized onions',
    },
    defaultSwapIds: ['sw-burghul'],
  ),
  StudioDish(
    id: 'd-kibbeh',
    nameAr: 'كبة مشوية',
    nameEn: 'Kibbeh (baked)',
    region: 'Levant',
    category: DishCategory.lunch,
    giEstimate: 45,
    giSource: _tdna,
    roles: {
      IngredientRole.starchCore: 'burghul wheat',
      IngredientRole.protein: 'minced lamb',
      IngredientRole.fatCrunch: 'pine nuts',
    },
    defaultSwapIds: ['sw-baking'],
  ),
  StudioDish(
    id: 'd-maqluba',
    nameAr: 'مقلوبة',
    nameEn: 'Maqluba (upside-down rice)',
    region: 'Levant',
    category: DishCategory.lunch,
    giEstimate: 55,
    giSource: _tdna,
    roles: {
      IngredientRole.starchCore: 'rice',
      IngredientRole.protein: 'chicken or lamb',
      IngredientRole.vegShell: 'eggplant, cauliflower, potato',
    },
    defaultSwapIds: ['sw-basmati', 'sw-halfcauli'],
  ),
  StudioDish(
    id: 'd-musakhan',
    nameAr: 'مسخّن',
    nameEn: 'Musakhan (sumac chicken)',
    region: 'Levant',
    category: DishCategory.lunch,
    giEstimate: 50,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'chicken',
      IngredientRole.starchCore: 'taboon bread',
      IngredientRole.sauce: 'caramelized onions + sumac + olive oil',
    },
    defaultSwapIds: ['sw-wholemeal'],
  ),

  // Gulf
  StudioDish(
    id: 'd-kabsa',
    nameAr: 'كبسة دجاج',
    nameEn: 'Chicken kabsa',
    region: 'Gulf',
    category: DishCategory.lunch,
    giEstimate: 52,
    giSource: _uaeGi,
    roles: {
      IngredientRole.starchCore: 'basmati rice',
      IngredientRole.protein: 'chicken',
      IngredientRole.sauce: 'spiced tomato dakkous',
    },
  ),
  StudioDish(
    id: 'd-harees',
    nameAr: 'هريس',
    nameEn: 'Harees',
    region: 'Gulf',
    category: DishCategory.lunch,
    giEstimate: 42,
    giSource: _uaeGi,
    roles: {
      IngredientRole.starchCore: 'wheat berries',
      IngredientRole.protein: 'slow-cooked meat',
    },
  ),
  StudioDish(
    id: 'd-thareed',
    nameAr: 'ثريد لحم',
    nameEn: 'Thareed (bread stew)',
    region: 'Gulf',
    category: DishCategory.lunch,
    giEstimate: 74,
    giSource: _tdna,
    roles: {
      IngredientRole.starchCore: 'thin regag bread layers',
      IngredientRole.protein: 'beef + vegetable stew',
    },
    defaultSwapIds: ['sw-wholemeal'],
  ),
  StudioDish(
    id: 'd-machbous',
    nameAr: 'مجبوس لحم',
    nameEn: 'Machbous (lamb)',
    region: 'Gulf',
    category: DishCategory.lunch,
    giEstimate: 55,
    giSource: _uaeGi,
    roles: {
      IngredientRole.starchCore: 'basmati rice',
      IngredientRole.protein: 'lamb on the bone',
      IngredientRole.sauce: 'bezar spice blend + dried lime',
    },
    defaultSwapIds: ['sw-basmati'],
  ),

  // Maghreb
  StudioDish(
    id: 'd-couscous',
    nameAr: 'كسكسي بالخضار',
    nameEn: 'Couscous with vegetables',
    region: 'Maghreb',
    category: DishCategory.lunch,
    giEstimate: 65,
    giSource: _giTables,
    roles: {
      IngredientRole.starchCore: 'semolina couscous',
      IngredientRole.vegShell: 'vegetable stew (carrot, turnip, zucchini)',
      IngredientRole.protein: 'chickpeas or lamb',
    },
    defaultSwapIds: ['sw-wholecouscous'],
  ),
  StudioDish(
    id: 'd-tagine',
    nameAr: 'طاجين لحم بالخضار',
    nameEn: 'Tagine (lamb with vegetables)',
    region: 'Maghreb',
    category: DishCategory.lunch,
    giEstimate: 38,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'lamb',
      IngredientRole.vegShell: 'carrots, turnips, zucchini, olives',
      IngredientRole.sauce: 'tomato, preserved lemon, saffron',
      IngredientRole.starchCore: 'bread on the side',
    },
    defaultSwapIds: ['sw-wholemeal'],
  ),
  StudioDish(
    id: 'd-tanjia',
    nameAr: 'طنجية',
    nameEn: 'Tanjia (slow-cooked lamb)',
    region: 'Maghreb',
    category: DishCategory.lunch,
    giEstimate: 20,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'lamb or beef (slow-cooked)',
      IngredientRole.sauce: 'cumin, saffron, preserved butter',
    },
  ),

  // ════════════════════════════════════════════════════════════════════════════
  //  DINNER (عشاء)
  // ════════════════════════════════════════════════════════════════════════════

  StudioDish(
    id: 'd-shish-tawook',
    nameAr: 'شيش طاووق',
    nameEn: 'Shish Tawook (chicken skewers)',
    region: 'Levant',
    category: DishCategory.dinner,
    giEstimate: 10,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'marinated chicken',
      IngredientRole.vegShell: 'garlic sauce (toum), salad, pickles',
      IngredientRole.starchCore: 'small portion pita',
    },
    defaultSwapIds: ['sw-wholemeal'],
  ),
  StudioDish(
    id: 'd-kofta',
    nameAr: 'كفتة مشوية',
    nameEn: 'Grilled kofta',
    region: 'Levant',
    category: DishCategory.dinner,
    giEstimate: 10,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'minced lamb + beef',
      IngredientRole.vegShell: 'tomato, onion, parsley',
      IngredientRole.starchCore: 'bread or small rice',
    },
    defaultSwapIds: ['sw-basmati'],
  ),
  StudioDish(
    id: 'd-grilled-fish',
    nameAr: 'سمك مشوي',
    nameEn: 'Grilled fish with rice',
    region: 'Gulf',
    category: DishCategory.dinner,
    giEstimate: 40,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'whole grilled fish (hammour or similar)',
      IngredientRole.starchCore: 'rice or bulgur',
      IngredientRole.vegShell: 'mixed salad, lemon',
    },
    defaultSwapIds: ['sw-basmati', 'sw-burghul'],
  ),
  StudioDish(
    id: 'd-kibda',
    nameAr: 'كبدة بلدي',
    nameEn: 'Pan-fried liver (Egyptian)',
    region: 'Egypt',
    category: DishCategory.dinner,
    giEstimate: 5,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'beef or lamb liver',
      IngredientRole.vegShell: 'onion, pepper, lime',
      IngredientRole.starchCore: 'baladi bread',
    },
    defaultSwapIds: ['sw-wholemeal'],
  ),

  // ════════════════════════════════════════════════════════════════════════════
  //  MEZZE / APPETIZERS (مقبلات)
  // ════════════════════════════════════════════════════════════════════════════

  // Egypt
  StudioDish(
    id: 'd-dukkah',
    nameAr: 'دقة مع زيت زيتون',
    nameEn: 'Dukkah with olive oil',
    region: 'Egypt',
    category: DishCategory.mezze,
    giEstimate: 35,
    giSource: _tdna,
    roles: {
      IngredientRole.fatCrunch: 'nuts + spice blend',
      IngredientRole.sauce: 'olive oil dip',
      IngredientRole.starchCore: 'bread dipper',
    },
  ),
  StudioDish(
    id: 'd-tahini',
    nameAr: 'سلطة طحينة',
    nameEn: 'Tahini salad',
    region: 'Egypt',
    category: DishCategory.mezze,
    giEstimate: 15,
    giSource: _tdna,
    roles: {
      IngredientRole.sauce: 'tahini + lemon + garlic',
      IngredientRole.vegShell: 'diced tomato + cucumber',
    },
  ),

  // Levant
  StudioDish(
    id: 'd-hummus',
    nameAr: 'حمص',
    nameEn: 'Hummus',
    region: 'Levant',
    category: DishCategory.mezze,
    giEstimate: 8,
    giSource: _hummusGi,
    roles: {
      IngredientRole.protein: 'chickpeas + tahini',
      IngredientRole.sauce: 'lemon, garlic, olive oil',
      IngredientRole.starchCore: 'pita bread on the side',
    },
  ),
  StudioDish(
    id: 'd-hummus-meat',
    nameAr: 'حمص باللحمة',
    nameEn: 'Hummus with meat',
    region: 'Levant',
    category: DishCategory.mezze,
    giEstimate: 15,
    giSource: _hummusGi,
    roles: {
      IngredientRole.protein: 'chickpeas + tahini + spiced meat',
      IngredientRole.starchCore: 'bread on the side',
    },
  ),
  StudioDish(
    id: 'd-baba-ghanoush',
    nameAr: 'بابا غنوج',
    nameEn: 'Baba ghanoush',
    region: 'Levant',
    category: DishCategory.mezze,
    giEstimate: 20,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'roasted eggplant',
      IngredientRole.sauce: 'tahini + lemon',
      IngredientRole.fatCrunch: 'olive oil + pomegranate seeds',
    },
  ),
  StudioDish(
    id: 'd-tabouleh',
    nameAr: 'تبولة',
    nameEn: 'Tabouleh',
    region: 'Levant',
    category: DishCategory.mezze,
    giEstimate: 15,
    giSource: _tdna,
    roles: {
      IngredientRole.vegShell: 'parsley + tomato + mint + bulgur',
      IngredientRole.sauce: 'lemon + olive oil',
    },
  ),
  StudioDish(
    id: 'd-fattoush',
    nameAr: 'فتوش',
    nameEn: 'Fattoush salad',
    region: 'Levant',
    category: DishCategory.mezze,
    giEstimate: 35,
    giSource: _tdna,
    roles: {
      IngredientRole.vegShell: 'mixed vegetables (tomato, cucumber, radish)',
      IngredientRole.starchCore: 'fried pita chips',
      IngredientRole.sauce: 'pomegranate molasses dressing',
    },
    defaultSwapIds: ['sw-baking'],
  ),

  // ════════════════════════════════════════════════════════════════════════════
  //  SOUPS (شوربة)
  // ════════════════════════════════════════════════════════════════════════════

  StudioDish(
    id: 'd-lentil-soup',
    nameAr: 'شوربة عدس',
    nameEn: 'Lentil soup',
    region: 'Levant',
    category: DishCategory.soup,
    giEstimate: 28,
    giSource: _lentilGi,
    roles: {
      IngredientRole.protein: 'red lentils',
      IngredientRole.sauce: 'onion, carrot, cumin, lemon',
      IngredientRole.starchCore: 'bread on the side',
    },
    defaultSwapIds: ['sw-wholemeal'],
  ),
  StudioDish(
    id: 'd-molokhia-soup',
    nameAr: 'شوربة ملوخية',
    nameEn: 'Molokhia soup (light)',
    region: 'Egypt',
    category: DishCategory.soup,
    giEstimate: 30,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'molokhia leaves',
      IngredientRole.sauce: 'chicken broth, garlic, coriander',
    },
  ),
  StudioDish(
    id: 'd-harira',
    nameAr: 'حريرة',
    nameEn: 'Harira soup',
    region: 'Maghreb',
    category: DishCategory.soup,
    giEstimate: 40,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'lentils + chickpeas',
      IngredientRole.starchCore: 'vermicelli + flour roux',
      IngredientRole.sauce: 'tomato + celery + herbs',
    },
    defaultSwapIds: ['sw-wholemeal'],
  ),
  StudioDish(
    id: 'd-shorbat-adass',
    nameAr: 'شوربة عدس أصفر',
    nameEn: 'Yellow lentil soup',
    region: 'Gulf',
    category: DishCategory.soup,
    giEstimate: 30,
    giSource: _lentilGi,
    roles: {
      IngredientRole.protein: 'yellow lentils',
      IngredientRole.sauce: 'onion, garlic, turmeric, lemon',
      IngredientRole.fatCrunch: 'olive oil drizzle',
    },
  ),

  // ════════════════════════════════════════════════════════════════════════════
  //  DESSERTS (حلويات)
  // ════════════════════════════════════════════════════════════════════════════

  // Egypt
  StudioDish(
    id: 'd-om-ali',
    nameAr: 'أم علي',
    nameEn: 'Om Ali (bread pudding)',
    region: 'Egypt',
    category: DishCategory.dessert,
    giEstimate: 58,
    giSource: _tdna,
    roles: {
      IngredientRole.starchCore: 'puff pastry or bread pieces',
      IngredientRole.sauce: 'milk + sugar + raisins + coconut',
      IngredientRole.fatCrunch: 'nuts (pistachios, almonds)',
    },
    defaultSwapIds: ['sw-yogurt', 'sw-datepuree'],
  ),
  StudioDish(
    id: 'd-basbousa',
    nameAr: 'بسبوسة',
    nameEn: 'Basbousa (semolina cake)',
    region: 'Egypt',
    category: DishCategory.dessert,
    giEstimate: 65,
    giSource: _giTables,
    roles: {
      IngredientRole.starchCore: 'semolina flour',
      IngredientRole.sauce: 'sugar syrup',
      IngredientRole.fatCrunch: 'coconut, ghee',
    },
    defaultSwapIds: ['sw-datepuree', 'sw-sweetener'],
  ),
  StudioDish(
    id: 'd-konafa',
    nameAr: 'كنافة نابلسية',
    nameEn: 'Kunafa Nabulsieh',
    region: 'Egypt',
    category: DishCategory.dessert,
    giEstimate: 72,
    giSource: _giTables,
    roles: {
      IngredientRole.starchCore: 'shredded kunafa dough',
      IngredientRole.protein: 'nabulsi cheese filling',
      IngredientRole.sauce: 'sugar syrup',
    },
    defaultSwapIds: ['sw-datepuree', 'sw-sweetener'],
  ),

  // Levant
  StudioDish(
    id: 'd-maamoul',
    nameAr: 'معمول تمر',
    nameEn: "Ma'amoul (date-filled cookies)",
    region: 'Levant',
    category: DishCategory.dessert,
    giEstimate: 50,
    giSource: _tdna,
    roles: {
      IngredientRole.starchCore: 'semolina + whole wheat dough',
      IngredientRole.protein: 'date paste filling',
      IngredientRole.fatCrunch: 'butter',
    },
    defaultSwapIds: ['sw-wholemeal'],
  ),

  // Gulf
  StudioDish(
    id: 'd-luqaimat',
    nameAr: 'لقيمات',
    nameEn: 'Luqaimat (sweet dumplings)',
    region: 'Gulf',
    category: DishCategory.dessert,
    giEstimate: 75,
    giSource: _uaeGi,
    roles: {
      IngredientRole.starchCore: 'flour + yeast batter',
      IngredientRole.sauce: 'date syrup (dibbs)',
      IngredientRole.fatCrunch: 'deep fried',
    },
    defaultSwapIds: ['sw-baking', 'sw-datepuree'],
  ),
  StudioDish(
    id: 'd-mehalabiya',
    nameAr: 'مهلبية',
    nameEn: 'Mehalabiya (milk pudding)',
    region: 'Gulf',
    category: DishCategory.dessert,
    giEstimate: 45,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'milk + cornstarch',
      IngredientRole.sauce: 'rose water',
      IngredientRole.fatCrunch: 'pistachios on top',
    },
    defaultSwapIds: ['sw-yogurt', 'sw-datepuree'],
  ),

  // Maghreb
  StudioDish(
    id: 'd-sellou',
    nameAr: 'سلو / zxal',
    nameEn: 'Sellou / Zaalouk (almond confection)',
    region: 'Maghreb',
    category: DishCategory.dessert,
    giEstimate: 42,
    giSource: _tdna,
    roles: {
      IngredientRole.fatCrunch: 'toasted almonds + sesame',
      IngredientRole.starchCore: 'toasted flour',
      IngredientRole.sauce: 'honey or date syrup',
    },
    defaultSwapIds: ['sw-datepuree'],
  ),

  // ════════════════════════════════════════════════════════════════════════════
  //  DRINKS (مشروبات)
  // ════════════════════════════════════════════════════════════════════════════

  StudioDish(
    id: 'd-mint-tea',
    nameAr: 'شاي بالنعناع',
    nameEn: 'Mint tea (unsweetened)',
    region: 'Levant',
    category: DishCategory.drink,
    giEstimate: 0,
    giSource: _tdna,
    roles: {
      IngredientRole.sauce: 'fresh mint leaves',
    },
  ),
  StudioDish(
    id: 'd-ayran',
    nameAr: 'لبن رائب / عيران',
    nameEn: 'Ayran / Laban (salted yogurt drink)',
    region: 'Gulf',
    category: DishCategory.drink,
    giEstimate: 18,
    giSource: _tdna,
    roles: {
      IngredientRole.protein: 'yogurt + water + salt',
    },
  ),
  StudioDish(
    id: 'd-qahwa',
    nameAr: 'قهوة عربية',
    nameEn: 'Arabic coffee (unsweetened)',
    region: 'Gulf',
    category: DishCategory.drink,
    giEstimate: 0,
    giSource: _tdna,
    roles: {
      IngredientRole.sauce: 'cardamom',
    },
  ),
];
