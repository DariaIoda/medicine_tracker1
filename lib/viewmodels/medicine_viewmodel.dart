import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';

class MedicineViewModel extends ChangeNotifier {
  List<Medicine> _medicines = [];
  List<DrugInteraction> _interactions = [];
  String? _warningMessage;
  bool _isLoading = true;

  List<Medicine> get medicines => _medicines;
  String? get warningMessage => _warningMessage;
  bool get isLoading => _isLoading;

  MedicineViewModel() {
    loadData();
  }

  // Комплексная инициализация при старте приложения
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    await loadInteractions();
    await loadMedicines();

    _isLoading = false;
    notifyListeners();
  }

  // 1. Загрузка матрицы несовместимости из статического JSON-файла (Лаб. работа №3)
  Future<void> loadInteractions() async {
    try {
      final String response = await rootBundle.loadString('assets/interactions.json');
      final data = json.decode(response) as List;
      _interactions = data.map((e) => DrugInteraction.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Ошибка загрузки JSON несовместимости: $e");
    }
  }

  // 2. Загрузка сохраненных пользователем лекарств из локального хранилища
  Future<void> loadMedicines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? medicinesString = prefs.getString('saved_medicines');
      if (medicinesString != null) {
        final List decodedData = json.decode(medicinesString);
        _medicines = decodedData.map((e) => Medicine.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Ошибка чтения локальной базы: $e");
    }
  }

  // 3. Сохранение списка лекарств в локальное хранилище
  Future<void> _saveMedicines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(_medicines.map((e) => e.toJson()).toList());
      await prefs.setString('saved_medicines', encodedData);
      debugPrint("Данные успешно сохранены в SharedPreferences!");
    } catch (e) {
      debugPrint("Ошибка записи в локальную базу: $e");
    }
  }

  // Проверка и добавление с учетом матрицы конфликтов (Лаб. работа №4)
  bool validateAndAddMedicine(Medicine newMed) {
    _warningMessage = null;

    for (var existing in _medicines) {
      for (var interaction in _interactions) {
        bool conflict = (existing.name.toLowerCase().contains(interaction.substanceA.toLowerCase()) &&
                         newMed.name.toLowerCase().contains(interaction.substanceB.toLowerCase())) ||
                        (existing.name.toLowerCase().contains(interaction.substanceB.toLowerCase()) &&
                         newMed.name.toLowerCase().contains(interaction.substanceA.toLowerCase()));
        
        if (conflict) {
          _warningMessage = 'Внимание! Конфликт: ${newMed.name} несовместим с ${existing.name}. (${interaction.description})';
          notifyListeners();
          return false; // Блокируем добавление опасного препарата
        }
      }
    }

    _medicines.add(newMed);
    _saveMedicines(); // Сохраняем изменения на диск
    notifyListeners();
    return true;
  }

  // Удаление лекарства
  void deleteMedicine(String id) {
    _medicines.removeWhere((med) => med.id == id);
    _saveMedicines(); // Сохраняем изменения на диск
    notifyListeners();
  }

  // Редактирование существующего препарата
  void updateMedicine(Medicine updatedMed) {
    final index = _medicines.indexWhere((m) => m.id == updatedMed.id);
    if (index != -1) {
      _medicines[index] = updatedMed;
      _saveMedicines();
      notifyListeners();
    }
  }
}