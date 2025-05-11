import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dietary_preferences.dart';

class DietaryPreferencesScreen extends StatefulWidget {
  const DietaryPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<DietaryPreferencesScreen> createState() => _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState extends State<DietaryPreferencesScreen> {
  final List<DietaryType> _selectedTypes = [];
  final List<String> _allergies = [];
  int? _maxCalories;
  bool _excludeSpicy = false;
  bool _excludeNuts = false;
  bool _excludeSeafood = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Диетические предпочтения',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Типы питания',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DietaryType.values.map((type) {
                final isSelected = _selectedTypes.contains(type);
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
                        _selectedTypes.add(type);
                      } else {
                        _selectedTypes.remove(type);
                      }
                    });
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
            const SizedBox(height: 24),
            Text(
              'Аллергии',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Орехи',
                'Молоко',
                'Яйца',
                'Рыба',
                'Морепродукты',
                'Соя',
                'Пшеница',
                'Глютен',
                'Арахис',
                'Кунжут',
              ].map((allergy) {
                final isSelected = _allergies.contains(allergy);
                return FilterChip(
                  label: Text(
                    allergy,
                    style: GoogleFonts.roboto(
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _allergies.add(allergy);
                      } else {
                        _allergies.remove(allergy);
                      }
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.red,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Максимальное количество калорий',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _maxCalories?.toDouble() ?? 2000,
              min: 500,
              max: 3000,
              divisions: 25,
              label: '${_maxCalories ?? 2000} ккал',
              onChanged: (value) {
                setState(() {
                  _maxCalories = value.round();
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Исключения',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                'Исключить острую пищу',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                ),
              ),
              value: _excludeSpicy,
              onChanged: (value) {
                setState(() {
                  _excludeSpicy = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(
                'Исключить орехи',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                ),
              ),
              value: _excludeNuts,
              onChanged: (value) {
                setState(() {
                  _excludeNuts = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(
                'Исключить морепродукты',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                ),
              ),
              value: _excludeSeafood,
              onChanged: (value) {
                setState(() {
                  _excludeSeafood = value;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final preferences = DietaryPreferences(
                    types: _selectedTypes,
                    allergies: _allergies,
                    maxCalories: _maxCalories,
                    excludeSpicy: _excludeSpicy,
                    excludeNuts: _excludeNuts,
                    excludeSeafood: _excludeSeafood,
                  );
                  // TODO: Сохранить предпочтения
                  Navigator.pop(context, preferences);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Сохранить',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 