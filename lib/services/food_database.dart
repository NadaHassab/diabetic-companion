import 'package:diabetic_companion/models/food_item.dart';

const _usda = 'https://fdc.nal.usda.gov';

const defaultFoods = [
  FoodItem(
    id: 'f001',
    nameAr: 'أرز أبيض',
    nameEn: 'White rice (cooked)',
    category: 'Grains',
    portions: [
      PortionPreset(label: 'S', grams: 75, carbGrams: 20),
      PortionPreset(label: 'M', grams: 150, carbGrams: 40),
      PortionPreset(label: 'L', grams: 225, carbGrams: 60),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f002',
    nameAr: 'خبز بيتا',
    nameEn: 'Pita bread',
    category: 'Grains',
    portions: [
      PortionPreset(label: 'S', grams: 28, carbGrams: 15),
      PortionPreset(label: 'M', grams: 56, carbGrams: 30),
      PortionPreset(label: 'L', grams: 84, carbGrams: 45),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f003',
    nameAr: 'فول مدمس',
    nameEn: 'Ful medames',
    category: 'Legumes',
    portions: [
      PortionPreset(label: 'S', grams: 100, carbGrams: 18),
      PortionPreset(label: 'M', grams: 200, carbGrams: 36),
      PortionPreset(label: 'L', grams: 300, carbGrams: 54),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f004',
    nameAr: 'حمص',
    nameEn: 'Hummus',
    category: 'Legumes',
    portions: [
      PortionPreset(label: 'S', grams: 30, carbGrams: 4),
      PortionPreset(label: 'M', grams: 60, carbGrams: 8),
      PortionPreset(label: 'L', grams: 100, carbGrams: 14),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f005',
    nameAr: 'شاورما دجاج',
    nameEn: 'Chicken shawarma',
    category: 'Protein',
    portions: [
      PortionPreset(label: 'S', grams: 100, carbGrams: 8),
      PortionPreset(label: 'M', grams: 200, carbGrams: 16),
      PortionPreset(label: 'L', grams: 300, carbGrams: 24),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f006',
    nameAr: 'كبسة دجاج',
    nameEn: 'Chicken kabsa',
    category: 'Mixed meals',
    portions: [
      PortionPreset(label: 'S', grams: 200, carbGrams: 50),
      PortionPreset(label: 'M', grams: 350, carbGrams: 88),
      PortionPreset(label: 'L', grams: 500, carbGrams: 125),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f007',
    nameAr: 'كنافة',
    nameEn: 'Kunafa',
    category: 'Desserts',
    portions: [
      PortionPreset(label: 'S', grams: 50, carbGrams: 25),
      PortionPreset(label: 'M', grams: 100, carbGrams: 50),
      PortionPreset(label: 'L', grams: 150, carbGrams: 75),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f008',
    nameAr: 'مشكي',
    nameEn: 'Kishk',
    category: 'Grains',
    portions: [
      PortionPreset(label: 'S', grams: 50, carbGrams: 20),
      PortionPreset(label: 'M', grams: 100, carbGrams: 40),
      PortionPreset(label: 'L', grams: 150, carbGrams: 60),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f009',
    nameAr: 'سلطة عربي',
    nameEn: 'Arabic salad',
    category: 'Vegetables',
    portions: [
      PortionPreset(label: 'S', grams: 100, carbGrams: 5),
      PortionPreset(label: 'M', grams: 200, carbGrams: 10),
      PortionPreset(label: 'L', grams: 300, carbGrams: 15),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f010',
    nameAr: 'مكسرات مشكلة',
    nameEn: 'Mixed nuts',
    category: 'Snacks',
    portions: [
      PortionPreset(label: 'S', grams: 15, carbGrams: 3),
      PortionPreset(label: 'M', grams: 30, carbGrams: 6),
      PortionPreset(label: 'L', grams: 50, carbGrams: 10),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f011',
    nameAr: 'خبز عربي',
    nameEn: 'Arabic bread (khubz)',
    category: 'Grains',
    portions: [
      PortionPreset(label: 'S', grams: 30, carbGrams: 15),
      PortionPreset(label: 'M', grams: 60, carbGrams: 30),
      PortionPreset(label: 'L', grams: 90, carbGrams: 45),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f012',
    nameAr: 'لبن رائب',
    nameEn: 'Buttermilk / laban',
    category: 'Dairy',
    portions: [
      PortionPreset(label: 'S', grams: 100, carbGrams: 5),
      PortionPreset(label: 'M', grams: 200, carbGrams: 10),
      PortionPreset(label: 'L', grams: 330, carbGrams: 17),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f013',
    nameAr: 'بيض مسلوق',
    nameEn: 'Boiled egg',
    category: 'Protein',
    portions: [
      PortionPreset(label: 'S', grams: 50, carbGrams: 1),
      PortionPreset(label: 'M', grams: 100, carbGrams: 1),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f014',
    nameAr: 'زبادي',
    nameEn: 'Yogurt (plain)',
    category: 'Dairy',
    portions: [
      PortionPreset(label: 'S', grams: 100, carbGrams: 5),
      PortionPreset(label: 'M', grams: 200, carbGrams: 10),
      PortionPreset(label: 'L', grams: 300, carbGrams: 15),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f015',
    nameAr: 'تمر',
    nameEn: 'Dates',
    category: 'Fruits',
    portions: [
      PortionPreset(label: 'S', grams: 15, carbGrams: 12),
      PortionPreset(label: 'M', grams: 30, carbGrams: 24),
      PortionPreset(label: 'L', grams: 50, carbGrams: 40),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f016',
    nameAr: 'موز',
    nameEn: 'Banana',
    category: 'Fruits',
    portions: [
      PortionPreset(label: 'S', grams: 50, carbGrams: 12),
      PortionPreset(label: 'M', grams: 100, carbGrams: 23),
      PortionPreset(label: 'L', grams: 150, carbGrams: 35),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f017',
    nameAr: 'تفاح',
    nameEn: 'Apple',
    category: 'Fruits',
    portions: [
      PortionPreset(label: 'S', grams: 80, carbGrams: 11),
      PortionPreset(label: 'M', grams: 150, carbGrams: 21),
      PortionPreset(label: 'L', grams: 200, carbGrams: 28),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f018',
    nameAr: 'عنب',
    nameEn: 'Grapes',
    category: 'Fruits',
    portions: [
      PortionPreset(label: 'S', grams: 50, carbGrams: 9),
      PortionPreset(label: 'M', grams: 100, carbGrams: 18),
      PortionPreset(label: 'L', grams: 150, carbGrams: 27),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f019',
    nameAr: 'جبنة بيضاء',
    nameEn: 'White cheese (feta)',
    category: 'Dairy',
    portions: [
      PortionPreset(label: 'S', grams: 20, carbGrams: 1),
      PortionPreset(label: 'M', grams: 40, carbGrams: 1),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f020',
    nameAr: 'شاي بالنعناع',
    nameEn: 'Mint tea (unsweetened)',
    category: 'Beverages',
    portions: [
      PortionPreset(label: 'S', grams: 200, carbGrams: 0),
      PortionPreset(label: 'M', grams: 250, carbGrams: 0),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f021',
    nameAr: 'نسكافيه',
    nameEn: 'Nescafe (with milk)',
    category: 'Beverages',
    portions: [
      PortionPreset(label: 'S', grams: 150, carbGrams: 8),
      PortionPreset(label: 'M', grams: 200, carbGrams: 10),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f022',
    nameAr: 'عصير برتقال',
    nameEn: 'Orange juice',
    category: 'Beverages',
    portions: [
      PortionPreset(label: 'S', grams: 100, carbGrams: 11),
      PortionPreset(label: 'M', grams: 200, carbGrams: 22),
      PortionPreset(label: 'L', grams: 330, carbGrams: 36),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f023',
    nameAr: 'معكرونة',
    nameEn: 'Pasta (cooked)',
    category: 'Grains',
    portions: [
      PortionPreset(label: 'S', grams: 75, carbGrams: 20),
      PortionPreset(label: 'M', grams: 150, carbGrams: 40),
      PortionPreset(label: 'L', grams: 225, carbGrams: 60),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f024',
    nameAr: 'خبز توست أبيض',
    nameEn: 'White toast bread',
    category: 'Grains',
    portions: [
      PortionPreset(label: 'S', grams: 25, carbGrams: 13),
      PortionPreset(label: 'M', grams: 50, carbGrams: 26),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f025',
    nameAr: 'ملوخية',
    nameEn: 'Molokhia',
    category: 'Mixed meals',
    portions: [
      PortionPreset(label: 'S', grams: 150, carbGrams: 8),
      PortionPreset(label: 'M', grams: 300, carbGrams: 16),
      PortionPreset(label: 'L', grams: 450, carbGrams: 24),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f026',
    nameAr: 'فتوش',
    nameEn: 'Fattoush',
    category: 'Vegetables',
    portions: [
      PortionPreset(label: 'S', grams: 100, carbGrams: 8),
      PortionPreset(label: 'M', grams: 200, carbGrams: 16),
      PortionPreset(label: 'L', grams: 300, carbGrams: 24),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f027',
    nameAr: 'كبة مشوية',
    nameEn: 'Kibbeh (baked)',
    category: 'Protein',
    portions: [
      PortionPreset(label: 'S', grams: 60, carbGrams: 10),
      PortionPreset(label: 'M', grams: 120, carbGrams: 20),
      PortionPreset(label: 'L', grams: 180, carbGrams: 30),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f028',
    nameAr: 'مجبوس لحم',
    nameEn: 'Machbous (lamb)',
    category: 'Mixed meals',
    portions: [
      PortionPreset(label: 'S', grams: 200, carbGrams: 48),
      PortionPreset(label: 'M', grams: 350, carbGrams: 84),
      PortionPreset(label: 'L', grams: 500, carbGrams: 120),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f029',
    nameAr: 'كسكسي بالخضار',
    nameEn: 'Couscous with vegetables',
    category: 'Mixed meals',
    portions: [
      PortionPreset(label: 'S', grams: 150, carbGrams: 30),
      PortionPreset(label: 'M', grams: 300, carbGrams: 60),
      PortionPreset(label: 'L', grams: 450, carbGrams: 90),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f030',
    nameAr: 'حريرة',
    nameEn: 'Harira soup',
    category: 'Mixed meals',
    portions: [
      PortionPreset(label: 'S', grams: 200, carbGrams: 18),
      PortionPreset(label: 'M', grams: 400, carbGrams: 36),
      PortionPreset(label: 'L', grams: 600, carbGrams: 54),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f031',
    nameAr: 'برغل',
    nameEn: 'Bulgur wheat',
    category: 'Grains',
    portions: [
      PortionPreset(label: 'S', grams: 75, carbGrams: 15),
      PortionPreset(label: 'M', grams: 150, carbGrams: 30),
      PortionPreset(label: 'L', grams: 225, carbGrams: 45),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f032',
    nameAr: 'فريك',
    nameEn: 'Freekeh',
    category: 'Grains',
    portions: [
      PortionPreset(label: 'S', grams: 75, carbGrams: 16),
      PortionPreset(label: 'M', grams: 150, carbGrams: 32),
      PortionPreset(label: 'L', grams: 225, carbGrams: 48),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f033',
    nameAr: 'طعمية',
    nameEn: "Ta'ameya (Egyptian falafel)",
    category: 'Protein',
    portions: [
      PortionPreset(label: 'S', grams: 30, carbGrams: 5),
      PortionPreset(label: 'M', grams: 60, carbGrams: 10),
      PortionPreset(label: 'L', grams: 100, carbGrams: 17),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f034',
    nameAr: 'مناقيش زعتر',
    nameEn: 'Manakish with zaatar',
    category: 'Grains',
    portions: [
      PortionPreset(label: 'S', grams: 60, carbGrams: 25),
      PortionPreset(label: 'M', grams: 120, carbGrams: 50),
      PortionPreset(label: 'L', grams: 180, carbGrams: 75),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f035',
    nameAr: 'بابا غنوج',
    nameEn: 'Baba ghanoush',
    category: 'Vegetables',
    portions: [
      PortionPreset(label: 'S', grams: 30, carbGrams: 2),
      PortionPreset(label: 'M', grams: 60, carbGrams: 4),
      PortionPreset(label: 'L', grams: 100, carbGrams: 7),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f036',
    nameAr: 'تبولة',
    nameEn: 'Tabouleh',
    category: 'Vegetables',
    portions: [
      PortionPreset(label: 'S', grams: 50, carbGrams: 2),
      PortionPreset(label: 'M', grams: 100, carbGrams: 4),
      PortionPreset(label: 'L', grams: 150, carbGrams: 6),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f037',
    nameAr: 'أم علي',
    nameEn: 'Om Ali (bread pudding)',
    category: 'Desserts',
    portions: [
      PortionPreset(label: 'S', grams: 80, carbGrams: 18),
      PortionPreset(label: 'M', grams: 150, carbGrams: 34),
      PortionPreset(label: 'L', grams: 225, carbGrams: 51),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f038',
    nameAr: 'بسبوسة',
    nameEn: 'Basbousa (semolina cake)',
    category: 'Desserts',
    portions: [
      PortionPreset(label: 'S', grams: 50, carbGrams: 28),
      PortionPreset(label: 'M', grams: 100, carbGrams: 56),
      PortionPreset(label: 'L', grams: 150, carbGrams: 84),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f039',
    nameAr: 'شوربة عدس',
    nameEn: 'Lentil soup',
    category: 'Soups',
    portions: [
      PortionPreset(label: 'S', grams: 200, carbGrams: 14),
      PortionPreset(label: 'M', grams: 400, carbGrams: 28),
      PortionPreset(label: 'L', grams: 600, carbGrams: 42),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f040',
    nameAr: 'مقلوبة',
    nameEn: 'Maqluba (upside-down rice)',
    category: 'Mixed meals',
    portions: [
      PortionPreset(label: 'S', grams: 200, carbGrams: 45),
      PortionPreset(label: 'M', grams: 350, carbGrams: 79),
      PortionPreset(label: 'L', grams: 500, carbGrams: 113),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f041',
    nameAr: 'لقيمات',
    nameEn: 'Luqaimat (sweet dumplings)',
    category: 'Desserts',
    portions: [
      PortionPreset(label: 'S', grams: 30, carbGrams: 15),
      PortionPreset(label: 'M', grams: 60, carbGrams: 30),
      PortionPreset(label: 'L', grams: 100, carbGrams: 50),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f042',
    nameAr: 'مهلبية',
    nameEn: 'Mehalabiya (milk pudding)',
    category: 'Desserts',
    portions: [
      PortionPreset(label: 'S', grams: 80, carbGrams: 14),
      PortionPreset(label: 'M', grams: 150, carbGrams: 26),
      PortionPreset(label: 'L', grams: 225, carbGrams: 39),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f043',
    nameAr: 'قطايف',
    nameEn: 'Qatayef (stuffed pancake)',
    category: 'Desserts',
    portions: [
      PortionPreset(label: 'S', grams: 40, carbGrams: 20),
      PortionPreset(label: 'M', grams: 80, carbGrams: 40),
      PortionPreset(label: 'L', grams: 120, carbGrams: 60),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f044',
    nameAr: 'لبنة',
    nameEn: 'Labneh (strained yogurt)',
    category: 'Dairy',
    portions: [
      PortionPreset(label: 'S', grams: 30, carbGrams: 1),
      PortionPreset(label: 'M', grams: 60, carbGrams: 2),
      PortionPreset(label: 'L', grams: 100, carbGrams: 4),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f045',
    nameAr: 'جبنة عكاوي / نابلسية',
    nameEn: 'Akkawi / Nabulsi cheese',
    category: 'Dairy',
    portions: [
      PortionPreset(label: 'S', grams: 30, carbGrams: 1),
      PortionPreset(label: 'M', grams: 60, carbGrams: 2),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f046',
    nameAr: 'عدس أحمر',
    nameEn: 'Red lentils (dry)',
    category: 'Legumes',
    portions: [
      PortionPreset(label: 'S', grams: 50, carbGrams: 25),
      PortionPreset(label: 'M', grams: 100, carbGrams: 50),
      PortionPreset(label: 'L', grams: 150, carbGrams: 75),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
  FoodItem(
    id: 'f047',
    nameAr: 'سميد',
    nameEn: 'Semolina flour',
    category: 'Grains',
    portions: [
      PortionPreset(label: 'S', grams: 30, carbGrams: 20),
      PortionPreset(label: 'M', grams: 60, carbGrams: 40),
      PortionPreset(label: 'L', grams: 100, carbGrams: 67),
    ],
    sources: [
      CarbSource(name: 'USDA FoodData Central', url: _usda),
    ],
  ),
];
