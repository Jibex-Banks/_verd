import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modern v3 equivalent of StateProvider
final counterProvider = NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}