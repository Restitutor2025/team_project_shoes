import 'dart:convert';

import 'package:customer_app/database/selected_store_database.dart';
import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/util/pcolor.dart';
import 'package:customer_app/util/snackbar.dart';
import 'package:customer_app/view/map/map_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlng;

class MapSelect extends StatefulWidget {
  const MapSelect({super.key});

  @override
  State<MapSelect> createState() => _MapSelectState();
}

class _MapSelectState extends State<MapSelect> {
  // Property
  MapController mapController = MapController();
  TextEditingController searchController = TextEditingController();
  int kindChoice = 0;
  bool canRun = false;
  int? selectedStoreId;
  String query = '';

  List storeList = [];

  late Position currentPosition;
  double latData = 0.0;
  double longData = 0.0;

  final SelectedStoreDatabase selectedStoreDB = SelectedStoreDatabase();

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    loadStoreData();
    loadSelectedStoreId();
  }

  void checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      getCurrentLocation();
    }
  }

  void getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    currentPosition = position;
    latData = currentPosition.latitude;
    longData = currentPosition.longitude;
    canRun = true;
    await loadStoreData();
    setState(() {});
  }

  Future<void> loadStoreData() async {
    var url = Uri.parse("${IpAddress.baseUrl}/store/select");
    var response = await http.get(url);
    storeList.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    if (query.isEmpty) {
      storeList.addAll(result);
    } else {
      storeList = result.where((store) => store['name'].toString().contains(query)).toList();
    }
    if (canRun) {
      storeList.sort((a, b) {
        final double aLat = (a['lat'] as num).toDouble();
        final double aLng = (a['long'] as num).toDouble();
        final double bLat = (b['lat'] as num).toDouble();
        final double bLng = (b['long'] as num).toDouble();

        final double distA = Geolocator.distanceBetween(latData, longData, aLat, aLng);
        final double distB = Geolocator.distanceBetween(latData, longData, bLat, bLng);

        return distA.compareTo(distB);
      });
    }

      setState(() {});
    }

  Future<void> loadSelectedStoreId() async {
    final sid = await selectedStoreDB.queryStoreId();
    print('앱 시작 시 DB에서 읽어온 매장 id: $sid');

    if (sid != null) {
      selectedStoreId = sid;
      setState(() {});
    }
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
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '매장 검색',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    color: Colors.black,
                    onPressed: () async{
                      query = searchController.text.trim();
                      await loadStoreData();
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 250,
                child: Stack(
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
                            heroTag: "a",
                            child: Icon(Icons.my_location),
                            onPressed: () => mapController.move(
                              latlng.LatLng(latData, longData),
                              mapController.camera.zoom,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: FloatingActionButton(
                              heroTag: "b",
                              child: Icon(Icons.zoom_out_map_outlined),
                              onPressed: () {
                                double? targetLat;
                                double? targetLng;
                                
                                if (selectedStoreId != null) {
                                  final matches = storeList.where((s) => s['id'] == selectedStoreId);
                                  if (matches.isNotEmpty) {
                                    final store = matches.first as Map<String, dynamic>;
                                    targetLat = (store['lat'] as num).toDouble();
                                    targetLng = (store['long'] as num).toDouble();
                                  }
                                }

                                Get.to(
                                  MapDetail(),
                                  arguments: {
                                    'lat': targetLat,
                                    'lng': targetLng,
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: storeList.isEmpty ? Center(child: Text('결과가 없습니다.'))
              : ListView.builder(
                itemCount: storeList.length,
                itemBuilder: (context, index) {
                  final store = storeList[index];
                  final int storeId = store['id'];
                  final bool isSelected = (selectedStoreId == storeId);
                  final double storeLat = store['lat'];
                  final double storeLng = store['long'];
      
                  final double distance = canRun
                      ? Geolocator.distanceBetween(latData, longData, storeLat, storeLng)
                      : 0.0;
      
                  return GestureDetector(
                    onTap: () => selectStore(store),
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
                                Text(
                                  store['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                                ),
                                Text(store['address']),
                                Text(
                                  canRun
                                      ? '${distance.toStringAsFixed(0)} m'
                                      : '- m',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
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
      
                                final double lat = store['lat'];
                                final double lng = store['long'];
      
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
      ),
    );
  } // build

  // Functions -------------------------------------
  FlutterMap flutterMap() {
    final List<Marker> markers = [];

    markers.add(
      Marker(
        width: 100,
        height: 100,
        point: latlng.LatLng(latData, longData),
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
        initialZoom: 17.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: "com.tj.gpsmapapp",
        ),
        MarkerLayer(markers: markers),
      ],
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

  void selectStore(Map<String, dynamic> store) {
    Get.defaultDialog(
      title: '매장 선택',
      middleText: '${store['name']} 매장을 선택하시겠습니까?',
      textConfirm: '선택',
      textCancel: '취소',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        final int storeId = store['id'];

        final result = await selectedStoreDB.insertStoreId(storeId);
        print('선택 매장 저장 결과: $result');

        selectedStoreId = storeId;

        setState(() {});
        Get.back();
        Snackbar().okSnackBar('성공', '매장이 선택 되었습니다.');
      },
    );
  }
} // class
