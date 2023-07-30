import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../app_models/news_model.dart';
import '../../../app_services/db_services.dart';
part 'search_news_state.dart';

class SearchNewsCubit extends Cubit<SearchNewsState> {
  final TextEditingController textEditingController = TextEditingController();
  String _currentCountryCode = 'IN';

  int _currentPage = 1;
  SearchNewsCubit() : super(const SearchNewsState([]));

  Future<void> searchTheList({
    required String country,
    required String topic,
  }) async {
    try {
      await DatabaseServices()
          .getNewsFeedList(topic.toLowerCase(), 1,
              country: country.toLowerCase())
          .then((newsList) {
        emit(state.copyWith(newsList));
      });
    } catch (e) {}
  }

  Future<void> addInSearchTheList({
    required String country,
    required String topic,
  }) async {
    debugPrint('adding in search list');
    try {
      await DatabaseServices()
          .getNewsFeedList(topic.toLowerCase(), _currentPage + 1,
              country: country.toLowerCase())
          .then((newsList) {
        emit(state.copyWith([...state.searchedNewsList, ...newsList]));
        _currentPage += 1;
      });
    } catch (e) {}
  }
}
