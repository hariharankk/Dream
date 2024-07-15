import 'dart:io';
import 'package:path/path.dart' as Path;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:http_parser/http_parser.dart';
import 'package:inventory/Utility.dart';
import 'package:inventory/Service/Api Service.dart';

class Imagestorage {
  // Uploads a file to Firebase Storage and returns the path to its location
  late String Token;
  JWT jwt = JWT();

  Future<dynamic> upload(File imageFile) async {
    Token = await jwt.read_token();
    var stream =  http.ByteStream(
        DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse('$SERVERURL/img-profile');

    var request =  http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      'x-access-token': Token
    };
    request.headers.addAll(headers);
    var multipartFile =  http.MultipartFile('file', stream, length,
        filename: Path.basename(imageFile.path),
        contentType: MediaType('image', 'png')
    );

    request.files.add(multipartFile);
    var response = await request.send();
    var responsevalue = await response.stream.bytesToString();
    return jsonDecode(responsevalue)['file_name'];
  }
}