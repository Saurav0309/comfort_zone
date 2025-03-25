// lib/models/custom_design_model.dart

class DesignModel {
  String name;
  double width;
  double height;
  String material;
  String? imagePath;

  DesignModel({
    required this.name,
    required this.width,
    required this.height,
    required this.material,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'width': width,
      'height': height,
      'material': material,
      'imagePath': imagePath,
    };
  }
}
