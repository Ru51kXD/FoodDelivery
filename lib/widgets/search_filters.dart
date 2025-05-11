import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dietary_preferences.dart';

class SearchFilters extends StatefulWidget {
  final DietaryPreferences initialFilters;
  final Function(DietaryPreferences) onFiltersChanged;

  const SearchFilters({
    Key? key,
    required this.initialFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<SearchFilters> createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {
  late DietaryPreferences _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Фильтры',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _filters = DietaryPreferences(
                      types: [],
                      allergies: [],
                    );
                  });
                  widget.onFiltersChanged(_filters);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Сбросить'),
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Типы блюд',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DietaryType.values.map((type) {
                  final isSelected = _filters.types.contains(type);
                  return FilterChip(
                    label: Text(
                      type.getName(),
                      style: GoogleFonts.roboto(
                        color: isSelected ? Colors.white : type.getColor(),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _filters = _filters.copyWith(
                            types: [..._filters.types, type],
                          );
                        } else {
                          _filters = _filters.copyWith(
                            types: _filters.types.where((t) => t != type).toList(),
                          );
                        }
                      });
                      widget.onFiltersChanged(_filters);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: type.getColor(),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: type.getColor(),
                      width: 1,
                    ),
                    avatar: Icon(
                      type.getIcon(),
                      size: 16,
                      color: isSelected ? Colors.white : type.getColor(),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Максимальная калорийность',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _filters.maxCalories?.toDouble() ?? 2000,
                      min: 500,
                      max: 3000,
                      divisions: 25,
                      label: '${_filters.maxCalories ?? 2000} ккал',
                      onChanged: (value) {
                        setState(() {
                          _filters = _filters.copyWith(
                            maxCalories: value.round(),
                          );
                        });
                        widget.onFiltersChanged(_filters);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_filters.maxCalories ?? 2000} ккал',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Исключения',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Исключить острое'),
                value: _filters.excludeSpicy ?? false,
                onChanged: (value) {
                  setState(() {
                    _filters = _filters.copyWith(excludeSpicy: value);
                  });
                  widget.onFiltersChanged(_filters);
                },
              ),
              SwitchListTile(
                title: const Text('Исключить орехи'),
                value: _filters.excludeNuts ?? false,
                onChanged: (value) {
                  setState(() {
                    _filters = _filters.copyWith(excludeNuts: value);
                  });
                  widget.onFiltersChanged(_filters);
                },
              ),
              SwitchListTile(
                title: const Text('Исключить морепродукты'),
                value: _filters.excludeSeafood ?? false,
                onChanged: (value) {
                  setState(() {
                    _filters = _filters.copyWith(excludeSeafood: value);
                  });
                  widget.onFiltersChanged(_filters);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
} 