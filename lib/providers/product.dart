import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFav;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFav = false,
  });

  void _setFavValue(bool newValue) {
    isFav = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFav;
    isFav = !isFav;
    notifyListeners();
    final uri = Uri.parse(
      'https://flutter-project-802a7-default-rtdb.firebaseio.com/userFav/$userId/$id.json?auth=$token',
    );
    try {
      final response = await http.put(uri,
          body: json.encode(
            isFav,
          ));
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
