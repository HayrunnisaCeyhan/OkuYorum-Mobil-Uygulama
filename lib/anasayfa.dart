import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:okuyorum/kitapekle.dart';
import 'package:okuyorum/kitaponer.dart';
import 'package:okuyorum/kitapsilme.dart';
import 'package:okuyorum/kitapduzenle.dart';
import 'package:okuyorum/services/kitap.dart';
import 'models/bookModel.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  int currentIndex = 0;

  late final List<Widget> _sayfalar;

  @override
  void initState() {
    super.initState();
    _sayfalar = [
      const _AnaIcerik(),
      const EklemeSayfasi(),
      const KitapOnerPage(),
      const KitapDuzenleSayfasi(),
      const SilmeSayfasi(),
    ];
  }

  Widget _appBarIcerigi() {
    if (currentIndex == 0) {
      return Row(
        children: [
          Image.asset('assets/images/okuyorumlogo.png', height: 35),
          const SizedBox(width: 10),
          const Text(
            "OkuYorum",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
          ),
        ],
      );
    } else {
      String baslik = "";
      switch (currentIndex) {
        case 1:
          baslik = "Yeni Kitap Ekleme";
          break;
        case 2:
          baslik = "Kitap Kaşifi";
          break;
        case 3:
          baslik = "Kitaplarımı Düzenle";
          break;
        case 4:
          baslik = "Kitap Silme";
          break;
      }
      return Text(baslik);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 255, 225, 1),
      appBar: AppBar(
        title: _appBarIcerigi(),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          color: Colors.green,
        ),
        backgroundColor: const Color.fromRGBO(225, 255, 225, 1),
        elevation: 0.8,
      ),
      body: _sayfalar[currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        height: 65,
        items: [
          Icon(
            Icons.home,
            color: currentIndex == 0 ? Colors.white : Colors.black54,
          ),
          Icon(
            Icons.add_box,
            color: currentIndex == 1 ? Colors.white : Colors.black54,
          ),
          Icon(
            Icons.auto_stories,
            color: currentIndex == 2 ? Colors.white : Colors.black54,
          ),
          Icon(
            Icons.edit_note,
            color: currentIndex == 3 ? Colors.white : Colors.black54,
          ),
          Icon(
            Icons.delete_forever,
            color: currentIndex == 4 ? Colors.white : Colors.black54,
          ),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.green,
        backgroundColor: const Color.fromRGBO(225, 255, 225, 1),
        animationCurve: Curves.easeInOutBack,
        animationDuration: const Duration(milliseconds: 500),
        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }
}

/// ================= ANA İÇERİK =================

class _AnaIcerik extends StatefulWidget {
  const _AnaIcerik();

  @override
  State<_AnaIcerik> createState() => _AnaIcerikState();
}

class _AnaIcerikState extends State<_AnaIcerik> {
  final KitapService _kitapService = KitapService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookModel>>(
      stream: _kitapService.kullaniciKitaplariniGetir(),
      builder: (context, snapshot) {
        final kitapSayisi = snapshot.data?.length ?? 0;
        final simdi = DateTime.now();
        final buYil = simdi.year;

        final buYilOkunanKitapSayisi =
            snapshot.data?.where((kitap) {
              if (kitap.okumaTarihi == null) return false;

              final parcalar = kitap.okumaTarihi!.split('/');
              if (parcalar.length != 3) return false;

              final yil = int.tryParse(parcalar[2]);
              return yil == buYil;
            }).length ??
            0;
        String enCokOkunanYazar = "-";

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final Map<String, int> yazarSayac = {};

          for (var kitap in snapshot.data!) {
            final yazar = kitap.yazarAdi;
            if (yazar != null && yazar.isNotEmpty) {
              yazarSayac[yazar] = (yazarSayac[yazar] ?? 0) + 1;
            }
          }

          if (yazarSayac.isNotEmpty) {
            enCokOkunanYazar = yazarSayac.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key;
          }
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// KARŞILAMA
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  "Bugün hangi dünyalara yolculuk yapıyoruz?",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),

              /// İSTATİSTİK KARTLARI
              SizedBox(
                height: 150,
                child: PageView(
                  controller: PageController(viewportFraction: 0.75),
                  children: [
                    /// OKUNAN KİTAP SAYISI
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),

                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Okunan Kitap Sayısı',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              kitapSayisi.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// BU YIL OKUNAN KİTAPLAR
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Bu Yıl Okunan',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              buYilOkunanKitapSayisi.toString(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'En Çok Okunan Yazar',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              enCokOkunanYazar.toString(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// MOTİVASYON
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "“Okumak, başka birinin kafasıyla düşünmektir.”\n- Schopenhauer",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// KÜTÜPHANE
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "KÜTÜPHANEM",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),

              if (!snapshot.hasData || snapshot.data!.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text("Henüz kitap eklenmemiş."),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final kitap = snapshot.data![i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(
                          ' ${kitap.kitapAdi}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(' ${kitap.yazarAdi}'),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
