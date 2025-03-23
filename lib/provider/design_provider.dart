// lib/provider/design_provider.dart
import 'package:flutter/material.dart';
import '../models/custom_design_model.dart'; // Import DesignModel

class DesignProvider extends ChangeNotifier {
  final List<DesignModel> _designs = [];

  List<DesignModel> get designs => _designs;

  void addDesign(DesignModel design) {
    _designs.add(design);
    notifyListeners();
  }

  void removeDesign(int index) {
    _designs.removeAt(index);
    notifyListeners();
  }
}
