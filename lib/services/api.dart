import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/bookAPI.dart';

class BookService {
  final String _baseUrl = "https://www.googleapis.com/books/v1/volumes";

  Future<BookAPI?> fetchRandomBook(String genre) async {
    final url = Uri.parse(
      '$_baseUrl?q=subject:$genre&langRestrict=tr&maxResults=40',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);

      if (data['items'] == null || data['items'].isEmpty) {
        return null;
      }

      final items = data['items'] as List;
      final randomItem = items[Random().nextInt(items.length)];

      return BookAPI.fromJson(randomItem);
    } catch (e) {
      print("API Hatası: $e");
      return null;
    }
  }
}
