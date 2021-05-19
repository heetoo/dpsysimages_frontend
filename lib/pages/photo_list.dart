import 'package:dpsysimages/pages/photo_take.dart';
import 'package:dpsysimages/pages/photo_view.dart';
import 'package:dpsysimages/store/image_model.dart';
import 'package:dpsysimages/store/local_storage.dart';
import 'package:dpsysimages/store/remote_storage.dart';
import 'package:flutter/material.dart';

class PhotoListItem extends StatelessWidget {
  final ImageModel image;

  PhotoListItem(this.image);

  String get localPath {
    if (image.localPath != null) return image.localPath!;
    return "not local";
  }

  String get url {
    if (image.url != null) return image.url!;
    return "not remote";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PhotoView(image: image),
          ),
        );
      },
      title: Text(image.name),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(image.id),
          Text(localPath),
          Text(url),
        ],
      ),
    );
  }
}

class PhotoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final local = LocalStorage.getInstance();
    final remote = RemoteStorage.getInstance();
    remote.load();
    local.load();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("PhotoList"),
        actions: [
          GestureDetector(
            child: Icon(Icons.replay_outlined),
            onTap: () {
              remote.load();
              local.load();
            },
          ),
        ],
      ),
      body: StreamBuilder<Map<String, ImageModel>>(
        stream: local.imagesStream,
        builder: (context, snapshot) {
          var images = Map<String, ImageModel>();
          if (snapshot.hasData) {
            final imagesData = snapshot.data;
            if (imagesData != null) images = imagesData;
          }
          return ListView(
            children: images
                .map((id, image) => MapEntry(id, PhotoListItem(image)))
                .values
                .toList(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt_outlined),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => PhotoTake()));
        },
      ),
    );
  }
}
