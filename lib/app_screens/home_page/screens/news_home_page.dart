import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokal_interview_assignment/app_models/news_model.dart';
import 'package:lokal_interview_assignment/app_providers/country_provider.dart';
import 'package:lokal_interview_assignment/app_screens/home_page/screens/news_details_screen.dart';
import '../../../app_models/app_enums.dart';
import '../../search_page/screens/search_page.dart';
import '../cubit/news_cubit.dart';

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _tabController = TabController(length: 6, vsync: this);
    context.read<NewsCubit>().initialize();
    debugPrint('scrollcontroller has clients');
    _scrollController.addListener(() {
      debugPrint('scrollcontroller listeners add');
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // User reached the end of the list, load more items
        debugPrint('scrollcontroller adding more');
        context.read<NewsCubit>().loadMoreCurrentCategoryNews();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<NewsCubit, NewsState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state.loadState == LoadState.initial ||
            state.loadState == LoadState.loading) {
          return _getShimmerPlaceholderWidget(size);
        } else if (state.loadState == LoadState.errorLoading) {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: () {
                return context.read<NewsCubit>().initialize();
              },
              child: _getErrorWidget(size),
            ),
          );
        }
        return Scaffold(
          backgroundColor: CupertinoColors.black,
          appBar: AppBar(
            systemOverlayStyle:
                const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
            elevation: 0.0,
            backgroundColor: CupertinoColors.black,
            title: const Text(
              'Informed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const NewsSearchPage()),
                  );
                },
                icon: const Icon(
                  Icons.search,
                  size: 28,
                ),
              ),
              Consumer(builder: (ctx, ref, _) {
                return CountryCodePicker(
                  onChanged: (CountryCode code) {
                    debugPrint('${code.name}\t${code.code}\t${code.dialCode}');
                    if (code.code == null) {
                      return;
                    }
                    ref
                        .read(countryProvider.notifier)
                        .changeCountryCode(code.code!);
                    context.read<NewsCubit>().countryCodeHasChanges(code.code!);
                  },
                  // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                  initialSelection: ref.watch(countryProvider),
                  favorite: [ref.watch(countryProvider)],
                  // optional. Shows only country name and flag
                  showCountryOnly: true,
                  boxDecoration:
                      const BoxDecoration(color: CupertinoColors.black),
                  // optional. Shows only country name and flag when popup is closed.
                  showOnlyCountryWhenClosed: true,
                  // optional. aligns the flag and the Text left
                  alignLeft: false,
                );
              }),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () {
              return context.read<NewsCubit>().initialize();
            },
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  onTap: (currTab) {
                    context.read<NewsCubit>().changeCurrentCategory(currTab);
                  },
                  indicatorWeight: 2.5,
                  indicatorColor: CupertinoColors.white,
                  isScrollable: true,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  labelPadding: const EdgeInsets.symmetric(
                      horizontal: 12.5, vertical: 10),
                  tabs: List.generate(
                    state.categoriesList.length,
                    (index) => Text(
                      state.categoriesList[index],
                      style: _getTabItemTextStyle(index, state.currentCategory),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state
                        .newsList[state.categoriesList[state.currentCategory]]!
                        .length,
                    itemBuilder: (ctx, index) {
                      NewsModel event = state.newsList[
                          state.categoriesList[state.currentCategory]]![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) =>
                                    NewsDetailsScreen(newsModel: event)),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900.withOpacity(0.50),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 2.5,
                                spreadRadius: 0.5,
                                offset: Offset(2.5, 2.5),
                              ),
                              BoxShadow(
                                blurRadius: 2.5,
                                spreadRadius: 2.5,
                                offset: Offset(2.5, 2.5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (event.urlToImage != null)
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  height: 100,
                                  width: 88,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      event.urlToImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (event.urlToImage == null)
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  height: 100,
                                  width: 88,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: const Icon(
                                      Icons.newspaper,
                                      size: 48,
                                      color: CupertinoColors.systemBlue,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: size.width - 140,
                                      child: Text(
                                        '${event.title}',
                                        softWrap: true,
                                        maxLines: 5,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2.5),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${event.description}',
                                            softWrap: true,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2.5),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'source: ',
                                          softWrap: true,
                                          maxLines: 5,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: CupertinoColors.systemBlue,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${event.source?.name.toString()}',
                                            softWrap: true,
                                            maxLines: 5,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getShimmerPlaceholderWidget(Size size) {
    return Scaffold(
      backgroundColor: CupertinoColors.black,
      appBar: AppBar(
        backgroundColor: CupertinoColors.black,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        title: const Text(
          'Informed',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Center(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (ctx, index) {
            double blurRadius = 2.5;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade900.withOpacity(0.45),
                boxShadow: [
                  BoxShadow(
                    blurRadius: blurRadius,
                    spreadRadius: 0.5,
                    offset: Offset(blurRadius, blurRadius),
                  ),
                  BoxShadow(
                    color: Colors.grey.shade800.withOpacity(0.45),
                    blurRadius: blurRadius,
                    spreadRadius: 2.5,
                    offset: Offset(blurRadius, blurRadius),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    height: 100,
                    width: 88,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade800.withOpacity(0.5),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            height: 16,
                            width: (size.width - 140),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            height: 36,
                            width: (size.width - 140),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10, top: 1),
                            height: 16,
                            width: (size.width - 140) * 0.6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey.shade800,
                            ),
                            height: 18,
                            width: (size.width - 140),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getErrorWidget(Size size) {
    return Container(
      height: size.height * 0.6,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: ListView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        shrinkWrap: false,
        children: [
          SizedBox(height: size.height * 0.3),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                color: CupertinoColors.systemRed,
                size: 48,
              ),
              SizedBox(height: 10),
              Text(
                'Error Loading Events, ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: CupertinoColors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Check Your Internet Connection and Try Again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

TextStyle _getTabItemTextStyle(int index, int currentTabNumber) {
  // debugPrint(_currentTabNumber.toString());
  if (currentTabNumber == index) {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      // color: Colors.blue,
    );
  } else {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade400,
    );
  }
}
