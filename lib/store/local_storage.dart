import 'package:shared_preferences/shared_preferences.dart';
import 'image_model.dart';
import 'dart:async';
import 'dart:convert';

class LocalStorage {
  static LocalStorage? _instance;
  static LocalStorage getInstance() {
    if (_instance == null) {
      _instance = LocalStorage();
    }
    return _instance!;
  }

  void load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('images');
    if (data is String) {
      final Map<String, dynamic> localData = jsonDecode(data);
      final localImages = localData
          .map((key, value) => MapEntry(key, ImageModel.fromJson(value)));
      images = localImages;
      update();
    }
  }

  final StreamController<Map<String, ImageModel>> _imagesController =
      StreamController();

  Stream<Map<String, ImageModel>> get imagesStream => _imagesController.stream;

  Map<String, ImageModel> images = {};

  void save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(images);
    prefs.setString('images', data);
  }

  void setImage(ImageModel image) {
    images[image.id] = image;
    update();
  }

  void update() {
    this._imagesController.sink.add(images);
  }

  void dispose() {
    this._imagesController.close();
  }
}
