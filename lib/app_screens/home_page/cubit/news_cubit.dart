import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lokal_interview_assignment/app_models/app_enums.dart';
import 'package:lokal_interview_assignment/app_models/news_model.dart';
import 'package:lokal_interview_assignment/app_services/db_services.dart';
import 'package:lokal_interview_assignment/app_utils/global_functions.dart';
part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  String _currentCountryCode = 'IN';
  // A ScrollController to listen to scroll events for pagination.
  final ScrollController scrollController = ScrollController();

  NewsCubit()
      : super(const NewsState(
          newsList: {
            'Trending': [],
            'Politics': [],
            'Sports': [],
            'Education': [],
            'Entertainment': [],
            'Science': [],
          },
          newsCategoriesCurrentPageNumber: {
            'Trending': 1,
            'Politics': 1,
            'Sports': 1,
            'Education': 1,
            'Entertainment': 1,
            'Science': 1,
          },
          categoriesList: [
            'Trending',
            'Politics',
            'Sports',
            'Education',
            'Entertainment',
            'Science'
          ],
          currentCategory: 0,
        ));

  // For the very first time
  Future<void> initialize() async {
    String topic = state.categoriesList[state.currentCategory];
    try {
      await DatabaseServices()
          .getNewsFeedList(topic.toLowerCase(), 1,
              country: _currentCountryCode.toLowerCase())
          .then((newsList) {
        emit(state.copyWith(
          newsList: {
            ...state.newsList,
            topic: [...?state.newsList[topic], ...newsList],
          },
          loadState: LoadState.loaded,
        ));
      });
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(loadState: LoadState.errorLoading));
    }
  }

  Future<void> changeCurrentCategory(int currCat) async {
    await loadCurrentCategoryNews(currCat).then((value) {
      emit(state.copyWith(currentCategory: currCat));
    });
  }

  Future<void> loadCurrentCategoryNews(int currCat) async {
    String topic = state.categoriesList[currCat];
    if (state.newsList[topic] != null && state.newsList[topic]!.isNotEmpty) {
      return;
    }
    emit(state.copyWith(loadState: LoadState.loading));
    try {
      await DatabaseServices()
          .getNewsFeedList(topic.toLowerCase(), 1)
          .then((newsList) {
        // debugPrint(newsList.toString());
        emit(state.copyWith(
          newsList: {
            ...state.newsList,
            topic: [...?state.newsList[topic], ...newsList],
          },
          loadState: LoadState.loaded,
        ));
        // getPrettyJSONString(state.newsList);
      });
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(loadState: LoadState.errorLoading));
    }
  }

  Future<void> loadMoreCurrentCategoryNews() async {
    String topic = state.categoriesList[state.currentCategory];

    try {
      await DatabaseServices()
          .getNewsFeedList(topic.toLowerCase(),
              state.newsCategoriesCurrentPageNumber[topic]! + 1)
          .then((newsList) {
        // debugPrint(newsList.toString());
        emit(state.copyWith(newsList: {
          ...state.newsList,
          topic: [...?state.newsList[topic], ...newsList],
        }, newsCategoryPageNumber: {
          ...state.newsCategoriesCurrentPageNumber,
          topic: state.newsCategoriesCurrentPageNumber[topic]! + 1,
        }));
        // getPrettyJSONString(state.newsList);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> countryCodeHasChanges(String newCode) async {
    if (_currentCountryCode.toLowerCase() == newCode.toLowerCase()) {
      return;
    }
    _currentCountryCode = newCode;
    //
    emit(state.copyWith(
      newsList: {
        // business entertainment general health science sportstechnology
        'Trending': [],
        'Politics': [],
        'Sports': [],
        'Education': [],
        'Entertainment': [],
        'Science': [],
      },
      newsCategoryPageNumber: {
        'Trending': 1,
        'Politics': 1,
        'Sports': 1,
        'Education': 1,
        'Entertainment': 1,
        'Science': 1,
      },
      currentCategory: state.currentCategory,
    ));

    await initialize();
  }
}
