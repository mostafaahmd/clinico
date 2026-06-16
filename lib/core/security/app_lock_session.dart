import 'package:flutter/foundation.dart';

class AppLockSession extends ChangeNotifier {
  bool _unlocked = false;

  bool get unlocked => _unlocked;

  void markUnlocked() {
    _unlocked = true;
    notifyListeners();
  }

  void reset() {
    _unlocked = false;
    notifyListeners();
  }
}