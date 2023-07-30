import 'package:flutter/cupertino.dart';
import 'package:lokal_interview_assignment/app_utils/global_functions.dart';
import '../app_models/news_model.dart';
import 'http_services.dart';

class DatabaseServices {
  // ignore: constant_identifier_names
  static const String _API_KEY = 'c5cb3e491ea64f26b0258b51323ad6cb';
  // 85940a4d7b23488ba7ecd9e9e7c6533e
  // c5cb3e491ea64f26b0258b51323ad6cb
  static const String _baseUrl = 'https://newsapi.org/v2';
  // https://newsapi.org/docs/endpoints/top-headlines
  Future<List<NewsModel>> getNewsFeedList(String topic, int page,
      {String country = 'in'}) async {
    List<NewsModel> eventList = [];
    // top-headlines?country=us
    await HttpServices.sendGetReq(
      '$_baseUrl/everything?q=$topic&top-headlines?country=$country&pageSize=10&page=$page&apikey=$_API_KEY',
    ).then((list) {
      if (list == null) {
        return;
      }
      List<dynamic> data = list['articles'];
      for (dynamic eventData in data) {
        Map<String, dynamic> eventJson = Map<String, dynamic>.from(eventData);
        try {
          NewsModel model = NewsModel.fromJson(eventJson);
          eventList.add(model);
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    });
    return eventList;
  }

  Future<NewsModel?> getEventDetails(num id) async {
    NewsModel? event;

    // https://api.musixmatch.com/ws/1.1/track.get?track_id=TRACK_ID&apikey=6b3cd5a4972dc0fd8ee2f4fc83390969
    await HttpServices.sendGetReq(
            '$_baseUrl/track.get?track_id=$id&apikey=$_API_KEY')
        .then((eventRest) {
      eventRest;
      if (eventRest == null) {
        return;
      }

      dynamic data = eventRest['message']['body']['track'];
      Map<String, dynamic> eventJson = Map<String, dynamic>.from(data);
      event = NewsModel.fromJson(eventJson);
    });
    // event;
    return event;
  }
}
// c5cb3e491ea64f26b0258b51323ad6cb
