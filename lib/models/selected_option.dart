class SelectedOption {
  final String name;
  final List<SelectedChoice> choices;

  SelectedOption({
    required this.name,
    required this.choices,
  });

  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(
      name: json['name'] as String,
      choices: (json['choices'] as List)
          .map((e) => SelectedChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'choices': choices.map((e) => e.toJson()).toList(),
    };
  }
}

class SelectedChoice {
  final String name;
  final double price;

  SelectedChoice({
    required this.name,
    required this.price,
  });

  factory SelectedChoice.fromJson(Map<String, dynamic> json) {
    return SelectedChoice(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
} 