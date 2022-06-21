import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

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
  int _counter = 0;
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


  @override
  void initState() {
    super.initState();
    readJson();
  }

  void sweatAlert() {

    Get.defaultDialog(
      title: "Horay",
      content: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children : [
            
            Text("Congratulations you managed to answer correctly"),
            SizedBox(height: 16),
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                html.window.location.reload();
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
        "distance" : data["data"]["distance"].toString() + " KM",
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
      content: Container(
        child: Column(
            children : [
              // TextFormField(
              //   onChanged: (text) {
              //     setState(() {
              //       listSearchCountry = listCountry.where((item) => (item["name"].toLowerCase()).contains(text.toLowerCase())).toList();
              //     });
              //     print(text);
              //     print(listSearchCountry);
              //     print(listSearchCountry.length);
              //   },
              //   textAlign: TextAlign.center,
              //   decoration: InputDecoration(
              //     hintText: "Type URL",
              //     fillColor: Color(0xFFECE8E8).withOpacity(0.4),
              //     filled: true,
              //     border: OutlineInputBorder(
              //       borderSide: BorderSide.none,
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderSide: BorderSide.none,
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderSide: BorderSide.none,
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //     errorBorder: OutlineInputBorder(
              //       borderSide: BorderSide.none,
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //     disabledBorder: OutlineInputBorder(
              //       borderSide: BorderSide.none,
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //   ),
              // ),
              Container(
                height: 200,
                width: 200,
                  child: ListView.builder(
                    itemCount: listSearchCountry.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: (){
                          Get.back();
                          if(listSearchCountry[index]["code"] == codeCountry["code"]){
                            sweatAlert();
                          } else {
                            calculateDistance({
                              "name" : listSearchCountry[index]["name"] as String,
                              "code" : listSearchCountry[index]["code"]  as String,
                              "lat" : listSearchCountry[index]["lat"],
                              "lng" : listSearchCountry[index]["lng"]
                            }, codeCountry);
                            randomGen();
                          }
                          
                        },
                        child: ListTile(
                          leading: const Icon(Icons.list),
                          title: Text(listSearchCountry[index]['name'])
                        )
                      );
                    }
                  ),
              )
            ]
        )
      )
    );
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

  Widget iconGenerator(String direction) {
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
        child: Center(
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
                child: Stack(
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
                                    color: Colors.green,
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
                                    color: Colors.green,
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
                                    color: Colors.green,
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
                                    color: Colors.green,
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
                                    color: Colors.green,
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
                                    color: Colors.green,
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

                margin: EdgeInsets.all(12), 
                padding: EdgeInsets.all(16),
              ),
              Container(

                margin: EdgeInsets.all(12), 
                padding: EdgeInsets.all(16),
                width: 201,
                child: Image.asset(
                  "assets/maps/${codeCountry['code']!.toLowerCase()}.png",
                  fit: BoxFit.contain,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                       return Container();
                 },
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

              SizedBox(height: 16),

              Container(
                margin: EdgeInsets.all(12), 
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
                width: 201,
                height: 100,
                child: ListView.builder(
                  itemCount: listGuestCountry.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(listGuestCountry[index]['name']),
                      subtitle: Text(listGuestCountry[index]['distance']),
                      trailing: iconGenerator(listGuestCountry[index]['direction']),
                    ); 
                  }
                ),
              ),
              SizedBox(height: 16),

              ElevatedButton(  
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(24.0),
                  ),
                ),

                onPressed: () {
                  if(listGuestCountry.length < 6){
                    showListCountry();
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Guest",
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.black
                        )
                      )
                    ],
                  )
                )
              ),
            ]
          )
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
