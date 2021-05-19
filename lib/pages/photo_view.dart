import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../store/image_model.dart';
import '../store/local_storage.dart';
import '../store/remote_storage.dart' show api;

class PhotoView extends StatelessWidget {
  final ImageModel image;

  const PhotoView({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Photo View'),
      ),
      body: Center(child: DownloadImage(image)),
    );
  }
}

class UploadImage extends StatelessWidget {
  final ImageModel image;

  UploadImage(this.image);

  Widget _show(context, image) {
    return image.localPath != null
        ? Image.file(File(image.localPath))
        : Text("No local Image to view");
  }

  @override
  Widget build(BuildContext context) {
    final url = Uri.parse(api);
    final localPath = image.localPath;

    if (localPath == null || image.url != null) return _show(context, image);

    final data = File(localPath).readAsBytesSync();
    final base64data = base64Encode(data);

    final body = {
      'id': image.id,
      'name': image.name,
      'image': base64data,
    };

    return FutureBuilder<http.Response>(
      future: http.post(url, body: body),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done)
          return Center(child: CircularProgressIndicator());

        final response = snap.data;
        if (response != null) {
          if (response.statusCode == 201) {
            final Map<String, dynamic> jsonBody = jsonDecode(response.body);
            final local = LocalStorage.getInstance();
            final localImage = image.copyWith(
              url: jsonBody['image'] as String,
            );
            local.setImage(localImage);
            local.save();

            return _show(context, localImage);
          }
        }

        return _show(context, image);
      },
    );
  }
}

class DownloadImage extends StatelessWidget {
  final ImageModel image;

  DownloadImage(this.image);

  Future<String> download(String imageUrl) async {
    final url = Uri.parse(imageUrl);
    var documentDirectory = await getApplicationDocumentsDirectory();
    final response = await http.get(url);
    print(response.statusCode);
    final path = "${documentDirectory.path}/${image.name}";
    File imageFile = new File(path);
    imageFile.writeAsBytesSync(response.bodyBytes);
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final localPath = image.localPath;
    final imageUrl = image.url;
    if (localPath != null || imageUrl == null) return UploadImage(image);

    return FutureBuilder<String>(
      future: download(imageUrl),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done)
          return Center(
            child: CircularProgressIndicator(),
          );
        final localImage = image.copyWith(localPath: snap.data);
        final local = LocalStorage.getInstance();
        local.setImage(localImage);
        local.save();
        return UploadImage(
          localImage,
        );
      },
    );
  }
}
