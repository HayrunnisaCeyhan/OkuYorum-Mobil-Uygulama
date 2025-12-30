import 'package:flutter/material.dart';
import 'models/bookModel.dart';

class KitapDetaySayfasi extends StatelessWidget {
  final BookModel kitap;

  const KitapDetaySayfasi({super.key, required this.kitap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 255, 225, 1),
      appBar: AppBar(
        title: Text('${kitap.kitapAdi}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Kitap İkonu ve Başlık Kartı
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Icon(
                  //////////////BURAYA FOTO KOY
                  Icons.menu_book,
                  size: 80,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Detay Bilgileri
            _detayKarti("Yazar", '${kitap.yazarAdi}', Icons.person),
            _detayKarti(
              "Okuma Tarihi",
              '${kitap.okumaTarihi}',
              Icons.calendar_today,
            ),
            _detayKarti(
              "Beğenilen Yerler",
              kitap.begenilenYerler ?? "Belirtilmedi",
              Icons.thumb_up_alt_outlined,
            ),
            _detayKarti(
              "Beğenilmeyen Yerler",
              kitap.begenilmeyenYerler ?? "Belirtilmedi",
              Icons.thumb_down_alt_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detayKarti(String baslik, String icerik, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.green),
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
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(icerik, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
