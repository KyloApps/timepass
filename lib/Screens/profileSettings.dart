import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:timepass/Authentication/SignUpScreen.dart';
import 'package:timepass/Authentication/authServices.dart';
import 'package:timepass/Screens/message_screen.dart';
import 'package:timepass/Widgets/EnabledNotifications.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  Widget items(
    double height,
    double width,
    String title,
    Widget widget,
    IconData icon,
    List<Color> gradient,
  ) {
    return ListTile(
      leading: Container(
        height: height * 0.07,
        width: width * 0.1,
        decoration: BoxDecoration(
            shape: BoxShape.circle, gradient: LinearGradient(colors: gradient)),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: widget,
    );
  }

  Widget divider(double height, double width) {
    return Divider(
      indent: width * 0.04,
      endIndent: width * 0.04,
      color: Colors.black45,
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          child: backAerrowButton(height, width),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(children: [
          SizedBox(
            height: height * 0.035,
          ),
          items(
              height,
              width,
              "Dark Mode",
              Switch(
                activeColor: Colors.white,
                activeTrackColor: Colors.black,
                value: true,
                onChanged: (value) {},
              ),
              Icons.brightness_4,
              [
                Color.fromRGBO(51, 51, 51, 1),
                Color.fromRGBO(51, 51, 51, 0.76),
              ]),
          divider(height, width),
          items(
              height,
              width,
              "Enable / Disable notification",
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return EnableDisabledNotification();
                  }));
                },
                child: Container(
                  margin: EdgeInsets.only(right: width * 0.02),
                  child: Icon(
                    EvaIcons.arrowCircleRight,
                  ),
                ),
              ),
              EvaIcons.bellOutline,
              [
                Color.fromRGBO(52, 190, 169, 1),
                Color.fromRGBO(52, 190, 169, 0.54),
              ]),
          divider(height, width),
          items(
              height,
              width,
              "Help & Support",
              Container(
                height: 0,
                width: 0,
              ),
              Icons.help_outline_outlined,
              [
                Color.fromRGBO(38, 203, 255, 1),
                Color.fromRGBO(38, 203, 255, 0.77),
              ]),
          divider(height, width),
          items(
              height,
              width,
              "About",
              Container(
                height: 0,
                width: 0,
              ),
              Icons.error,
              [
                Color.fromRGBO(255, 182, 0, 1),
                Color.fromRGBO(255, 182, 0, 0.73),
              ]),
          divider(height, width),
          GestureDetector(
            onTap: () async {
              await AuthService().auth.signOut().then((value) async {
                // await AuthService().googleSignIn.signOut();
                await FacebookAuth.instance.logOut();
              }).then((value) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return SignUpScreen();
                }));
              });
            },
            child: items(
                height,
                width,
                "Logout",
                Container(
                  height: 0,
                  width: 0,
                ),
                Icons.logout_sharp,
                [
                  Color.fromRGBO(255, 0, 0, 1),
                  Color.fromRGBO(255, 0, 0, 1),
                ]),
          ),
        ]),
      ),
    );
  }
}
