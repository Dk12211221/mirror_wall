import 'package:flutter/material.dart';
import 'package:mirror_wall/screens/browser_screen.dart';
import 'package:provider/provider.dart';
import 'models/connectivity_provider.dart';
import 'models/webview_model.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (context) => WebViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BrowserScreen(),
    );
  }
}
