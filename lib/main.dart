import 'package:flutter/material.dart';
import 'views/home_view.dart'; // Импортируем HomeView из lib/models/

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MedicineTrackerApp());
}

class MedicineTrackerApp extends StatelessWidget {
  const MedicineTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Контроль домашней аптечки',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}