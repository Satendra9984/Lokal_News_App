//https://bit.ly/tif-flutter-intern-assignment

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../app_models/news_model.dart';
import '../../../app_providers/country_provider.dart';
import '../../home_page/screens/news_details_screen.dart';
import '../cubit/search_news_cubit.dart';

class NewsSearchPage extends ConsumerStatefulWidget {
  const NewsSearchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NewsSearchPage> createState() => _NewsSearchPageState();
}

class _NewsSearchPageState extends ConsumerState<NewsSearchPage> {
  late final TextEditingController _textEditingController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();

    // if (_scrollController.hasClients) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // User reached the end of the list, load more items
        if (_textEditingController.text.isNotEmpty) {
          context.read<SearchNewsCubit>().addInSearchTheList(
                country: ref.read(countryProvider).toLowerCase(),
                topic: _textEditingController.text,
              );
        }
      }
    });
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<SearchNewsCubit, SearchNewsState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: CupertinoColors.black,
          appBar: AppBar(
            backgroundColor: CupertinoColors.black,
            systemOverlayStyle:
                const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
            title: const Text(
              'Search',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              CountryCodePicker(
                onChanged: (CountryCode code) {
                  debugPrint('${code.name}\t${code.code}\t${code.dialCode}');
                  ref
                      .read(countryProvider.notifier)
                      .changeCountryCode(code.code!);
                },
                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                initialSelection: 'IN',
                favorite: [ref.watch(countryProvider)],
                // optional. Shows only country name and flag
                showCountryOnly: true,
                boxDecoration:
                    const BoxDecoration(color: CupertinoColors.black),
                // optional. Shows only country name and flag when popup is closed.
                showOnlyCountryWhenClosed: true,
                // optional. aligns the flag and the Text left
                alignLeft: false,
              ),
            ],
          ),
          body: Column(
            children: [
              FormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: _textEditingController,
                validator: (controller) {
                  if (controller!.text.isEmpty) {
                    return 'Enter Your Query';
                  }
                  return null;
                },
                builder: (formState) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 8,
                          child: TextField(
                            onChanged: (value) {
                              _textEditingController.text = value;
                              _textEditingController.selection =
                                  TextSelection.collapsed(
                                      offset:
                                          _textEditingController.text.length);
                              formState.didChange(_textEditingController);

                              if (formState.hasError == false) {
                                // context.read<DashboardCubit>().loadSearchEvents(
                                //     _textEditingController.text);
                              }
                            },
                            controller: _textEditingController,
                            keyboardType: TextInputType.text,
                            cursorColor: CupertinoColors.systemBlue,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: CupertinoColors.white,
                            ),
                            decoration: const InputDecoration(
                              isDense: false,
                              hintText: 'Write your query',
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                                color: CupertinoColors.systemGrey,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              border: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              if (formState.hasError) {
                                return;
                              }
                              context.read<SearchNewsCubit>().searchTheList(
                                    country:
                                        ref.read(countryProvider).toLowerCase(),
                                    topic: _textEditingController.text,
                                  );
                            },
                            icon: formState.hasError
                                ? const Icon(
                                    Icons.search,
                                    size: 28,
                                    color: CupertinoColors.black,
                                  )
                                : const Icon(
                                    Icons.search,
                                    size: 28,
                                    color: CupertinoColors.systemBlue,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.searchedNewsList.length,
                  itemBuilder: (ctx, index) {
                    NewsModel event = state.searchedNewsList[index];

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
        );
      },
    );
  }
}
