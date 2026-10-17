import '../models/escrow_transaction.dart';

abstract class EscrowState {
  const EscrowState();
}

class EscrowInitial extends EscrowState {
  const EscrowInitial();
}

class EscrowLoading extends EscrowState {
  const EscrowLoading();
}

class EscrowLoaded extends EscrowState {
  final EscrowTransaction transaction;
  const EscrowLoaded(this.transaction);
}

class EscrowError extends EscrowState {
  final String message;
  const EscrowError(this.message);
}
