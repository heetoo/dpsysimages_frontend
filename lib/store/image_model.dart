class ImageModel {
  final String id;
  final String name;
  final String? url;
  final String? localPath;

  ImageModel({
    required this.id,
    required this.name,
    this.url,
    this.localPath,
  });

  ImageModel copyWith({String? url, String? localPath}) {
    return ImageModel(
      id: this.id,
      name: this.name,
      url: url != null ? url : this.url,
      localPath: localPath != null ? localPath : this.localPath,
    );
  }

  ImageModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        url = json['url'],
        localPath = json['localPath'],
        name = json['name'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'localPath': localPath,
    };
  }
}
