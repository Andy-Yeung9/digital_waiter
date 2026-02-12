import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/start_screen.dart';
import 'dev/seed_menu_categories.dart';
import 'dev/seed_menu_items.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  print('Firebase initialized');
  try {
    await MenuCategoriesSeeder.seedBurgersAndSteakCategories();
    print('Seeded/updated MenuCategories (Burgers + Steak)');
    await MenuItemsSeeder.seedAllCurrentBurgers();
    print('Seeded current burgers into MenuItems');
    await MenuItemsSeeder.seedAllCurrentSteaks();
    print('Seeded current steaks into MenuItems');
  } catch (e, st) {
    print('Seeding failed: $e');
    print(st);
  }


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Waiter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartScreen(), //  new entry point
    );
  }
}


