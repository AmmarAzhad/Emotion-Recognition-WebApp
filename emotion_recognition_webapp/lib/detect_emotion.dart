import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

fetchdata(String url, String image) async {
  http.MultipartRequest request = http.MultipartRequest('GET', Uri.parse(url));

  request.files.add(
    http.MultipartFile.fromString(
      'images',
      image,
      contentType: MediaType('text/plain', 'charset=utf-8'),
    ),
  );
  return '1';
}
