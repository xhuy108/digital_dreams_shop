part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object> get props => [];
}

class GetAllProductsByCategoryEvent extends ProductsEvent {
  const GetAllProductsByCategoryEvent(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

class GetProductByIdEvent extends ProductsEvent {
  const GetProductByIdEvent(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

class GetNewArrivalProductsEvent extends ProductsEvent {
  const GetNewArrivalProductsEvent();

  @override
  List<Object> get props => [];
}

class GetPopularProductsEvent extends ProductsEvent {
  const GetPopularProductsEvent();

  @override
  List<Object> get props => [];
}

class SearchProductsByNameEvent extends ProductsEvent {
  const SearchProductsByNameEvent(this.text);

  final String text;

  @override
  List<Object> get props => [text];
}

class SearchProductsByNamePerCategoryEvent extends ProductsEvent {
  const SearchProductsByNamePerCategoryEvent(this.id, this.text);

  final String id;
  final String text;

  @override
  List<Object> get props => [id, text];
}

class GetProductsByBrandPerCategoryEvent extends ProductsEvent {
  const GetProductsByBrandPerCategoryEvent({
    required this.id,
    required this.brand,
    required this.search,
  });

  final String id;
  final String brand;
  final String search;

  @override
  List<Object> get props => [id, brand];
}

class GetRelevantProductsEvent extends ProductsEvent {
  const GetRelevantProductsEvent({
    required this.categoryId,
    required this.productId,
  });

  final String categoryId;
  final String productId;

  @override
  List<Object> get props => [categoryId, productId];
}
