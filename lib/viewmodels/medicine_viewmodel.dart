import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/medicine.dart';

class MedicineViewModel extends ChangeNotifier {
  List<Medicine> _medicines = [];
  List<DrugInteraction> _interactions = [];
  String? _warningMessage;

  List<Medicine> get medicines => _medicines;
  String? get warningMessage => _warningMessage;

  // Загрузка JSON-матрицы несовместимости (Лаб. работа №3)
  Future<void> loadInteractions() async {
    try {
      final String response = await rootBundle.loadString('assets/interactions.json');
      final data = await json.decode(response) as List;
      _interactions = data.map((e) => DrugInteraction.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Ошибка загрузки JSON: $e");
    }
  }

  // Проверка через потоки/логику Combine-подобного подхода (Лаб. работа №4)
  bool validateAndAddMedicine(Medicine newMed) {
    _warningMessage = null;

    // Проверяем по матрице несовместимости
    for (var existing in _medicines) {
      for (var interaction in _interactions) {
        bool conflict = (existing.name.toLowerCase().contains(interaction.substanceA.toLowerCase()) &&
                         newMed.name.toLowerCase().contains(interaction.substanceB.toLowerCase())) ||
                        (existing.name.toLowerCase().contains(interaction.substanceB.toLowerCase()) &&
                         newMed.name.toLowerCase().contains(interaction.substanceA.toLowerCase()));
        
        if (conflict) {
          _warningMessage = 'Критический конфликт! ${newMed.name} несовместим с ${existing.name}: ${interaction.description}';
          notifyListeners();
          return false; // Блокируем добавление
        }
      }
    }

    _medicines.add(newMed);
    notifyListeners();
    return true;
  }

  void deleteMedicine(String id) {
    _medicines.removeWhere((med) => med.id == id);
    notifyListeners();
  }
}