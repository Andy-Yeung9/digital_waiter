import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemsSeeder {
  const MenuItemsSeeder._();

  // Burgers category doc id from your MenuCategories screenshot.
  static const String burgersCategoryId = 'wmT1Eh89MEQp7fLQuRh7';
  // Steak category doc id from your MenuCategories screenshot.
  static const String steakCategoryId = 'Q8WvEQVQ7H5LYv6OsXam';

  static Map<String, double> _prices({
    required double single,
    double? mealSet,
  }) {
    final map = <String, double>{'single': single};
    if (mealSet != null) {
      map['mealSet'] = mealSet;
    }
    return map;
  }

  static String _storageDownloadUrl(String fileName) {
    return 'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-burgers%2F$fileName?alt=media';
  }

  static String _steakStorageDownloadUrl(String fileName) {
    return 'https://firebasestorage.googleapis.com/v0/b/digital-waiter-5dbd1.firebasestorage.app/o/menu_items-steaks%2F$fileName?alt=media';
  }

  static Future<void> _upsertMenuItem({
    required String categoryId,
    required String englishName,
    required Map<String, dynamic> data,
  }) async {
    final menuItems = FirebaseFirestore.instance.collection('MenuItems');
    final existing = await menuItems
        .where('categoryId', isEqualTo: categoryId)
        .where('nameTranslations.en', isEqualTo: englishName)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.set(data, SetOptions(merge: true));
      print('MenuItems seed: updated existing "$englishName".');
      return;
    }

    final doc = menuItems.doc();
    await doc.set({
      'itemId': doc.id,
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('MenuItems seed: inserted "$englishName" with id ${doc.id}.');
  }

  static Future<void> seedChickenBreastBurger() async {
    final data = <String, dynamic>{
      'categoryId': burgersCategoryId,
      'nameTranslations': {
        'en': 'Chicken Breast Burger',
        'fr': 'Burger au poulet',
        'hi': 'चिकन ब्रेस्ट बर्गर',
        'ur': 'چکن بریسٹ برگر',
        'man': '鸡胸肉汉堡',
      },
      'descriptionTranslations': {
        'en': 'Grilled chicken breast burger with crisp lettuce and house sauce.',
        'fr': 'Burger de poulet grille avec laitue croquante et sauce maison.',
        'hi': 'ग्रिल्ड चिकन ब्रेस्ट बर्गर, कुरकुरी लेट्यूस और हाउस सॉस के साथ।',
        'ur': 'گرلڈ چکن بریسٹ برگر، کرسپ لیٹس اور ہاؤس ساس کے ساتھ۔',
        'man': '炭烤鸡胸汉堡，配生菜和招牌酱。',
      },
      'prices': _prices(single: 250.0, mealSet: 400.0),
      'prepTimeMinutes': 12,
      'allergens': ['GLUTEN', 'EGGS', 'DAIRY'],
      'dietaryLabels': ['HALAL'],
      'availabilityStatus': 'Available',
      'specialFlag': 'None',
      'imageUrl': _storageDownloadUrl('chicken_breast-removebg-preview.png'),
      'isActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _upsertMenuItem(
      categoryId: burgersCategoryId,
      englishName: 'Chicken Breast Burger',
      data: data,
    );
  }

  static Future<void> seedFourMoreBurgers() async {
    final items = <Map<String, dynamic>>[
      {
        'englishName': 'Beef Burger',
        'data': {
          'categoryId': burgersCategoryId,
          'nameTranslations': {
            'en': 'Beef Burger',
            'fr': 'Burger au boeuf',
            'hi': 'बीफ बर्गर',
            'ur': 'بیف برگر',
            'man': '牛肉汉堡',
          },
          'descriptionTranslations': {
            'en':
                'Juicy grilled beef patty burger with cheddar, lettuce, tomato, and signature sauce.',
            'fr':
                'Burger au boeuf grille avec cheddar, laitue, tomate et sauce signature.',
            'hi':
                'रसदार ग्रिल्ड बीफ पैटी बर्गर, चेडर, लेट्यूस, टमाटर और सिग्नेचर सॉस के साथ।',
            'ur':
                'رسیلا گرلڈ بیف پیٹی برگر، چیڈر، لیٹس، ٹماٹر اور سگنیچر ساس کے ساتھ۔',
            'man': '多汁炭烤牛肉饼汉堡，配切达芝士、生菜、番茄和招牌酱。',
          },
          'prices': _prices(single: 350.0, mealSet: 450.0),
          'prepTimeMinutes': 14,
          'allergens': ['GLUTEN', 'EGGS', 'DAIRY', 'SESAME'],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl': _storageDownloadUrl('Beef_Burger.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Beyond Meat Plant-Based Patty',
        'data': {
          'categoryId': burgersCategoryId,
          'nameTranslations': {
            'en': 'Beyond Meat Plant-Based Patty',
            'fr': 'Galette vegetale Beyond Meat',
            'hi': 'बियॉन्ड मीट प्लांट-बेस्ड पैटी बर्गर',
            'ur': 'بیونڈ میٹ پلانٹ بیسڈ پیٹی برگر',
            'man': 'Beyond Meat 植物基肉饼汉堡',
          },
          'descriptionTranslations': {
            'en':
                'Plant-based patty burger with fresh vegetables and a light smoky sauce.',
            'fr':
                'Burger a base vegetale avec legumes frais et sauce fumee legere.',
            'hi':
                'प्लांट-बेस्ड पैटी बर्गर, ताजी सब्जियों और हल्की स्मोकी सॉस के साथ।',
            'ur':
                'پلانٹ بیسڈ پیٹی برگر، تازہ سبزیوں اور ہلکی اسموکی ساس کے ساتھ۔',
            'man': '植物基肉饼汉堡，搭配新鲜蔬菜和微烟熏酱。',
          },
          'prices': _prices(single: 300.0, mealSet: 400.0),
          'prepTimeMinutes': 12,
          'allergens': ['GLUTEN', 'SOY', 'SESAME'],
          'dietaryLabels': ['VEGETARIAN'],
          'availabilityStatus': 'Available',
          'specialFlag': 'ChefRecommendation',
          'imageUrl': _storageDownloadUrl('burger_veg-removebg-preview.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Teriyaki Chicken Thighs',
        'data': {
          'categoryId': burgersCategoryId,
          'nameTranslations': {
            'en': 'Teriyaki Chicken Thighs',
            'fr': 'Poulet teriyaki (cuisse)',
            'hi': 'तेरियाकी चिकन थाइज बर्गर',
            'ur': 'تیریاکی چکن تھائیز برگر',
            'man': '照烧鸡腿肉汉堡',
          },
          'descriptionTranslations': {
            'en':
                'Tender teriyaki glazed chicken thigh burger with crunchy slaw and sesame mayo.',
            'fr':
                'Burger de cuisse de poulet teriyaki avec salade croquante et mayo au sesame.',
            'hi':
                'टेंडर तेरियाकी ग्लेज्ड चिकन थाइज बर्गर, क्रंची स्लॉ और सेसमे मेयो के साथ।',
            'ur':
                'نرم تیریاکی گلیزڈ چکن تھائیز برگر، کرنچی سلا اور سیسمی میو کے ساتھ۔',
            'man': '照烧鸡腿肉汉堡，配爽脆蔬菜丝和芝麻蛋黄酱。',
          },
          'prices': _prices(single: 320.0, mealSet: 420.0),
          'prepTimeMinutes': 13,
          'allergens': ['GLUTEN', 'SOY', 'EGGS', 'SESAME'],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl': _storageDownloadUrl('Chicken_Teriyaki-removebg-preview.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Catfish Fillet',
        'data': {
          'categoryId': burgersCategoryId,
          'nameTranslations': {
            'en': 'Catfish Fillet',
            'fr': 'Filet de poisson-chat',
            'hi': 'कैटफिश फिलेट बर्गर',
            'ur': 'کیٹ فِش فِلیٹ برگر',
            'man': '鲶鱼柳汉堡',
          },
          'descriptionTranslations': {
            'en':
                'Crispy catfish fillet burger with tartar sauce, lettuce, and pickles.',
            'fr':
                'Burger au filet de poisson-chat croustillant avec sauce tartare, laitue et cornichons.',
            'hi':
                'क्रिस्पी कैटफिश फिलेट बर्गर, टार्टर सॉस, लेट्यूस और पिकल्स के साथ।',
            'ur':
                'کرسپی کیٹ فش فلیٹ برگر، ٹارٹر ساس، لیٹس اور اچار کے ساتھ۔',
            'man': '酥脆鲶鱼柳汉堡，配塔塔酱、生菜和酸黄瓜。',
          },
          'prices': _prices(single: 300.0, mealSet: 400.0),
          'prepTimeMinutes': 14,
          'allergens': ['GLUTEN', 'FISH', 'EGGS', 'DAIRY'],
          'dietaryLabels': ['PESCATARIAN'],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl': _storageDownloadUrl('fillet_burger-removebg-preview.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
    ];

    for (final item in items) {
      await _upsertMenuItem(
        categoryId: burgersCategoryId,
        englishName: item['englishName'] as String,
        data: item['data'] as Map<String, dynamic>,
      );
    }
  }

  static Future<void> seedAllCurrentBurgers() async {
    await seedChickenBreastBurger();
    await seedFourMoreBurgers();
  }

  static Future<void> seedAllCurrentSteaks() async {
    final items = <Map<String, dynamic>>[
      {
        'englishName': 'BBQ Chicken Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'BBQ Chicken Steak',
            'fr': 'Steak de poulet BBQ',
            'hi': 'बीबीक्यू चिकन स्टेक',
            'ur': 'بی بی کیو چکن اسٹیک',
            'man': '烧烤鸡排',
          },
          'descriptionTranslations': {
            'en':
                'Chargrilled chicken steak glazed with smoky BBQ sauce, served hot and juicy.',
            'fr':
                'Steak de poulet grille avec sauce BBQ fumee, servi chaud et juteux.',
            'hi': 'स्मोकी बीबीक्यू सॉस के साथ चारग्रिल्ड चिकन स्टेक।',
            'ur':
                'اسموکی بی بی کیو ساس کے ساتھ چارگرلڈ چکن اسٹیک، گرم اور رسیلا۔',
            'man': '炭烤鸡排配烟熏烧烤酱，鲜嫩多汁。',
          },
          'prices': _prices(single: 540.0, mealSet: 690.0),
          'prepTimeMinutes': 16,
          'allergens': ['SOY'],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl':
              _steakStorageDownloadUrl('BBQ_chicken-removebg-preview.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Chicken Breast Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'Chicken Breast Steak',
            'fr': 'Steak de blanc de poulet',
            'hi': 'चिकन ब्रेस्ट स्टेक',
            'ur': 'چکن بریسٹ اسٹیک',
            'man': '鸡胸肉排',
          },
          'descriptionTranslations': {
            'en':
                'Lean grilled chicken breast steak with light herb seasoning and pan jus.',
            'fr':
                'Steak de blanc de poulet grille, assaisonnement aux herbes et jus de cuisson.',
            'hi': 'हर्ब सीज़निंग के साथ ग्रिल्ड चिकन ब्रेस्ट स्टेक।',
            'ur':
                'ہلکی جڑی بوٹیوں کی سیزننگ کے ساتھ گرلڈ چکن بریسٹ اسٹیک۔',
            'man': '香草调味烤鸡胸肉排，清爽不腻。',
          },
          'prices': _prices(single: 560.0, mealSet: 710.0),
          'prepTimeMinutes': 15,
          'allergens': [],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl': _steakStorageDownloadUrl('Chicken_Breast.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Chicken Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'Chicken Steak',
            'fr': 'Steak de poulet',
            'hi': 'चिकन स्टेक',
            'ur': 'چکن اسٹیک',
            'man': '鸡排',
          },
          'descriptionTranslations': {
            'en':
                'Tender chicken steak seared and finished with house savory gravy.',
            'fr':
                'Steak de poulet tendre, saisi puis nappe de sauce maison savoureuse.',
            'hi': 'नरम चिकन स्टेक, हाउस सेवरी ग्रेवी के साथ।',
            'ur': 'نرم چکن اسٹیک، ہاؤس سیوری گریوی کے ساتھ۔',
            'man': '鲜嫩鸡排，搭配招牌咸香肉汁。',
          },
          'prices': _prices(single: 580.0, mealSet: 730.0),
          'prepTimeMinutes': 16,
          'allergens': ['DAIRY'],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl': _steakStorageDownloadUrl('Chicken_Steak.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Filet Mignon',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'Filet Mignon',
            'fr': 'Filet mignon',
            'hi': 'फिले मिग्नॉन',
            'ur': 'فِلے مِنیون',
            'man': '菲力牛排',
          },
          'descriptionTranslations': {
            'en':
                'Premium center-cut beef tenderloin, pan-seared for a buttery texture.',
            'fr':
                'Filet de boeuf premium, saisi a la poele pour une texture fondante.',
            'hi': 'प्रीमियम टेंडरलॉइन फिले, बटर जैसा मुलायम टेक्सचर।',
            'ur': 'پریمیم بیف ٹینڈرلوئن، پین سیئرڈ اور نہایت نرم۔',
            'man': '精选牛里脊，煎制后口感细嫩。',
          },
          'prices': _prices(single: 800.0, mealSet: 950.0),
          'prepTimeMinutes': 20,
          'allergens': ['DAIRY'],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'ChefRecommendation',
          'imageUrl': _steakStorageDownloadUrl('Fillet_Mignon.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'New York Strip Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'New York Strip Steak',
            'fr': 'Steak New York Strip',
            'hi': 'न्यू यॉर्क स्ट्रिप स्टेक',
            'ur': 'نیو یارک اسٹرپ اسٹیک',
            'man': '纽约客牛排',
          },
          'descriptionTranslations': {
            'en':
                'Classic strip steak with robust beef flavor and a crisp seared edge.',
            'fr':
                'Steak strip classique au gout boeuf prononce et bord croustillant.',
            'hi': 'क्लासिक स्ट्रिप स्टेक, गहरा बीफ फ्लेवर और क्रिस्प सीयर।',
            'ur': 'کلاسک اسٹرپ اسٹیک، بھرپور بیف ذائقہ اور خستہ سیئر۔',
            'man': '经典纽约客牛排，肉香浓郁，外层焦香。',
          },
          'prices': _prices(single: 780.0, mealSet: 930.0),
          'prepTimeMinutes': 19,
          'allergens': [],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl': _steakStorageDownloadUrl('NY_strip.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Peri Peri Chicken Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'Peri Peri Chicken Steak',
            'fr': 'Steak de poulet peri peri',
            'hi': 'पेरी पेरी चिकन स्टेक',
            'ur': 'پیری پیری چکن اسٹیک',
            'man': '香辣鸡排',
          },
          'descriptionTranslations': {
            'en':
                'Spicy peri peri marinated chicken steak, grilled for bold heat.',
            'fr':
                'Steak de poulet marine peri peri, grille pour une saveur epicee.',
            'hi': 'स्पाइसी पेरी पेरी मैरिनेड के साथ ग्रिल्ड चिकन स्टेक।',
            'ur': 'تیز پیری پیری میرینیڈ کے ساتھ گرلڈ چکن اسٹیک۔',
            'man': '秘制香辣腌料鸡排，炭烤风味十足。',
          },
          'prices': _prices(single: 570.0, mealSet: 720.0),
          'prepTimeMinutes': 16,
          'allergens': [],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl': _steakStorageDownloadUrl('Peri_Peri.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Roasted Pork Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'Roasted Pork Steak',
            'fr': 'Steak de porc roti',
            'hi': 'रोस्टेड पोर्क स्टेक',
            'ur': 'روسٹڈ پورک اسٹیک',
            'man': '烤猪排',
          },
          'descriptionTranslations': {
            'en':
                'Slow-roasted pork steak with pepper glaze and caramelized finish.',
            'fr':
                'Steak de porc roti lentement, glace au poivre et finition caramélisee.',
            'hi': 'धीमी आँच पर रोस्टेड पोर्क स्टेक, पेपर ग्लेज़ के साथ।',
            'ur': 'سلو روسٹڈ پورک اسٹیک، پیپر گلیز کے ساتھ۔',
            'man': '慢烤猪排，黑椒酱汁，表面微焦。',
          },
          'prices': _prices(single: 620.0, mealSet: 770.0),
          'prepTimeMinutes': 20,
          'allergens': ['SOY'],
          'dietaryLabels': [],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl': _steakStorageDownloadUrl('Roasted_Pork.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Salmon Fillet Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'Salmon Fillet Steak',
            'fr': 'Steak de filet de saumon',
            'hi': 'सैल्मन फिलेट स्टेक',
            'ur': 'سالمَن فِلیٹ اسٹیک',
            'man': '三文鱼菲力',
          },
          'descriptionTranslations': {
            'en':
                'Pan-seared salmon fillet steak with lemon herb butter and flaky texture.',
            'fr':
                'Filet de saumon saisi, beurre citron-herbes et texture fondante.',
            'hi': 'पैन-सीयर्ड सैल्मन फिलेट, लेमन हर्ब बटर के साथ।',
            'ur': 'پین سیئرڈ سالمَن فلیٹ، لیموں ہرب بٹر کے ساتھ۔',
            'man': '香煎三文鱼菲力，配柠檬香草黄油。',
          },
          'prices': _prices(single: 760.0, mealSet: 910.0),
          'prepTimeMinutes': 18,
          'allergens': ['FISH', 'DAIRY'],
          'dietaryLabels': ['PESCATARIAN'],
          'availabilityStatus': 'Available',
          'specialFlag': 'ChefRecommendation',
          'imageUrl': _steakStorageDownloadUrl('Salmon_fillet.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'T-Bone Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'T-Bone Steak',
            'fr': 'Steak T-bone',
            'hi': 'टी-बोन स्टेक',
            'ur': 'ٹی بون اسٹیک',
            'man': '丁骨牛排',
          },
          'descriptionTranslations': {
            'en':
                'Bone-in beef steak with rich marbling, grilled for deep flavor.',
            'fr':
                'Steak de boeuf avec os, bien persille, grille pour une saveur intense.',
            'hi': 'बोन-इन बीफ स्टेक, रिच मार्बलिंग और गहरा फ्लेवर।',
            'ur': 'بون اِن بیف اسٹیک، بہترین ماربلنگ اور بھرپور ذائقہ۔',
            'man': '带骨牛排，油花丰富，肉香浓郁。',
          },
          'prices': _prices(single: 790.0, mealSet: 940.0),
          'prepTimeMinutes': 21,
          'allergens': [],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'ChefRecommendation',
          'imageUrl':
              _steakStorageDownloadUrl('Tbone_steak-removebg-preview.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Chicken Supreme Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'Chicken Supreme Steak',
            'fr': 'Steak supreme de poulet',
            'hi': 'चिकन सुप्रीम स्टेक',
            'ur': 'چکن سپریم اسٹیک',
            'man': '至尊鸡排',
          },
          'descriptionTranslations': {
            'en':
                'Signature chicken steak topped with creamy mushroom pepper sauce.',
            'fr':
                'Steak de poulet signature avec sauce cremeuse champignon-poivre.',
            'hi': 'सिग्नेचर चिकन स्टेक, क्रीमी मशरूम पेपर सॉस के साथ।',
            'ur': 'سگنیچر چکن اسٹیک، کریمی مشروم پیپر ساس کے ساتھ۔',
            'man': '招牌鸡排，搭配奶香蘑菇黑椒酱。',
          },
          'prices': _prices(single: 610.0, mealSet: 760.0),
          'prepTimeMinutes': 17,
          'allergens': ['DAIRY'],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl':
              _steakStorageDownloadUrl('chicken_supreme-removebg-preview.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Chicken Teriyaki Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'Chicken Teriyaki Steak',
            'fr': 'Steak de poulet teriyaki',
            'hi': 'चिकन टेरियाकी स्टेक',
            'ur': 'چکن تیریاکی اسٹیک',
            'man': '照烧鸡排',
          },
          'descriptionTranslations': {
            'en':
                'Chicken steak glazed in teriyaki sauce with balanced sweet-savory taste.',
            'fr':
                'Steak de poulet glace sauce teriyaki, saveur sucree-salee equilibree.',
            'hi': 'टेरियाकी ग्लेज़ वाला चिकन स्टेक, स्वीट-सेवरी फ्लेवर।',
            'ur': 'تیریاکی گلیز کے ساتھ چکن اسٹیک، میٹھا اور نمکین متوازن ذائقہ۔',
            'man': '照烧酱鸡排，咸甜平衡。',
          },
          'prices': _prices(single: 590.0, mealSet: 740.0),
          'prepTimeMinutes': 16,
          'allergens': ['SOY'],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl':
              _steakStorageDownloadUrl(
                'chicken_teriyaki_steak-removebg-preview.png',
              ),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Ribeye Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'Ribeye Steak',
            'fr': 'Steak ribeye',
            'hi': 'रिबआई स्टेक',
            'ur': 'رب آئی اسٹیک',
            'man': '肉眼牛排',
          },
          'descriptionTranslations': {
            'en':
                'Well-marbled ribeye steak grilled to lock in rich, juicy flavor.',
            'fr':
                'Ribeye bien persille, grille pour conserver une saveur riche et juteuse.',
            'hi': 'मार्बल्ड रिबआई स्टेक, ग्रिल्ड और बेहद जूसी।',
            'ur': 'خوب ماربلڈ رب آئی اسٹیک، گرلڈ اور بھرپور رسیلا ذائقہ۔',
            'man': '油花丰富的肉眼牛排，烤后鲜嫩多汁。',
          },
          'prices': _prices(single: 800.0, mealSet: 950.0),
          'prepTimeMinutes': 20,
          'allergens': [],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'ChefRecommendation',
          'imageUrl':
              _steakStorageDownloadUrl('ribeye_steak-removebg-preview.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Shawarma Spiced Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'Shawarma Spiced Steak',
            'fr': 'Steak epice shawarma',
            'hi': 'शावरमा मसाला स्टेक',
            'ur': 'شاورما مصالحہ اسٹیک',
            'man': '沙威玛风味牛排',
          },
          'descriptionTranslations': {
            'en':
                'Steak seasoned with shawarma spices, grilled and finished with garlic sauce.',
            'fr':
                'Steak assaisonne aux epices shawarma, grille et fini sauce a l ail.',
            'hi': 'शावरमा मसालों वाला ग्रिल्ड स्टेक, गार्लिक सॉस के साथ।',
            'ur': 'شاورما مصالحے والا گرلڈ اسٹیک، گارلک ساس کے ساتھ۔',
            'man': '沙威玛香料调味牛排，搭配蒜香酱。',
          },
          'prices': _prices(single: 600.0, mealSet: 750.0),
          'prepTimeMinutes': 17,
          'allergens': ['EGGS'],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl':
              _steakStorageDownloadUrl('shawarma_steak-removebg-preview.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      {
        'englishName': 'Sirloin Steak',
        'data': {
          'categoryId': steakCategoryId,
          'nameTranslations': {
            'en': 'Sirloin Steak',
            'fr': 'Steak de surlonge',
            'hi': 'सिरलॉइन स्टेक',
            'ur': 'سرلائن اسٹیک',
            'man': '西冷牛排',
          },
          'descriptionTranslations': {
            'en':
                'Balanced cut sirloin steak with meaty bite and pepper-herb finish.',
            'fr':
                'Steak de surlonge equilibre, texture charnue et finition poivre-herbes.',
            'hi': 'संतुलित कट सिरलॉइन स्टेक, पेपर-हर्ब फिनिश के साथ।',
            'ur': 'متوازن کٹ سرلائن اسٹیک، پیپر ہرب فنش کے ساتھ۔',
            'man': '西冷牛排口感扎实，黑椒香草风味。',
          },
          'prices': _prices(single: 740.0, mealSet: 890.0),
          'prepTimeMinutes': 19,
          'allergens': [],
          'dietaryLabels': ['HALAL'],
          'availabilityStatus': 'Available',
          'specialFlag': 'None',
          'imageUrl':
              _steakStorageDownloadUrl('sirloin_steak-removebg-preview.png'),
          'isActive': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
    ];

    for (final item in items) {
      await _upsertMenuItem(
        categoryId: steakCategoryId,
        englishName: item['englishName'] as String,
        data: item['data'] as Map<String, dynamic>,
      );
    }
  }
}
