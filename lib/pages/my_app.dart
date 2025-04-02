import 'package:flutter/material.dart';
import 'package:evaluate_app/apps/router/router.dart';

class MyApp extends StatelessWidget{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {   
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: RouterCustorm.router
    );
  }
}