import 'package:flutter/material.dart';
import 'models/bookModel.dart';
import 'services/kitap.dart';

class KitapGuncelleSayfasi extends StatefulWidget {
  final BookModel kitap;

  const KitapGuncelleSayfasi({super.key, required this.kitap});

  @override
  State<KitapGuncelleSayfasi> createState() => _KitapGuncelleSayfasiState();
}

class _KitapGuncelleSayfasiState extends State<KitapGuncelleSayfasi> {
  late TextEditingController _kitapAdiController;
  late TextEditingController _yazarAdiController;
  late TextEditingController _begenilenController;
  late TextEditingController _begenilmeyenController;
  late TextEditingController _okumaTarihiController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _kitapAdiController = TextEditingController(text: widget.kitap.kitapAdi);
    _yazarAdiController = TextEditingController(text: widget.kitap.yazarAdi);
    _begenilenController = TextEditingController(
      text: widget.kitap.begenilenYerler,
    );
    _begenilmeyenController = TextEditingController(
      text: widget.kitap.begenilmeyenYerler,
    );
    _okumaTarihiController = TextEditingController(
      text: widget.kitap.okumaTarihi,
    );
  }

  @override
  void dispose() {
    _kitapAdiController.dispose();
    _yazarAdiController.dispose();
    _begenilenController.dispose();
    _begenilmeyenController.dispose();
    _okumaTarihiController.dispose();
    super.dispose();
  }

  Future<void> _tarihSec() async {
    DateTime? secilenTarih = await showDatePicker(
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

    if (secilenTarih != null) {
      _okumaTarihiController.text =
          "${secilenTarih.day}.${secilenTarih.month}.${secilenTarih.year}";
    }
  }

  Future<void> _guncelle() async {
    setState(() => _isLoading = true);
    try {
      await KitapService().kitapGuncelle(
        kitapID: widget.kitap.kitapID!,
        kitapAdi: _kitapAdiController.text,
        yazarAdi: _yazarAdiController.text,
        okumaTarihi: widget.kitap.okumaTarihi ?? "",
        begenilenYerler: _begenilenController.text,
        begenilmeyenYerler: _begenilmeyenController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kitap başarıyla güncellendi!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 255, 225, 1),
      appBar: AppBar(
        title: const Text("Kitap Bilgilerini Düzenle"),
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          color: Colors.green,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.8,
        foregroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Kitap İkonu
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Icon(
                  Icons.menu_book,
                  size: 80,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Düzenlenebilir Kartlar
            _duzenlemeKarti("Kitap Adı", _kitapAdiController, Icons.book),
            _duzenlemeKarti("Yazar", _yazarAdiController, Icons.person),
            _duzenlemeKarti(
              "Okuma Tarihi",
              _okumaTarihiController,
              Icons.calendar_today,
              readOnly: true,
              onTap: _tarihSec,
            ),

            _duzenlemeKarti(
              "Beğenilen Yerler",
              _begenilenController,
              Icons.thumb_up_alt_outlined,
              maxLines: 3,
            ),
            _duzenlemeKarti(
              "Beğenilmeyen Yerler",
              _begenilmeyenController,
              Icons.thumb_down_alt_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // Güncelle Butonu
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _guncelle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "DEĞİŞİKLİKLERİ KAYDET",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Detay Kartı Tasarımında Düzenleme Kartı
  Widget _duzenlemeKarti(
    String baslik,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Icon(icon, color: Colors.green),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baslik,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  TextField(
                    controller: controller,
                    maxLines: maxLines,
                    readOnly: readOnly,
                    onTap: onTap,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      border: InputBorder.none,
                      hintText: "Bir şeyler yazın...",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
