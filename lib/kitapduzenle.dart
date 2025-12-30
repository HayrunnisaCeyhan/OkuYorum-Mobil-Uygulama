import 'package:flutter/material.dart';
import 'models/bookModel.dart';
import 'services/kitap.dart';
import 'kitapguncelle.dart';

class KitapDuzenleSayfasi extends StatefulWidget {
  const KitapDuzenleSayfasi({super.key});

  @override
  State<KitapDuzenleSayfasi> createState() => _KitapDuzenleSayfasiState();
}

class _KitapDuzenleSayfasiState extends State<KitapDuzenleSayfasi> {
  final KitapService _kitapService = KitapService();
  late final Stream<List<BookModel>> _kitapStream;

  @override
  void initState() {
    super.initState();
    _kitapStream = _kitapService.kullaniciKitaplariniGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 255, 225, 1),
      body: StreamBuilder<List<BookModel>>(
        stream: _kitapStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Kitap bulunamadı"));
          }

          final kitaplar = snapshot.data!;

          return ListView.builder(
            itemCount: kitaplar.length,
            itemBuilder: (context, index) {
              final kitap = kitaplar[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.collections_bookmark_rounded,
                    color: Colors.green,
                  ),
                  title: Text(
                    kitap.kitapAdi ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(kitap.yazarAdi ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KitapGuncelleSayfasi(kitap: kitap),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
