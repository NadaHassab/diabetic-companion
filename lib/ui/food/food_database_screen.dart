import 'package:flutter/material.dart';
import 'package:diabetic_companion/models/food_item.dart';
import 'package:diabetic_companion/services/food_database.dart';

class FoodDatabaseScreen extends StatefulWidget {
  const FoodDatabaseScreen({super.key});

  @override
  State<FoodDatabaseScreen> createState() => _FoodDatabaseScreenState();
}

class _FoodDatabaseScreenState extends State<FoodDatabaseScreen> {
  String _query = '';
  String _selectedCategory = 'All';
  final Set<String> _favorites = {};

  List<String> get _categories {
    final cats = defaultFoods.map((f) => f.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<FoodItem> get _filtered {
    var list = defaultFoods;
    if (_selectedCategory != 'All') {
      list = list.where((f) => f.category == _selectedCategory).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((f) =>
              f.nameEn.toLowerCase().contains(q) ||
              f.nameAr.contains(q) ||
              f.category.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Food Database')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No foods found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) =>
                        _foodCard(_filtered[i], theme),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _foodCard(FoodItem food, ThemeData theme) {
    final isFav = _favorites.contains(food.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showFoodDetail(food),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(food.nameAr,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food.nameEn,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(food.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (food.portions.isNotEmpty)
                Text(
                  '${food.portions.first.carbGrams.toStringAsFixed(0)}g carbs',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? theme.colorScheme.error : null,
                ),
                onPressed: () => setState(() {
                  if (isFav) {
                    _favorites.remove(food.id);
                  } else {
                    _favorites.add(food.id);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFoodDetail(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: .3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(food.nameAr,
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text(food.nameEn,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Text(food.category,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 20),
            Text('Portions & Carbs',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...food.portions.map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(p.label,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      Expanded(child: Text('${p.grams.toStringAsFixed(0)}g')),
                      Text('${p.carbGrams.toStringAsFixed(0)}g carbs',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
            if (food.sources.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Sources',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              for (final src in food.sources)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(src.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary)),
                ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Carb values are estimates based on published data. '
                'Actual values vary by brand, preparation, and portion size. '
                'Use these as starting points and adjust based on your personal response.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
