//used with Provider
//import 'dart:collection';

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personal_gallery/networking.dart';
import 'package:personal_gallery/shared_prefs.dart';

import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:personal_gallery/app_navigator.dart';
import 'package:personal_gallery/screens/home_screen.dart';

class GalleryData extends ChangeNotifier {
  List<dynamic> photosList = [];
  bool addCheckbox = false;
  bool checkboxState = false;
  bool netConnected = false;
  String serverAddress = '';
  Timer? _pingTimer;
  Timer? walkAwayTimer;
  bool walkAwayRunning = false;
  bool doPop = false;
  List<File> localPhotosList = [];
  late Directory directory;
  bool savePhotosToFile =
      false; // Set to true to save photos to file, false to use network images

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool timeExtended = false;

  GalleryData() {
    if (serverAddress == '') {
      try {
        getServerAddress();
      } catch (e) {
        print('Error retrieving server address: $e');
      }
    }
    getPing();
    // Start the ping timer when the GalleryData is created
    _pingTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      getPing();
    });
    //startWalkAwayTimer();
  }

  // Store selected photo indexes
  Set<int> _selectedIndexes = {};

  // Expose an unmodifiable view of the selections to prevent direct mutation
  Set<int> get selectedIndexes => _selectedIndexes;

  SharedPreferencesAsync prefs = SharedPreferencesAsync();

  void setServerAddress(String address) async {
    serverAddress = address;
    await prefs.setString('serverAddress', serverAddress);
    notifyListeners();
  }

  void getServerAddress() async {
    serverAddress = await prefs.getString('serverAddress') ?? '';
    notifyListeners();
  }

  void getPing() async {
    bool currentNetConnectionStatus = netConnected;
    try {
      netConnected = await NetworkHelper().getPing(serverAddress);
      print('Network connected: $netConnected');
    } catch (e) {
      print(e.toString());
    }
    if (currentNetConnectionStatus != netConnected) {
      // Network connection status has changed, fetch photos if connected
      notifyListeners();
    }
  }

  void getPhotos(bool savePhotostoFile) async {
    _isLoading = true;
    timeExtended = false;
    notifyListeners(); // Tells GalleryScreen to show the progress indicator
    if (netConnected) {
      try {
        photosList = await NetworkHelper().getData(serverAddress);
      } catch (e) {
        print('no network');
      }
      if (photosList.isNotEmpty && savePhotostoFile) {
        directory = await getApplicationDocumentsDirectory();
        for (var photo in photosList) {
          String fileName =
              '${directory.path}/${photo['PhotoDescription']}.jpg';
          print('Saving photo to: $fileName');
          //download the image from the server and save it to the file
          print('Downloading image from: ${photo['imgSource']}');
          final imageResponse = await NetworkHelper().getImage(
            photo['imgSource'],
          );

          try {
            final file = File(fileName);
            await file.writeAsBytes(imageResponse.bodyBytes);
            print('$fileName downloaded');
          } catch (e) {
            print('Error downloading image: $e');
          }
        }
        localPhotosList = loadPhotos; // Load the photos from the local directory after downloading
      }
    }
    print('Finished fetching photos');
    //print(photosList[0]['imgSource']);
    // if (!savePhotostoFile) {
    _isLoading = false;
    notifyListeners(); // Tells GalleryScreen to hide indicator and build GridView
    //}
  }

  List<File> get loadPhotos {
    try {
      final List<FileSystemEntity> entities = directory.listSync();

      // make sure only jpg files
      List<File> loadingList = entities
          .whereType<File>()
          .where((file) => file.path.endsWith('.jpg'))
          .toList();

      print(loadingList.length);
      return loadingList;
    } catch (e) {
      print('Error loading files $e');
      return <File>[];
    }

    //notifyListeners();
  }

  int get photosCount {
    return photosList.length;
  }

  void boolSavePhotosToFile() {
    savePhotosToFile = true;
    notifyListeners();
  }

  void checkBox() {
    addCheckbox = !addCheckbox;
    notifyListeners();
  }

  // Check if an index is selected
  bool isSelected(int index) => _selectedIndexes.contains(index);

  // Toggle selection on or off
  void toggleSelection(int index) {
    stopWalkAwayTimer(); // Stop the walk away timer when a selection is made
    print('checkbox toggled, walk away timer stopped');
    if (_selectedIndexes.contains(index)) {
      _selectedIndexes.remove(index);
    } else {
      _selectedIndexes.add(index);
    }
    // Rebuild all listening widgets
    notifyListeners();
    print(_selectedIndexes);
    startWalkAwayTimer(); // Restart the walk away timer after a selection is made
    print('checkbox toggled, walk away timer restarted');
  }

  // Clear selections
  void clearSelections() {
    _selectedIndexes = {};
    notifyListeners();
  }

  dynamic sendStatus;

  Future sendPhotos() async {
    List<dynamic> photosToSend = [];

    for (var index in _selectedIndexes) {
      photosToSend.add(photosList[index]);
    }
    try {
      if (netConnected) {
        sendStatus = await NetworkHelper().sendData(
          serverAddress,
          photosToSend,
        );
      }
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
    print(sendStatus);
  }

  void removePhotosFromDevice() async {
    try {
      if (await directory.exists()) {
        final List<FileSystemEntity> entities = directory.listSync();
        for (var entity in entities) {
          if (entity is File && entity.path.endsWith('.jpg')) {
            await entity.delete();
            print('Deleted: ${entity.path}');
          }
        }
      }
    } catch (e) {
      print('Error deleting files: $e');
    }
    //notifyListeners();
  }

  void startWalkAwayTimer() {
    if (walkAwayRunning) {
      walkAwayTimer?.cancel(); // Cancel any existing timer
    }
    walkAwayRunning = true;
    print('Walk away timer started');
    walkAwayTimer = Timer(Duration(seconds: 30), () {
      Timer? _dialogTimer;
      if (_isLoading) {
        //timeExtended = true;
        startWalkAwayTimer();
      } else {
        _dialogTimer = Timer(Duration(seconds: 5), () {
          // If the user doesn't respond within 5 seconds, proceed with the default action
          doPop = false; // Reset the flag
          stopWalkAwayTimer();
          _selectedIndexes = {};
          addCheckbox = false;
          removePhotosFromDevice();
          doPop = true;
          walkAwayRunning = false;
          print('Walk away timer completed');
          // Navigate back to the home screen
          _dialogTimer?.cancel();
          Navigator.of(AppNavigator.navigatorKey.currentContext!)
              .popUntil(ModalRoute.withName(HomeScreen.id));
        });
        //get current context from navigator key
        final context = AppNavigator.navigatorKey.currentContext;
        if (context != null) {
          // Show dialog to ask user if they need more time
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Need more time?'),
                content: const Text(
                  'Do you need more time to view the image? If not, you will be returned to the home screen.',
                ),
                actions: <Widget>[
                  Row(
                    children: [
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          doPop = false; // Reset the flag
                          _dialogTimer?.cancel(); // Cancel the dialog timer since user responded
                          startWalkAwayTimer();
                          print(
                            'walk away timer started from dialog after user selected yes',
                          );
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        child: const Text('No'),
                        onPressed: () {
                          doPop = false; // Reset the flag
                          stopWalkAwayTimer();
                          // Clear selections after 30 seconds of inactivity, reset checkboxes, and return to home
                          _selectedIndexes = {};
                          addCheckbox = false;
                          removePhotosFromDevice();
                          doPop = true;
                          walkAwayRunning = false;
                          print('Walk away timer completed');
                          Navigator.of(
                            AppNavigator.navigatorKey.currentContext!,
                          ).popUntil(ModalRoute.withName(HomeScreen.id));
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        }
      }
      notifyListeners();
    });
    doPop = false;
  }

  void stopWalkAwayTimer() {
    walkAwayTimer?.cancel();
    walkAwayRunning = false;
    print('Walk away timer stopped');
  }

  @override
  void dispose() {
    _pingTimer?.cancel(); // Cancel the timer when the object is disposed
    walkAwayTimer
        ?.cancel(); // Cancel the walk away timer when the object is disposed

    super.dispose();
  }
}
