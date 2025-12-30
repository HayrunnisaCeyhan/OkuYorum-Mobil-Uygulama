import 'package:flutter/material.dart';
import 'package:okuyorum/services/kitap.dart';
import 'anasayfa.dart';

class EklemeSayfasi extends StatefulWidget {
  const EklemeSayfasi({super.key});

  @override
  State<EklemeSayfasi> createState() => EklemeSayfasiState();
}

class EklemeSayfasiState extends State<EklemeSayfasi> {
  final TextEditingController _kitapAdiController = TextEditingController();
  final TextEditingController _yazarAdiController = TextEditingController();
  final TextEditingController _begenilenYerlerController =
      TextEditingController();
  final TextEditingController _begenilmeyenYerlerController =
      TextEditingController();
  final TextEditingController _okumaTarihiController = TextEditingController();

  String? errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _kitapAdiController.dispose();
    _yazarAdiController.dispose();
    _begenilenYerlerController.dispose();
    _begenilmeyenYerlerController.dispose();
    _okumaTarihiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.green),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _okumaTarihiController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> kitapEkle() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    if (_kitapAdiController.text.isEmpty ||
        _yazarAdiController.text.isEmpty ||
        _okumaTarihiController.text.isEmpty) {
      setState(() {
        errorMessage = "Lütfen zorunlu alanları doldurun.";
        _isLoading = false;
      });
      return;
    }

    try {
      await KitapService().kitapEkle(
        kitapAdi: _kitapAdiController.text,
        yazarAdi: _yazarAdiController.text,
        okumaTarihi: _okumaTarihiController.text,
        begenilenYerler: _begenilenYerlerController.text,
        begenilmeyenYerler: _begenilmeyenYerlerController.text,
      );

      if (!mounted) return;

      // ✅ SnackBar göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kitap başarıyla kaydedildi"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // ⏳ Kısa gecikme sonra yönlendir
      await Future.delayed(const Duration(milliseconds: 800));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Anasayfa()),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Ortak Tasarım Metodu (Label'ları yukarı taşır)
  InputDecoration _inputStyle(
    String label, {
    IconData? icon,
    bool isLong = false,
  }) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior:
          FloatingLabelBehavior.always, // Etiketi hep yukarıda tutar
      floatingLabelStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      alignLabelWithHint: isLong,
      prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
      border: const OutlineInputBorder(),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 255, 225, 1),
      body: GestureDetector(
        onTap: () => FocusScope.of(
          context,
        ).unfocus(), // Ekrana tıklayınca klavyeyi kapatır
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              TextField(
                controller: _kitapAdiController,
                decoration: _inputStyle('Kitap Adı'),
              ),
              const SizedBox(height: 25),

              TextField(
                controller: _yazarAdiController,
                decoration: _inputStyle('Yazar Adı'),
              ),
              const SizedBox(height: 25),

              TextField(
                controller: _okumaTarihiController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: _inputStyle(
                  'Okuma Tarihi',
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(height: 25),

              TextField(
                controller: _begenilenYerlerController,
                minLines: 4,
                maxLines: 6,
                decoration: _inputStyle('Beğenilen Yerler', isLong: true),
              ),
              const SizedBox(height: 25),

              TextField(
                controller: _begenilmeyenYerlerController,
                minLines: 4,
                maxLines: 6,
                decoration: _inputStyle('Beğenilmeyen Yerler', isLong: true),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : kitapEkle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'KİTABI EKLE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
