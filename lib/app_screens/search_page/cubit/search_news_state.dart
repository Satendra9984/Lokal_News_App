part of 'search_news_cubit.dart';

class SearchNewsState extends Equatable {
  final List<NewsModel> searchedNewsList;

  const SearchNewsState(this.searchedNewsList);

  SearchNewsState copyWith(List<NewsModel>? searchedNewsList) {
    return SearchNewsState(searchedNewsList ?? this.searchedNewsList);
  }

  @override
  List<Object> get props => [searchedNewsList];
}
