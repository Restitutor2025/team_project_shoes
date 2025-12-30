import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//  Configuration of the App
/*
  Create: 12/12/2025 18:12, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Desc: Configuration of the App
*/

//  DB
//  For use
//  '${rDBName}${rDBFileExt}';
const String rDBName = 'DBname';  //  Database Name
const String rDBFileExt = '.db';
const int rVersion = 1;



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
final NumberFormat priceFormatter = NumberFormat('#,###.##'); //  Number format ###,###

final RegExp emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
);

//  Features
const bool kEnableSaleFeature = true;
const bool kEnableStockAutoRequest = true;
const bool kUseLocalDBOnly = true;

//  Tables
const String kTableCustomer = 'Customer';
const String kTableManufacturer = 'Manufacturer';
const String kTableProduct = 'Product';
const String tTableEmployee = 'Employee';


//  Routes
const String routeLogin = '/';
const String routeSettings = '/mypage';

// Districts
const List<String> district = [
];