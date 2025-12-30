import 'package:customer_app/util/pcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
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

  List<Map<String, dynamic>> storeList = [];

  late Position currentPosition;
  double latData = 0.0;
  double longData = 0.0;

  @override
  void initState() {
    super.initState();
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
    latData = currentPosition.latitude;
    longData = currentPosition.longitude;
    canRun = true;
    setState(() {});
  }

  Future<void> loadStoreData() async{
  storeList = [
    {
      'id': 1,
      'name': '강남역점',
      'lat': 37.4979,
      'lng': 127.0276,
      'address': '서울특별시 강남구 강남대로 78길'
    },
    {
      'id': 2,
      'name': '동작구점',
      'lat': 37.5124,
      'lng': 126.9393,
      'address': '서울특별시 동작구'
    },
    {
      'id': 3,
      'name': '송파구점',
      'lat': 37.5146,
      'lng': 127.1058,
      'address': '서울특별시 송파구'
    },
  ];
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
            child: FloatingActionButton(
              child: Icon(Icons.zoom_out_map_outlined),
              onPressed: () => Get.back(),
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
        width: 60,
        height: 60,
        point: latlng.LatLng(latData, longData),
        child: Icon(
          Icons.my_location,
          size: 40,
          color: Colors.blue,
        ),
      ),
    );

    markers.addAll(
      storeList.map((store) {
        final int storeId = store['id'] as int;
        final String storeName = store['name'] as String;
        final double lat = store['lat'] as double;
        final double lng = store['lng'] as double;
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

  // 거리 계산
  double calcDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }

} // class