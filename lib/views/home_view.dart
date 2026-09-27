import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../../viewmodels/medicine_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final MedicineViewModel _viewModel = MedicineViewModel();
  String _selectedFilter = 'Все';

  @override
  void initState() {
    super.initState();
    _viewModel.loadInteractions();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Домашняя аптечка'),
        actions: [
          DropdownButton<String>(
            value: _selectedFilter,
            items: ['Все', 'таблетки', 'сиропы']
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (val) => setState(() => _selectedFilter = val!),
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          final filteredList = _viewModel.medicines.where((m) {
            if (_selectedFilter == 'Все') return true;
            return m.form == _selectedFilter;
          }).toList();

          return Column(
            children: [
              if (_viewModel.warningMessage != null)
                Container(
                  color: Colors.red[100],
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _viewModel.warningMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final med = filteredList[index];
                    return ListTile(
                      title: Text(med.name),
                      subtitle: Text('Форма: ${med.form} | Остаток: ${med.quantity} шт.'),
                      trailing: Text(med.expiryDate.toString().split(' ')[0]),
                      onLongPress: () => _viewModel.deleteMedicine(med.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Пример добавления препарата для демонстрации
          bool success = _viewModel.validateAndAddMedicine(
            Medicine(
              id: DateTime.now().toString(),
              name: 'Аспирин',
              quantity: 20,
              dosage: '500мг',
              form: 'таблетки',
              expiryDate: DateTime.now().add(const Duration(days: 100)),
              instructions: 'Принимать после еды',
            ),
          );
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Препарат успешно добавлен!')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}