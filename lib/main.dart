import 'package:flutter/material.dart';
import 'pages/find_location.dart';

void main()
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Location by Voice APP (PL)',
      theme: ThemeData( colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo),),
      home: FindLocationScreen(),);
  }
}


