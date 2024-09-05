import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// GetX
import 'package:get/get.dart';
// 위치 정보 패키지
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlng;

class LocateRestaurant extends StatefulWidget {
  const LocateRestaurant({super.key});

  @override
  State<LocateRestaurant> createState() => _LocateRestaurantState();
}

class _LocateRestaurantState extends State<LocateRestaurant> {
  late Position currentPosition;
  late double latData;
  late double longData;
  late bool canRun;
  late MapController mapController;

  var value = Get.arguments ?? '__';

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    canRun = false;
    latData = value[0];
    longData = value[1];
    checkLocationPermission();
  }

  checkLocationPermission()async{
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }
    
    if(permission == LocationPermission.deniedForever){
      return;
    }

    if(permission == LocationPermission.whileInUse || permission == LocationPermission.always){
      getCurrentLocation();
    }
  }

  getCurrentLocation() async{
    // 현재 위치 저장
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;
        canRun = true;
        latData = currentPosition.latitude;
        longData = currentPosition.longitude;
        // print("lat:$latData, long:$longData");
        setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '맛집 위치',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
          ),
      ),
      // 맵 출력
      body: canRun 
      ? flutterMap()
      : const Center(
        child: CircularProgressIndicator(),
      )
    );
  }
  // Widget
  Widget flutterMap(){
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: latlng.LatLng(latData, longData),
        initialZoom: 17
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: [
            // 음식점 위치 마커
            Marker(
              width: 80,
              height: 80,
              point: latlng.LatLng(latData, longData),
              child: Column(
                children: [
                  SizedBox(
                    child: Text(
                      value[2],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),
                  ),
                  Icon(
                    Icons.pin_drop,
                    size: 50,
                    color: Colors.red,
                  )
                ],
              )
              )
          ]
          )
      ]
      );
  }
}