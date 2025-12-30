class BookAPI {
  final String title;
  final String authors;

  BookAPI({required this.title, required this.authors});

  factory BookAPI.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];

    if (volumeInfo == null) {
      return BookAPI(title: "Başlık Yok", authors: "Yazar Bilinmiyor");
    }

    return BookAPI(
      title: volumeInfo['title']?.toString() ?? "Başlık Yok",
      authors:
          (volumeInfo['authors'] as List?)
              ?.map((e) => e.toString())
              .join(', ') ??
          "Yazar Bilinmiyor",
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'authors': authors};
  }

  factory BookAPI.fromMap(Map<String, dynamic> map) {
    return BookAPI(title: map['title'], authors: map['authors']);
  }
}
