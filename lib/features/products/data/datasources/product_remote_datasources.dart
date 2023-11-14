import 'dart:convert';

import 'package:digital_dreams_shop/core/constraints/constraints.dart';
import 'package:digital_dreams_shop/core/errors/exceptions.dart';
import 'package:digital_dreams_shop/core/utils/injection_container.dart';
import 'package:digital_dreams_shop/core/utils/typdefs.dart';
import 'package:digital_dreams_shop/features/products/data/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProductRemoteDataSource {
  const ProductRemoteDataSource();

  Future<List<ProductModel>> getAllProductsByCategory(String id);
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> searchProductByName(String text);
  Future<List<ProductModel>> searchProductsByNamePerCategory(
      String id, String text);
  Future<List<ProductModel>> getNewArrivalProducts();
  Future<List<ProductModel>> getPopularProducts();
  Future<void> addOrRemoveProductWishlist(String id);
}

class ProductRemoteDataSourceImpl extends ProductRemoteDataSource {
  const ProductRemoteDataSourceImpl({required this.client});

  final http.Client client;

  @override
  Future<List<ProductModel>> getAllProductsByCategory(String id) async {
    final url = Uri.parse('$kBaseUrl/categories/$id/products?sort=createdAt');
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final DataMap data = jsonDecode(response.body);
    final List<ProductModel> products = [];
    if (response.statusCode == 200) {
      for (final product in data['data']['data']) {
        products.add(
          ProductModel.fromJson(product),
        );
      }

      return products;
    }

    throw ServerException(
      data['message'],
      response.statusCode,
    );
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final url = Uri.parse('$kBaseUrl/products/$id');
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final DataMap data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ProductModel.fromJson(data['data']['data']);
    }

    throw ServerException(
      data['message'],
      response.statusCode,
    );
  }

  @override
  Future<List<ProductModel>> searchProductByName(String text) async {
    final url = Uri.parse('$kBaseUrl/products?search=$text');
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final DataMap data = jsonDecode(response.body);
    final List<ProductModel> products = [];
    if (response.statusCode == 200) {
      for (final product in data['data']['data']) {
        products.add(
          ProductModel.fromJson(product),
        );
      }

      return products;
    }

    throw ServerException(
      data['message'],
      response.statusCode,
    );
  }

  @override
  Future<List<ProductModel>> searchProductsByNamePerCategory(
      String id, String text) async {
    final url = Uri.parse('$kBaseUrl/categories/$id/products?search=$text');
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final DataMap data = jsonDecode(response.body);
    final List<ProductModel> products = [];
    if (response.statusCode == 200) {
      for (final product in data['data']['data']) {
        products.add(
          ProductModel.fromJson(product),
        );
      }

      return products;
    }

    throw ServerException(
      data['message'],
      response.statusCode,
    );
  }

  @override
  Future<List<ProductModel>> getNewArrivalProducts() async {
    final url = Uri.parse('$kBaseUrl/products?sort=-updatedAt&limit=5');
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final DataMap data = jsonDecode(response.body);
    final List<ProductModel> products = [];
    if (response.statusCode == 200) {
      for (final product in data['data']['data']) {
        products.add(
          ProductModel.fromJson(product),
        );
      }

      return products;
    }

    throw ServerException(
      data['message'],
      response.statusCode,
    );
  }

  @override
  Future<List<ProductModel>> getPopularProducts() async {
    final url = Uri.parse(
        '$kBaseUrl/products?sort=-ratingsQuantity,-updatedAt&limit=5');
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final DataMap data = jsonDecode(response.body);
    final List<ProductModel> products = [];
    if (response.statusCode == 200) {
      for (final product in data['data']['data']) {
        products.add(
          ProductModel.fromJson(product),
        );
      }

      return products;
    }

    throw ServerException(
      data['message'],
      response.statusCode,
    );
  }

  @override
  Future<void> addOrRemoveProductWishlist(String id) async {
    final url = Uri.parse('$kBaseUrl/products/$id/wishlist');
    final response = await client.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${sl<SharedPreferences>().getString(kAuthToken)}',
      },
    );
    final DataMap data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }

    throw ServerException(
      data['message'],
      response.statusCode,
    );
  }
}
