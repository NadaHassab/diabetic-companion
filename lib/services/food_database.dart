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
    nameAr: 'كنافة نابلسية',
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
];
