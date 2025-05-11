import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dietary_preferences.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(DietaryPreferences) onFilterChanged;
  final DietaryPreferences? initialFilters;

  const CustomSearchBar({
    Key? key,
    required this.onSearch,
    required this.onFilterChanged,
    this.initialFilters,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFilterExpanded = false;
  late DietaryPreferences _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters ??
        DietaryPreferences(
          types: [],
          allergies: [],
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Поиск блюд...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () {
                            setState(() {
                              _isFilterExpanded = !_isFilterExpanded;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      onChanged: widget.onSearch,
                    ),
                  ),
                ],
              ),
              if (_isFilterExpanded) ...[
                const SizedBox(height: 16),
                _buildFilters(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Фильтры',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
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
                widget.onFilterChanged(_filters);
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Максимальная калорийность: ${_filters.maxCalories ?? 2000} ккал',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _filters = DietaryPreferences(
                    types: [],
                    allergies: [],
                  );
                });
                widget.onFilterChanged(_filters);
              },
              tooltip: 'Сбросить фильтры',
            ),
          ],
        ),
        Slider(
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
            widget.onFilterChanged(_filters);
          },
        ),
      ],
    );
  }
} 