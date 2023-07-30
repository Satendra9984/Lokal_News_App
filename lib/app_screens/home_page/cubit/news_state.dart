part of 'news_cubit.dart';

class NewsState extends Equatable {
  final LoadState loadState;
  final Map<String, List<NewsModel>> newsList; // For each category
  final Map<String, int> newsCategoriesCurrentPageNumber; // For each category
  final List<String> categoriesList;
  final int currentCategory;

  const NewsState({
    this.loadState = LoadState.initial,
    required this.newsList,
    required this.newsCategoriesCurrentPageNumber,
    this.currentCategory = 0,
    required this.categoriesList,
  });

  NewsState copyWith({
    LoadState? loadState,
    Map<String, List<NewsModel>>? newsList,
    Map<String, int>? newsCategoryPageNumber,
    List<String>? categoriesList,
    int? currentCategory,
  }) {
    return NewsState(
      loadState: loadState ?? this.loadState,
      newsList: newsList ?? this.newsList,
      newsCategoriesCurrentPageNumber:
          newsCategoryPageNumber ?? newsCategoriesCurrentPageNumber,
      categoriesList: categoriesList ?? this.categoriesList,
      currentCategory: currentCategory ?? this.currentCategory,
    );
  }

  @override
  List<Object> get props => [
        loadState,
        newsList,
        newsCategoriesCurrentPageNumber,
        categoriesList,
        currentCategory,
      ];
}
