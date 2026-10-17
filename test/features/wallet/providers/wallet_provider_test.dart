import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/wallet/models/wallet_model.dart';
import 'package:trueke/features/wallet/repositories/wallet_repository.dart';
import 'package:trueke/features/wallet/providers/wallet_provider.dart';
import 'package:trueke/features/auth/auth_service.dart';

// Stub manual de la sesión para eludir la red nativa de Supabase
class FakeUser extends Fake implements User {
  @override
  String get id => 'usr_david_123';
}

class FakeWalletRepository implements WalletRepository {
  bool depositFundsCalled = false;
  double? capturedAmount;
  bool throwError = false;

  @override
  Future<WalletModel> getWallet(String userId) async {
    return WalletModel(
      id: 'w_1',
      userId: userId,
      balance: 100.0,
      escrowBalance: 0.0,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> depositFunds({
    required String userId,
    required double amount,
  }) async {
    if (throwError) throw Exception('Network failure');
    depositFundsCalled = true;
    capturedAmount = amount;
  }
}

void main() {
  group('WalletMutationNotifier - Pruebas Unitarias de Flujos Contables', () {
    late ProviderContainer container;
    late FakeWalletRepository fakeRepository;
    late FakeUser fakeUser;

    setUp(() {
      fakeRepository = FakeWalletRepository();
      fakeUser = FakeUser();
      container = ProviderContainer(
        overrides: [
          walletRepositoryProvider.overrideWithValue(fakeRepository),
          currentUserProvider.overrideWith((ref) => fakeUser),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'Debe transicionar a AsyncData con exito e invalidar cache tras una recarga de saldo valida',
      () async {
        final notifier = container.read(walletMutationProvider.notifier);

        final result = await notifier.depositFunds(amount: 50.0);

        expect(result, isTrue);
        expect(fakeRepository.depositFundsCalled, isTrue);
        expect(fakeRepository.capturedAmount, equals(50.0));
        expect(container.read(walletMutationProvider), isA<AsyncData<void>>());
      },
    );

    test(
      'Debe mutar el estado a AsyncError y retornar false si el repositorio financiero falla',
      () async {
        fakeRepository.throwError = true;
        final notifier = container.read(walletMutationProvider.notifier);

        final result = await notifier.depositFunds(amount: 50.0);

        expect(result, isFalse);
        expect(fakeRepository.depositFundsCalled, isFalse);
        expect(container.read(walletMutationProvider), isA<AsyncError<void>>());
      },
    );
  });
}
