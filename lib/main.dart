import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokal_interview_assignment/app_screens/home_page/cubit/news_cubit.dart';
import 'package:lokal_interview_assignment/app_screens/search_page/cubit/search_news_cubit.dart';
import 'app_screens/home_page/screens/news_home_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => NewsCubit()),
        BlocProvider(create: (ctx) => SearchNewsCubit()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        // fontFamily: 'Inter',
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // useMaterial3: true,
        theme: ThemeData.dark(
          useMaterial3: false,
        ),
        home: const NewsHomePage(),
      ),
    );
  }
}

// https://dribbble.com/shots/20391043-News-App
