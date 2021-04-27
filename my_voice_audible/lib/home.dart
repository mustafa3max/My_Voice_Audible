import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_voice_audible/login.dart';
import 'package:my_voice_audible/profile.dart';
import 'package:my_voice_audible/round_slider_track_shape.dart';

import 'list_test.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _player = AudioPlayer();

  List<bool> _isLikes = [false, false, false, false];
  List<bool> _isDislikes = [false, false, false, false];
  List<int> _numLikes = [0, 0, 0, 0];
  List<int> _numDisLikes = [0, 0, 0, 0];

  BannerAd _myBanner;
  InterstitialAd _interstitialAd;

  bool _isListen = false;
  bool _isLogin = true;
  bool _isPlay = false;
  bool _isClickComment = false;

  var _nameComment = "";
  var _comment = "";
  var _historyComment = "";
  var _imageComment = "";
  var _replyComment = 0;

  void _createInterstitialAd() {
    _interstitialAd ??= InterstitialAd(
      adUnitId: "ca-app-pub-3940256099942544/1033173712",
      request: AdRequest(),
      listener: AdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          _interstitialAd = null;
          _createInterstitialAd();
        },
        onAdClosed: (Ad ad) {
          ad.dispose();
          _createInterstitialAd();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // تهيئة الاعلان البيني
    MobileAds.instance.initialize().then((InitializationStatus status) {
      MobileAds.instance
          .updateRequestConfiguration(RequestConfiguration(
              tagForChildDirectedTreatment:
                  TagForChildDirectedTreatment.unspecified))
          .then((value) {
        _createInterstitialAd();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isPlay
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              shadowColor: Colors.grey.shade800,
              leading: Padding(
                padding: EdgeInsets.all(5),
                // صورة الملف الشخصي تنقل الى الملف الشخصي او تسجيل الدخول
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => _isLogin ? Profile() : Login(),
                        ),
                        (route) => false);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: AssetImage("assets/images/man.webp"),
                  ),
                ),
              ),
              actions: [
                IconButton(icon: Icon(Icons.add_alert), onPressed: () {})
              ],
            ),
      body: SafeArea(
        child: PageView.builder(
          physics: _isPlay ? NeverScrollableScrollPhysics() : null,
          scrollDirection: Axis.vertical,
          itemCount: ListTest().listNamesUser.length,
          itemBuilder: (context, index) {
            // تشغيل الاعلان البيني كل عدة تمريرات
            if (index != 0 && index % 3 == 0) {
              if (_interstitialAd != null) {
                _interstitialAd.show();
                _interstitialAd = null;
              }
            }

            // تهيئة اعلان البنر
            _myBanner = BannerAd(
              adUnitId: "ca-app-pub-3940256099942544/6300978111",
              size: AdSize.banner,
              request: AdRequest(),
              listener: AdListener(),
            )..load();

            return _isClickComment
                ? _moreDetailsComment(
                    name: _nameComment,
                    comment: _comment,
                    history: _historyComment,
                    image: _imageComment,
                    reply: _replyComment,
                  )
                : Stack(
                    children: [
                      // خلفية خاصة بالعنصر
                      Image.asset(
                        ListTest().listImgMusic[index],
                        width: double.maxFinite,
                        height: double.maxFinite,
                        fit: BoxFit.cover,
                      ),

                      // لون شفاف فوق صورة الخلفية
                      Container(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        color: Colors.black87,
                      ),

                      // اسم الموسيقى واسم المستخدم
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // اسم الملف الصوتي
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  ListTest().listNameMusic[index],
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),

                              // اسم صاحب الملف الصوتي
                              Visibility(
                                visible: !_isPlay,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(ListTest().listNamesUser[index]),
                                ),
                              )
                            ],
                          ),

                          // اعلان بنر
                          Visibility(
                            visible: !_isPlay,
                            child: Container(
                              child: AdWidget(ad: _myBanner),
                              width: _myBanner.size.width.toDouble(),
                              height: _myBanner.size.height.toDouble(),
                            ),
                          ),
                          // تم نقل زر الاعجاب وصندوق الوصف خارج هذه المجموعة
                        ],
                      ),

                      // زر التشغيل والاعجاب وصندوق التعليقات
                      Container(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // صندوق التعليقات
                            Visibility(
                              visible: _isPlay,
                              child: Container(
                                height: 200,
                                margin: EdgeInsets.only(
                                    top: 50, left: 10, right: 10),
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  color: Color(0xcc111111),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.grey.shade800, width: 0.4),
                                ),
                                child: PageView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: ListTest().listComment.length,
                                  itemBuilder: (context, index) {
                                    return _commentItem(
                                        "name $index",
                                        ListTest().listImgUser[0],
                                        ListTest().listComment[index],
                                        "20/01/2021",
                                        ListTest().listReplyComment[index]);
                                  },
                                ),
                              ),
                            ),

                            // زر تشغيل وايقاف الموسيقى
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                    child: Icon(
                                      !_isPlay ? Icons.play_arrow : Icons.pause,
                                      color: Colors.blue,
                                      size: 48,
                                    ),
                                    onTap: () async {
                                      if (!_isPlay) {
                                        await _player.setAsset(
                                            ListTest().listVoices[index]);
                                        _player.play();
                                      } else {
                                        _player.stop();
                                      }
                                      setState(() {
                                        _isPlay = !_isPlay;
                                      });
                                    }),
                              ),
                            ),

                            // دالة مخصصة لزر اعجاب والغاء الاعجاب
                            // خاصة للملف الصوتي
                            Visibility(
                              visible: _isPlay,
                              child: _likeAndDislike(
                                  iconSize: 36,
                                  funcLocation: 1,
                                  allLike: 32,
                                  allDisLike: 14),
                            ),

                            // شريط تقدم الصوت
                            // زر التبليغ عن محتوى مخالف او الاستماع الى المستخدم
                            Visibility(
                              visible: _isPlay,
                              child: Column(
                                children: [
                                  // ازرار التبليغ والمشاركة
                                  Row(
                                    children: [
                                      TextButton.icon(
                                          onPressed: () => _isLogin
                                              ? _reportingContent()
                                              : null,
                                          icon: Icon(Icons.report_problem,
                                              color: Colors.red),
                                          label: Text(
                                            "Reporting",
                                            style: TextStyle(color: Colors.red),
                                          )),
                                      Expanded(child: Text("")),
                                      Row(
                                        children: [
                                          TextButton.icon(
                                              icon: Icon(
                                                  Icons.multitrack_audio_sharp,
                                                  color: _isListen
                                                      ? Colors.blue
                                                      : Colors.grey),
                                              onPressed: () {
                                                // تم اضافة كود
                                                if (_isListen)
                                                  _alertCancelListen();
                                                setState(() {
                                                  _isListen = true;
                                                });
                                              },
                                              label: _isListen
                                                  ? Text(
                                                      "Listener",
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    )
                                                  : Text(
                                                      "Listen",
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    )),
                                          Text("4567"),
                                          SizedBox(width: 10)
                                        ],
                                      ),
                                    ],
                                  ),

                                  // شريط تقدم الصوت
                                  StreamBuilder(
                                      stream: _player.positionStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          var secondStatic =
                                              _player.duration.inSeconds;
                                          var minuteStatic =
                                              _player.duration.inMinutes;
                                          var hourStatic =
                                              _player.duration.inHours;

                                          var secondChange =
                                              snapshot.data.inSeconds;
                                          var minuteChange =
                                              snapshot.data.inMinutes;
                                          var hourChange =
                                              snapshot.data.inHours;

                                          if (snapshot.data.inMilliseconds >=
                                              _player.duration.inMilliseconds) {
                                            _player.load();
                                          }
                                          return Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
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
                                                    activeTrackColor:
                                                        Colors.blue,
                                                    inactiveTrackColor:
                                                        Colors.grey.shade700,
                                                    thumbShape:
                                                        RoundSliderThumbShape(
                                                            enabledThumbRadius:
                                                                0),
                                                    trackShape:
                                                        RoundSliderTrackShape()),
                                                child: Slider(
                                                  value: snapshot
                                                      .data.inMilliseconds
                                                      .toDouble(),
                                                  min: 0,
                                                  max: snapshot
                                                              .data.inMilliseconds <
                                                          _player.duration
                                                              .inMilliseconds
                                                      ? _player.duration
                                                          .inMilliseconds
                                                          .toDouble()
                                                      : snapshot
                                                          .data.inMilliseconds
                                                          .toDouble(),
                                                  onChanged: (value) {},
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                        return Slider(
                                          value: 0,
                                          min: 0,
                                          max: 100,
                                          onChanged: (value) {},
                                        );
                                      })
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      // صندوق الوصف وصورة المستخدم وزر الاعجاب
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Visibility(
                          visible: !_isPlay,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // صندوق الوصف
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        "12/04/2021",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        ListTest().listDecMusic[index],
                                        textAlign: TextAlign.left,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(width: 10),

                              // صورة المستخدم وزر الاعجاب
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    // صورة المستخدم
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Profile()),
                                              (route) => false);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                              color: _isListen
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(100)),
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundImage: AssetImage(
                                              ListTest().listImgUser[index],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // عدد المشتركين او المستمعين
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 5, bottom: 20),
                                      child: Text("3434"),
                                    ),

                                    Column(
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                          color: _isLikes[0]
                                              ? Colors.blue
                                              : Colors.grey,
                                          size: 36,
                                        ),
                                        Text("23")
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      children: [
                                        Icon(
                                          Icons.thumb_down,
                                          color: _isDislikes[0]
                                              ? Colors.blue
                                              : Colors.grey,
                                          size: 36,
                                        ),
                                        Text("2")
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  // دالة مخصصة لزر الاعجاب وعدم الاعجاب
  // تمت كتابة الكود مرة واحدة وتكرر اربعة مرات داخل الصفحة
  // المتغير funcLocation يشير الى موقع الدالة في الاماكن الاربعة
  // رقم 1 يعني زر الاعجاب والغاء الاعجاب للملف الصوتي للمستخدم
  // رقم 2 يعني زر الاعجاب والغاء الاعجاب للتعليق الرئيسي للمستخدمين
  // رقم 4 يعني زر الاعجاب والغاء الاعجاب للرد على تعليق المستخدم
  Widget _likeAndDislike(
      {double iconSize = 24, funcLocation = 1, allLike = 0, allDisLike = 0}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: IconButton(
                    color:
                        _isLikes[funcLocation - 1] ? Colors.blue : Colors.grey,
                    iconSize: iconSize,
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {
                      setState(() {
                        _isDislikes[funcLocation - 1] = false;
                        _numDisLikes[funcLocation - 1] = 0;
                        if (_numLikes[funcLocation - 1] == 1)
                          _alertRemoveLike(funcLocation: funcLocation);
                        _isLikes[funcLocation - 1] = true;
                        if (_isLikes[funcLocation - 1])
                          _numLikes[funcLocation - 1] = 1;
                      });
                    }),
              ),
            ),
            Text("${allLike + _numLikes[funcLocation - 1]}")
          ],
        ),
        Column(
          children: [
            Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: IconButton(
                    color: _isDislikes[funcLocation - 1]
                        ? Colors.blue
                        : Colors.grey,
                    iconSize: iconSize,
                    icon: Icon(Icons.thumb_down),
                    onPressed: () {
                      setState(() {
                        _isDislikes[funcLocation - 1] =
                            !_isDislikes[funcLocation - 1];

                        if (_isDislikes[funcLocation - 1])
                          _numDisLikes[funcLocation - 1] = 1;
                        else
                          _numDisLikes[funcLocation - 1] = 0;
                        if (_numLikes[funcLocation - 1] == 1)
                          _alertRemoveLike(funcLocation: funcLocation);
                      });
                    }),
              ),
            ),
            Text("${allDisLike + _numDisLikes[funcLocation - 1]}")
          ],
        ),
      ],
    );
  }

  // العنصر الخاص بصندوق التعليقات
  Widget _commentItem(name, image, String comment, history, reply) {
    bool isClick = false;

    if (comment.length > 300 || reply > 0) {
      isClick = true;
    }

    _nameComment = name;
    _imageComment = image;
    this._comment = comment;
    _historyComment = history;
    _replyComment = reply;

    return Column(
      children: [
        // اسم وصورة المستخدم
        Container(
          padding: EdgeInsets.only(left: 5),
          color: Colors.grey.shade900,
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(image),
                radius: 12,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(child: Text(name)),
              Material(
                color: Colors.transparent,
                child: IconButton(
                  color: Colors.red,
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _alertEditOrRemoveComment();
                  },
                  iconSize: 20,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.red,
                    onPressed: () {
                      _alertAddComment();
                    }),
              )
            ],
          ),
        ),

        // التعليق
        Expanded(
          child: Material(
            color: Colors.black87,
            child: InkWell(
              onTap: isClick
                  ? () {
                      setState(() {
                        _isClickComment = true;
                      });
                    }
                  : null,
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    comment,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  )),
            ),
          ),
        ),

        // التاريخ اعجبني لم يعجبني وعدد الردود
        Container(
          padding: EdgeInsets.only(left: 5),
          color: Colors.black87,
          child: Row(
            children: [
              // دالة مخصصة لزر اعجاب والغاء الاعجاب
              // خاصة للتعليق الرئيسي
              _likeAndDislike(funcLocation: 2, allLike: 45, allDisLike: 27),

              Expanded(child: Text("")),

              Text(history),

              SizedBox(width: 10),

              // الردود على التعليق
              Row(
                children: [
                  Icon(Icons.chat),
                  SizedBox(
                    width: 5,
                  ),
                  Text(reply.toString())
                ],
              ),

              SizedBox(width: 10)
            ],
          ),
        ),
      ],
    );
  }

  // المزيد من التعليقات
  Widget _moreDetailsComment({name, image, String comment, history, reply}) {
    return Container(
      width: double.maxFinite,
      child: Column(
        children: [
          // زر الغاء واسم وصورة المستخدم
          Container(
            color: Colors.grey.shade900,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(image),
                  ),
                ),
                Expanded(child: Text(name)),
                IconButton(
                    icon: Icon(Icons.clear),
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _isClickComment = false;
                      });
                    }),
                IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.red,
                    onPressed: () {
                      _alertAddComment();
                    })
              ],
            ),
          ),

          // صندوق التعليق
          Container(padding: EdgeInsets.all(10), child: Text(comment)),

          Divider(),

          // اعجبني لم يعجبني ورقم الردرد
          Row(
            children: [
              // رقم الردود على التعليق
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Icon(Icons.chat),
                    SizedBox(
                      width: 5,
                    ),
                    Text(reply.toString())
                  ],
                ),
              ),

              Expanded(child: Text("")),

              // دالة مخصصة لزر اعجاب والغاء الاعجاب
              // خاصة للتعليق الرئيسي داخل صندوق المزيد من التعليقات
              _likeAndDislike(
                  iconSize: 36, funcLocation: 2, allLike: 45, allDisLike: 27)
            ],
          ),

          Divider(
            color: Colors.black45,
            height: 50,
            thickness: 1.5,
          ),

          // صندوق الردود على التعليق
          Expanded(
            child: ListView.builder(
              itemCount: reply,
              itemBuilder: (context, index) {
                return Container(
                    margin: EdgeInsets.only(bottom: 10, left: 15, right: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38, width: 0.8),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        // زر حذف واسم وصورة المستخدم
                        Container(
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage(image),
                                ),
                              ),
                              Expanded(child: Text(name)),
                              IconButton(
                                  icon: Icon(Icons.clear),
                                  color: Colors.red,
                                  onPressed: () {})
                            ],
                          ),
                        ),

                        // الرد على التعليق
                        Container(
                          padding: EdgeInsets.all(10),
                          width: double.maxFinite,
                          color: Colors.black26,
                          child: Text("data $index"),
                        ),

                        // اعجبني لم يعجبني
                        Row(
                          children: [
                            Expanded(child: Text("")),
                            // دالة مخصصة لزر اعجاب والغاء الاعجاب
                            // خاصة للردود على التعليق
                            _likeAndDislike(
                                funcLocation: 4, allLike: 143, allDisLike: 13)
                          ],
                        ),
                      ],
                    ));
              },
            ),
          )
        ],
      ),
    );
  }

  // هل تريد الحذف ام تعديل التعليق
  Future _alertEditOrRemoveComment() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.clear),
              color: Colors.red,
            ),
          ),
          content: Text("Do you want to delete or edit a comment?"),
          actions: [
            TextButton(onPressed: () {}, child: Text("Remove")),
            TextButton(onPressed: () {}, child: Text("Edit")),
          ],
        );
      },
    );
  }

  // دالة للتبليغ عن محتوى مخالف
  Future _reportingContent() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Why are you reporting this Voice?"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text("False information"),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("I just don't like it"),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("Scam or fraud"),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("Suicide, self-injury or eating disorders"),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("Intellectual property violation"),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("Bullying or harassment"),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("Sale of illegal or regulated goods"),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("Violence or dangerous organizations"),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("Hate speech or symbols"),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("Nudity or sexual activity"),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text("It's spam"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel")),
          ],
        );
      },
    );
  }

  // اضافة تعليق جديد
  Future _alertAddComment() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Comment"),
          content: TextFormField(),
          actions: [
            TextButton(onPressed: () {}, child: Text("Add Comment")),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel")),
          ],
        );
      },
    );
  }

  // دالة تاكد على المستخدم قبل حذف الاعجاب
  Future _alertRemoveLike({funcLocation = 1}) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Remove Like"),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    _isLikes[funcLocation - 1] = false;
                    _numLikes[funcLocation - 1] = 0;
                    if (_numDisLikes[funcLocation - 1] == 1)
                      _isDislikes[funcLocation - 1] = true;
                  });
                  Navigator.pop(context);
                },
                child: Text("Yes")),
            TextButton(
                onPressed: () {
                  setState(() {
                    if (_numDisLikes[funcLocation - 1] == 1) {
                      _isDislikes[funcLocation - 1] = false;
                      _numDisLikes[funcLocation - 1] = 0;
                    }
                  });
                  Navigator.pop(context);
                },
                child: Text("No")),
          ],
        );
      },
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
