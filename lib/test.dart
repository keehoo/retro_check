import 'dart:async';

Stream<C> combineLatest2WithLimit<A, B, C>(
  Stream<int?> stream1,
  Stream<int?> stream2, {
  required int Function(int, int) combiner,
  required int limit,
}) async* {
  List<List<int?>> ints = [];

  List<StreamSubscription> subs = [];

  StreamController c = StreamController<List<int?>>(
    sync: true,
  );

  StreamSubscription controllerSub = c.stream.listen((data) {
    print("Controller emission $data");
    ints.add(data);
  });

  controllerSub.onDone(() {
    print("ints ${ints.join()}");
  });
  int? str1Val;
  int? str2Val;
  for (var stream in [stream1, stream2]) {
    final sub = stream.listen((a) {
      bool isStream1 = stream == stream1;
      print("${isStream1 ? "Stream 1" : "Stream 2"} : Emission $a");

      if (isStream1) {
        str1Val = a;
      } else {
        str2Val = a;
      }

      if (str1Val != null && str2Val != null) {
        c.sink.add([str1Val, str2Val]);
        str2Val = null;
        str1Val = null;
      }
    });
    sub.onDone(() {
      c.close();
    });
    subs.add(sub);
    print("Amount of subscriptions ${subs.length}");
  }
}

Future<void> main() async {
  Stream<int> stream1 = Stream.fromIterable([1, 2, 3, 4, 5]);
  Stream<int> stream2 = Stream.fromIterable([6, 7, 8, 9, 10]);

  await for (var combined in combineLatest2WithLimit(stream1, stream2,
      combiner: (a, b) => a + b, limit: 3)) {
    print(combined);
  }

// Output: 7, 9, 11
}

StreamController<R> _buildController<T, R>(
  Iterable<Stream<T>> streams,
  R Function(List<T> values) combiner,
) {
  final controller = StreamController<R>(sync: true);
  late List<StreamSubscription<T>> subscriptions;
  List<T?>? values;

  controller.onListen = () {
    var triggered = 0, completed = 0;

    void onDone() {
      if (++completed == subscriptions.length) {
        controller.close();
      }
    }

    subscriptions = streams.map((stream) {
      var hasFirstEvent = false;

      return stream.listen(
        (T value) {
          if (values == null) {
            return;
          }

          // values![index] = value;

          if (!hasFirstEvent) {
            hasFirstEvent = true;
            triggered++;
          }

          if (triggered == subscriptions.length) {
            final R combined;
            try {
              combined = combiner(List<T>.unmodifiable(values!));
            } catch (e, s) {
              controller.addError(e, s);
              return;
            }
            controller.add(combined);
          }
        },
        onError: controller.addError,
        onDone: onDone,
      );
    }).toList(growable: false);
    if (subscriptions.isEmpty) {
      controller.close();
    } else {
      values = List<T?>.filled(subscriptions.length, null);
    }
  };
  // controller.onPause = () => subscriptions.pauseAll();
  // controller.onResume = () => subscriptions.resumeAll();
  controller.onCancel = () {
    values = null;
    // return subscriptions.cancelAll();
  };

  return controller;
}
