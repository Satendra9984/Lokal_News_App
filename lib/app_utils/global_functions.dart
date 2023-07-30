import 'dart:convert';

DateTime getDateTimeObject(String pattern) {
  return DateTime.parse(pattern);
}

String getPrettyJSONString(jsonObject) {
  var encoder = const JsonEncoder.withIndent("     ");
  return encoder.convert(jsonObject);
}
