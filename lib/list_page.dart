import 'package:clock_app/db_helper.dart';
import 'package:clock_app/constants/theme_data.dart';
import 'package:clock_app/main.dart';
import 'package:clock_app/models/db_info.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  TextEditingController url1controller = TextEditingController();
  TextEditingController url2controller = TextEditingController();
  TextEditingController url3controller = TextEditingController();
  TextEditingController urlpcontroller = TextEditingController();
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController url1controller2 = TextEditingController();
  TextEditingController url2controller2 = TextEditingController();
  TextEditingController url3controller2 = TextEditingController();
  TextEditingController urlpcontroller2 = TextEditingController();
  TextEditingController titlecontroller2 = TextEditingController();

  DBHelper _dbHelper = DBHelper();
  Future<List<DBInfo>> _elements;

  var clickedonce = false;

  @override
  void initState() {
    _dbHelper.initializeDatabase().then((value) {
      print('------database intialized');
      loadElements();
    });
    checkhelp();
    super.initState();
  }

  void checkhelp() async {
    print(await getnotfirststart());
    if (await getnotfirststart() == false) {
      showHelp(context);
      setfirststarttrue();
    }
  }

  _showInternetDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("No Internet Conncetion"),
              content: new Text(
                  "Please conncet your device to the Internet and try again"),
              actions: <Widget>[
                FlatButton(
                  child: Text('Close me!'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  void loadElements() {
    _elements = _dbHelper.getElements();
    if (mounted) setState(() {});
  }

  String checkhttps(urltext) {
    if (!(urltext.contains('https://') || urltext.contains('http://')) &&
        urltext.isNotEmpty) {
      urltext = 'https://' + urltext;
    }
    return urltext;
  }

  Future refreshfunction() async {
    if (await DataConnectionChecker().hasConnection) {
      await checkurlwonotif();
      setState(() {
        loadElements();
      });
      print('refreshed');
    } else {
      _showInternetDialog();
    }
  }

  Future checkurlwonotif() async {
    if (await DataConnectionChecker().hasConnection) {
      var elements = await _dbHelper.getElements();

      // print(elements[0].title);
      // elements[0].title = 'try';
      // print(await _dbHelper.update(elements[0]));
      // print(elements[0].title);
      for (int i = 0; i < elements.length; i++) {
        var checked = 0;
        if (elements[i].url1.isNotEmpty) {
          var url = elements[i].url1;
          checked = await urlsubfunction(checked, url);
        }
        if (elements[i].url2.isNotEmpty) {
          var url = elements[i].url2;
          checked = await urlsubfunction(checked, url);
        }
        if (elements[i].url3.isNotEmpty) {
          var url = elements[i].url3;
          checked = await urlsubfunction(checked, url);
        }
        if (elements[i].checked != checked) {
          //Turn on notification if the status changed
          elements[i].notification = 0;
        }
        elements[i].checked = checked;
        print(elements[i].title);
        print(checked);
        await _dbHelper.update(elements[i]);
      }
    }
  }

  Future urlsubfunction(checked, url) async {
    try {
      final Response response = await get(url);
      // print(response.statusCode);
      // print(response.headers);
      if (response.statusCode == 200) {
        checked = 1;
      }
    } catch (e) {
      // print(e);
    }
    return checked;
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(children: [
          Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(
                  Icons.help_outline,
                  color: Colors.white30,
                  size: 30,
                ),
                onPressed: () {
                  showHelp(context);
                },
              )),
          Container(
            padding: EdgeInsets.fromLTRB(
                32, 30, 32, 64), //Change here for Top padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'BaeWatch',
                      style: TextStyle(
                          fontFamily: 'avenir',
                          fontWeight: FontWeight.w700,
                          color: CustomColors.primaryTextColor,
                          fontSize: 50),
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<DBInfo>>(
                    future: _elements,
                    builder: (context, snapshot) {
                      if (snapshot.hasData)
                        return RefreshIndicator(
                          onRefresh: refreshfunction,
                          child: ListView(
                            children: snapshot.data.map<Widget>((element) {
                              var symbol = element.checked == 0
                                  ? Icons.highlight_off
                                  : Icons.check_circle_outline;
                              var gradientColor = element.checked == 0
                                  ? GradientTemplate.gradientTemplate[1].colors
                                  : GradientTemplate.gradientTemplate[2].colors;
                              var url1symbol = element.url1.isEmpty
                                  ? Icons.remove_circle_outline
                                  : Icons.brightness_1;
                              var url2symbol = element.url2.isEmpty
                                  ? Icons.remove_circle_outline
                                  : Icons.brightness_1;
                              var url3symbol = element.url3.isEmpty
                                  ? Icons.remove_circle_outline
                                  : Icons.brightness_1;
                              return GestureDetector(
                                onTap: () {
                                  var clickedonce2 = false;
                                  url1controller2.text = element.url1;
                                  url2controller2.text = element.url2;
                                  url3controller2.text = element.url3;
                                  urlpcontroller2.text = element.urlp;
                                  titlecontroller2.text = element.title;
                                  showModalBottomSheet(
                                    isScrollControlled: true,

                                    ///Better Option?
                                    useRootNavigator: true,
                                    context: context,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                    ),
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setModalState) {
                                          return Container(
                                            padding: const EdgeInsets.only(
                                                right: 16, left: 16),
                                            child: Column(
                                              children: [
                                                ///START
                                                Form(
                                                  key: _formKey,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            50),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          TextFormField(
                                                            controller:
                                                                titlecontroller2,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            autocorrect: false,
                                                            decoration:
                                                                InputDecoration(
                                                              labelText: 'Name',
                                                              border:
                                                                  OutlineInputBorder(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .all(
                                                                const Radius
                                                                        .circular(
                                                                    40.0),
                                                              )),
                                                            ),
                                                          ),
                                                          SizedBox(height: 20),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      url1controller2,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .text,
                                                                  autocorrect:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'URL1',
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .all(
                                                                        const Radius.circular(
                                                                            40.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              new IconButton(
                                                                iconSize: 24,
                                                                icon: new Icon(Icons
                                                                    .open_in_new),
                                                                onPressed: () {
                                                                  var url1 = checkhttps(
                                                                      url1controller2
                                                                          .text);
                                                                  if (url1
                                                                      .isNotEmpty) {
                                                                    launch(
                                                                        '$url1');
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 20),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      url2controller2,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .text,
                                                                  autocorrect:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'URL2',
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .all(
                                                                        const Radius.circular(
                                                                            40.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              new IconButton(
                                                                iconSize: 24,
                                                                icon: new Icon(Icons
                                                                    .open_in_new),
                                                                onPressed: () {
                                                                  var url2 = checkhttps(
                                                                      url2controller2
                                                                          .text);
                                                                  if (url2
                                                                      .isNotEmpty) {
                                                                    launch(
                                                                        '$url2');
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 20),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      url3controller2,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .text,
                                                                  autocorrect:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'URL3',
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .all(
                                                                        const Radius.circular(
                                                                            40.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              new IconButton(
                                                                iconSize: 24,
                                                                icon: new Icon(Icons
                                                                    .open_in_new),
                                                                onPressed: () {
                                                                  var url3 = checkhttps(
                                                                      url3controller2
                                                                          .text);
                                                                  if (url3
                                                                      .isNotEmpty) {
                                                                    launch(
                                                                        '$url3');
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 20),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      urlpcontroller2,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .text,
                                                                  autocorrect:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Profile URL',
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .all(
                                                                        const Radius.circular(
                                                                            40.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              new IconButton(
                                                                iconSize: 24,
                                                                icon: new Icon(Icons
                                                                    .open_in_new),
                                                                onPressed: () {
                                                                  var urlp = checkhttps(
                                                                      urlpcontroller2
                                                                          .text);
                                                                  if (urlp
                                                                      .isNotEmpty) {
                                                                    launch(
                                                                        '$urlp');
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                                FloatingActionButton.extended(
                                                  onPressed: () async {
                                                    if (await DataConnectionChecker()
                                                        .hasConnection) {
                                                      if (!clickedonce2) {
                                                        clickedonce2 = true;
                                                        var url1text =
                                                            url1controller2
                                                                .text;
                                                        if (!(url1text.contains(
                                                                    'https://') ||
                                                                url1text.contains(
                                                                    'http://')) &&
                                                            url1text
                                                                .isNotEmpty) {
                                                          url1text =
                                                              'https://' +
                                                                  url1text;
                                                        }
                                                        var url2text =
                                                            url2controller2
                                                                .text;
                                                        if (!(url2text.contains(
                                                                    'https://') ||
                                                                url2text.contains(
                                                                    'http://')) &&
                                                            url2text
                                                                .isNotEmpty) {
                                                          url2text =
                                                              'https://' +
                                                                  url2text;
                                                        }
                                                        var url3text =
                                                            url3controller2
                                                                .text;
                                                        if (!(url3text.contains(
                                                                    'https://') ||
                                                                url3text.contains(
                                                                    'http://')) &&
                                                            url3text
                                                                .isNotEmpty) {
                                                          url3text =
                                                              'https://' +
                                                                  url3text;
                                                        }
                                                        var urlptext =
                                                            urlpcontroller2
                                                                .text;
                                                        if (!(urlptext.contains(
                                                                    'https://') ||
                                                                urlptext.contains(
                                                                    'http://')) &&
                                                            urlptext
                                                                .isNotEmpty) {
                                                          urlptext =
                                                              'https://' +
                                                                  urlptext;
                                                        }
                                                        element.url1 = url1text;
                                                        element.url2 = url2text;
                                                        element.url3 = url3text;
                                                        element.urlp = urlptext;
                                                        element.title =
                                                            titlecontroller2
                                                                .text;
                                                        element.checked = 0;

                                                        await _dbHelper
                                                            .update(element);
                                                        await checkurlwonotif();
                                                        setState(() {
                                                          loadElements();
                                                        });
                                                        Navigator.pop(context);
                                                      }
                                                    } else {
                                                      _showInternetDialog();
                                                    }
                                                  },
                                                  icon: Icon(Icons.save),
                                                  label: Text('Save Changes'),
                                                ),
                                                Container(
                                                  height: 10,
                                                ),
                                                FloatingActionButton.extended(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                  },
                                                  icon: Icon(Icons
                                                      .keyboard_arrow_left),
                                                  label: Text('Back'),
                                                )
                                              ],

                                              ///Ende
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 32, right: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColor,
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            gradientColor.last.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Icon(symbol,
                                                  color: Colors.white,
                                                  size: 32),
                                              SizedBox(width: 8),
                                              Text(
                                                element.title,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'avenir',
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 40),
                                        width: 75,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Icon(
                                                url1symbol,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              Icon(
                                                url2symbol,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              Icon(
                                                url3symbol,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ]),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            '',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'avenir',
                                                fontSize: 2,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            color: Colors.white,
                                            onPressed: () {
                                              _dbHelper.delete(element.id);
                                              setState(() {
                                                loadElements();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).followedBy([
                              Container(
                                margin: const EdgeInsets.only(right: 5),
                                child: DottedBorder(
                                  strokeWidth: 0,
                                  color: CustomColors.dotOutline,
                                  borderType: BorderType.RRect,
                                  radius: Radius.circular(24),
                                  dashPattern: [5, 4],
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: GradientTemplate
                                            .gradientTemplate[0].colors,
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      //color: CustomColors.addBG,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(24)),
                                    ),
                                    child: FlatButton(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 36, vertical: 12),
                                      onPressed: () {
                                        clickedonce = false;
                                        showModalBottomSheet(
                                          isScrollControlled: true,

                                          ///Better Option?
                                          useRootNavigator: true,
                                          context: context,
                                          clipBehavior: Clip.antiAlias,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(24),
                                            ),
                                          ),
                                          builder: (context) {
                                            return StatefulBuilder(
                                              builder:
                                                  (context, setModalState) {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.all(32),
                                                  child: Column(
                                                    children: [
                                                      ///START
                                                      Form(
                                                        key: _formKey,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(50),
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                TextFormField(
                                                                  controller:
                                                                      titlecontroller,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .text,
                                                                  autocorrect:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Name',
                                                                    border:
                                                                        OutlineInputBorder(
                                                                            borderRadius:
                                                                                const BorderRadius.all(
                                                                      const Radius
                                                                              .circular(
                                                                          40.0),
                                                                    )),
                                                                  ),
                                                                  validator:
                                                                      (value) {
                                                                    if (value
                                                                        .isEmpty) {
                                                                      return 'Please enter a name';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                    height: 20),
                                                                TextFormField(
                                                                  controller:
                                                                      url1controller,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .text,
                                                                  autocorrect:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'URL1',
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .all(
                                                                        const Radius.circular(
                                                                            40.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  validator:
                                                                      (value) {
                                                                    if (value
                                                                        .isEmpty) {
                                                                      return 'Please enter an url';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                    height: 20),
                                                                TextFormField(
                                                                  controller:
                                                                      url2controller,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .text,
                                                                  autocorrect:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'URL2',
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .all(
                                                                        const Radius.circular(
                                                                            40.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 20),
                                                                TextFormField(
                                                                  controller:
                                                                      url3controller,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .text,
                                                                  autocorrect:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'URL3',
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .all(
                                                                        const Radius.circular(
                                                                            40.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 20),
                                                                TextFormField(
                                                                  controller:
                                                                      urlpcontroller,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .text,
                                                                  autocorrect:
                                                                      false,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        'Profile URL',
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .all(
                                                                        const Radius.circular(
                                                                            40.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ]),
                                                        ),
                                                      ),

                                                      FloatingActionButton
                                                          .extended(
                                                        onPressed: () async {
                                                          if (await DataConnectionChecker()
                                                              .hasConnection) {
                                                            if (!clickedonce) {
                                                              clickedonce =
                                                                  true;
                                                              var url1text =
                                                                  url1controller
                                                                      .text;
                                                              if (!(url1text.contains(
                                                                          'https://') ||
                                                                      url1text.contains(
                                                                          'http://')) &&
                                                                  url1text
                                                                      .isNotEmpty) {
                                                                url1text =
                                                                    'https://' +
                                                                        url1text;
                                                              }
                                                              var url2text =
                                                                  url2controller
                                                                      .text;
                                                              if (!(url2text.contains(
                                                                          'https://') ||
                                                                      url2text.contains(
                                                                          'http://')) &&
                                                                  url2text
                                                                      .isNotEmpty) {
                                                                url2text =
                                                                    'https://' +
                                                                        url2text;
                                                              }
                                                              var url3text =
                                                                  url3controller
                                                                      .text;
                                                              if (!(url3text.contains(
                                                                          'https://') ||
                                                                      url3text.contains(
                                                                          'http://')) &&
                                                                  url3text
                                                                      .isNotEmpty) {
                                                                url3text =
                                                                    'https://' +
                                                                        url3text;
                                                              }
                                                              var urlptext =
                                                                  urlpcontroller
                                                                      .text;
                                                              if (!(urlptext.contains(
                                                                          'https://') ||
                                                                      urlptext.contains(
                                                                          'http://')) &&
                                                                  urlptext
                                                                      .isNotEmpty) {
                                                                urlptext =
                                                                    'https://' +
                                                                        urlptext;
                                                              }
                                                              print(urlptext);
                                                              var elementInfo =
                                                                  DBInfo(
                                                                url1: url1text,
                                                                url2: url2text,
                                                                url3: url3text,
                                                                urlp: urlptext,
                                                                title:
                                                                    titlecontroller
                                                                        .text,
                                                                checked: 0,
                                                                notification: 0,
                                                              );
                                                              _dbHelper
                                                                  .insertElement(
                                                                      elementInfo);
                                                              urlpcontroller
                                                                  .clear();
                                                              url1controller
                                                                  .clear();
                                                              url2controller
                                                                  .clear();
                                                              url3controller
                                                                  .clear();
                                                              titlecontroller
                                                                  .clear();
                                                              await checkurlwonotif();
                                                              setState(() {
                                                                loadElements();
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          } else {
                                                            _showInternetDialog();
                                                          }
                                                        },
                                                        icon: Icon(Icons.save),
                                                        label: Text('Save'),
                                                      ),
                                                    ],

                                                    ///Ende
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                        // scheduleAlarm();
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Icon(Icons.add_circle_outline,
                                              color: Colors.white, size: 48),
                                          SizedBox(height: 0),
                                          Text(
                                            'New Entry',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'avenir'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ]).toList(),
                          ),
                        );
                      return Center(
                        child: Text(
                          'Loading..',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
