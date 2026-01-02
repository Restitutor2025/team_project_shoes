import 'dart:convert';

import 'package:customer_app/util/pcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlng;

class MapDetail extends StatefulWidget {
  const MapDetail({super.key});

  @override
  State<MapDetail> createState() => _MapDetailState();
}

class _MapDetailState extends State<MapDetail> {
  // Property
  MapController mapController = MapController();
  int kindChoice = 0;
  bool canRun = false;
  int? selectedStoreId;

  List storeList = [];

  late Position currentPosition;
  double latData = 0.0;
  double longData = 0.0;
  double mylatData = 0.0;
  double mylongData = 0.0;

@override
void initState() {
  super.initState();

  final value = Get.arguments;

  if (value != null) {
    final double? argLat = (value['lat']);
    final double? argLng = (value['lng']);

    if (argLat != null && argLng != null) {
      latData = argLat;
      longData = argLng;
      canRun = true;
    }
  }
  checkLocationPermission();
  loadStoreData();
}

  void checkLocationPermission() async{
    LocationPermission permission = await Geolocator.checkPermission();
    
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.deniedForever){
      return;
    }
    if(permission == LocationPermission.whileInUse || 
       permission == LocationPermission.always){
        getCurrentLocation();
    }
  }

  void getCurrentLocation() async{
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;
    mylatData = currentPosition.latitude;
    mylongData = currentPosition.longitude;
    canRun = true;
    setState(() {});
  }

  Future<void> loadStoreData() async {
    var url = Uri.parse("http://172.16.250.193:8008/store/select");
    var response = await http.get(url);
    storeList.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    storeList.addAll(result);
    setState(() {});
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지도'),
        centerTitle: true,
        backgroundColor: Pcolor.appBarBackgroundColor,
        foregroundColor: Pcolor.appBarForegroundColor,
      ),
      body: Stack(
        children: [
          canRun
            ? flutterMap()
            : Center(child: CircularProgressIndicator()),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "c",
                        child: Icon(Icons.my_location),
                        onPressed: () => mapController.move(
                          latlng.LatLng(mylatData, mylongData),
                          mapController.camera.zoom
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: FloatingActionButton(
                          heroTag: "d",
                          child: Icon(Icons.zoom_out_map_outlined),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  } // build

  // Functions -------------------------------------
  FlutterMap flutterMap(){
    final List<Marker> markers = [];

    markers.add(
      Marker(
        width: 100,
        height: 100,
        point: latlng.LatLng(mylatData, mylongData),
        child: Column(
          children: [
            Text(
              '현위치',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
            ),
            Icon(
              Icons.my_location,
              size: 40,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );

    markers.addAll(
      storeList.map((store) {
        final int storeId = store['id'];
        final String storeName = store['name'];
        final double lat = store['lat'];
        final double lng = store['long'];
        final bool isSelected = (selectedStoreId == storeId);
        return Marker(
          width: isSelected ? 120 : 100,
          height: isSelected ? 100 : 80,
          point: latlng.LatLng(lat, lng),
          child: Column(
            children: [
              Text(
                storeName,
                style: TextStyle(
                  fontSize: isSelected ? 12 : 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Image.asset('images/logo.png', width: 50),
              Icon(
                isSelected
                    ? Icons.pin_drop_rounded
                    : Icons.pin_drop_outlined,
                size: isSelected ? 60 : 40,
                color: Colors.black,
              ),
            ],
          ),
        );
      }),
    );

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: latlng.LatLng(latData, longData),
        initialZoom: 17.0
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: "com.tj.gpsmapapp",
        ),
        MarkerLayer(
          markers: markers
        ),
      ]
    );
  }

} // class