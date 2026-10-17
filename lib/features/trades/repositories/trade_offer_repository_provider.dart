import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import 'trade_offer_repository.dart';

final tradeOfferRepositoryProvider = Provider<TradeOfferRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TradeOfferRepository(client);
});
