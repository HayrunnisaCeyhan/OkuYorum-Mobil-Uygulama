import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth.dart';
import 'anasayfa.dart';
import 'giris.dart'; // Giriş sayfasına geri yönlendirmek için

// Firebase Auth Hizmet Sınıfı örneği (aynı Auth sınıfını kullanır)
final Auth _authService = Auth();

class KayitSayfasi extends StatefulWidget {
  const KayitSayfasi({super.key});

  @override
  State<KayitSayfasi> createState() => KayitSayfasiState();
}

class KayitSayfasiState extends State<KayitSayfasi> {
  // 💡 1. E-posta, Şifre ve Şifre Tekrarı için Controller'lar tanımlandı
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController(); // Yeni Controller

  String? errorMessage;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Yeni Controller'ı dispose et
    super.dispose();
  }

  Future<void> createUser() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    // 🚀 Kontrol 1: Şifreler Eşleşiyor mu?
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Şifreler eşleşmiyor. Lütfen kontrol edin.';
        isLoading = false;
      });
      return; // Kayıt işlemini durdur
    }

    try {
      await _authService.createUser(
        // Auth sınıfındaki createUser metodunu kullanıyoruz
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Başarılı kayıttan sonra Anasayfa'ya yönlendir
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Anasayfa()),
        );
      }
    }
    // 🚀 Hata Yakalama Düzeltmesi: Kayıt hatalarını yakala
    on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Şifre çok zayıf. En az 6 karakter olmalıdır.';
          break;
        case 'email-already-in-use':
          message = 'Bu e-posta adresi zaten kullanılıyor.';
          break;
        case 'invalid-email':
          message = 'Geçersiz e-posta formatı.';
          break;
        default:
          message = 'Kayıt başarısız: Bilinmeyen bir hata oluştu. (${e.code})';
      }
      setState(() {
        errorMessage = message;
      });
    } catch (e) {
      // Genel hatalar için
      setState(() {
        errorMessage = 'Kayıt sırasında beklenmeyen bir hata oluştu.';
        print('Kayıt Hata Detayı: $e');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 255, 225, 1),
      appBar: AppBar(
        title: const Text(" "),
        titleTextStyle: TextStyle(
          color: Color.fromRGBO(106, 159, 32, 1),
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        backgroundColor: Color.fromRGBO(225, 255, 225, 1),
        elevation: 0.8,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo (küçük boyutlandırma ile daha uyumlu)
            Image.asset(
              'assets/images/okuyorumlogo.png',
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 35),

            // E-posta Girişi
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta Adresi',
                floatingLabelStyle: TextStyle(color: Colors.green),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Şifre Girişi
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre ',
                floatingLabelStyle: TextStyle(color: Colors.green),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 💡 Şifre Tekrarı Girişi
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre Tekrarı',
                floatingLabelStyle: TextStyle(color: Colors.green),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),

            // Hata Mesajı
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 50),

            // KAYIT OL Butonu
            ElevatedButton(
              onPressed: isLoading ? null : createUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(225, 255, 225, 1),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: Colors.green, width: 1.5),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : const Text(
                      'KAYIT OL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),

            const SizedBox(height: 20),

            // Giriş Yap Linki
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Zaten bir hesabın var mı?"),
                TextButton(
                  onPressed: () {
                    // Kayıt sayfasını kapatıp Giriş sayfasına dön (pop kullanmak daha verimli)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GirisSayfasi(),
                      ),
                    );
                  },
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
