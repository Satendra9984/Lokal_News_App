import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

StateNotifierProvider<CountryProvider, String> countryProvider =
    StateNotifierProvider<CountryProvider, String>((ref) => CountryProvider());

class CountryProvider extends StateNotifier<String> {
  CountryProvider() : super('IN');

  void changeCountryCode(String newCountry) {
    state = newCountry;
    debugPrint(state);
  }
}
