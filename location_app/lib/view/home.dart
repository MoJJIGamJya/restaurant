import 'dart:async';
import 'package:flutter/material.dart';
// slidable
import 'package:flutter_slidable/flutter_slidable.dart';
//geolocator
import 'package:geolocator/geolocator.dart';
// GetX
import 'package:get/get.dart';
// latlong
import 'package:latlong2/latlong.dart';
//Location
import 'package:location_app/view/insert_rastaurant.dart';
import 'package:location_app/view/locate_restaurant.dart';
import 'package:location_app/view/modify_restaurant.dart';
import 'package:location_app/vm/database_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // property
  late Distance distance;
  late DatabaseHandler handler;
  late Position currentPosition;
  late double latData;
  late double lonData;
  late String inputText;
  late double meter;
  late String dropdownValue;
  late List<String> items;
  late String arrayitem;

  @override
  void initState() {
    super.initState();
    dropdownValue = '선택';
    items = ['선택', '가까운순', '먼 순'];
    arrayitem = '';
    meter = 0;
    // 거리 계산
    distance = const Distance();
    // DB
    handler = DatabaseHandler();
    latData = 0;
    lonData = 0;
    inputText = '';
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
    // 현재 위치
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;
    latData = currentPosition.latitude;
    lonData = currentPosition.longitude;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            '내가 경험한 맛집 리스트',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          actions: [
            DropdownButton(
              dropdownColor: Colors.white,
              iconEnabledColor: Colors.black,
              value: dropdownValue, // 드롭다운버튼 초기값
              icon: const Icon(Icons.keyboard_arrow_down), // 오른쪽에있는 밑방향 화살표
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
                arrayitem = value;
                setState(() {});
              },
            ),
            IconButton(
                onPressed: () {
                  checkLocationPermission();
                },
                icon: const Icon(Icons.refresh)),
            IconButton(
                onPressed: () {
                  Get.to(() => const InsertAddress())!
                      .then((value) => reloadData());
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                // 검색창
                child: SearchBar(
                  hintText: '검색어를 입력하세요',
                  keyboardType: TextInputType.text,
                  backgroundColor: const WidgetStatePropertyAll(Colors.white),
                  side: WidgetStateProperty.all(
                      const BorderSide(color: Colors.black, width: 2)),
                  trailing: const [Icon(Icons.search)],
                  onSubmitted: (value) {
                    inputText = value; // value값 저장
                    searchList(inputText);
                    setState(() {});
                  },
                ),
              ),
              SizedBox(
                height: 745,
                child: FutureBuilder(
                  // 검색, 정렬
                  future: arrayitem == '가까운순'
                      ? handler.arrayRestaurant()
                      : arrayitem == '먼 순'
                          ? handler.arrayRestaurantDESC()
                          : inputText == ''
                              ? handler.queryRestaurant()
                              : handler.searchRestaurant(inputText),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          // 현재위치, 가게위치 계산 후 업데이트
                          for (int i = 0; i < snapshot.data!.length; i++) {
                            meter = distance.as(
                                LengthUnit.Meter,
                                LatLng(latData, lonData),
                                LatLng(snapshot.data![i].latitude,
                                    snapshot.data![i].longitude));
                            updateList(meter, snapshot.data![i].seq);
                          }
                          return GestureDetector(
                            // 리스트 터치 후 지도로 이동
                            onTap: () {
                              Get.to(() => const LocateRestaurant(),
                                      arguments: [
                                    snapshot.data![index].latitude,
                                    snapshot.data![index].longitude,
                                    snapshot.data![index].name
                                  ])!
                                  .then(
                                (value) => reloadData(),
                              );
                            },
                            child: Slidable(
                              startActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    // 수정
                                    SlidableAction(
                                      borderRadius: BorderRadius.circular(5),
                                      onPressed: (context) {
                                        Get.to(() => const ModifyRestaurant(),
                                                arguments: [
                                              snapshot.data![index].name,
                                              snapshot.data![index].phone,
                                              snapshot.data![index].estimate,
                                              snapshot.data![index].latitude,
                                              snapshot.data![index].longitude,
                                              snapshot.data![index].image,
                                              snapshot.data![index].seq
                                            ])!
                                            .then((value) => reloadData());
                                      },
                                      backgroundColor: Colors.lightGreen,
                                      foregroundColor: Colors.white,
                                      icon: Icons.edit,
                                      label: '수정',
                                    )
                                  ]),
                              endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    // 삭제
                                    SlidableAction(
                                      borderRadius: BorderRadius.circular(5),
                                      onPressed: (context) {
                                        int seq = snapshot.data![index].seq!;
                                        showDialog(seq);
                                        setState(() {});
                                      },
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    )
                                  ]),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    // 리스트 출력
                                child: Card(
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 30, 10),
                                        child: Image.memory(
                                          snapshot.data![index].image,
                                          width: 100,
                                          height: 100,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '가게 이름 : ${snapshot.data![index].name}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '연락처 : ${snapshot.data![index].phone}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '거리 : ${snapshot.data![index].distance!.toStringAsFixed(0)}M',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }

  // Function
  reloadData() {
    setState(() {});
  }

  Future deleteList(int seq) async {
    await handler.deleteRestaurant(seq);
  }

  showDialog(seq) {
    Get.defaultDialog(
        backgroundColor: Colors.white,
        title: '삭제',
        middleText: '정말로 삭제하시겠습니까?',
        barrierDismissible: false,
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.black),
              )),
          TextButton(
              onPressed: () {
                deleteList(seq);
                Get.back();
                setState(() {});
              },
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ))
        ]);
  }
  // 검색
  Future searchList(String name) async {
    await handler.searchRestaurant(name);
  }
  // 업데이트
  Future updateList(distance, seq) async {
    await handler.updateRestauranDistance(distance, seq);
  }
}
