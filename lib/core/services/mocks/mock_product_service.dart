import "../../../models/product.dart";

class MockProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;

  MockProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
  });
}

class MockProductService {
  static List<MockProduct> getFeaturedProducts() {
    return [
      MockProduct(
        id: "1",
        name: "MacBook Air M2 (16GB RAM)",
        category: "Electrónica",
        price: 999.99,
        imageUrl: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=600&auto=format&fit=crop",
      ),
      MockProduct(
        id: "2",
        name: "Sony WH-1000XM5 Auriculares",
        category: "Electrónica",
        price: 280.00,
        imageUrl: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=600&auto=format&fit=crop",
      ),
      MockProduct(
        id: "3",
        name: "Zapatillas Nike Air Max",
        category: "Moda",
        price: 129.99,
        imageUrl: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=600&auto=format&fit=crop",
      ),
      MockProduct(
        id: "4",
        name: "Chaqueta Cazadora Vintage",
        category: "Moda",
        price: 85.00,
        imageUrl: "https://images.unsplash.com/photo-1551028719-00167b16eac5?q=80&w=600&auto=format&fit=crop",
      ),
      MockProduct(
        id: "5",
        name: "Sofá Cama Estilo Nórdico",
        category: "Hogar",
        price: 499.99,
        imageUrl: "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=600&auto=format&fit=crop",
      ),
      MockProduct(
        id: "6",
        name: "Cafetera Espresso Italiana",
        category: "Hogar",
        price: 65.00,
        imageUrl: "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?q=80&w=600&auto=format&fit=crop",
      ),
      MockProduct(
        id: "7",
        name: "PlayStation 5 + 2 Mandos",
        category: "Gaming",
        price: 450.00,
        imageUrl: "https://images.unsplash.com/photo-1606813907291-d86efa9b94db?q=80&w=600&auto=format&fit=crop",
      ),
      MockProduct(
        id: "8",
        name: "Nintendo Switch OLED",
        category: "Gaming",
        price: 290.00,
        imageUrl: "https://images.unsplash.com/photo-1578303512597-81e6cc155b3e?q=80&w=600&auto=format&fit=crop",
      ),
      MockProduct(
        id: "9",
        name: "Bicicleta de Montaña Trek",
        category: "Deporte",
        price: 749.99,
        imageUrl: "https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?q=80&w=600&auto=format&fit=crop",
      ),
      MockProduct(
        id: "10",
        name: "Tabla de Surf All-Round",
        category: "Deporte",
        price: 320.00,
        imageUrl: "https://images.unsplash.com/photo-1531722561554-aac56ef5c40b?q=80&w=600&auto=format&fit=crop",
      ),
      MockProduct(
        id: "11",
        name: "Guitarra Acústica Fender",
        category: "Otros",
        price: 210.00,
        imageUrl: "https://images.unsplash.com/photo-1510915361894-db8b60106cb1?q=80&w=600&auto=format&fit=crop",
      ),
      MockProduct(
        id: "12",
        name: "Cámara Réflex Canon EOS",
        category: "Otros",
        price: 520.00,
        imageUrl: "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=600&auto=format&fit=crop",
      ),
    ];
  }

  static List<Product> getFullMockProducts() {
    final now = DateTime.now();
    return [
      Product(
        id: "m1",
        title: "MacBook Air M2 (16GB / 512GB)",
        description: "Impecable estado. Usado solo para proyectos de diseño. Incluye caja y cargador original.",
        price: 999.99,
        images: ["https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=600&auto=format&fit=crop"],
        category: "Electrónica",
        owner: "David Lledó",
        ownerId: "u1",
        condition: "Como nuevo",
        tradeType: TradeType.tradeAndMoney,
        wanted: "iPad Pro o iPhone 15",
        location: "Madrid, España",
        latitude: 40.416775,
        longitude: -3.703790,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Product(
        id: "m2",
        title: "Zapatillas Nike Air Max 90",
        description: "Talla 42. Edición especial en perfecto estado. Solo puestas 2 veces.",
        price: 129.99,
        images: ["https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=600&auto=format&fit=crop"],
        category: "Moda",
        owner: "Elena Gómez",
        ownerId: "u2",
        condition: "Excelente",
        tradeType: TradeType.trade,
        wanted: "Ropa de abrigo o calzado similar talla 42",
        location: "Barcelona, España",
        latitude: 41.385064,
        longitude: 2.173403,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Product(
        id: "m3",
        title: "PlayStation 5 + Mando DualSense Extra",
        description: "Consola con muy poco uso. Incluye cable HDMI 2.1 y soporte vertical.",
        price: 450.00,
        images: ["https://images.unsplash.com/photo-1606813907291-d86efa9b94db?q=80&w=600&auto=format&fit=crop"],
        category: "Gaming",
        owner: "Carlos Ruiz",
        ownerId: "u3",
        condition: "Como nuevo",
        tradeType: TradeType.sale,
        wanted: "Solo venta o trueque por PC Gaming equivalente",
        location: "Valencia, España",
        latitude: 39.469907,
        longitude: -0.376288,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      Product(
        id: "m4",
        title: "Bicicleta de Montaña Trek Marlin 7",
        description: "Cuadro de aluminio talla M, frenos hidráulicos Shimano. Revisión recién hecha.",
        price: 749.99,
        images: ["https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?q=80&w=600&auto=format&fit=crop"],
        category: "Deporte",
        owner: "Sofía Martin",
        ownerId: "u4",
        condition: "Buen estado",
        tradeType: TradeType.tradeAndMoney,
        wanted: "Patinete eléctrico de alta gama",
        location: "Sevilla, España",
        latitude: 37.389092,
        longitude: -5.984459,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Product(
        id: "m5",
        title: "Sofá Cama 3 Plazas Gris",
        description: "Diseño moderno, muy cómodo y fácil de desplegar. Ideal para invitados.",
        price: 499.99,
        images: ["https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=600&auto=format&fit=crop"],
        category: "Hogar",
        owner: "Marcos Alonso",
        ownerId: "u5",
        condition: "Bueno",
        tradeType: TradeType.trade,
        wanted: "Mesa de comedor con sillas",
        location: "Bilbao, España",
        latitude: 43.263013,
        longitude: -2.934985,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Product(
        id: "m6",
        title: "Guitarra Acústica Fender FA-125",
        description: "Sonido cálido y resonante. Incluye funda acolchada, afinador y púas.",
        price: 210.00,
        images: ["https://images.unsplash.com/photo-1510915361894-db8b60106cb1?q=80&w=600&auto=format&fit=crop"],
        category: "Otros",
        owner: "Lucía Fernández",
        ownerId: "u6",
        condition: "Excelente",
        tradeType: TradeType.trade,
        wanted: "Teclado / Piano eléctrico",
        location: "Málaga, España",
        latitude: 36.721261,
        longitude: -4.421266,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }
}
