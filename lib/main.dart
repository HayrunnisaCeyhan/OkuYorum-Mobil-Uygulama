import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core'u içe aktar
import 'package:okuyorum/giris.dart';

// import 'firebase_options.dart'; // Eğer flutterfire configure komutunu kullandıysanız

void main() async {
  // 💡 Flutter'ı başlatmadan önce bu satır zorunludur.
  WidgetsFlutterBinding.ensureInitialized();

  // 💡 Firebase uygulamasını başlatma komutu
  // Eğer flutterfire configure komutunu başarılı çalıştırdıysanız,
  // options kısmını kullanmalısınız. Şu an sade bırakıyoruz.
  try {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform, // Eğer dosya varsa kullanın
    );
  } catch (e) {
    // Başlatma başarısız olursa konsola yazdır
    print("Firebase başlatma hatası: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Okuyorum',
      home: const GirisSayfasi(),
    );
  }
}
