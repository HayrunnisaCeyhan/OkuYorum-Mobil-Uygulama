import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Hata yakalama için
import 'services/auth.dart'; // Kendi Auth hizmet sınıfınızı içe aktarın
import 'anasayfa.dart';
import 'kayit.dart';

// Firebase Auth Hizmet Sınıfı

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({super.key});

  @override
  State<GirisSayfasi> createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  // 💡 Kullanıcı girişi için Controller'lar tanımlandı
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 💡 Hata mesajlarını tutmak için
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🚀 Firebase ile giriş yapma işlemi
  Future<void> _signIn() async {
    try {
      await Auth().signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Başarılı girişten sonra Anasayfa'ya yönlendir
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Anasayfa()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Firebase'den gelen hataları yakala ve Türkçe mesaja çevir
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
          break;
        case 'wrong-password':
          message = 'Yanlış şifre. Lütfen tekrar deneyin.';
          break;
        case 'invalid-email':
          message = 'Geçersiz e-posta formatı.';
          break;
        default:
          message = 'Giriş başarısız: Bilinmeyen bir hata oluştu.';
      }
      setState(() {
        _errorMessage = message;
        _isLoading = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Giriş sırasında bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 255, 225, 1),
      body: SingleChildScrollView(
        // Padding'i dinamik boyutlara uyacak şekilde biraz düzenledim
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Yatayda yayılması için
          children: [
            // Logo
            Image.asset(
              'assets/images/okuyorumlogo.png',
              height: 350,
              width: 600,
            ),
            const SizedBox(height: 35),

            // E-posta Girişi (Kullanıcı Adı yerine E-posta kullanılmalı)
            TextField(
              controller: _emailController, // 💡 Controller bağlandı
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-posta Adresi', // 💡 E-posta olarak değiştirildi
                floatingLabelStyle: const TextStyle(color: Colors.green),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Şifre Girişi
            TextField(
              controller: _passwordController, // 💡 Controller bağlandı
              obscureText: true, // Şifreyi gizle
              decoration: InputDecoration(
                labelText: 'Şifre',
                floatingLabelStyle: const TextStyle(color: Colors.green),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
            ),

            // 💡 Hata Mesajı
            _errorMessage != null
                ? Text(_errorMessage!)
                : const SizedBox.shrink(),

            const SizedBox(height: 50),

            // GİRİŞ YAP Butonu
            ElevatedButton(
              // 🚀 OnPressed metodu Firebase girişini çağırır
              onPressed: _isLoading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(225, 255, 225, 1),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(
                    color: Colors.green,
                    width: 1.5,
                  ), // Çerçeve eklendi
                ),
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Boyutu büyütüldü
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : const Text(
                      'GİRİŞ YAP',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),

            const SizedBox(height: 20),

            // Kayıt Ol Linki
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Hesabın yok mu?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KayitSayfasi(),
                      ),
                    );
                  },
                  child: const Text(
                    'Kayıt Ol',
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
