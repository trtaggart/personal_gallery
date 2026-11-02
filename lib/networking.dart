import 'package:http/http.dart' as http;
import 'package:personal_gallery/shared_prefs.dart';
import 'dart:convert';
import 'package:personal_gallery/gallery_data.dart';

class NetworkHelper {
  NetworkHelper();
  

  Future getPing(String serverAddress) async {
    try{
    http.Response response = await http.get(
      Uri.parse('$serverAddress/ping'),
    );
    
    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.statusCode.toString());
      return false;

    }
    } catch(e){
      print(e.toString());
      return false;
    }
  }

  Future getData(String serverAddress) async {
      try{
      http.Response dataResponse = await http.get(
        Uri.parse('$serverAddress/photos'),
      );
      if (dataResponse.statusCode == 200) {
        String data = dataResponse.body;
        var decodeData = jsonDecode(data);
        print(decodeData);
        return decodeData;
      } else {
        print(dataResponse.statusCode.toString());
      }
      } catch(e){
      print(e.toString());
    }
    
  }

  Future getImage(String imageSource) async {
    try{
      http.Response imageResponse = await http.get(
        Uri.parse(imageSource),
      );
      if (imageResponse.statusCode == 200) {
        return imageResponse;
      } else {
        print(imageResponse.statusCode.toString());
      }
    } catch(e){
      print(e.toString());
    }
  }

  Future sendData(String serverAddress, List<dynamic> photoList) async {
    try{
      var request =  http.MultipartRequest('Post', Uri.parse('$serverAddress/upload'));
        request.fields['data'] = jsonEncode(photoList);

      http.StreamedResponse streamResponse = await request.send();
      http.Response dataResponse = await http.Response.fromStream(streamResponse);
      
      if (dataResponse.statusCode == 200) {
      
        return 'Success';
      } else {
        print(dataResponse.statusCode.toString());
      }
    } catch(e){
      print(e.toString());
    }
  }
}
