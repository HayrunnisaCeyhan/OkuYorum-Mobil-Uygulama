import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/bookModel.dart'; // Modelinizi import edin

class KitapService {
  // CollectionReference'ı, users/{UID}/kitaplar yoluna göre yeniden tanımlıyoruz (En güvenli yol)
  CollectionReference<Map<String, dynamic>> _getKitaplarCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Bu metodun çağrılmaması gerekir, ancak çağrılırsa hata fırlatırız.
      throw Exception("Kullanıcı oturum açmamış");
    }
    // Güvenli yol: users -> [UID] -> kitaplar
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('kitaplar');
  }

  // 1. KİTAP EKLEME
  Future<void> kitapEkle({
    required String kitapAdi,
    required String yazarAdi, // Veritabanına uyumlu hale getirildi
    required String okumaTarihi,
    required String begenilenYerler,
    required String begenilmeyenYerler,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış");

    // BookModel'i kullanmadan direkt map oluşturmak daha hızlıdır
    await _getKitaplarCollection().add({
      'userId': user.uid,
      'kitapAdi': kitapAdi,
      'yazarAdi': yazarAdi, // KitapEkle'yi yazarAdi olarak güncelledik
      'okumaTarihi': okumaTarihi,
      'begenilenYerler': begenilenYerler,
      'begenilmeyenYerler': begenilmeyenYerler,
      'timestamp': FieldValue.serverTimestamp(), // Sıralama için ekledik
    });

    // 💡 NOT: Firestore ID'yi dokümana yazma ihtiyacı yoktur.
    // Belge zaten doc.id ile çekilirken alınır. (Önceki kodunuzdaki bu kısım kaldırıldı.)
  }

  // services/kitap.dart dosyanın içine ekle:

  Future<void> kitapGuncelle({
    required String kitapID,
    required String kitapAdi,
    required String yazarAdi,
    required String okumaTarihi,
    required String begenilenYerler,
    required String begenilmeyenYerler,
  }) async {
    try {
      // 1. Önce giriş yapmış kullanıcının UID'sini alıyoruz
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Kullanıcı giriş yapmamış");

      // 2. Doğru yolu izliyoruz: users -> [UID] -> kitaplar -> [kitapID]
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Kullanıcının klasörüne gir
          .collection('kitaplar') // Kitaplar klasörüne gir
          .doc(kitapID) // Değişecek kitabı bul
          .update({
            'kitapAdi': kitapAdi,
            'yazarAdi': yazarAdi,
            'okumaTarihi': okumaTarihi,
            'begenilenYerler': begenilenYerler,
            'begenilmeyenYerler': begenilmeyenYerler,
          });
    } catch (e) {
      print("Güncelleme hatası: $e");
      rethrow;
    }
  }

  // 2. SEÇİLEN KİTAPLARI SİL
  Future<void> secilenleriSil(List<String> seciliKitapIdleri) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Kullanıcı giriş yapmamış");
    }

    if (seciliKitapIdleri.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    final kitaplarCollection = _getKitaplarCollection();

    for (final kitapId in seciliKitapIdleri) {
      batch.delete(kitaplarCollection.doc(kitapId));
    }

    await batch.commit();
  }

  // 3. KULLANICI KİTAPLARINI GETİR (Hata Düzeltildi)
  Stream<List<BookModel>> kullaniciKitaplariniGetir() {
    return _getKitaplarCollection().snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            // 🚀 Burası düzeltildi: doc.id BookModel.fromJson'a ikinci parametre olarak gönderilir
            (doc) => BookModel.fromJson(
              doc.data(), // doc.data() zaten Map<String, dynamic> döndürür
              doc.id,
            ),
          )
          .toList(),
    );
  }
}
