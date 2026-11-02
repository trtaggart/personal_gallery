import 'package:flutter/material.dart';
import 'package:personal_gallery/gallery_data.dart';
import 'package:provider/provider.dart';
import 'package:personal_gallery/screens/home_screen.dart';

class ScreenArguments {
  final dynamic imageUrl;
  final dynamic imageDescription;
  final int index;

  ScreenArguments({required this.imageUrl, required this.imageDescription, required this.index});
}

class LargeImageScreen extends StatelessWidget {
  const LargeImageScreen({super.key});
  static const id = 'LargeImageScreen';
  // final String? imageUrl;
  // final String? imageDescription;
  // final int? index;

  @override
  Widget build(BuildContext context) {
  final savePhotoToFile = Provider.of<GalleryData>(context, listen: false).savePhotosToFile; // Set to true to save photos to file, false to use network images

    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    final index = args.index;
    // final shouldPop = context.select<GalleryData, bool>(
    //   (galleryData) => galleryData.doPop,
    // );
    // if (shouldPop) {
    //   Provider.of<GalleryData>(context, listen: false).doPop =
    //       false; // Reset the flag
    //   Provider.of<GalleryData>(context, listen: false).walkAwayTimer?.cancel();
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Navigator.popUntil(context, ModalRoute.withName(HomeScreen.id));
    //   });
    // }
    // if (!shouldPop) {
      Provider.of<GalleryData>(context, listen: false).startWalkAwayTimer();
      print('walk away timer started in large image screen');
    //}
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Provider.of<GalleryData>(context, listen: false).stopWalkAwayTimer();
            Navigator.pop(context);
            Provider.of<GalleryData>(context, listen: false).startWalkAwayTimer();
            print('walk away timer restarted in large image screen after user pressed back button');
          },
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(args.imageDescription, 
        style: const TextStyle(
          color: Colors.white),
        ),
      ),
      body: Center(
        child: Hero(
          tag: 'image_hero_$index',
          // InteractiveViewer handles multi-touch pinch to zoom and panning automatically
          child: InteractiveViewer(
            clipBehavior: Clip.none,
            minScale: 1.0,
            maxScale: 4.0,
            child: savePhotoToFile ? Image.file(
              args.imageUrl,
              fit: BoxFit.contain,
            ): Image.network(
              args.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

// showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Need more time?'),
//             content: const Text('Do you need more time to view the image? If not, you will be returned to the home screen.'),
//             actions: <Widget>[
//               Row(
//                 children: [
//                   TextButton(
//                     child: const Text('Yes'),
//                     onPressed: () {
//                       Navigator.of(context).pop(); // Close the dialog
//                       Provider.of<GalleryData>(context, listen: false).doPop =
//                         false; // Reset the flag
//                       Provider.of<GalleryData>(context, listen: false).startWalkAwayTimer();
//                       print('walk away timer started in large image screen after user selected yes');
//                     },
//                   ),
//                   TextButton(
//                     child: const Text('No'),
//                     onPressed: () {
//                       Navigator.of(context).pop(); // Close the dialog
//                       Provider.of<GalleryData>(context, listen: false).doPop =
//                         false; // Reset the flag
//                       Provider.of<GalleryData>(context, listen: false).walkAwayTimer?.cancel();
//                       Navigator.popUntil(context, ModalRoute.withName(HomeScreen.id));
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           );
//         },
//       );

