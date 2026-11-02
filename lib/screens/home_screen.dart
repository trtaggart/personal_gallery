import 'package:flutter/material.dart';
import 'package:personal_gallery/screens/gallery_screen.dart';
import 'package:personal_gallery/gallery_data.dart';
import 'package:provider/provider.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';

class HomeScreen extends StatelessWidget {
   new({super.key});
  static const id = "HomeScreen";

  final TextEditingController _serverAddressController = TextEditingController();


  void dispose() {
    _serverAddressController.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
    //Provider.of<GalleryData>(context, listen: false).stopWalkAwayTimer();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: TextButton(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
            ),
            onLongPress: () async {
              print('Exiting app...');
              await FlutterExitApp.exitApp(iosForceExit: false);
            },
            onPressed: null,
            child: Text(""),
          ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onLongPress: () {
                    _serverAddressController.text = Provider.of<GalleryData>(context, listen: false).serverAddress;
                showDialog(
                  context: context, 
                  builder: (BuildContext context) => AlertDialog(
                    title: (Text('Set server address')),
                        content: (Text(
                          'Enter the server address',
                        )),
                        actions: [
                          TextField(
                            controller: _serverAddressController,
                            onChanged: (value) {
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Provider.of<GalleryData>(context, listen: false).setServerAddress(_serverAddressController.text);
                                 Navigator.pop(context, 'OK');
                                },
                                              
                                child: const Text('OK'),
                              ),
                              TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                            ],
                          ),
                          
                        ],
                      ),
                  );
              },
                  
                  child: Icon(
                    Icons.circle,
                    color: Provider.of<GalleryData>(context).netConnected ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Provider.of<GalleryData>(context, listen: false).boolSavePhotosToFile();
          },
          child: const Icon(Icons.arrow_forward),
        ),
        body: Center(
                  child: TextButton(
         style: TextButton.styleFrom(
           minimumSize: Size(100, 50),
           backgroundColor: Provider.of<GalleryData>(context).netConnected ? Colors.blue : Colors.grey
         ),
         onPressed: Provider.of<GalleryData>(context).netConnected ? () {
          print('server address: ${Provider.of<GalleryData>(context, listen: false).serverAddress}');
          print('calling get photos');
           Provider.of<GalleryData>(context, listen: false).getPhotos(true);
           print('opening gallery screen');
           Navigator.pushNamed(context, GalleryScreen.id);
         } : null,
         child: Text('Begin',
         style: TextStyle(
           color: Colors.white,
           fontSize: 24,
           fontWeight: FontWeight.bold),
         ),),
                ),
      ),
    );
  }
}