import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

final uri = Uri.parse("http://127.0.0.1:5000/convert");

fetchdata(XFile image) async {
  final imageBytes = await image.readAsBytes();
  var request = http.MultipartRequest("POST", uri);
  request.files.add(http.MultipartFile.fromBytes("image", imageBytes, filename: "image.jpg", contentType: MediaType("image", "jpg")));

  var response = await request.send();

  final responseBytes = response.stream.toBytes();
  return responseBytes;
}
