import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home.dart';
import 'round_slider_track_shape.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  TabController _tabController;

  final _player = AudioPlayer();
  final _formKey = GlobalKey<FormState>();

  var _ctrlTitle = TextEditingController();
  var _ctrlDesc = TextEditingController();
  var _ctrlDescUser = TextEditingController();
  var _ctrlLink1 = TextEditingController();
  var _ctrlLink2 = TextEditingController();
  var _ctrlLink3 = TextEditingController();
  var _ctrlTitleAdd = TextEditingController();
  var _ctrlDescAdd = TextEditingController();

  File _voiceFile = File("");
  File _imgUserFile = File("");
  File _imgVoiceFile = File("");
  File _imgAddVoiceFile = File("");

  bool _isAddVoice = false;
  bool _isPlay = false;
  bool _isListen = false;
  bool _isEdit = false;
  bool _isEditDescUser = false;
  bool _isEditLink1 = false;
  bool _isEditLink2 = false;
  bool _isEditLink3 = false;

  @override
  void dispose() {
    _player.dispose();
    _tabController.dispose();
    _ctrlTitle.dispose();
    _ctrlDesc.dispose();
    _ctrlDescUser.dispose();
    _ctrlLink1.dispose();
    _ctrlLink2.dispose();
    _ctrlLink3.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
          (route) => false),
      child: SafeArea(
        child: _isEdit
            ? Material(
                child: _editVoice(),
              )
            : _isAddVoice
                ? Material(
                    child: _addVoice(),
                  )
                : Scaffold(
                    body: Stack(
                      children: [
                        // صورة الخلفية
                        Image.asset("assets/images/background_login.webp",
                            height: double.maxFinite, fit: BoxFit.cover),
                        // لون شفاف على الخلفية
                        Container(
                          color: Color(0xdd000000),
                        ),

                        Column(
                          children: [
                            // صورة المستخدم واسمه وتاريخ انضمامه
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  // صورة المستخدم
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 55,
                                        backgroundImage: _imgUserFile.path == ""
                                            ? AssetImage(
                                                "assets/images/user1.webp")
                                            : FileImage(_imgUserFile),
                                      ),
                                      Positioned(
                                          left: 0,
                                          right: 0,
                                          top: 0,
                                          bottom: 0,
                                          child: Material(
                                              color: Colors.transparent,
                                              child: IconButton(
                                                  icon: Icon(
                                                    Icons.add_a_photo,
                                                    color: Colors.blue,
                                                  ),
                                                  onPressed: () async {
                                                    FilePickerResult result =
                                                        await FilePicker
                                                            .platform
                                                            .pickFiles();
                                                    if (result != null) {
                                                      setState(() {
                                                        _imgUserFile = File(
                                                            result.files.single
                                                                .path);
                                                      });
                                                    }
                                                  })))
                                    ],
                                  ),

                                  // الاسم والتاريخ
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // الاسم
                                        Container(
                                          padding: EdgeInsets.all(15),
                                          margin: EdgeInsets.only(
                                              left: 5, bottom: 5),
                                          child: Text("Name"),
                                          decoration: BoxDecoration(
                                              color: Color(0x20ffffff),
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                        ),
                                        // التاريخ
                                        Container(
                                          padding: EdgeInsets.all(15),
                                          margin: EdgeInsets.only(
                                              left: 5, bottom: 5),
                                          child: Text("12/01/2019"),
                                          decoration: BoxDecoration(
                                              color: Color(0x20ffffff),
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),

                            Divider(color: Colors.grey.shade700),

                            TabBar(
                              tabs: [
                                Tab(text: "Voices"),
                                Tab(
                                  text: "Stardom",
                                  icon: Icon(Icons.star_sharp),
                                ),
                                Tab(text: "About")
                              ],
                              controller: _tabController,
                              indicatorColor: Colors.blue,
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  Column(
                                    children: [
                                      Align(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: IconButton(
                                            icon: Icon(Icons.add,
                                                color: Colors.white),
                                            onPressed: () {
                                              _ctrlTitleAdd.text = "";
                                              _ctrlDescAdd.text = "";
                                              setState(() {
                                                _isAddVoice = true;
                                              });
                                            },
                                          ),
                                        ),
                                        alignment: Alignment.centerLeft,
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: 10,
                                          itemBuilder: (context, index) {
                                            return _itemVoice();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  _stardom(),
                                  _aboutUser(),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  // دالة مخصصة لانشاء عنصر يحتوي على معلومات الصوت
  Widget _itemVoice() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      decoration: BoxDecoration(
          color: Color(0x99333333),
          border: Border.all(color: Colors.grey, width: 0.5)),
      child: InkWell(
        onTap: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home()),
              (route) => false);
        },
        child: Container(
          height: 200,
          child: Stack(
            children: [
              // صورة الموسيقى
              Image.asset(
                "assets/images/music3.webp",
                width: double.maxFinite,
                fit: BoxFit.cover,
              ),

              // لون فوق الخلفية
              Container(
                color: Colors.black54,
                width: double.maxFinite,
                height: 200,
              ),

              // اسم ووصف وتاريخ نشر الموسيقى
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // اسم الموسيقى
                  Container(
                    color: Color(0x99000000),
                    padding: EdgeInsets.all(10),
                    child: Text("Name Voice", style: TextStyle(fontSize: 20)),
                  ),

                  // وصف الموسيقى
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Description Voice",
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  Divider(color: Colors.grey.shade600),

                  // تاريخ نشر الموسيقى
                  Material(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text("30/05/2018"),
                          ),
                        ),
                        // حذف الموسيقى
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () => _alertRemoveVoice(),
                          color: Colors.blue,
                        ),

                        // تعديل الموسيقى
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _isEdit = true;
                            });
                          },
                          color: Colors.blue,
                        ),
                      ],
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

  // دالة مخصصة لتعديل الملف الصوتي
  Widget _editVoice() {
    _ctrlTitle.text = "making it look like readable";
    _ctrlDesc.text =
        "opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like";

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            // تعديل عنوان الملف الصوتي
            TextFormField(
              controller: _ctrlTitle,
              decoration: InputDecoration(
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(5)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none),
                hintText: "Change Title",
                hintStyle: TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Color(0x20ffffff),
                focusColor: Colors.red,
                focusedBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            SizedBox(height: 10),

            // تعديل وصف الملف الصوتي
            TextFormField(
              controller: _ctrlDesc,
              minLines: 5,
              maxLines: 10,
              decoration: InputDecoration(
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(5)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none),
                hintText: "Change Title",
                hintStyle: TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Color(0x20ffffff),
                focusColor: Colors.red,
                focusedBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            // تعديل صورة الغلاف للملف الصوتي
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Stack(
                children: [
                  _imgVoiceFile.path == ""
                      ? Image.asset(
                          "assets/images/music3.webp",
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width - 20,
                          height: MediaQuery.of(context).size.width - 20,
                        )
                      : Image.file(_imgVoiceFile),
                  Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      top: 0,
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: Icon(Icons.add_a_photo),
                          // تم تعديل كود هنا
                          onPressed: () async {
                            FilePickerResult result = await FilePicker.platform
                                .pickFiles(type: FileType.image);
                            if (result != null) {
                              setState(() {
                                _imgVoiceFile = File(result.files.single.path);
                              });
                            }
                          },
                          iconSize: 48,
                          color: Colors.blue,
                        ),
                      ))
                ],
              ),
            ),

            // حفظ او الغاء التعديل
            Row(
              children: [
                // زر الغاء التعديل
                TextButton(child: Text("Edit Save"), onPressed: () {}),
                Expanded(child: Text("")),
                TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      setState(() {
                        _isEdit = false;
                      });
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // معلومات اضافية عن المستخدم
  Widget _aboutUser() {
    _ctrlDescUser.text = "Description User";
    _ctrlLink1.text = "https://www.youtube.com/";
    _ctrlLink2.text = "https://www.facebook.com/";
    _ctrlLink3.text = "https://twitter.com/";

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الوصف
            Container(
                decoration: BoxDecoration(
                  color: Color(0x20ffffff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: _isEditDescUser
                          ? TextFormField(
                              controller: _ctrlDescUser,
                            )
                          : Text(_ctrlDescUser.text),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            IconButton(
                                icon: _isEditDescUser
                                    ? Icon(Icons.done)
                                    : Icon(Icons.edit),
                                onPressed: () {
                                  if (!_isEditDescUser) {
                                    setState(() {
                                      _isEditDescUser = !_isEditDescUser;
                                    });
                                  } else {}
                                },
                                color: Colors.blue),
                            Visibility(
                              visible: _isEditDescUser,
                              child: IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _isEditDescUser = !_isEditDescUser;
                                    });
                                  },
                                  color: Colors.blue),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )),

            SizedBox(height: 10),

            // روابط الى صفحات اجتماعية
            // يوتيوب
            Container(
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: Color(0x20ffffff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _launchURL(_ctrlLink1.text);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: _isEditLink1
                              ? TextFormField(
                                  controller: _ctrlLink1,
                                )
                              : Text("YouTube"),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            IconButton(
                                icon: _isEditLink1
                                    ? Icon(Icons.done)
                                    : Icon(Icons.edit),
                                onPressed: () {
                                  if (!_isEditLink1) {
                                    setState(() {
                                      _isEditLink1 = !_isEditLink1;
                                    });
                                  } else {}
                                },
                                color: Colors.blue),
                            Visibility(
                              visible: _isEditLink1,
                              child: IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _isEditLink1 = !_isEditLink1;
                                    });
                                  },
                                  color: Colors.blue),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )),

            SizedBox(height: 10),

            // فيسبوك
            Container(
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: Color(0x20ffffff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _launchURL(_ctrlLink2.text);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: _isEditLink2
                              ? TextFormField(
                                  controller: _ctrlLink2,
                                )
                              : Text("Facebook"),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            IconButton(
                                icon: _isEditLink2
                                    ? Icon(Icons.done)
                                    : Icon(Icons.edit),
                                onPressed: () {
                                  if (!_isEditLink2) {
                                    setState(() {
                                      _isEditLink2 = !_isEditLink2;
                                    });
                                  } else {}
                                },
                                color: Colors.blue),
                            Visibility(
                              visible: _isEditLink2,
                              child: IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _isEditLink2 = !_isEditLink2;
                                    });
                                  },
                                  color: Colors.blue),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )),

            SizedBox(height: 10),

            // تويتر
            Container(
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: Color(0x20ffffff),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _launchURL(_ctrlLink3.text);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: _isEditLink3
                              ? TextFormField(
                                  controller: _ctrlLink3,
                                )
                              : Text("Twitter"),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            IconButton(
                                icon: _isEditLink3
                                    ? Icon(Icons.done)
                                    : Icon(Icons.edit),
                                onPressed: () {
                                  if (!_isEditLink3) {
                                    setState(() {
                                      _isEditLink3 = !_isEditLink3;
                                    });
                                  } else {}
                                },
                                color: Colors.blue),
                            Visibility(
                              visible: _isEditLink3,
                              child: IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _isEditLink3 = !_isEditLink3;
                                    });
                                  },
                                  color: Colors.blue),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  // شهره المستخدم
  Widget _stardom() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            // عدد المستمعين
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.multitrack_audio_rounded),
                        SizedBox(width: 10),
                        Text("Listeners"),
                        SizedBox(width: 10),
                        Text(
                          "56742",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                      icon: Icon(Icons.multitrack_audio_sharp,
                          color: _isListen ? Colors.blue : Colors.grey),
                      onPressed: () {
                        if (_isListen) _alertCancelListen();
                        setState(() {
                          _isListen = true;
                        });
                      },
                      label: _isListen
                          ? Text(
                              "Listener",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.blue),
                            )
                          : Text(
                              "Listen",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey),
                            )),
                ],
              ),
            ),

            Divider(color: Colors.grey.shade700, thickness: 1, height: 40),

            // نقاط الجودة
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.star_border_outlined),
                  SizedBox(width: 10),
                  Text("Quality Score"),
                  SizedBox(width: 10),
                  Text(
                    "543",
                    style: TextStyle(color: Colors.blue),
                  )
                ],
              ),
            ),

            Divider(color: Colors.grey.shade700, thickness: 1, height: 40),

            // عدد الأعجابات
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.thumb_up_outlined),
                  SizedBox(width: 10),
                  Text("Number of likes"),
                  SizedBox(width: 10),
                  Text(
                    "5678",
                    style: TextStyle(color: Colors.blue),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة مخصصة لفتح الروابط في المتصفح
  Future _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  // دالة مخصصة لاظهار رسالة تخبر المستخدم بحذف الصوت
  Future _alertRemoveVoice() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
              "Do you want to delete this audio?\nThis action is irreversible"),
          actions: [
            TextButton(onPressed: () {}, child: Text("Yes")),
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ],
        );
      },
    );
  }

  // دالة مخصصة لاضافة مقطع صوتي
  Widget _addVoice() {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // اضافة ملف صوتي
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(10),
                  color: Colors.grey.shade800,
                  child: Column(
                    children: [
                      // زر فتح فتح ملفات الجهاز واسم الملف
                      Row(
                        children: [
                          Text(""),
                          Expanded(child: Text("")),
                          ElevatedButton(
                              onPressed: () async {
                                FilePickerResult result = await FilePicker
                                    .platform
                                    .pickFiles(type: FileType.audio);
                                if (result != null) {
                                  setState(() {
                                    _voiceFile = File(result.files.single.path);
                                  });
                                }
                              },
                              child: Text("Get Voice")),
                        ],
                      ),

                      // زر تشغيل وايقاف الصوت
                      InkWell(
                          child: Icon(
                            !_isPlay ? Icons.play_arrow : Icons.pause,
                            color: Colors.blue,
                            size: 48,
                          ),
                          onTap: _voiceFile.path == ""
                              ? null
                              : () async {
                                  if (!_isPlay) {
                                    await _player.setFilePath(_voiceFile.path);
                                    _player.play();
                                  } else {
                                    _player.stop();
                                  }
                                  setState(() {
                                    _isPlay = !_isPlay;
                                  });
                                }),

                      StreamBuilder(
                          stream: !_isPlay ? null : _player.positionStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var secondStatic = _player.duration.inSeconds;
                              var minuteStatic = _player.duration.inMinutes;
                              var hourStatic = _player.duration.inHours;

                              var secondChange = snapshot.data.inSeconds;
                              var minuteChange = snapshot.data.inMinutes;
                              var hourChange = snapshot.data.inHours;

                              if (snapshot.data.inMilliseconds >=
                                  _player.duration.inMilliseconds) {
                                _player.load();
                              }
                              return Column(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      children: [
                                        Text(
                                            "$hourStatic:$minuteStatic:$secondStatic"),
                                        Expanded(child: Text("")),
                                        Text(
                                            "$hourChange:$minuteChange:$secondChange"),
                                      ],
                                    ),
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: Colors.blue,
                                        inactiveTrackColor:
                                            Colors.grey.shade700,
                                        thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 0),
                                        trackShape: RoundSliderTrackShape()),
                                    child: Slider(
                                      value: snapshot.data.inMilliseconds
                                          .toDouble(),
                                      min: 0,
                                      max: snapshot.data.inMilliseconds <
                                              _player.duration.inMilliseconds
                                          ? _player.duration.inMilliseconds
                                              .toDouble()
                                          : snapshot.data.inMilliseconds
                                              .toDouble(),
                                      onChanged: (value) {},
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Text("");
                          }),
                    ],
                  ),
                ),

                // اضافة عنوان الملف الصوتي
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: _ctrlTitleAdd,
                  decoration: InputDecoration(
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent),
                        borderRadius: BorderRadius.circular(5)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none),
                    hintText: "Change Title",
                    hintStyle: TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Color(0x20ffffff),
                    focusColor: Colors.red,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value.isEmpty) return "The field is empty";
                    if (value.length > 100) return "The title is long";
                    if (value.length < 3) return "The title is short";
                    return null;
                  },
                ),

                SizedBox(height: 10),

                // اضافة وصف الملف الصوتي
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: _ctrlDescAdd,
                  minLines: 5,
                  maxLines: 10,
                  decoration: InputDecoration(
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent),
                        borderRadius: BorderRadius.circular(5)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none),
                    hintText: "Change Title",
                    hintStyle: TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Color(0x20ffffff),
                    focusColor: Colors.red,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value.length > 200) return "The title is long";
                    return null;
                  },
                ),

                // اضافة صورة الغلاف للملف الصوتي
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Stack(
                    children: [
                      _imgAddVoiceFile.path == ""
                          ? Container(height: 200, color: Colors.grey.shade900)
                          : Image.file(_imgAddVoiceFile),
                      Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          top: 0,
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              icon: Icon(Icons.add_a_photo),
                              // تم تعديل كود هنا
                              onPressed: () async {
                                FilePickerResult result = await FilePicker
                                    .platform
                                    .pickFiles(type: FileType.image);
                                if (result != null) {
                                  setState(() {
                                    _imgAddVoiceFile =
                                        File(result.files.single.path);
                                  });
                                }
                              },
                              iconSize: 48,
                              color: Colors.blue,
                            ),
                          ))
                    ],
                  ),
                ),

                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {}
                        },
                        child: Text("Upload Voice")),
                    Expanded(child: Text("")),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _isAddVoice = false;
                          });
                        },
                        child: Text("Cancel")),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة تاكد على المستخدم قبل الغاء الاشتراك
  Future _alertCancelListen() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Cancel Listen"),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    _isListen = false;
                  });
                  Navigator.pop(context);
                },
                child: Text("Yes")),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No")),
          ],
        );
      },
    );
  }
}
