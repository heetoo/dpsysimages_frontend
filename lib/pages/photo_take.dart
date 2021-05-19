import 'package:dpsysimages/pages/photo_view.dart';
import 'package:dpsysimages/store/image_model.dart';
import 'package:dpsysimages/store/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';

class PhotoTake extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CameraDescription>>(
      future: availableCameras(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator();
        }

        final cameras = snapshot.data;
        if (cameras != null) {
          return PhotoTakeCamera(cameras);
        }
        return Text("What");
      },
    );
  }
}

class PhotoTakeCamera extends StatefulWidget {
  final List<CameraDescription> cameras;

  PhotoTakeCamera(this.cameras);

  @override
  _PhotoTakeCameraState createState() => _PhotoTakeCameraState();
}

class _PhotoTakeCameraState extends State<PhotoTakeCamera> {
  CameraController? _controller;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.max);
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller is CameraController) {
      if (!controller.value.isInitialized) {
        return Container();
      } else {
        return PhotoTakeCameraContainer(
          CameraPreview(controller),
          controller,
          () {
            setState(() {
              saving = true;
            });
          },
          () {
            setState(() {
              saving = false;
            });
          },
          saving,
        );
      }
    }
    return PhotoTakeNoCamera();
  }
}

class PhotoTakeCameraContainer extends StatelessWidget {
  final CameraController controller;
  final Widget preview;
  final Function saving;
  final Function saved;
  final bool loading;

  PhotoTakeCameraContainer(
    this.preview,
    this.controller,
    this.saving,
    this.saved,
    this.loading,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("PhotoTake"),
      ),
      body: Center(
        child: loading ? CircularProgressIndicator() : preview,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: () async {
          saving();
          final uuid = Uuid();
          final image = await this.controller.takePicture();
          final imageId = uuid.v4();
          LocalStorage local = LocalStorage.getInstance();
          final model = ImageModel(
            id: imageId,
            name: image.name,
            localPath: image.path,
          );
          local.setImage(model);
          local.save();

          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => PhotoView(image: model)),
          );
          saved();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class PhotoTakeNoCamera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("No Camera"),
      ),
    );
  }
}
