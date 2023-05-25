import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'product.dart';
import 'dart:convert';

class ProductProviders with ChangeNotifier {
  List<Product> _items = [];

  Future<void> fetchAndSetProduct([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var uri = Uri.parse(
      'https://flutter-project-802a7-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString  ',
    );
    try {
      final response = await http.get(uri);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        return;
      }
      uri = Uri.parse(
        'https://flutter-project-802a7-default-rtdb.firebaseio.com/userFav/$userId.json?auth=$authToken',
      );
      final favResponse = await http.get(uri);
      final favData = json.decode(favResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFav: favData == null ? false : favData[prodId] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProducts(Product product) async {
    final uri = Uri.parse(
      'https://flutter-project-802a7-default-rtdb.firebaseio.com/products.json?auth=$authToken',
    );
    try {
      final response = await http.post(
        uri,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          isFav: product.isFav);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProducts(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prodId) => prodId.id == id);
    if (prodIndex >= 0) {
      final uri = Uri.parse(
        'https://flutter-project-802a7-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken',
      );
      await http.patch(uri,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {}
  }

  Future<void> deleteProducts(String id) async {
    final uri = Uri.parse(
      'https://flutter-project-802a7-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken',
    );
    final existingProductIndex = _items.indexWhere((prodId) => prodId.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(uri);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct!);
      notifyListeners();
      throw HttpException('Could not delete message.');
    }
    existingProduct = null;
  }

  // var _showFavOnly = false;
  //
  // void showFavOnly(){
  //   _showFavOnly = true;
  //   notifyListeners();
  // }
  //
  // void showAll(){
  //   _showFavOnly = false;
  //   notifyListeners();
  // }
  String authToken;
  String userId;

  ProductProviders(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if(_showFavOnly){
    //   return _items.where((prodItem) => prodItem.isFav).toList();
    // }
    return [..._items];
    // ... is a spread operator
  }

  List<Product> get favItems {
    return _items.where((prodItem) => prodItem.isFav).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  void updateUser(String token, String id) {
    userId = id;
    authToken = token;
    notifyListeners();
  }
}
