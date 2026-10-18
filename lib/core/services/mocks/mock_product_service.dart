import '../../../features/home/widgets/trueke_logo_painter.dart'; // Solo para referencia de color si se usa

class MockProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;

  MockProduct({required this.id, required this.name, required this.category, required this.price, required this.imageUrl});
}

class MockProductService {
  static List<MockProduct> getFeaturedProducts() {
    return [
      MockProduct(id: '1', name: 'MacBook Air M2', category: 'Electrónica', price: 999.99, imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=400&auto=format&fit=crop'),
      MockProduct(id: '2', name: 'Zapatillas Nike Air Max', category: 'Moda', price: 129.99, imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=400&auto=format&fit=crop'),
      MockProduct(id: '3', name: 'Sofa Cama Moderno', category: 'Hogar', price: 499.99, imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=400&auto=format&fit=crop'),
      MockProduct(id: '4', name: 'Libro de Dart avanzado', category: 'Libros', price: 49.99, imageUrl: 'https://images.unsplash.com/photo-1589998059171-988d887df646?q=80&w=400&auto=format&fit=crop'),
      MockProduct(id: '5', name: 'Bicicleta de Montaña', category: 'Deporte', price: 749.99, imageUrl: 'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?q=80&w=400&auto=format&fit=crop'),
    ];
  }
}
