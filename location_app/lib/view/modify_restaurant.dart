import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
// GetX
import 'package:get/get.dart';
// Image Picker
import 'package:image_picker/image_picker.dart';
// DB
import '../vm/database_handler.dart';

class ModifyRestaurant extends StatefulWidget {
  const ModifyRestaurant({super.key});

  @override
  State<ModifyRestaurant> createState() => _ModifyRestaurant();
}

class _ModifyRestaurant extends State<ModifyRestaurant> {

  // Property
  late DatabaseHandler handler;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController estimateController;
  late String modifyNumber;
  late String phoneNumber;
  late String firstNumber;
  late String phoneBar;
  late List<String> items;
  late String dropdownValue;

  // argument
  var value = Get.arguments ?? '__';

  //Image Picker
  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    nameController = TextEditingController(text: value[0]);
    estimateController = TextEditingController(text: value[2]);
    phoneNumber = '';
    phoneBar = ' - ';
    // 02, 010 구분
    if(value[1].toString().substring(0, 2) == '02'){
    firstNumber = '02';
    dropdownValue = '02';
    modifyNumber = value[1].toString().substring(5, 9) + value[1].toString().substring(12, 16);
    phoneController = TextEditingController(text: modifyNumber);
    }else{
    firstNumber = '010';
    dropdownValue = '010';
    modifyNumber = value[1].toString().substring(6, 10) + value[1].toString().substring(13, 17);
    phoneController = TextEditingController(text: modifyNumber);
    }
    items = ['02', '010'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '맛집 수정',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
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
                            borderRadius: BorderRadius.circular(5)
                          )
                        ),
                      child: const Text(
                          'Image',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                          )
                      ),
                  ),
                ),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      border: Border.all(
                        width: 2,
                        color: Colors.black
                      )
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    child: Center(
                      child: imageFile == null
                      ? Image.memory(value[5])
                      : Image.file(File(imageFile!.path))
                      ,
                    ),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text(
                          '위치',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                          ),
                      ),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                      child: Text(
                        '위도 : ${value[3]}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17
                        ),
                        ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                      child: Text(
                        '경도 : ${value[4]}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17
                        ),
                        ),
                    ),
                  ],
                ),
                const Row(
                    children: [
                      Text(
                        '이름',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                        ),
                        ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: '이름을 입력하세요',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2
                            )
                          )
                        ),
                      ),
                ),
                const Row(
                    children: [
                      Text(
                        '전화번호',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                        ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                        ),
                        ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextField(
                        controller: estimateController,
                        decoration: const InputDecoration(
                          labelText: '평가를 입력하세요',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2
                            )
                          )
                        ),
                      ),
                ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: SizedBox(
                      width: 100,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          if(nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty || estimateController.text.trim().isEmpty){
                            showSnackBar();
                          }else if(phoneController.text.trim().length == 8){
                          phoneNumber = firstNumber + phoneBar + phoneController.text.trim().substring(0, 4) + phoneBar + phoneController.text.trim().substring(4);
                          modifyAction();
                          }else{
                            showSnackBarPhone();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                          )
                        ),
                        child: const Text(
                          '수정',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                          )
                        ),
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
  Future getImageFromGallery(ImageSource imageSource) async{
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if(pickedFile == null){
      return;
    }else {
      imageFile = XFile(pickedFile.path);
      setState(() {});
    }
  }

  Future modifyAction()async{
    if(imageFile != null){
    // File Type을 Byte Type으로 변환하기
    File imageFile1 = File(imageFile!.path);
    Uint8List getImage = await imageFile1.readAsBytes();
      int result = await handler.updateRestauran(
        nameController.text.trim(), phoneNumber, estimateController.text.trim(), getImage, value[6]
      );
      if(result != 0){
        _showDialog();
      }
    }else {
      int result = await handler.updateRestauran(
        nameController.text.trim(), phoneNumber, estimateController.text.trim(), value[5], value[6]
      );
      if(result != 0){
        _showDialog();
      }
    }
    
    
    }
  _showDialog(){
        Get.defaultDialog(
          title: '입력 결과',
          middleText: '입력이 완료되었습니다.',
          backgroundColor: Colors.white,
          barrierDismissible: false,
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Colors.red
                ),
                )
              ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text(
                '수정',
                style: TextStyle(
                  color: Colors.black
                ),
                )
              )
          ]
        );
      }

            showSnackBar(){
        Get.snackbar(
          '경고',
          '빈칸을 모두 채우시오',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          colorText: Colors.white
          );
      }
      showSnackBarPhone(){
        Get.snackbar(
          '경고',
          '연락처를 8자리 입력하세요',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          colorText: Colors.white
          );
      }
} // End