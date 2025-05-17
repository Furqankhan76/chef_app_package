import 'package:chef_app/features/product_management/domain/product.dart';

abstract class ProductRepository {
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product); // Note: Name cannot be updated
  Future<void> deleteProduct(String productId);
  Stream<List<Product>> getProductsByCategory(String category);
  Stream<List<Product>> getProductsBySeller(String sellerId);
  Stream<Product?> getProductById(String productId);
  // Add other methods as needed, e.g., search products
}

