import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../viewmodels/medicine_viewmodel.dart';

class AddMedicineView extends StatefulWidget {
  final MedicineViewModel viewModel;
  final Medicine? medicineToEdit; // Если передан — режим редактирования

  const AddMedicineView({super.key, required this.viewModel, this.medicineToEdit});

  @override
  State<AddMedicineView> createState() => _AddMedicineViewState();
}

class _AddMedicineViewState extends State<AddMedicineView> {
  final _formKey = GlobalKey<FormState>();
  
  late String _name;
  late int _quantity;
  late String _dosage;
  late String _form;
  late String _instructions;
  late DateTime _expiryDate;

  @override
  void initState() {
    super.initState();
    // Инициализируем поля (если редактируем — старыми данными, если новый — пустыми)
    final med = widget.medicineToEdit;
    _name = med?.name ?? '';
    _quantity = med?.quantity ?? 10;
    _dosage = med?.dosage ?? '500 мг';
    _form = med?.form ?? 'таблетки';
    _instructions = med?.instructions ?? 'Принимать после еды';
    _expiryDate = med?.expiryDate ?? DateTime.now().add(const Duration(days: 180));
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.medicineToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать препарат' : 'Добавить препарат'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!isEditing) ...[
                ElevatedButton.icon(
                  onPressed: () {
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
              ],
              
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Коммерческое название препарата', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Введите название' : null,
                onChanged: (val) => _name = val,
              ),
              const SizedBox(height: 15),

              TextFormField(
                initialValue: _dosage,
                decoration: const InputDecoration(labelText: 'Дозировка (например, 500мг)', border: OutlineInputBorder()),
                onChanged: (val) => _dosage = val,
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: _form,
                decoration: const InputDecoration(labelText: 'Форма выпуска', border: OutlineInputBorder()),
                items: ['таблетки', 'сиропы']
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (val) => setState(() => _form = val!),
              ),
              const SizedBox(height: 15),

              TextFormField(
                initialValue: _quantity.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Остаток (количество упаковок)', border: OutlineInputBorder()),
                onChanged: (val) => _quantity = int.tryParse(val) ?? 1,
              ),
              const SizedBox(height: 15),

              TextFormField(
                initialValue: _instructions,
                decoration: const InputDecoration(labelText: 'Правила приема / инструкция', border: OutlineInputBorder()),
                onChanged: (val) => _instructions = val,
              ),
              const SizedBox(height: 25),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (isEditing) {
                      // Режим обновления
                      final updatedMed = Medicine(
                        id: widget.medicineToEdit!.id,
                        name: _name,
                        quantity: _quantity,
                        dosage: _dosage,
                        form: _form,
                        expiryDate: _expiryDate,
                        instructions: _instructions,
                      );
                      widget.viewModel.updateMedicine(updatedMed);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Препарат успешно изменен!')),
                      );
                    } else {
                      // Режим создания нового
                      final newMed = Medicine(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _name,
                        quantity: _quantity,
                        dosage: _dosage,
                        form: _form,
                        expiryDate: _expiryDate,
                        instructions: _instructions,
                      );

                      bool success = widget.viewModel.validateAndAddMedicine(newMed);

                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Препарат успешно добавлен в аптечку!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(widget.viewModel.warningMessage ?? 'Ошибка конфликта препаратов!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(isEditing ? 'Сохранить изменения' : 'Сохранить и проверить совместимость'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}