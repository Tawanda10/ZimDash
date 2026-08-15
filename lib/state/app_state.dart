import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZimUser {
  final String name;
  final String email;
  const ZimUser({required this.name, required this.email});

  Map<String, dynamic> toJson() => {'name': name, 'email': email};
  factory ZimUser.fromJson(Map<String, dynamic> json) =>
      ZimUser(name: json['name'] as String, email: json['email'] as String);
}

enum SortMode { relevance, ratingDesc, feeAsc, fastest }

/// App-wide state that isn't the cart: signed-in user, favourite
/// restaurants, theme mode and the home screen's sort preference — all
/// persisted with shared_preferences so it survives restarts.
class AppState extends ChangeNotifier {
  static const _userKey = 'zimdash_user';
  static const _favKey = 'zimdash_favorites';
  static const _themeKey = 'zimdash_theme_mode';

  ZimUser? _user;
  final Set<String> _favorites = {};
  ThemeMode _themeMode = ThemeMode.system;
  SortMode sortMode = SortMode.relevance;

  ZimUser? get user => _user;
  Set<String> get favorites => Set.unmodifiable(_favorites);
  ThemeMode get themeMode => _themeMode;

  bool isFavorite(String restaurantId) => _favorites.contains(restaurantId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final userRaw = prefs.getString(_userKey);
    if (userRaw != null) {
      try {
        _user = ZimUser.fromJson(jsonDecode(userRaw) as Map<String, dynamic>);
      } catch (_) {}
    }
    final favRaw = prefs.getStringList(_favKey);
    if (favRaw != null) _favorites.addAll(favRaw);

    final theme = prefs.getString(_themeKey);
    _themeMode = switch (theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> signIn(String name, String email) async {
    _user = ZimUser(name: name, email: email);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    notifyListeners();
  }

  Future<void> toggleFavorite(String restaurantId) async {
    if (_favorites.contains(restaurantId)) {
      _favorites.remove(restaurantId);
    } else {
      _favorites.add(restaurantId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favKey, _favorites.toList());
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
    notifyListeners();
  }

  void setSortMode(SortMode mode) {
    sortMode = mode;
    notifyListeners();
  }
}
