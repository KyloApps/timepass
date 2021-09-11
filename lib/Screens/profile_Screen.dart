import 'dart:convert';
import 'dart:math';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:timepass/API/BasicAPI.dart';
import 'package:timepass/Authentication/authServices.dart';
import 'package:timepass/Screens/leaderBoard.dart';
import 'package:timepass/Screens/profileSettings.dart';
import 'package:timepass/Utils/colors.dart';
import 'package:timepass/Widgets/backAerrowWidget.dart';
import 'package:http/http.dart' as http;
import 'package:timepass/Widgets/progressIndicators.dart';
import 'package:timepass/main.dart';
import 'package:timepass/models/profileModel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void initState() {
    super.initState();
  }
  //Leading icon

  //grid items
  Widget gridItems(String path) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(path),
        ),
      ),
    );
  }

  Future getProfile() async {
    try {
      var url = Uri.parse('$weburl/profile');
      var response;
      if (xAccessToken != null) {
        response = await http.get(url, headers: {
          'x-access-token': xAccessToken!,
        });
        if (response.statusCode == 200) {
          return response.body;
        } else {
          AuthService().errorDialog(
            context,
            "Oops! Something went wrong",
          );
        }
      } else {
        AuthService().errorDialog(
          context,
          "Oops! Something went wrong",
        );
      }
    } catch (e) {
      AuthService().errorDialog(
        context,
        "Oops! Something went wrong",
      );
    }
  }

  Future getUserPost() async {
    try {
      var url = Uri.parse('$weburl/posts/post/$userid');
      var response;
      if (xAccessToken != null) {
        response = await http.get(url, headers: {
          'x-access-token': xAccessToken!,
        });
        if (response.statusCode == 200) {
          print(response.body);
          return response.body;
          // return response.body;
        } else {
          AuthService().errorDialog(
            context,
            "Oops! Something went wrong",
          );
        }
      } else {
        AuthService().errorDialog(
          context,
          "Oops! Something went wrong",
        );
      }
    } catch (e) {
      AuthService().errorDialog(
        context,
        "Oops! Something went wrong",
      );
    }
  }

  Widget container(double height, double width, String imageUrl) {
    return Stack(children: [
      Container(
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.009,
        ),
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey[600]!,
                blurRadius: 0.07,
                spreadRadius: 0.07,
              )
            ],
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(imageUrl),
              // image: AssetImage(
              //   'assets/images/s${Random().nextInt(9) + 1}.jpg',
              // )
            )),
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: Container(
            height: height * 0.05,
            margin: EdgeInsets.only(
              right: width * 0.03,
              bottom: 0,
            ),
            alignment: Alignment.centerRight,
            child: Container(
              height: height * 0.06,
              width: width * 0.06,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(
                  0.4,
                ),
              ),
              child: Icon(
                EvaIcons.share,
                size: 12,
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
            )),
      ),
    ]);
  }

  //gridview
  Widget gridview(double height, double width) {
    return FutureBuilder(
        future: getUserPost(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var postDataList = jsonDecode(snapshot.data!);
            List<ProfileModel> _list = [];
            postDataList.forEach((element) {
              ProfileModel model = ProfileModel.fromJson(element);
              _list.add(model);
            });
            return _list.isEmpty
                ? Container(
                    height: height * 0.25,
                    alignment: Alignment.center,
                    child: Text("Posts are not generated."))
                : StaggeredGridView.countBuilder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    itemCount: _list.length,
                    padding: EdgeInsets.only(
                      left: width * 0.02,
                      right: width * 0.02,
                    ),
                    itemBuilder: (BuildContext context, int i) {
                      return container(
                        height,
                        width,
                        _list[i].postUrl!,
                      );
                    },
                    crossAxisSpacing: width * 0.02,
                    mainAxisSpacing: height * 0.015,
                    staggeredTileBuilder: (index) {
                      return StaggeredTile.count(1, index.isOdd ? 1 : 1.4);
                    });
          } else {
            return Container(
              height: height * 0.6,
              child: Center(child: circularProgressIndicator()),
            );
          }
        });
  }

  Widget calculationsWidget(
      double height, double width, String title, String subtitle) {
    return Container(
      height: height * 0.1,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: height * 0.011, bottom: height * 0.01),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 19,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Color.fromRGBO(255, 255, 255, 0.74),
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              )),
        ],
      ),
    );
  }

  //CenterBar
  Widget centerbar(double height, double width) {
    return Container(
      height: height * 0.072,
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.06,
      ),
      margin: EdgeInsets.only(
        top: height * 0.005,
        left: width * 0.08,
        right: width * 0.08,
        bottom: height * 0.01,
      ),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 1),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(147, 144, 144, 0.25),
            offset: Offset(0, 7),
            blurRadius: 10,
            spreadRadius: 0,
          )
        ],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.category,
            size: 31,
          ),
          Icon(
            Icons.play_circle_fill_outlined,
            size: 31,
          ),
          Icon(
            EvaIcons.bookmark,
            size: 31,
          )
        ],
      ),
    );
  }

  Widget storyContainer(
    double height,
    double width,
    String image,
  ) {
    return Container(
      child: ClipOval(
        clipBehavior: Clip.antiAlias,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(3.2),
            child: ClipOval(
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: height * 0.105,
                width: width * 0.22,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                        image,
                      ),
                      fit: BoxFit.cover),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Color.fromRGBO(38, 203, 255, 1),
              Color.fromRGBO(38, 203, 255, 1),
              Color.fromRGBO(105, 128, 253, 1),
              Color.fromRGBO(105, 128, 253, 1),
            ]),
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
    );
  }

  //profile Header
  Widget profileHeader(double height, double width) {
    return Container(
      height: height * 0.405,
      width: width,
      decoration: BoxDecoration(
          color: Color.fromRGBO(40, 40, 40, 1),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(34),
            bottomRight: Radius.circular(34),
          )),
      child: FutureBuilder(
          future: getProfile(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var result = jsonDecode(snapshot.data);
              UserProfile user = UserProfile.fromJson(result);
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.015),
                    Container(
                      margin: EdgeInsets.only(
                        left: width * 0.045,
                        top: height * 0.025,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          storyContainer(
                            height,
                            width,
                            user.imageurl!,
                          ),
                          SizedBox(
                            width: width * 0.04,
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.name.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 22,
                                              ),
                                            ),
                                            Text(
                                              "vijayawada,AP",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder:
                                                    (BuildContext context) {
                                              return ProfileSettingsScreen();
                                            }));
                                          },
                                          icon: Icon(
                                            EvaIcons.settings2Outline,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ]),
                                  Container(
                                    margin: EdgeInsets.only(
                                      right: width * 0.07,
                                      top: height * 0.015,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          height: height * 0.05,
                                          width: width * 0.28,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              gradient: LinearGradient(colors: [
                                                Color.fromRGBO(
                                                    38, 203, 255, 0.86),
                                                Color.fromRGBO(
                                                    38, 203, 255, 0.5),
                                                Color.fromRGBO(
                                                    38, 203, 255, 0.48),
                                              ])),
                                          child: Text("Connect",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder:
                                                    (BuildContext context) {
                                              return LeaderBoard();
                                            }));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                left: width * 0.04),
                                            alignment: Alignment.center,
                                            height: height * 0.05,
                                            width: width * 0.28,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color.fromRGBO(
                                                      200, 16, 46, 0.63),
                                                  Color.fromRGBO(
                                                      200, 16, 46, 0.76),
                                                  Color.fromRGBO(
                                                      200, 16, 46, 0.47),
                                                ])),
                                            child: Text("Message",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: width * 0.15,
                        right: width * 0.15,
                        top: height * 0.028,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          calculationsWidget(height, width, "100", "Stories"),
                          calculationsWidget(
                              height,
                              width,
                              user.connections!.length.toString(),
                              "Connections"),
                          calculationsWidget(
                              height, width, "5K", "Total likes"),
                        ],
                      ),
                    ),
                    centerbar(height, width),
                  ]);
            } else if (snapshot.hasError) {
              return Text("Something went wrong");
            } else {
              return Center(
                child: circularProgressIndicator(),
              );
            }
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Material(
      child: Container(
        color: Colors.white,
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            profileHeader(height, width),
            SizedBox(
              height: height * 0.015,
            ),
            gridview(height, width),
          ],
        ),
      ),
    );
  }
}
