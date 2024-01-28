import 'package:app_ets_projet_durable/serviceMeteo/airQuality.dart';
import 'package:flutter/material.dart';
import '/serviceMeteo/meteoModel.dart';
import '/serviceMeteo/meteoService.dart';

class PageMeteo extends StatefulWidget {
  const PageMeteo({Key? key}) : super(key: key);

  @override
  State<PageMeteo> createState() => _PageMeteoState();
}

class _PageMeteoState extends State<PageMeteo> {
  WeatherService weatherService = WeatherService();
  UpComingWeatherService upComingWeatherService = UpComingWeatherService();
  Weather weather = Weather();
  List<Weather> weeklyForecast = [];

  String cityName = "new york";
  double temperatureC = 0;
  String condition = "";
  String iconUrl = "";
  AirQuality airQuality = AirQuality();
  DateTime currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    getWeather();
    getWeeklyForecast();
  }

  void getWeather() async {
    weather = await weatherService.getWeatherData(cityName);
    airQuality = await AirQualityService().getAirQualityData(cityName);
    setState(() {
      condition = weather.condition;
      temperatureC = weather.temperatureC;
      iconUrl = weather.iconUrl;
    });
  }

  void getWeeklyForecast() async {
    List<Weather> forecasts = [];
    for (int i = 0; i < 7; i++) {
      DateTime forecastDate = DateTime.now().add(Duration(days: i));
      String formattedDate =
          "${forecastDate.year}-${forecastDate.month.toString().padLeft(2, '0')}-${forecastDate.day.toString().padLeft(2, '0')}";

      try {
        UpComingWeather forecast = await upComingWeatherService
            .getGivenDayWeatherDate(cityName, formattedDate);
        forecasts.add(Weather(
          temperatureC: forecast.upComingAvgtemperatureC,
          condition: forecast.upComingcondition,
          iconUrl: forecast.iconUrl,
        ));
      } catch (e) {
        print('Error fetching weather data for Day $i: $e');
      }
    }

    setState(() {
      weeklyForecast = forecasts;
      print('Weekly forecast updated: $weeklyForecast');
    });
  }

  String CheckDanger(String condition) {
    if (condition.contains("Rain".toLowerCase()) ||
        condition.contains("Snow".toLowerCase()) ||
        condition.contains("icy".toLowerCase())) {
      print(temperatureC);
      return "Stay vigilent";
    }
    return "Conditions are good";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Information'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  cityName,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1),
                Image.network(
                  iconUrl,
                  width: 60,
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                ),
                SizedBox(height: 1),
                Text(
                  "${temperatureC.toStringAsFixed(1)}°C",
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Qualité de l\'air : ${airQuality!.airQualityPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  condition,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  CheckDanger(condition),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  '7-Day Forecast',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  height: 150,
                  child: weeklyForecast.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: weeklyForecast.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    Image.network(
                                      weeklyForecast[index].iconUrl,
                                      width: 50,
                                      height: 50,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.error);
                                      },
                                    ),
                                    Text('Day ${index + 1}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        '${weeklyForecast[index].temperatureC}°C'),
                                    Text(weeklyForecast[index].condition),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Center(child: Text('Loading forecast...')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
