import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../app_utils/global_functions.dart';

class HttpServices {
  static Future<Map<String, dynamic>?> sendGetReq(String path,
      {Map<String, String>? extraHeaders}) async {
    Map<String, dynamic>? result;
    await http.get(Uri.parse(path), headers: {
      'Content-Type': 'application/json',
      ...?extraHeaders,
    }).then((res) {
      // debugPrint(getPrettyJSONString(res.body));
      if (res.body.isNotEmpty && res.statusCode == 200) {
        result = jsonDecode(res.body) as Map<String, dynamic>;
      }
    });
    return result;
  }
}
