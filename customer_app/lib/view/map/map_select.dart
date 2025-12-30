import 'package:customer_app/util/pcolor.dart';
import 'package:customer_app/view/map/map_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MapSelect extends StatefulWidget {
  const MapSelect({super.key});

  @override
  State<MapSelect> createState() => _MapSelectState();
}

class _MapSelectState extends State<MapSelect> {
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
        title: Text('매장 검색'),
        centerTitle: true,
        backgroundColor: Pcolor.appBarBackgroundColor,
        foregroundColor: Pcolor.appBarForegroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                color: Colors.grey,
                width: MediaQuery.of(context).size.width*0.8,
                height: 50,
                child: Text('검색창'),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.9,
              height: 400,
              child: Stack(
                children: [
                  canRun
                    ? flutterMap()
                    : Center(child: CircularProgressIndicator()),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: FloatingActionButton(
                      child: Icon(Icons.zoom_out_map_outlined),
                      onPressed: () => Get.to(MapDetail()),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: storeList.length,
                itemBuilder: (context, index) {
                  final store = storeList[index];
                  final int storeId = store['id'] as int;
                  final bool isSelected = (selectedStoreId == storeId);
                  final double storeLat = store['lat'] as double;
                  final double storeLng = store['lng'] as double;
                  final double distance = Geolocator.distanceBetween(latData, longData, storeLat, storeLng);
                  return GestureDetector(
                    onTap: () => selectStore(),
                    child: Card(
                      color: Pcolor.basebackgroundColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(store['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                Text(store['address']),
                                Text(canRun ? '${distance.toStringAsFixed(0)} m' : '- m', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              onPressed: () {
                                if (selectedStoreId == storeId) {
                                  selectedStoreId = null;
                                } else {
                                  selectedStoreId = storeId;
                                }
                                    
                                final double lat = store['lat'] as double;
                                final double lng = store['lng'] as double;
                                    
                                mapController.move(
                                  latlng.LatLng(lat, lng),
                                  mapController.camera.zoom,
                                );
                                    
                                setState(() {});
                              },
                              icon: Icon(
                                isSelected
                                    ? Icons.pin_drop_rounded
                                    : Icons.pin_drop_outlined,
                                size: 50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  } // build

  // Functions -------------------------------------
  FlutterMap flutterMap(){
    final List<Marker> markers = [];

    markers.add(
      Marker(
        width: 100,
        height: 100,
        point: latlng.LatLng(latData, longData),
        child: Column(
          children: [
            Text('현위치', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
        final int storeId = store['id'] as int;
        final String storeName = store['name'] as String;
        final double lat = store['lat'] as double;
        final double lng = store['lng'] as double;
        final bool isSelected = (selectedStoreId == storeId);
        return Marker(
          width: 200,
          height: 200,
          point: latlng.LatLng(lat, lng),
          child: Column(
            children: [
              Text(
                storeName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Image.asset('images/logo.png', width: 100),
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

  void selectStore() {
    //
  }

} // class