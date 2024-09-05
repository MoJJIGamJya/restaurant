import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
// GetX
import 'package:get/get.dart';
// image Picker
import 'package:image_picker/image_picker.dart';
// 위치 정보 패키지
import 'package:latlong2/latlong.dart';
import 'package:location_app/model/restaurant.dart';
import 'package:geolocator/geolocator.dart';

import '../vm/database_handler.dart';

class InsertAddress extends StatefulWidget {
  const InsertAddress({super.key});

  @override
  State<InsertAddress> createState() => _InsertAddressState();
}

class _InsertAddressState extends State<InsertAddress> {
  // Property
  late Distance distance;
  late DatabaseHandler handler;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController estimateController;
  late double latData;
  late double longData;
  late Position currentPosition;
  late String phoneNumber;
  late String firstNumber;
  late String phoneBar;
  late String dropdownValue;
  late List<String> items;
  late double km;
  //Image Picker
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    distance = const Distance(); // 위치 정보
    handler = DatabaseHandler(); // DB
    km = 0;
    firstNumber = '02';
    items = ['02', '010'];
    dropdownValue = '02';
    phoneNumber = '';
    phoneBar = ' - ';
    latData = 0;
    longData = 0;
    latitudeController = TextEditingController();
    longitudeController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    estimateController = TextEditingController();
    checkLocationPermission();
  }

  checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      getCurrentLocation();
    }
  }

  getCurrentLocation() async {
    // 현재 위치 저장
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;
    latData = currentPosition.latitude;
    longData = currentPosition.longitude;
    latitudeController.text = latData.toString();
    longitudeController.text = longData.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '맛집 추가',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  // 갤러리에서 이미지 선택
                  child: SizedBox(
                    width: 100,
                    height: 45,
                    child: ElevatedButton(
                        onPressed: () {
                          getImageFromGallery(ImageSource.gallery);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: const Text(
                          'Image',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        )),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      border: Border.all(width: 2, color: Colors.black)),
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  child: Center(
                    child: imageFile == null
                        ? const Text('image is not selected')
                        : Image.file(File(imageFile!.path)),
                  ),
                ),
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        '위치',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ],
                ),
                // DB정보 저장
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: SizedBox(
                        width: 180,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: latitudeController,
                          // readOnly: true,
                          decoration: const InputDecoration(
                              labelText: '위도를 입력하세요',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 2))),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                      child: SizedBox(
                        width: 180,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: longitudeController,
                          // readOnly: true,
                          decoration: const InputDecoration(
                              labelText: '경도를 입력하세요',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 2))),
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      '이름',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: '이름을 입력하세요',
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2))),
                  ),
                ),
                const Row(
                  children: [
                    Text(
                      '전화번호',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
                Row(
                  children: [
                    DropdownButton(
                      dropdownColor: Colors.white,
                      iconEnabledColor: Colors.black,
                      value: dropdownValue, // 드롭다운버튼 초기값
                      icon: const Icon(
                          Icons.keyboard_arrow_down), // 오른쪽에있는 밑방향 화살표
                      items: items.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(
                            items,
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(), // 시작할 때 .map으로 바꾸고 시작해서 .toList()로 바꾸어 주어야 한다.
                      onChanged: (value) {
                        dropdownValue = value!;
                        firstNumber = value;
                        setState(() {});
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
                      child: SizedBox(
                        width: 300,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: phoneController,
                          maxLength: 8,
                          decoration: const InputDecoration(
                              labelText: '전화번호를 입력하세요',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 2))),
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      '평가',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: estimateController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: '평가를 입력하세요',
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                  child: SizedBox(
                    width: 100,
                    height: 45,
                    child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty ||
                              phoneController.text.trim().isEmpty ||
                              estimateController.text.trim().isEmpty) {
                            showSnackBar(); // 입력칸이 비어있으면 스낵바 출력
                          } else if (phoneController.text.trim().length == 8) {
                            // 휴대폰, 전화번호 '-' 추가 저장
                            phoneNumber = firstNumber +
                                phoneBar +
                                phoneController.text.trim().substring(0, 4) +
                                phoneBar +
                                phoneController.text.trim().substring(4);
                            insertAction();
                          } else {
                            // 전화번호 8자리 적지 않으면 스낵바 출력
                            showSnackBarPhone();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5))),
                        child: const Text(
                          '입력',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---Function---
  // 외부의 갤러리 이기 때문에 async를 써준다.
  Future getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) {
      return;
    } else {
      imageFile = XFile(pickedFile.path);
      setState(() {});
    }
  }

  Future insertAction() async {
    // File Type을 Byte Type으로 변환하기
    File imageFile1 = File(imageFile!.path);
    Uint8List getImage = await imageFile1.readAsBytes();
    km = distance.as(LengthUnit.Meter, LatLng(double.parse(latitudeController.text.trim()), double.parse(longitudeController.text.trim())), LatLng(latData, longData));
    var restaurantInsert = Restaurant(
        latitude: double.parse(latitudeController.text.trim()),
        longitude: double.parse(longitudeController.text.trim()),
        name: nameController.text.trim(),
        phone: phoneNumber,
        estimate: estimateController.text.trim(),
        image: getImage,
        distance: km);
    int result = await handler.insertRestaurant(restaurantInsert);
    if (result != 0) {
      _showDialog();
    }
  }

  _showDialog() {
    Get.defaultDialog(
        title: '입력 결과',
        titleStyle: const TextStyle(color: Colors.black),
        middleText: '입력이 완료되었습니다.',
        middleTextStyle: const TextStyle(color: Colors.black),
        backgroundColor: Colors.white,
        barrierDismissible: false,
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('취소')),
          TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text(
                '추가',
                style: TextStyle(color: Colors.black),
              ))
        ]);
  }

  showSnackBar() {
    Get.snackbar('경고', '빈칸을 모두 채우시오',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white);
  }

  showSnackBarPhone() {
    Get.snackbar('경고', '연락처를 8자리 입력하세요',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white);
  }
} // End