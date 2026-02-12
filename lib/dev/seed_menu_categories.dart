import 'package:cloud_firestore/cloud_firestore.dart';

class MenuCategoriesSeeder {
  const MenuCategoriesSeeder._();

  // Existing burgers category doc id from your Firestore screenshot.
  static const String burgersCategoryId = 'wmT1Eh89MEQp7fLQuRh7';
  // Existing steak category doc id from your Firestore screenshot.
  static const String steakCategoryId = 'Q8WvEQVQ7H5LYv6OsXam';

  static Future<void> _upsertCategory({
    required String docId,
    required int sortOrder,
    required Map<String, String> nameTranslations,
  }) async {
    final ref = FirebaseFirestore.instance.collection('MenuCategories').doc(docId);
    final snapshot = await ref.get();

    await ref.set({
      'isActive': true,
      'nameTranslations': nameTranslations,
      'sortOrder': sortOrder,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> seedBurgersAndSteakCategories() async {
    await _upsertCategory(
      docId: burgersCategoryId,
      sortOrder: 1,
      nameTranslations: const {
        'en': 'Burgers',
        'fr': 'Burgers',
        'hi': 'बर्गर',
        'ur': 'برگر',
        'man': '汉堡',
      },
    );

    await _upsertCategory(
      docId: steakCategoryId,
      sortOrder: 2,
      nameTranslations: const {
        'en': 'Steak',
        'fr': 'Steak',
        'hi': 'स्टेक',
        'ur': 'اسٹیک',
        'man': '牛排',
      },
    );
  }
}
