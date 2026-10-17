import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/products/providers/publish_product_provider.dart';
import 'package:trueke/models/product.dart';

void main() {
  group('PublishProductNotifier - Moderacion y Resiliencia', () {
    late ProviderContainer container;
    late File dummyFile;

    setUp(() {
      container = ProviderContainer();
      dummyFile = File('dummy_image.jpg');
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'Debe interceptar y setear el mensaje de error si el titulo contiene una palabra prohibida',
      () async {
        final notifier = container.read(publishProductProvider.notifier);

        // Al capturarse internamente la excepcion, se espera la resolucion de la promesa
        await notifier.submitProduct(
          title: 'Vendo una pistola de juguete',
          description: 'En perfecto estado para coleccionistas',
          price: 50.0,
          category: 'Otros',
          owner: 'David',
          ownerId: 'usr_123',
          condition: 'Como nuevo',
          tradeType: TradeType.sale,
          wanted: 'Dinero',
          location: 'Madrid',
          latitude: 40.0,
          longitude: -3.0,
        );

        final state = container.read(publishProductProvider);
        expect(state.errorMessage, contains('normas de Trueke'));
        expect(state.isPublishing, isFalse);
      },
    );

    test(
      'Debe mantener la lista de imagenes intacta en el estado si la operacion asincrona falla',
      () async {
        final notifier = container.read(publishProductProvider.notifier);
        notifier.setImages([dummyFile]);

        await notifier.submitProduct(
          title: 'MacBook Pro M1',
          description: 'Atencion esto contiene droga',
          price: 999.0,
          category: 'Electronica',
          owner: 'David',
          ownerId: 'usr_123',
          condition: 'Como nuevo',
          tradeType: TradeType.trade,
          wanted: 'Cambio',
          location: 'Madrid',
          latitude: 40.0,
          longitude: -3.0,
        );

        final state = container.read(publishProductProvider);
        expect(state.errorMessage, contains('normas de Trueke'));
        expect(state.selectedImages, isNotEmpty);
        expect(state.selectedImages.first.path, equals('dummy_image.jpg'));
      },
    );
  });
}
