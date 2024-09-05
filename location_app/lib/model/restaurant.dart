import 'dart:typed_data';

class Restaurant {
  final int? seq;
  final double latitude;
  final double longitude;
  final String name;
  final String phone;
  final String estimate;
  final Uint8List image;
  final double? distance;

  Restaurant(
      {this.seq,
      required this.latitude,
      required this.longitude,
      required this.name,
      required this.phone,
      required this.estimate,
      required this.image,
      this.distance});

        Restaurant.fromMap(Map<String, dynamic> res)
      : seq = res['seq'],
        latitude = res['latitude'],
        longitude = res['longitude'],
        name = res['name'],
        phone = res['phone'],
        estimate = res['estimate'],
        image = res['image'],
        distance = res['distance'];
}
