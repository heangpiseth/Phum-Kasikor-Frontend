import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/weather_controller.dart';
import 'package:phum_kasikors/model/farmer/weather_model.dart';

class FarmerWeatherScreen extends StatefulWidget {
  const FarmerWeatherScreen({super.key});

  @override
  State<FarmerWeatherScreen> createState() =>
      _FarmerWeatherScreenState();
}

class _FarmerWeatherScreenState extends State<FarmerWeatherScreen> {
  late final WeatherController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<WeatherController>()
        ? Get.find<WeatherController>()
        : Get.put(WeatherController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F3),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const _WeatherLoading();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _WeatherError(
              message: controller.errorMessage.value,
              onRetry: controller.loadWeather,
            );
          }

          final weather = controller.weather.value;

          if (weather == null) {
            return _WeatherError(
              message:
                  'Weather information is not available yet.',
              onRetry: controller.loadWeather,
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF2E7D32),
            onRefresh: controller.loadWeather,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(),

                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(18, 8, 18, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildLocationCard(weather),
                      const SizedBox(height: 16),

                      _buildCurrentWeatherCard(weather),
                      const SizedBox(height: 16),

                      _buildQuickStats(weather),
                      const SizedBox(height: 22),

                      _buildTodaySection(weather),
                      const SizedBox(height: 22),

                      _buildForecastSection(weather),
                      const SizedBox(height: 22),

                      _buildFarmingAdvice(weather),
                      const SizedBox(height: 22),

                      _buildWeatherLegend(),
                    ]),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFFF4F8F3),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      expandedHeight: 82,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton(
          onPressed: Get.back,
          icon: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF263238),
            ),
          ),
        ),
      ),
      title: const Text(
        'Farm Weather',
        style: TextStyle(
          color: Color(0xFF173B1A),
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: controller.loadWeather,
            icon: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FARM LOCATION
  // ============================================================

  Widget _buildLocationCard(WeatherModel weather) {
    final farm = weather.farm;

    final farmName =
        farm.name?.trim().isNotEmpty == true
            ? farm.name!
            : 'My Farm';

    final location =
        farm.location?.trim().isNotEmpty == true
            ? farm.location!
            : 'Farm location';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8F5E9),
            Color(0xFFF1F8E9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC8E6C9),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'WEATHER AT YOUR FARM',
                  style: TextStyle(
                    color: Color(0xFF558B2F),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  farmName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF689F38),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF607D63),
                          fontSize: 12,
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
    );
  }

  // ============================================================
  // CURRENT WEATHER
  // ============================================================

  Widget _buildCurrentWeatherCard(
    WeatherModel weather,
  ) {
    final current = weather.current;

    final temperature = current.temperatureC ?? 0;
    final rain = current.rainMm ?? 0;
    final humidity = current.humidityPercent ?? 0;
    final wind = current.windKmh ?? 0;

    final code = current.weatherCode;

    final description =
        controller.weatherDescription;

    final icon = controller.weatherIcon;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        22,
        22,
        20,
      ),
      decoration: BoxDecoration(
        gradient: _weatherGradient(code),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _weatherAccent(code)
                .withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -35,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -65,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.wb_sunny_outlined,
                    color: Colors.white,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'CURRENT CONDITIONS',
                    style: TextStyle(
                      color: Colors.white
                          .withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.16),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      current.isDay == false
                          ? 'Night'
                          : 'Daytime',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  Text(
                    icon,
                    style: const TextStyle(
                      fontSize: 68,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              temperature
                                  .toStringAsFixed(0),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 58,
                                height: 0.95,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            const Padding(
                              padding:
                                  EdgeInsets.only(top: 5),
                              child: Text(
                                '°C',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white
                                .withValues(alpha: 0.92),
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                height: 1,
                color: Colors.white
                    .withValues(alpha: 0.16),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _HeroMetric(
                      icon:
                          Icons.water_drop_rounded,
                      label: 'Rain',
                      value:
                          '${rain.toStringAsFixed(1)} mm',
                    ),
                  ),
                  Expanded(
                    child: _HeroMetric(
                      icon: Icons.opacity_rounded,
                      label: 'Humidity',
                      value:
                          '${humidity.toStringAsFixed(0)}%',
                    ),
                  ),
                  Expanded(
                    child: _HeroMetric(
                      icon: Icons.air_rounded,
                      label: 'Wind',
                      value:
                          '${wind.toStringAsFixed(0)} km/h',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK STATS
  // ============================================================

  Widget _buildQuickStats(WeatherModel weather) {
    final current = weather.current;

    final temperature =
        current.temperatureC ?? 0;

    final humidity =
        current.humidityPercent ?? 0;

    final wind =
        current.windKmh ?? 0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.thermostat_rounded,
            iconColor: const Color(0xFFE65100),
            background: const Color(0xFFFFF3E0),
            title: 'Temperature',
            value:
                '${temperature.toStringAsFixed(0)}°C',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.water_drop_rounded,
            iconColor: const Color(0xFF0277BD),
            background: const Color(0xFFE1F5FE),
            title: 'Humidity',
            value:
                '${humidity.toStringAsFixed(0)}%',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.air_rounded,
            iconColor: const Color(0xFF6A1B9A),
            background: const Color(0xFFF3E5F5),
            title: 'Wind',
            value:
                '${wind.toStringAsFixed(0)}',
            suffix: 'km/h',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TODAY
  // ============================================================

  Widget _buildTodaySection(WeatherModel weather) {
    final today =
        weather.daily.isNotEmpty
            ? weather.daily.first
            : null;

    if (today == null) {
      return const SizedBox.shrink();
    }

    final max = today.maxTemperature;
    final min = today.minTemperature;
    final rainToday = today.rainMm;
    final probability = today.rainProbability;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.today_rounded,
          title: 'Today at a glance',
          subtitle:
              'Quick information for your farm',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TodayInfo(
                      icon:
                          Icons.thermostat_rounded,
                      color:
                          const Color(0xFFE65100),
                      background:
                          const Color(0xFFFFF3E0),
                      title: 'High',
                      value:
                          '${max.toStringAsFixed(0)}°C',
                    ),
                  ),
                  Expanded(
                    child: _TodayInfo(
                      icon: Icons.ac_unit_rounded,
                      color:
                          const Color(0xFF1565C0),
                      background:
                          const Color(0xFFE3F2FD),
                      title: 'Low',
                      value:
                          '${min.toStringAsFixed(0)}°C',
                    ),
                  ),
                  Expanded(
                    child: _TodayInfo(
                      icon:
                          Icons.water_drop_rounded,
                      color:
                          const Color(0xFF0277BD),
                      background:
                          const Color(0xFFE1F5FE),
                      title: 'Rain',
                      value:
                          '${rainToday.toStringAsFixed(1)} mm',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration:
                          const BoxDecoration(
                        color: Color(0xFF8BC34A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.umbrella_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chance of rain',
                            style: TextStyle(
                              color:
                                  Color(0xFF45612D),
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${probability.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color:
                                  Color(0xFF33691E),
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _RainBadge(
                      probability: probability,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 7 DAY FORECAST
  // ============================================================

  Widget _buildForecastSection(
    WeatherModel weather,
  ) {
    final daily = weather.daily;

    if (daily.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: Icons.calendar_month_rounded,
          title: '7-day forecast',
          subtitle:
              'Plan your farm activities ahead',
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics:
                const BouncingScrollPhysics(),
            itemCount: daily.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final day = daily[index];

              return _ForecastCard(
                day: _forecastDay(
                  day.date,
                  index,
                ),
                date: _forecastDate(day.date),
                icon: _weatherIcon(
                  day.weatherCode,
                ),
                maxTemp: day.maxTemperature,
                minTemp: day.minTemperature,
                rainProbability:
                    day.rainProbability,
                isToday: index == 0,
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FARMING ADVICE
  // ============================================================

  Widget _buildFarmingAdvice(
    WeatherModel weather,
  ) {
    final current = weather.current;

    final temperature =
        current.temperatureC ?? 0;

    final humidity =
        current.humidityPercent ?? 0;

    final rain =
        current.rainMm ?? 0;

    final todayProbability =
        weather.daily.isNotEmpty
            ? weather.daily.first.rainProbability
            : 0;

    String title;
    String message;
    IconData icon;
    Color color;
    Color background;

    if (todayProbability >= 70 || rain >= 5) {
      title = 'Rainy conditions';
      message =
          'Rain is likely around your farm. Consider checking drainage and avoid unnecessary irrigation today.';
      icon = Icons.umbrella_rounded;
      color = const Color(0xFF0277BD);
      background = const Color(0xFFE1F5FE);
    } else if (temperature >= 35) {
      title = 'Hot conditions';
      message =
          'Temperatures are high. Check crops for heat stress and make sure young plants have enough water.';
      icon = Icons.wb_sunny_rounded;
      color = const Color(0xFFE65100);
      background = const Color(0xFFFFF3E0);
    } else if (humidity >= 80) {
      title = 'High humidity';
      message =
          'Humidity is high. Keep an eye on fungal problems and allow good airflow around your crops.';
      icon = Icons.water_drop_rounded;
      color = const Color(0xFF1565C0);
      background = const Color(0xFFE3F2FD);
    } else {
      title = 'Good farming conditions';
      message =
          'Current conditions look relatively comfortable. Continue monitoring your crops and soil moisture.';
      icon = Icons.eco_rounded;
      color = const Color(0xFF2E7D32);
      background = const Color(0xFFE8F5E9);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'FARMING INSIGHT',
                  style: TextStyle(
                    color: Color(0xFF607D63),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF546E57),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEGEND
  // ============================================================

  Widget _buildWeatherLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE0E8E0),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF78909C),
            size: 19,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Weather data is based on your farm location and updated from the weather service.',
              style: TextStyle(
                color: Color(0xFF607D63),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEATHER HELPERS
  // ============================================================

  String _weatherIcon(int code) {
    if (code == 0) return '☀️';

    if ([1, 2].contains(code)) {
      return '🌤️';
    }

    if (code == 3) {
      return '☁️';
    }

    if ([45, 48].contains(code)) {
      return '🌫️';
    }

    if ([51, 53, 55, 56, 57].contains(code)) {
      return '🌦️';
    }

    if ([61, 63, 65, 66, 67, 80, 81, 82]
        .contains(code)) {
      return '🌧️';
    }

    if ([71, 73, 75, 77].contains(code)) {
      return '❄️';
    }

    if ([85, 86].contains(code)) {
      return '🌨️';
    }

    if ([95, 96, 99].contains(code)) {
      return '⛈️';
    }

    return '🌤️';
  }

  String _forecastDay(
    String date,
    int index,
  ) {
    if (index == 0) {
      return 'Today';
    }

    try {
      final parsed = DateTime.parse(date);

      const days = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];

      return days[parsed.weekday - 1];
    } catch (_) {
      return 'Day ${index + 1}';
    }
  }

  String _forecastDate(String date) {
    try {
      final parsed = DateTime.parse(date);

      return '${parsed.day}/${parsed.month}';
    } catch (_) {
      return '';
    }
  }

  LinearGradient _weatherGradient(int code) {
    if ([61, 63, 65, 80, 81, 82, 95, 96, 99]
        .contains(code)) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1565C0),
          Color(0xFF0277BD),
          Color(0xFF00838F),
        ],
      );
    }

    if ([1, 2, 3].contains(code)) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1976D2),
          Color(0xFF42A5F5),
          Color(0xFF26A69A),
        ],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2E7D32),
        Color(0xFF43A047),
        Color(0xFF8BC34A),
      ],
    );
  }

  Color _weatherAccent(int code) {
    if ([61, 63, 65, 80, 81, 82, 95, 96, 99]
        .contains(code)) {
      return const Color(0xFF0277BD);
    }

    return const Color(0xFF2E7D32);
  }
}

// ============================================================
// HERO METRIC
// ============================================================

class _HeroMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.85),
          size: 17,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white
                      .withValues(alpha: 0.72),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color background;
  final String title;
  final String value;
  final String? suffix;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.title,
    required this.value,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: background,
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 19,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF78909C),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF263238),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 2),
                Text(
                  suffix!,
                  style: const TextStyle(
                    color: Color(0xFF90A4AE),
                    fontSize: 8,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2E7D32),
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF173B1A),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF78909C),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TODAY INFO
// ============================================================

class _TodayInfo extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String value;

  const _TodayInfo({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: background,
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: color,
            size: 21,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF90A4AE),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF263238),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// RAIN BADGE
// ============================================================

class _RainBadge extends StatelessWidget {
  final double probability;

  const _RainBadge({
    required this.probability,
  });

  @override
  Widget build(BuildContext context) {
    final bool high = probability >= 60;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: high
            ? const Color(0xFFB3E5FC)
            : const Color(0xFFDCEFCB),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Text(
        high ? 'Bring care' : 'Low risk',
        style: TextStyle(
          color: high
              ? const Color(0xFF01579B)
              : const Color(0xFF33691E),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ============================================================
// FORECAST CARD
// ============================================================

class _ForecastCard extends StatelessWidget {
  final String day;
  final String date;
  final String icon;
  final double maxTemp;
  final double minTemp;
  final double rainProbability;
  final bool isToday;

  const _ForecastCard({
    required this.day,
    required this.date,
    required this.icon,
    required this.maxTemp,
    required this.minTemp,
    required this.rainProbability,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFF2E7D32)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: isToday
              ? const Color(0xFF2E7D32)
              : const Color(0xFFE0E8E0),
        ),
        boxShadow: [
          if (!isToday)
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              color: isToday
                  ? Colors.white
                  : const Color(0xFF263238),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: TextStyle(
              color: isToday
                  ? Colors.white
                      .withValues(alpha: 0.72)
                  : const Color(0xFF90A4AE),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            icon,
            style: const TextStyle(
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                '${maxTemp.toStringAsFixed(0)}°',
                style: TextStyle(
                  color: isToday
                      ? Colors.white
                      : const Color(0xFFE65100),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${minTemp.toStringAsFixed(0)}°',
                style: TextStyle(
                  color: isToday
                      ? Colors.white
                          .withValues(alpha: 0.65)
                      : const Color(0xFF90A4AE),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop_rounded,
                size: 12,
                color: isToday
                    ? Colors.white
                        .withValues(alpha: 0.8)
                    : const Color(0xFF0288D1),
              ),
              const SizedBox(width: 3),
              Text(
                '${rainProbability.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: isToday
                      ? Colors.white
                          .withValues(alpha: 0.8)
                      : const Color(0xFF0288D1),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _WeatherLoading extends StatelessWidget {
  const _WeatherLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF8BC34A),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.cloud_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Checking your farm weather...',
            style: TextStyle(
              color: Color(0xFF263238),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Getting the latest conditions',
            style: TextStyle(
              color: Color(0xFF78909C),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _WeatherError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _WeatherError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius:
                    BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xFFE65100),
                size: 43,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Weather unavailable',
              style: TextStyle(
                color: Color(0xFF263238),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF78909C),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}