import 'dart:async';

class CounterBloc {
  int _counter = 0;

  final StreamController<int> _streamController =
      StreamController<int>.broadcast();

  Stream<int> get stream => _streamController.stream;

  void incrementCounter() {
    print('incrementCounter $_counter');
    _counter++;
    _streamController.add(_counter);
  }

  void dispose() {
    _streamController.close();
  }
}
