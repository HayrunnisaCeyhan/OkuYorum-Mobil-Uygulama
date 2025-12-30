class BookModel {
  final String? userID;
  final String? kitapID;
  final String? kitapAdi;
  final String? yazarAdi;
  final String? okumaTarihi;
  final String? begenilenYerler;
  final String? begenilmeyenYerler;
  bool seciliMi;

  BookModel({
    this.userID,
    this.kitapID,
    this.kitapAdi,
    this.yazarAdi,
    this.okumaTarihi,
    this.begenilenYerler,
    this.begenilmeyenYerler,
    this.seciliMi = false,
  });

  factory BookModel.fromJson(Map<String, dynamic> json, String docId) {
    return BookModel(
      userID: json['userId'],
      kitapID: docId,
      kitapAdi: json['kitapAdi'] ?? '',
      yazarAdi: json['yazarAdi'] ?? '',
      okumaTarihi: json['okumaTarihi'] ?? '',
      begenilenYerler: json['begenilenYerler'] ?? '',
      begenilmeyenYerler: json['begenilmeyenYerler'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userID,
      'kitapAdi': kitapAdi,
      'yazarAdi': yazarAdi,
      'okumaTarihi': okumaTarihi,
      'begenilenYerler': begenilenYerler,
      'begenilmeyenYerler': begenilmeyenYerler,
    };
  }
}
