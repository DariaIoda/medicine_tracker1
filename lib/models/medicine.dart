// import 'dart:convert';

class Medicine {
  final String id;
  final String name;
  final int quantity;
  final String dosage;
  final String form; // 'таблетки', 'сиропы'
  final DateTime expiryDate;
  final String instructions;

  Medicine({
    required this.id,
    required this.name,
    required this.quantity,
    required this.dosage,
    required this.form,
    required this.expiryDate,
    required this.instructions,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'dosage': dosage,
    'form': form,
    'expiryDate': expiryDate.toIso8601String(),
    'instructions': instructions,
  };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json['id'],
    name: json['name'],
    quantity: json['quantity'],
    dosage: json['dosage'],
    form: json['form'],
    expiryDate: DateTime.parse(json['expiryDate']),
    instructions: json['instructions'],
  );
}

class DrugInteraction {
  final String id;
  final String substanceA;
  final String substanceB;
  final String description;

  DrugInteraction({
    required this.id,
    required this.substanceA,
    required this.substanceB,
    required this.description,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) => DrugInteraction(
    id: json['id'],
    substanceA: json['substanceA'],
    substanceB: json['substanceB'],
    description: json['description'],
  );
}