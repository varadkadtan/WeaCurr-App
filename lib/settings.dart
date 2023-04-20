class Settings {
  bool showWeather;
  bool showCurrency;
  String? selectedCity;
  int selectedTabIndex; // add this line

  Settings({
    this.showWeather = true,
    this.showCurrency = true,
    this.selectedCity = 'New York',
    this.selectedTabIndex = 0, // add this line and set default value to 0
  });
}
