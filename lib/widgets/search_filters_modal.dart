import 'package:flutter/material.dart';
import '../models/dietary_preferences.dart';
import 'search_filters.dart';

class SearchFiltersModal extends StatelessWidget {
  final DietaryPreferences initialFilters;
  final Function(DietaryPreferences) onFiltersChanged;

  const SearchFiltersModal({
    Key? key,
    required this.initialFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: SearchFilters(
                initialFilters: initialFilters,
                onFiltersChanged: onFiltersChanged,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Применить'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required DietaryPreferences initialFilters,
    required Function(DietaryPreferences) onFiltersChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFiltersModal(
        initialFilters: initialFilters,
        onFiltersChanged: onFiltersChanged,
      ),
    );
  }
} 