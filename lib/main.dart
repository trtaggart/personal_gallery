import 'package:flutter/material.dart';
import 'package:personal_gallery/screens/gallery_screen.dart';
import 'package:personal_gallery/screens/home_screen.dart';
import 'package:personal_gallery/screens/large_image_screen.dart';
import 'package:personal_gallery/gallery_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_prefs.dart';
import 'package:flutter/services.dart';
import 'package:personal_gallery/app_navigator.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  // Hide the status bar and bottom navigation overlays
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [],
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return ChangeNotifierProvider(create: (context) => GalleryData(),
      child: MaterialApp(
        navigatorKey: AppNavigator.navigatorKey,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
          brightness: Brightness.light,
          primaryColorLight: Colors.white,
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: HomeScreen.id,
        routes: {
          HomeScreen.id:(context) => HomeScreen(),
          GalleryScreen.id:(context) => GalleryScreen(),
          LargeImageScreen.id:(context)=> LargeImageScreen(),
          }
      ),
    );
  }
}

