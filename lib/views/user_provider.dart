import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;

  String? get userId => _userId;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }
}
