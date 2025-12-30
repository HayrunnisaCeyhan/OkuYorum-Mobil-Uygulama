import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:okuyorum/kitapdetay.dart';
import 'models/bookModel.dart';
import 'services/kitap.dart';

class SilmeSayfasi extends StatefulWidget {
  const SilmeSayfasi({super.key});

  @override
  State<SilmeSayfasi> createState() => _SilmeSayfasiState();
}

class _SilmeSayfasiState extends State<SilmeSayfasi> {
  final Set<String> _seciliKitapIdleri = {};
  final KitapService _kitapService = KitapService();

  late final Stream<List<BookModel>> _kitapStream;

  @override
  void initState() {
    super.initState();
    _kitapStream = _kitapService.kullaniciKitaplariniGetir();
  }

  bool seciliKitapVarMi(List<BookModel> kitaplar) {
    return kitaplar.any((kitap) => _seciliKitapIdleri.contains(kitap.kitapID));
  }

  Future<void> secilenleriSil(List<BookModel> kitaplar) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final seciliIdler = kitaplar
        .where((k) => _seciliKitapIdleri.contains(k.kitapID))
        .map((k) => k.kitapID!)
        .toList();

    if (seciliIdler.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('kitaplar');

    for (final id in seciliIdler) {
      batch.delete(col.doc(id));
    }

    await batch.commit();

    setState(() => _seciliKitapIdleri.clear());
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

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Kitap bulunamadı"));
          }

          final kitaplar = snapshot.data!;

          return Column(
            children: [
              /// 📚 LİSTE
              Expanded(
                child: ListView.builder(
                  itemCount: kitaplar.length,
                  itemBuilder: (context, i) {
                    final kitap = kitaplar[i];
                    final kitapID = kitap.kitapID!;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: _seciliKitapIdleri.contains(kitapID),
                          activeColor: Colors.green,
                          onChanged: (val) {
                            setState(() {
                              val!
                                  ? _seciliKitapIdleri.add(kitapID)
                                  : _seciliKitapIdleri.remove(kitapID);
                            });
                          },
                        ),
                        title: Text(kitap.kitapAdi ?? ""),
                        subtitle: Text(kitap.yazarAdi ?? ""),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    KitapDetaySayfasi(kitap: kitap),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                              225,
                              255,
                              225,
                              1,
                            ),
                            foregroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Detay"),
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// 🗑 SİL BUTONU
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text("SEÇİLENLERİ SİL"),
                    onPressed: seciliKitapVarMi(kitaplar)
                        ? () => secilenleriSil(kitaplar)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.green.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
