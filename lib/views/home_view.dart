import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../../viewmodels/medicine_viewmodel.dart';
import 'add_medicine_view.dart';

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMedicineView(viewModel: _viewModel),
            ),
          );
        },
      child: const Icon(Icons.add),
      ),
    );
  }
}