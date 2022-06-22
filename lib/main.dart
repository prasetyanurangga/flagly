import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:search_choices/search_choices.dart';
import 'package:flagly/layout/layout.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic> codeCountry = {
    "name" : "Indonesia",
    "code" : "ID",
    "lat" : 0,
    "lng" : 0
  };
  Set<int> setOfInts = Set();
  List<int> showContainer = [];
  List<dynamic> listCountry = [];
  List<dynamic> listSearchCountry = [];
  List<Map<String, dynamic>> listGuestCountry = [];
  int currentOpenIndex = 0;
  Map<String, dynamic>? selectedValueSingleDialog;
  bool isCorrect = false;


  @override
  void initState() {
    super.initState();
    final loader = document.getElementById('loading_indicator');
    if(loader != null) {
      loader.remove();
    }
    readJson();
  }

  void failAlert() {

    Get.defaultDialog(
      title: "Fail 😭😭",
      titlePadding: EdgeInsets.all(16),
      content: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children : [

            RichText(
              text : TextSpan(
                text: "The answer is ",
                style: TextStyle(
                  color: Colors.black
                ),
                children: [
                  TextSpan(
                    text: codeCountry["name"],
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.black
                    ),
                  )
                ]
              )
            ),
            SizedBox(height: 16),
            TextButton(
              child: Text('Share'),
              onPressed: () {
                Get.back();
                handleShare();
                copiedAlert();
              }
            )
            
          ]
        )
      )
    );

  }


  void sweatAlert() {

    Get.defaultDialog(
      title: "Horay🥳🥳",
      titlePadding: EdgeInsets.all(16),
      content: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children : [
            
            Text("Your answers correct"),
            SizedBox(height: 16),
            TextButton(
              child: Text('Share'),
              onPressed: () {
                Get.back();
                handleShare();
                copiedAlert();
              }
            )
            
          ]
        )
      )
    );

  }

  void copiedAlert() {

    Get.defaultDialog(
      title: "😁😁😁",
      titlePadding: EdgeInsets.all(16),
      content: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children : [
            Text("Copied Result To Clipboard "),
            SizedBox(height: 16),
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Get.back();
              }
            )
            
          ]
        )
      )
    );

  }

  void calculateDistance(Map<String, dynamic> from, Map<String, dynamic> to) async{
    print({
      'lat_from': from["lat"].toString(), 
      'lng_from': from["lng"].toString(), 
      'lat_to': to["lat"].toString(),  
      'lng_to': to["lng"].toString(),  
    });
    var url = Uri.parse('https://pintas.my.id/calculate_distance_bearing');
    var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, 
      body: json.encode({
        'lat_from': from["lat"], 
        'lng_from': from["lng"], 
        'lat_to': to["lat"],  
        'lng_to': to["lng"], 
      })
    );
    if(response.statusCode == 200){
      final data = await json.decode(response.body);

      var temp = listGuestCountry;
      temp.add({
        "name" : from["name"] as String,
        "code" : from["code"]  as String,
        'lat_to': from["lat"].toString(),  
        'lng_to': from["lng"].toString(),
        "distance" : data["data"]["distance"].toString(),
        "direction" : data["data"]["direction"].toString()
      });
      setState((){
          listGuestCountry = temp;
      });

      print(listGuestCountry);
    }
    
  }


  void showListCountry() {
    setState((){
      listSearchCountry = listCountry;
    });
     
    Get.defaultDialog(
      title: "Choose Country",
      titlePadding: EdgeInsets.all(16),
      content: Container(
        width: 300,
        child: SearchChoices.single(
          items: listSearchCountry.map<DropdownMenuItem>((item) {
            return (DropdownMenuItem(
              child: Text(
                item["name"]
              ),
              value: item,
            ));
          }).toList(),
          value: selectedValueSingleDialog,
          hint: "Select one",
          searchHint: null,
          onChanged: (value) {
            setState((){
              selectedValueSingleDialog = value;
            });
          },
          searchFn: (String keyword, items) {
          List<int> ret = [];
            if (items != null && keyword.isNotEmpty) {
              keyword.split(" ").forEach((k) {
                int i = 0;
                items.forEach((item) {
                  var itemCountry = item.value as Map<String, dynamic>;
                  if (k.isNotEmpty &&
                      (itemCountry["name"]
                          .toString()
                          .toLowerCase()
                          .contains(k.toLowerCase()))) {
                    ret.add(i);
                  }
                  i++;
                });
              });
            }
            if (keyword.isEmpty) {
              ret = Iterable<int>.generate(items.length).toList();
            }
            return (ret);
          },
          dialogBox: false,
          isExpanded: true,
          menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
        )
      ),
      confirm : Container(
         padding: EdgeInsets.all(16),
        child: TextButton(
          child: Text('Choose'),
          onPressed: () {
            if(selectedValueSingleDialog != null){
              Get.back();

              calculateDistance({
                "name" : selectedValueSingleDialog!["name"] as String,
                "code" : selectedValueSingleDialog!["code"]  as String,
                "lat" : selectedValueSingleDialog!["lat"],
                "lng" : selectedValueSingleDialog!["lng"]
              }, codeCountry);
              if(selectedValueSingleDialog!["code"] == codeCountry["code"]){
                setState((){
                    isCorrect = true;
                    currentOpenIndex = 6;
                });
                sweatAlert();
              } else {
                randomGen();

                if(currentOpenIndex == 6){
                  failAlert();
                }
              }

              setState((){
                selectedValueSingleDialog = null;
              });
            }
          }
        )
      )
    );
  }

  void handleShare(){
    var result = "Flag X/6 \n\n";
    listGuestCountry.forEach((item) {
      var distance = int.parse(item["distance"]);

      var iconDistance = "⬛⬛⬛⬛⬛⬛";

      if(distance < 1000) {
        iconDistance = "🟨🟨🟨🟨🟨🟨";
      }

      if(distance >= 1000) {
        iconDistance = "🟥🟥🟥🟥🟥🟥";
      }

      if(distance == 0) {
        iconDistance = "🟩🟩🟩🟩🟩🟩";
      }

      var directionIcon = "☑";


      

      if(item["direction"] == "N"){
        directionIcon = "⬆";
      } else if(item["direction"] == "NE"){
        directionIcon = "↗";
      } else if(item["direction"] == "E"){
        directionIcon = "➡";
      } else if(item["direction"] == "SE"){
        directionIcon = "↘";
      } else if(item["direction"] == "S"){
        directionIcon = "⬇";
      } else if(item["direction"] == "SW"){
        directionIcon = "↙";
      } else if(item["direction"] == "W"){
        directionIcon = "⬅";
      } else if(item["direction"] == "NW"){
        directionIcon = "↖";
      }

      if(distance == 0){
        directionIcon = "🥳";

      }

      result = result + iconDistance +" "+item["distance"]+"KM " + directionIcon +"\n";


    });

    result = result + "\nhttps://prasetyanurangga.github.io/flagly";

    Clipboard.setData(ClipboardData(text: result));
  }

  Future<void> readJson() async {

    var rng = Random();
    final String response = await rootBundle.loadString('assets/country.json');
    final data = await json.decode(response);
    final listName = data.map((item){
      return {
        "name" : item["name"] as String,
        "code" : item["country_code"]  as String,
        "lat" : item["latlng"][0],
        "lng" : item["latlng"][1]
      };
    }).toList();




    final countListName = listName.length;
    var randNum = rng.nextInt(countListName);
    print(countListName);
    Map<String, dynamic > randomCountry = listName[randNum];
    setState(() {
      listCountry = listName;
      codeCountry = {
        "name" : randomCountry["name"] as String,
        "code" : randomCountry["code"]  as String,
        "lat" : randomCountry["lat"],
        "lng" : randomCountry["lng"]
      };
    });
  }

  void launchUrlBuyMeCoffe() async {
    if (!await launchUrl(Uri.parse("https://ko-fi.com/prasetyanurangga"))) throw 'Could not launch';
  }

  void openUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch';
  }

  void randomGen(){
    
    var randNum = currentOpenIndex + 1;
    print(randNum);
    var temp = showContainer;
    temp.add(randNum);

    print(temp);
    setState((){
        showContainer = temp;
        currentOpenIndex = randNum;
    });
     

    

    // setOfInts.add(Random().nextInt(6));
    // print(setOfInts);
  }

  Widget iconGenerator(String direction, String distance) {


    var distanceNum = int.parse(distance);
    if(distanceNum == 0){
      return Icon(Icons.check);
    }

    if(direction == "N"){
      return Icon(Icons.north);
    } else if(direction == "NE"){
      return Icon(Icons.north_east);
    } else if(direction == "E"){
      return Icon(Icons.east);
    } else if(direction == "SE"){
      return Icon(Icons.south_east);
    } else if(direction == "S"){
      return Icon(Icons.south);
    } else if(direction == "SW"){
      return Icon(Icons.south_west);
    } else if(direction == "W"){
      return Icon(Icons.west);
    } else if(direction == "NW"){
      return Icon(Icons.north_west);
    } else {
      return Icon(Icons.close);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : SingleChildScrollView(
        child : Container(
          padding: EdgeInsets.all(16),
          child: ResponsiveLayoutBuilder(
            small: (_, __) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'FlagLy',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.03),
                                spreadRadius: 8.0,
                                blurRadius: 8.0,
                                offset: Offset(0, 0)
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Flag',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              SizedBox(height: 20),
                              Stack(
                                children : [
                                  Container(
                                    height: 150, 
                                    width: 201,
                                    child: Image.asset(
                                      "assets/flags/${codeCountry['code']!.toLowerCase()}.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Container(
                                    height: 150, width: 201,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 1 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                            
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 2 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 3 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                          ]
                                        ),
                                        Row(
                                          children: [
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 4 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 5 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 6 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                          ]
                                        )
                                      ]
                                    )
                                  )
                                ]
                              ),
                            ]
                          ),

                          padding: EdgeInsets.all(16),
                        ),

                        SizedBox(height: 16),
                        Container(

                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [

                              Text(
                                'Map',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                width: 201,
                                child: Image.asset(
                                  "assets/maps/${codeCountry['code']!.toLowerCase()}.png",
                                  fit: BoxFit.contain,
                                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                       return Container();
                                 },
                                ), 
                              )
                            ]
                          ),
                          
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.03),
                                spreadRadius: 8.0,
                                blurRadius: 8.0,
                                offset: Offset(0, 0)
                              )
                            ],
                          ),
                        ),
                      ]
                    ),
                  ),
                  SizedBox(height: 16),

                  
                  ElevatedButton(  
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF16a34a),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(16.0),
                      ),
                    ),

                    onPressed: () {
                      if(listGuestCountry.length < 6 && !isCorrect){
                        showListCountry();
                      } else{
                        handleShare();
                        copiedAlert();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (listGuestCountry.length < 6 && !isCorrect) ? "Guest Country"  : "Share",
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white
                            )
                          )
                        ],
                      )
                    )
                  ),

                  SizedBox(height: 16),
                  isCorrect ? Container(
                    width: 402,
                    child: Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text : TextSpan(
                                text: "Show On Maps🗺",
                                recognizer: new TapGestureRecognizer()..onTap = () => openUrl("https://www.google.com/maps?q="+ codeCountry["name"]+" "+codeCountry["code"]),
                              ),
                              textAlign: TextAlign.center,
                            )
                          ),
                          Expanded(
                            child: RichText(
                              text : TextSpan(
                                text: "Show On Wikipedia🌎",
                                recognizer: new TapGestureRecognizer()..onTap = () => openUrl("https://en.wikipedia.org/wiki/"+codeCountry["name"]),
                              ),
                              textAlign: TextAlign.center,
                            )
                          )
                        ]
                    ),
                  ) :  Container(),

                  SizedBox(height: 16),

                  Text(
                    "Attempt ${currentOpenIndex}/6",
                    style: TextStyle(
                      fontWeight: FontWeight.w700
                    ),
                  ),

                  SizedBox(height: 16),

                  listGuestCountry.length > 0 ? Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.03),
                          spreadRadius: 8.0,
                          blurRadius: 8.0,
                          offset: Offset(0, 0)
                        )
                      ],
                    ),
                    width: 301,
                    height: 420,
                    child: ListView.builder(
                      itemCount: listGuestCountry.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(listGuestCountry[index]['name']),
                          subtitle: Text(
                            listGuestCountry[index]['distance'] + " KM",
                            style: TextStyle(
                              fontWeight: FontWeight.w700
                            ),
                          ),
                          trailing: iconGenerator(listGuestCountry[index]['direction'], listGuestCountry[index]['distance']),
                        ); 
                      }
                    ),
                  ) : Container(),

                  SizedBox(height: 20),
                  RichText(
                    text : TextSpan(
                      text: "Want to support us? ",
                      children: [
                        new TextSpan(
                          text: 'Buy Me a Coffee☕',
                          style: TextStyle(
                            fontWeight: FontWeight.w700
                          ),
                          recognizer: new TapGestureRecognizer()..onTap = () => launchUrlBuyMeCoffe(),
                        )
                      ]
                    ),
                  )
                ]
              )
            ),
            medium: (_, __) =>  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'FlagLy',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.03),
                                spreadRadius: 8.0,
                                blurRadius: 8.0,
                                offset: Offset(0, 0)
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Flag',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              SizedBox(height: 20),
                              Stack(
                                children : [
                                  Container(
                                    height: 150, 
                                    width: 201,
                                    child: Image.asset(
                                      "assets/flags/${codeCountry['code']!.toLowerCase()}.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Container(
                                    height: 150, width: 201,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 1 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                            
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 2 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 3 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                          ]
                                        ),
                                        Row(
                                          children: [
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 4 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 5 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 6 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                          ]
                                        )
                                      ]
                                    )
                                  )
                                ]
                              ),
                            ]
                          ),

                          padding: EdgeInsets.all(16),
                        ),

                        SizedBox(width: 16),
                        Container(

                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [

                              Text(
                                'Map',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 150,
                                child: Image.asset(
                                  "assets/maps/${codeCountry['code']!.toLowerCase()}.png",
                                  fit: BoxFit.contain,
                                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                       return Container();
                                 },
                                ), 
                              )
                            ]
                          ),
                          
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.03),
                                spreadRadius: 8.0,
                                blurRadius: 8.0,
                                offset: Offset(0, 0)
                              )
                            ],
                          ),
                        ),
                      ]
                    ),
                  ),

                  SizedBox(height: 16),

                  
                  ElevatedButton(  
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF16a34a),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(16.0),
                      ),
                    ),

                    onPressed: () {
                      if(listGuestCountry.length < 6 && !isCorrect){
                        showListCountry();
                      } else{
                        handleShare();
                        copiedAlert();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (listGuestCountry.length < 6 && !isCorrect) ? "Guest Country"  : "Share",
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white
                            )
                          )
                        ],
                      )
                    )
                  ),

                  SizedBox(height: 16),
                  isCorrect ? Container(
                    width: 402,
                    child: Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text : TextSpan(
                                text: "Show On Maps🗺",
                                recognizer: new TapGestureRecognizer()..onTap = () => openUrl("https://www.google.com/maps?q="+ codeCountry["name"]+" "+codeCountry["code"]),
                              ),
                              textAlign: TextAlign.center,
                            )
                          ),
                          Expanded(
                            child: RichText(
                              text : TextSpan(
                                text: "Show On Wikipedia🌎",
                                recognizer: new TapGestureRecognizer()..onTap = () => openUrl("https://en.wikipedia.org/wiki/"+codeCountry["name"]),
                              ),
                              textAlign: TextAlign.center,
                            )
                          )
                        ]
                    ),
                  ) :  Container(),

                  SizedBox(height: 16),

                  Text(
                    "Attempt ${currentOpenIndex}/6",
                    style: TextStyle(
                      fontWeight: FontWeight.w700
                    ),
                  ),

                  SizedBox(height: 16),

                  listGuestCountry.length > 0 ? Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.03),
                          spreadRadius: 8.0,
                          blurRadius: 8.0,
                          offset: Offset(0, 0)
                        )
                      ],
                    ),
                    width: 402,
                    height: 420,
                    child: ListView.builder(
                      itemCount: listGuestCountry.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(listGuestCountry[index]['name']),
                          subtitle: Text(
                            listGuestCountry[index]['distance'] + " KM",
                            style: TextStyle(
                              fontWeight: FontWeight.w700
                            ),
                          ),
                          trailing: iconGenerator(listGuestCountry[index]['direction'], listGuestCountry[index]['distance']),
                        ); 
                      }
                    ),
                  ) : Container(),

                  SizedBox(height: 20),
                  RichText(
                    text : TextSpan(
                      text: "Want to support us? ",
                      children: [
                        new TextSpan(
                          text: 'Buy Me a Coffee☕',
                          style: TextStyle(
                            fontWeight: FontWeight.w700
                          ),
                          recognizer: new TapGestureRecognizer()..onTap = () => launchUrlBuyMeCoffe(),
                        )
                      ]
                    ),
                  )
                ]
              )
            ),
            large: (_, __) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'FlagLy',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.03),
                                spreadRadius: 8.0,
                                blurRadius: 8.0,
                                offset: Offset(0, 0)
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Flag',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              SizedBox(height: 20),
                              Stack(
                                children : [
                                  Container(
                                    height: 150, 
                                    width: 201,
                                    child: Image.asset(
                                      "assets/flags/${codeCountry['code']!.toLowerCase()}.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Container(
                                    height: 150, width: 201,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 1 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                            
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 2 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 3 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                          ]
                                        ),
                                        Row(
                                          children: [
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 4 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 5 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                            AnimatedOpacity(
                                              opacity: currentOpenIndex < 6 ? 1.0 : 0.0,
                                              duration: const Duration(milliseconds: 100),
                                              child: Container(
                                                height: 75, width: 67,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1
                                                  ), 
                                                )
                                              ),
                                            ),
                                          ]
                                        )
                                      ]
                                    )
                                  )
                                ]
                              ),
                            ]
                          ),

                          padding: EdgeInsets.all(16),
                        ),

                        SizedBox(width: 16),
                        Container(

                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [

                              Text(
                                'Map',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 150,
                                child: Image.asset(
                                  "assets/maps/${codeCountry['code']!.toLowerCase()}.png",
                                  fit: BoxFit.contain,
                                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                       return Container();
                                 },
                                ), 
                              )
                            ]
                          ),
                          
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.03),
                                spreadRadius: 8.0,
                                blurRadius: 8.0,
                                offset: Offset(0, 0)
                              )
                            ],
                          ),
                        ),
                      ]
                    ),
                  ),

                  SizedBox(height: 16),

                  
                  ElevatedButton(  
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF16a34a),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(16.0),
                      ),
                    ),

                    onPressed: () {
                      if(listGuestCountry.length < 6 && !isCorrect){
                        showListCountry();
                      } else{
                        handleShare();
                        copiedAlert();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (listGuestCountry.length < 6 && !isCorrect) ? "Guest Country"  : "Share",
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white
                            )
                          )
                        ],
                      )
                    )
                  ),

                  SizedBox(height: 16),
                  isCorrect ? Container(
                    width: 402,
                    child: Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text : TextSpan(
                                text: "Show On Maps🗺",
                                recognizer: new TapGestureRecognizer()..onTap = () => openUrl("https://www.google.com/maps?q="+ codeCountry["name"]+" "+codeCountry["code"]),
                              ),
                              textAlign: TextAlign.center,
                            )
                          ),
                          Expanded(
                            child: RichText(
                              text : TextSpan(
                                text: "Show On Wikipedia🌎",
                                recognizer: new TapGestureRecognizer()..onTap = () => openUrl("https://en.wikipedia.org/wiki/"+codeCountry["name"]),
                              ),
                              textAlign: TextAlign.center,
                            )
                          )
                        ]
                    ),
                  ) :  Container(),

                  SizedBox(height: 16),

                  Text(
                    "Attempt ${currentOpenIndex}/6",
                    style: TextStyle(
                      fontWeight: FontWeight.w700
                    ),
                  ),

                  SizedBox(height: 16),

                  listGuestCountry.length > 0 ? Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.03),
                          spreadRadius: 8.0,
                          blurRadius: 8.0,
                          offset: Offset(0, 0)
                        )
                      ],
                    ),
                    width: 402,
                    height: 420,
                    child: ListView.builder(
                      itemCount: listGuestCountry.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(listGuestCountry[index]['name']),
                          subtitle: Text(
                            listGuestCountry[index]['distance'] + " KM",
                            style: TextStyle(
                              fontWeight: FontWeight.w700
                            ),
                          ),
                          trailing: iconGenerator(listGuestCountry[index]['direction'], listGuestCountry[index]['distance']),
                        ); 
                      }
                    ),
                  ) : Container(),

                  SizedBox(height: 20),
                  RichText(
                    text : TextSpan(
                      text: "Want to support us? ",
                      children: [
                        new TextSpan(
                          text: 'Buy Me a Coffee☕',
                          style: TextStyle(
                            fontWeight: FontWeight.w700
                          ),
                          recognizer: new TapGestureRecognizer()..onTap = () => launchUrlBuyMeCoffe(),
                        )
                      ]
                    ),
                  )
                ]
              )
            ),
          )
        )
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
