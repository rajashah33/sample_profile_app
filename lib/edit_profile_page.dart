import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  var pickedFile;
  String profileImgUrl = '';
  String username = '';
  bool isUploading = false;

  Future getSharedPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    profileImgUrl = prefs.getString('imgUrl')!;
    print(profileImgUrl);
    username = prefs.getString('username')!;
    print(username);
  }

  Future<String> uploadFileToFirebaseStorage(XFile file) async {
    setState(() {
      isUploading = true;
    });
    Reference reference =
        FirebaseStorage.instance.ref().child('profilePics/${file.name}');
    UploadTask uploadTask = reference.putFile(File(file.path));
    String downloadUrl = await uploadTask.then((res) async {
      String url = await res.ref.getDownloadURL();
      //success
      return url;
    }, onError: (err) {
      return null;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('imgUrl', downloadUrl);
    setState(() {
      isUploading = false;
      profileImgUrl = downloadUrl;
    });
    return downloadUrl;
  }

  @override
  void initState() {
    getSharedPrefs().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SafeArea(
        child: Center(
          child: ListView(
            // shrinkWrap: true,
            children: [
              Container(
                margin: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                          margin: EdgeInsets.only(right: 8),
                          child: TextFormField(
                            // controller: nameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Full Name',
                            ),
                            // initialValue: username,
                            controller: TextEditingController(text: username),
                            onChanged: (text) {
                              username = text;
                            },
                          )),
                    ),
                    ConstrainedBox(
                      constraints:
                          BoxConstraints.tightFor(width: 100, height: 57),
                      child: ElevatedButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('username', username);
                            print(prefs.getString('username'));
                          },
                          child: Text('Change')),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: isUploading
                    ? Center(
                        child: Image.asset(
                          'assets/pw.gif',
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,
                        ),
                      )
                    : profileImgUrl.isEmpty
                        ? Image.asset('assets/default_avatar.png')
                        : FadeInImage.assetNetwork(
                            fit: BoxFit.cover,
                            height: 300,
                            width: 300,
                            placeholder: 'assets/pw.gif',
                            image: profileImgUrl,
                          ),
              ),
              Container(
                margin: EdgeInsets.only(left: 80, right: 80),
                height: 50,
                // constraints: BoxConstraints.tightFor(width: 200, height: 50),
                child: ElevatedButton(
                  child: Text('Change Profile Picture'),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context1) {
                          return AlertDialog(
                              title: new Text("Select Image"),
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                      iconSize: 45,
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: () async {
                                        pickedFile = (await ImagePicker()
                                            .pickImage(
                                                source: ImageSource.camera))!;

                                        Navigator.pop(context);
                                        await uploadFileToFirebaseStorage(
                                            pickedFile);
                                      }),
                                  IconButton(
                                      iconSize: 45,
                                      icon: Icon(Icons.photo),
                                      onPressed: () async {
                                        pickedFile = (await ImagePicker()
                                            .pickImage(
                                                source: ImageSource.gallery))!;

                                        Navigator.pop(context);
                                        await uploadFileToFirebaseStorage(
                                            pickedFile);
                                      }),
                                ],
                              ));
                        });
                    // if (pickedFile != null) {
                    //   print('File Picked');
                    //   print(pickedFile.path);
                    //   print(pickedFile.name);
                    // }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
