import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:timepass/API/APIservices.dart';
import 'package:timepass/API/BasicAPI.dart';

import 'package:timepass/Screens/message_screen.dart';
import 'package:timepass/Screens/profileSettings.dart';
import 'package:timepass/Utils/colors.dart';

import 'package:http/http.dart' as http;
import 'package:timepass/Widgets/progressIndicators.dart';
import 'package:timepass/main.dart';
import 'package:timepass/models/profileModel.dart';
import 'package:video_player/video_player.dart';

enum PostCategory { Image, Video, Bookmark }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PostCategory postCategory = PostCategory.Image;

  void initState() {
    getStories(userid!);
    super.initState();
  }

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
          throw Exception("Oops! Something went wrong");
        }
      } else {
        throw Exception("Oops! Something went wrong");
      }
    } catch (e) {
      throw Exception("Oops! Something went wrong");
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
          return response.body;
          // return response.body;
        } else {
          throw Exception("Oops! Something went wrong");
        }
      } else {
        throw Exception("Oops! Something went wrong");
      }
    } catch (e) {
      throw Exception("Oops! Something went wrong");
    }
  }

  Widget imageContainer(double height, double width, String imageUrl) {
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

  Widget videoContainer(double height, double width, String url) {
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
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: PostVideoIntializeWidget(
            url: url,
          ),
        ),
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
      Align(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return PostVideoPlayer(
                url: url,
              );
            }));
          },
          child: Icon(
            EvaIcons.playCircleOutline,
            size: height * 0.035,
            color: Colors.grey[300],
          ),
        ),
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
            List<ProfileModel> _totalList = [];
            List<ProfileModel> _imagelist = [];
            List<ProfileModel> _videolist = [];
            postDataList.forEach((element) {
              ProfileModel model = ProfileModel.fromJson(element);
              _totalList.add(model);
              if (model.type == "Image") {
                _imagelist.add(model);
              } else if (model.type == "Video") {
                _videolist.add(model);
              }
            });
            return _totalList.isEmpty
                ? Container(
                    height: height * 0.25,
                    alignment: Alignment.center,
                    child: Text("Posts are not generated."))
                : postCategory == PostCategory.Image
                    ? _imagelist.isEmpty
                        ? Container(
                            height: height * 0.25,
                            alignment: Alignment.center,
                            child: Text("Image posts are not generated."))
                        : StaggeredGridView.countBuilder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            itemCount: _imagelist.length,
                            padding: EdgeInsets.only(
                              left: width * 0.02,
                              right: width * 0.02,
                            ),
                            itemBuilder: (BuildContext context, int i) {
                              return imageContainer(
                                height,
                                width,
                                _imagelist[i].postUrl!,
                              );
                            },
                            crossAxisSpacing: width * 0.02,
                            mainAxisSpacing: height * 0.015,
                            staggeredTileBuilder: (index) {
                              return StaggeredTile.count(
                                  1, index.isOdd ? 1 : 1.4);
                            })
                    : postCategory == PostCategory.Video
                        ? _videolist.isEmpty
                            ? Container(
                                height: height * 0.25,
                                alignment: Alignment.center,
                                child: Text("Video posts are not generated."))
                            : StaggeredGridView.countBuilder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                itemCount: _videolist.length,
                                padding: EdgeInsets.only(
                                  left: width * 0.02,
                                  right: width * 0.02,
                                ),
                                itemBuilder: (BuildContext context, int i) {
                                  return videoContainer(
                                    height,
                                    width,
                                    _videolist[i].postUrl!,
                                  );
                                },
                                crossAxisSpacing: width * 0.02,
                                mainAxisSpacing: height * 0.015,
                                staggeredTileBuilder: (index) {
                                  return StaggeredTile.count(
                                      1, index.isOdd ? 1 : 1.4);
                                })
                        : Container();
          } else if (snapshot.hasError) {
            return Container(
                height: height * 0.25,
                alignment: Alignment.center,
                child: Text("Something went wrong. Try again later."));
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
      padding: postCategory == PostCategory.Image
          ? EdgeInsets.only(right: width * 0.06)
          : postCategory == PostCategory.Bookmark
              ? EdgeInsets.only(left: width * 0.06)
              : EdgeInsets.symmetric(
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
          postCategory == PostCategory.Image
              ? selectedCatagory(
                  height,
                  width,
                  Icon(
                    Icons.category,
                    size: 31,
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      postCategory = PostCategory.Image;
                    });
                  },
                  child: Icon(
                    Icons.category,
                    size: 31,
                  ),
                ),
          postCategory == PostCategory.Video
              ? selectedCatagory(
                  height,
                  width,
                  Icon(
                    Icons.play_circle_fill_outlined,
                    size: 31,
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      postCategory = PostCategory.Video;
                    });
                  },
                  child: Icon(
                    Icons.play_circle_fill_outlined,
                    size: 31,
                  ),
                ),
          postCategory == PostCategory.Bookmark
              ? selectedCatagory(
                  height,
                  width,
                  Icon(
                    EvaIcons.bookmark,
                    size: 31,
                  ))
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      postCategory = PostCategory.Bookmark;
                    });
                  },
                  child: Icon(
                    EvaIcons.bookmark,
                    size: 31,
                  ),
                )
        ],
      ),
    );
  }

  Widget selectedCatagory(double height, double width, Widget icon) {
    return Container(
        width: width * 0.25,
        height: height * 0.072,
        decoration: BoxDecoration(
          gradient: profileCategoryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(147, 144, 144, 0.25),
              offset: Offset(0, 7),
              blurRadius: 10,
              spreadRadius: 0,
            )
          ],
        ),
        child: icon);
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
                                  SizedBox(
                                    height: height * 0.025,
                                  ),
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
                                              "YOUR CITY NAME",
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
                          FutureBuilder(
                              future: getStories(userid!),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  var data = jsonDecode(snapshot.data);
                                  return calculationsWidget(height, width,
                                      data.toString(), "Stories");
                                } else if (snapshot.hasError) {
                                  return calculationsWidget(
                                      height, width, "!", "Stories");
                                } else {
                                  return Container();
                                }
                              }),
                          calculationsWidget(
                              height,
                              width,
                              user.connections!.length.toString(),
                              "Connections"),
                          FutureBuilder(
                              future: getLikes(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  var data2 = jsonDecode(snapshot.data);
                                  return calculationsWidget(height, width,
                                      data2.toString(), "Total Likes");
                                } else if (snapshot.hasError) {
                                  return calculationsWidget(
                                      height, width, "0", "Total Likes");
                                } else {
                                  return Container();
                                }
                              }),
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
        color: Theme.of(context).primaryColor,
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

class PostVideoIntializeWidget extends StatefulWidget {
  final String? url;
  PostVideoIntializeWidget({this.url});

  @override
  _PostVideoIntializeWidgetState createState() =>
      _PostVideoIntializeWidgetState();
}

class _PostVideoIntializeWidgetState extends State<PostVideoIntializeWidget> {
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    videoPlayerController = VideoPlayerController.network(widget.url!);
    getStories(userid!);
    videoPlayerController.initialize().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: VideoPlayer(
        videoPlayerController,
      ),
    );
  }
}

class PostVideoPlayer extends StatefulWidget {
  final String? url;
  PostVideoPlayer({this.url});
  @override
  _PostVideoPlayerState createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  @override
  void initState() {
    initialize();

    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  Future initialize() async {
    videoPlayerController = VideoPlayerController.network(widget.url!);

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      aspectRatio: 1,
      allowFullScreen: false,
      showControls: true,
      looping: false,
      placeholder: Center(
        child: circularProgressIndicator(),
      ),
    );
  }

  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: backAerrowButton(height, width),
          ),
          title: Text(
            "Posted video",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    child: Chewie(
                      controller: chewieController,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
