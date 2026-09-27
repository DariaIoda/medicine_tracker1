import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../viewmodels/medicine_viewmodel.dart';

class AddMedicineView extends StatefulWidget {
  final MedicineViewModel viewModel;

  const AddMedicineView({super.key, required this.viewModel});

  @override
  State<AddMedicineView> createState() => _AddMedicineViewState();
}

class _AddMedicineViewState extends State<AddMedicineView> {
  final _formKey = GlobalKey<FormState>();
  
  // Поля формы
  String _name = '';
  int _quantity = 10;
  String _dosage = '500 мг';
  String _form = 'таблетки'; // 'таблетки' или 'сиропы'
  String _instructions = 'Принимать после еды';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 180));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавление лекарства (Сканер / Ввод)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Кнопка имитации сканирования камеры (Требование Варианта 11)
              ElevatedButton.icon(
                onPressed: () {
                  // Имитируем успешное сканирование упаковки камерой
                  setState(() {
                    _name = 'Аспирин';
                    _dosage = '500мг';
                    _form = 'таблетки';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Камера распознала: Аспирин')),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Сканировать название с упаковки (Mock)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50]),
              ),
              const SizedBox(height: 20),
              
              // Поле названия
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Коммерческое название препарата', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Введите название' : null,
                onChanged: (val) => _name = val,
              ),
              const SizedBox(height: 15),

              // Поле дозировки
              TextFormField(
                initialValue: _dosage,
                decoration: const InputDecoration(labelText: 'Дозировка (например, 500мг)', border: OutlineInputBorder()),
                onChanged: (val) => _dosage = val,
              ),
              const SizedBox(height: 15),

              // Выбор формы выпуска
              DropdownButtonFormField<String>(
                value: _form,
                decoration: const InputDecoration(labelText: 'Форма выпуска', border: OutlineInputBorder()),
                items: ['таблетки', 'сиропы']
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (val) => setState(() => _form = val!),
              ),
              const SizedBox(height: 15),

              // Количество
              TextFormField(
                initialValue: _quantity.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Остаток (количество упаковок)', border: OutlineInputBorder()),
                onChanged: (val) => _quantity = int.tryParse(val) ?? 1,
              ),
              const SizedBox(height: 15),

              // Инструкция
              TextFormField(
                initialValue: _instructions,
                decoration: const InputDecoration(labelText: 'Правила приема / инструкция', border: OutlineInputBorder()),
                onChanged: (val) => _instructions = val,
              ),
              const SizedBox(height: 25),

              // Кнопка сохранения
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newMed = Medicine(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _name,
                      quantity: _quantity,
                      dosage: _dosage,
                      form: _form,
                      expiryDate: _expiryDate,
                      instructions: _instructions,
                    );

                    // Проводим через валидатор несовместимости ( Combine-подобный поток )
                    bool success = widget.viewModel.validateAndAddMedicine(newMed);

                    if (success) {
                      Navigator.pop(context); // Возвращаемся на главный экран
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Препарат успешно добавлен в аптечку!')),
                      );
                    } else {
                      // Ошибка конфликта показана во ViewModel, выводим диалог или снекбар
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.viewModel.warningMessage ?? 'Ошибка конфликта препаратов!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Сохранить и проверить совместимость'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}