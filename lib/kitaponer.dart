import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api.dart';
import '../models/bookAPI.dart';
import '/services/translation.dart';

class KitapOnerPage extends StatefulWidget {
  const KitapOnerPage({super.key});

  @override
  State<KitapOnerPage> createState() => _KitapOnerPageState();
}

class _KitapOnerPageState extends State<KitapOnerPage> {
  final BookService _bookService = BookService();
  final TranslationService _translationService = TranslationService();

  BookAPI? _suggestedBook;
  bool _isLoading = false;
  String? _selectedGenre;

  final List<String> _genres = [
    "Roman",
    "Bilim Kurgu",
    "Fantastik",
    "Polisiye",
    "Gerilim",
    "Romantik",
    "Korku",
    "Distopya",
    "Tarih",
    "Biyografi",
    "Kişisel Gelişim",
    "Psikoloji",
    "Felsefe",
    "Çocuk",
    "Gençlik",
  ];

  Future<void> _getRecommendation(String genre) async {
    setState(() {
      _selectedGenre = genre;
      _isLoading = true;
    });

    try {
      final book = await _bookService.fetchRandomBook(genre);

      await Future.delayed(const Duration(milliseconds: 1200));

      if (book != null) {
        final translatedTitle = await _translationService.translateToTurkish(
          book.title,
        );

        setState(() {
          _suggestedBook = BookAPI(
            title: translatedTitle,
            authors: book.authors,
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _suggestedBook = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Bir hata oluştu")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(225, 255, 225, 100),
      body: Center(
        child: _selectedGenre == null ? _buildGenreGrid() : _buildResultArea(),
      ),
    );
  }

  /// 🟢 TÜR SEÇİMİ
  Widget _buildGenreGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.6,
          ),
          itemCount: _genres.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => _getRecommendation(_genres[index]),
              child: Text(
                _genres[index],
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 🎞️ ANİMASYON / SONUÇ
  Widget _buildResultArea() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _isLoading
          ? Lottie.asset(
              'assets/lottie/book.json',
              width: 250,
              key: const ValueKey("loading"),
            )
          : _suggestedBook != null
          ? _buildBookCard(_suggestedBook!)
          : const Text(
              "Kitap bulunamadı",
              style: TextStyle(color: Colors.grey),
            ),
    );
  }

  /// 📚 KİTAP KARTI
  Widget _buildBookCard(BookAPI book) {
    return Container(
      key: const ValueKey("book"),
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_stories, color: Colors.white, size: 60),
          const SizedBox(height: 20),
          Text(
            book.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Yazar: ${book.authors}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => _getRecommendation(_selectedGenre!),
            child: const Text("Bu Türde Başka Öner"),
          ),
        ],
      ),
    );
  }
}
