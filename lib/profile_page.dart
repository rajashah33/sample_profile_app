import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sample_app_nm/edit_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String profileImgUrl = '';
  String username = '';
  Future getSharedPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    profileImgUrl = prefs.getString('imgUrl')!;
    print(profileImgUrl);
    username = prefs.getString('username')!;
    print(username);
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
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  var prefs = await SharedPreferences.getInstance();
                  prefs.setString('imgUrl', '');
                  await Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => EditProfilePage()));

                  getSharedPrefs().then((value) {
                    setState(() {});
                  });
                },
                child: Text('Edit Profile'),
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Column(
                children: [
                  Text(
                    'Howdy, ' + username,
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(height: 40),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(150.0),
                    child: profileImgUrl.isEmpty
                        ? Image.asset(
                            'assets/default_avatar.png',
                            height: 300,
                            width: 300,
                          )
                        : FadeInImage.assetNetwork(
                            fit: BoxFit.cover,
                            height: 300,
                            width: 300,
                            placeholder: 'assets/default_avatar.png',
                            image: profileImgUrl,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
