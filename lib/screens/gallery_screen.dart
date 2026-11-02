import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:personal_gallery/networking.dart';
import 'package:personal_gallery/gallery_data.dart';
import 'package:personal_gallery/screens/large_image_screen.dart';
import 'package:provider/provider.dart';

class GalleryScreen extends StatelessWidget {
  static const id = "GalleryScreen";
  bool selectionMode = false;

  void reset(BuildContext context) {
    Provider.of<GalleryData>(
      context,
      listen: false,
    ).walkAwayTimer?.cancel(); // Cancel the walk away timer when resetting
    //Clear all checkboxes
    if (Provider.of<GalleryData>(context, listen: false).addCheckbox) {
      Provider.of<GalleryData>(context, listen: false).clearSelections();
      Provider.of<GalleryData>(context, listen: false).checkBox();
    }
    Navigator.pop(context);
  }

  bool photosSent = false;

  @override
  Widget build(BuildContext context) {
    bool savePhotosToFile = Provider.of<GalleryData>(
      context,
      listen: false,
    ).savePhotosToFile;

    if (!Provider.of<GalleryData>(context, listen: false).walkAwayRunning &&
        !photosSent) {
      Provider.of<GalleryData>(context, listen: false).startWalkAwayTimer();
      print('walk away timer started in gallery screen');
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 80,
          leadingWidth: 150,
          leading: Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
              ),
              onPressed: () {
                Provider.of<GalleryData>(
                  context,
                  listen: false,
                ).stopWalkAwayTimer();
                print('clearing selections walk away timer stopped');

                Provider.of<GalleryData>(
                  context,
                  listen: false,
                ).clearSelections();
                Provider.of<GalleryData>(
                  context,
                  listen: false,
                ).startWalkAwayTimer();
                print('clearing selections walk away timer restarted');
              },
              child: Text(
                'Clear Selections',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  //fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            'Select Photos Press Finished when done.',
            textAlign: TextAlign.center,
          ),
          actions: [
            IconButton(
              iconSize: 30,
              onPressed: () {
                Provider.of<GalleryData>(
                  context,
                  listen: false,
                ).stopWalkAwayTimer();
                print('cancel button walk away timer stopped');
                //remove photos from device
                Provider.of<GalleryData>(
                  context,
                  listen: false,
                ).removePhotosFromDevice();
                //Clear all checkboxes
                if (Provider.of<GalleryData>(
                  context,
                  listen: false,
                ).addCheckbox) {
                  Provider.of<GalleryData>(
                    context,
                    listen: false,
                  ).selectedIndexes.clear();
                  Provider.of<GalleryData>(
                    context,
                    listen: false,
                  ).addCheckbox = !Provider.of<GalleryData>(
                    context,
                    listen: false,
                  ).addCheckbox;
                }
                Navigator.pop(context);
              },
              icon: Icon(Icons.cancel),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.circle,
                color: Provider.of<GalleryData>(context).netConnected
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
        floatingActionButton:
            (Provider.of<GalleryData>(context, listen: false).addCheckbox)
            ? FloatingActionButton.extended(
                backgroundColor: Colors.lightBlueAccent,
                onPressed: () async {
                  Provider.of<GalleryData>(
                    context,
                    listen: false,
                  ).stopWalkAwayTimer();
                  print('finished button walk away timer stopped');
                  await Provider.of<GalleryData>(
                    context,
                    listen: false,
                  ).sendPhotos();
                  if (Provider.of<GalleryData>(
                        context,
                        listen: false,
                      ).sendStatus ==
                      'Success') {
                    photosSent = true;
                    //Clear and remove all checkboxes
                    if (Provider.of<GalleryData>(
                      context,
                      listen: false,
                    ).addCheckbox) {
                      Provider.of<GalleryData>(
                        context,
                        listen: false,
                      ).selectedIndexes.clear();
                      Provider.of<GalleryData>(
                        context,
                        listen: false,
                      ).addCheckbox = !Provider.of<GalleryData>(
                        context,
                        listen: false,
                      ).addCheckbox;
                      Provider.of<GalleryData>(
                        context,
                        listen: false,
                      ).removePhotosFromDevice();
                    }
                    print(
                      'photos sent:$photosSent, selections cleared, checkboxes removed',
                    );
                    Navigator.pop(context);
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: (Text('Post Error')),
                        content: (Text(
                          'There was an error posting the photo(s) to the server',
                        )),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                label: Text(
                  'Finished',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: Icon(Icons.send),
              )
            : null,
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Consumer<GalleryData>(
            builder: (context, galleryData, child) {
              // 1. CHECK IF IMAGES ARE CURRENTLY DOWNLOADING
              // Change 'isLoading' to whatever boolean flag you use in gallery_data.dart
              if (galleryData.isLoading || galleryData.photosCount == 0) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.lightBlueAccent,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Downloading gallery images...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: Provider.of<GalleryData>(context)
                    .photosCount, //photosList.length,
                itemBuilder: (context, index) {
                  dynamic image;
                  String imageDescription = "";
                  print('savePhotosToFile: $savePhotosToFile');

                  if (savePhotosToFile) {
                    image = Provider.of<GalleryData>(
                      context,
                      listen: false,
                    ).localPhotosList[index];
                    imageDescription = Provider.of<GalleryData>(
                      context,
                      listen: false,
                    ).localPhotosList[index].path.split('/').last;
                  } else {
                    image = Provider.of<GalleryData>(context)
                        .photosList[index]['imgSource']; //photosList[index]['imgSource'];
                    imageDescription = Provider.of<GalleryData>(context)
                        .photosList[index]['PhotoDescription'];
                  }
                  final isChecked = Provider.of<GalleryData>(context)
                      .isSelected(index);

                  return GestureDetector(
                    onTap: () {
                      Provider.of<GalleryData>(
                        context,
                        listen: false,
                      ).stopWalkAwayTimer();
                      print('image tap walk away timer stopped');
                      Navigator.pushNamed(
                        context,
                        LargeImageScreen.id,
                        arguments: ScreenArguments(
                          imageUrl: image,
                          imageDescription: imageDescription,
                          index: index,
                        ),
                      );
                    },
                    onLongPress: () {
                      Provider.of<GalleryData>(
                        context,
                        listen: false,
                      ).stopWalkAwayTimer();
                      print('long press walk away timer stopped');

                      Provider.of<GalleryData>(
                        context,
                        listen: false,
                      ).checkBox();
                      Provider.of<GalleryData>(
                        context,
                        listen: false,
                      ).startWalkAwayTimer();
                      print('long press walk away timer restarted');
                    },
                    child: Stack(
                      //alignment: Alignment.topRight,
                      children: [
                        Hero(
                          tag: 'image_hero_$index',
                          //child: Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: savePhotosToFile
                                ? Image.file(
                                    image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    frameBuilder:
                                        (
                                          context,
                                          child,
                                          frame,
                                          wasSynchronouslyLoaded,
                                        ) {
                                          if (wasSynchronouslyLoaded)
                                            return child;
                                          return frame != null
                                              ? child
                                              : Container(
                                                  color: Colors.grey[900],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[900],
                                        child: const Icon(
                                          size: 150,
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            color: Colors.grey[900],
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[900],
                                        child: const Icon(
                                          size: 150,
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          //),
                        ),
                        if (Provider.of<GalleryData>(context).addCheckbox)
                          //MyCheckbox(),
                          Positioned(
                            //top: 0.1,
                            //right: 0.1,
                            child: Transform.scale(
                              scale: 1.5,
                              child: Checkbox(
                                side: BorderSide(color: Colors.white, width: 2),
                                checkColor: Colors.greenAccent,
                                shape: CircleBorder(
                                  side: BorderSide(color: Colors.white),
                                ),
                                value: isChecked,
                                onChanged: (bool? checked) {
                                  // Provider.of<GalleryData>(
                                  //   context,
                                  //   listen: false,
                                  // ).stopWalkAwayTimer();

                                  Provider.of<GalleryData>(
                                    context,
                                    listen: false,
                                  ).toggleSelection(index);

                                  // Provider.of<GalleryData>(
                                  //   context,
                                  //   listen: false,
                                  // ).startWalkAwayTimer();
                                  print('checkbox walk away timer restarted');
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
