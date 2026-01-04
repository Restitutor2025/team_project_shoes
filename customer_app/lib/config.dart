import 'dart:convert';

import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/model/name.dart';
import 'package:customer_app/model/product.dart';
import 'package:customer_app/model/product_image.dart';
import 'package:customer_app/model/purchase.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

//  Configuration of the App
/*
  Create: 12/12/2025 18:12, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    30/12/2025 14:10, 'Point 1, Chatting chatDateFormat', Creator: Chansol Park
    31/12/2025 10:17, 'Point 2, rDBName changed', Creator: Chansol Park
    02/01/2026 15:55, 'Point 3, created getJSONdata', Creator: Chansol Park
  Version: 1.0
  Desc: Configuration of the App
*/

//  DB
//  For use
//  '${rDBName}${rDBFileExt}';
const String rDBName = 'teamproject';  //  Database Name
const String rDBFileExt = '.db';
//  Point 3
const hostip='${IpAddress.host}';
//  Point 2
const String rDBFull = rDBName+rDBFileExt;
const int rVersion = 1;

//  Point 3
Future<List<dynamic>> getJSONData(String page) async {
    var url = Uri.parse("http://$hostip:8008/$page");
    var response = await http.get(url);

    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON["results"];

    final key = page.split('/').first.split('?').first;

    return procData(key, result);
  }

  List<dynamic> procData(String input, data) {
  switch (input) {
    case 'purchase':
      return data.map((e) => Purchase.fromJson(e)).toList();
    case 'name':
    case 'productname':
      return data.map((e) => Name.fromJson(e)).toList();
    case 'product':
      return data.map((e) => Product.fromJson(e)).toList();
    case 'productimage':
      return data.map((e) => ProductImage.fromJson(e)).toList();
    default:
      return [];
  }
}



//  Screen Datas
const seedColorDefault = Colors.deepPurple; //  Default Color for seedColor in main.dart
const defaultThemeMode = ThemeMode.system;  //  Default ThemeMode for ThemeMode in main.dart

//  Paths
const String rImageAssetPath = 'images/'; //  Default path for image
const String rlogoImage = 'images/logo.png';

//  DB Dummies
const String rDefaultProductImage = '${rImageAssetPath}default.png';  //  Default image for ProductBase

//  Formats
const String dateFormat = 'yyyy-MM-dd'; //  DateTime Format
const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';  //  DateTime Format to second 
//  Point 1
final String chatDateFormat = 'HH:mm';  //  Chat Date Format
final formatter = NumberFormat('#,###');
final NumberFormat priceFormatter = NumberFormat('#,###.##'); //  Number format ###,###

final RegExp emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
);

Widget chatDate({
  required String title,
  required DateTime datetime
}){
  return SizedBox(
    width: double.infinity,
    child: Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.fromLTRB(20,0,20,0),
          child: Text('$title, ${datetime.year}.${datetime.month}.${datetime.day}'),
        ),
        Expanded(child: Divider()),
      ],
    ),
  );
}

//  Tables
const String rTableColor = 'Customer';
const String rTableManufacturer = 'Manufacturer';
const String rTableProduct = 'Product';
const String rTableEmployee = 'Employee';


//  Routes
const String routeLogin = '/';
const String routeSettings = '/mypage';

// Districts
const List<String> district = [
];