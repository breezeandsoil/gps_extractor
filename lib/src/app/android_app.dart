import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:gps_extractor/src/app/app_views_interface.dart';

// To be passed to the runApp() function.
// This is the app's first StatefulWidget.
class MyApp extends AppStatefulWidgetMVC {
	MyApp({Key? key}) : super(key: key);
	
	@override
	AppStateMVC createState() => _MyAppState();
}

class _MyAppState extends AppStateMVC<MyApp> {
	
	@override
	Widget buildApp(BuildContext context) {
		return MaterialApp(
			initialRoute: PageSplash.pageName,
			routes: {
				PageSplash.pageName : (BuildContext context) => PageSplash(),
				PageExample1.pageName : (BuildContext context) => PageExample1(),
				// PageExample2.pageName : (BuildContext context) => PageExample2()
			}
		);
	}
}


