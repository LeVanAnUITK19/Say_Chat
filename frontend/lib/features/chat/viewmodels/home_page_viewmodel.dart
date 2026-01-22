import 'package:flutter/material.dart';

class HomePageViewmodel extends ChangeNotifier {
  final BuildContext context;

  HomePageViewmodel(this.context);

  final TextEditingController searchController = TextEditingController();

  String _keyword = '';
  String get keyword => _keyword;

  void onSearchChanged(String value) {
    _keyword = value;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
