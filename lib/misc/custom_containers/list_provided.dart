import 'package:flutter/foundation.dart';

import './list_serializable.dart';

abstract class ListProvided<T> extends ListSerializable<T> with ChangeNotifier {
  @override
  void add(T item, {bool notify = true}) {
    super.add(item);
    if (notify) notifyListeners();
  }

  @override
  void remove(value, {bool notify = true}) {
    super.remove(value);
    if (notify) notifyListeners();
  }
}