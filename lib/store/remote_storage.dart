import 'image_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage.dart';

const api = 'https://dpsysimages.herokuapp.com/api/image/';
final url = Uri.parse(api);

class RemoteStorage {
  static RemoteStorage? _instance;
  static RemoteStorage getInstance() {
    if (_instance == null) {
      _instance = RemoteStorage();
    }
    return _instance!;
  }

  void load() {
    final local = LocalStorage.getInstance();
    http.get(url).then((response) {
      if (response.statusCode == 200) {
        List<dynamic> images = jsonDecode(response.body);
        images.forEach((image) {
          final String id = image['id'];
          if (local.images.containsKey(id)) {
            final localImage = local.images[id];
            if (localImage != null) {
              local.setImage(localImage.copyWith(url: image['image']));
            }
          } else {
            final localImage = ImageModel(
              id: id,
              name: image['name'],
              url: image['image'],
            );
            local.setImage(localImage);
            local.save();
          }
        });
      }
    });
  }
}
