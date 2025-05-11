import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dietary_preferences.dart';
import 'search_filters_modal.dart';

class SearchBarWithFilters extends StatefulWidget {
  final Function(String) onSearch;
  final Function(DietaryPreferences) onFiltersChanged;
  final DietaryPreferences? initialFilters;
  final String? hintText;

  const SearchBarWithFilters({
    Key? key,
    required this.onSearch,
    required this.onFiltersChanged,
    this.initialFilters,
    this.hintText,
  }) : super(key: key);

  @override
  State<SearchBarWithFilters> createState() => _SearchBarWithFiltersState();
}

class _SearchBarWithFiltersState extends State<SearchBarWithFilters> {
  final TextEditingController _searchController = TextEditingController();
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
    return Container(
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
                    hintText: widget.hintText ?? 'Поиск блюд...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        SearchFiltersModal.show(
                          context: context,
                          initialFilters: _filters,
                          onFiltersChanged: (filters) {
                            setState(() {
                              _filters = filters;
                            });
                            widget.onFiltersChanged(filters);
                          },
                        );
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
          if (_filters.types.isNotEmpty || _filters.maxCalories != null) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_filters.types.isNotEmpty)
                    ..._filters.types.map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(
                            type.getName(),
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: type.getColor(),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                          onDeleted: () {
                            setState(() {
                              _filters = _filters.copyWith(
                                types: _filters.types.where((t) => t != type).toList(),
                              );
                            });
                            widget.onFiltersChanged(_filters);
                          },
                        ),
                      );
                    }),
                  if (_filters.maxCalories != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(
                          'До ${_filters.maxCalories} ккал',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        deleteIcon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                        onDeleted: () {
                          setState(() {
                            _filters = _filters.copyWith(maxCalories: null);
                          });
                          widget.onFiltersChanged(_filters);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
} 