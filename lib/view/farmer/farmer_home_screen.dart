import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phum_kasikors/controller/farmer/farm_controller.dart';
import 'package:phum_kasikors/controller/farmer/crop_controller.dart';
import 'package:phum_kasikors/controller/farmer/weather_controller.dart';
import 'package:phum_kasikors/controller/farmer/earnings_controller.dart';
import 'package:phum_kasikors/core/network/api_client.dart';
import 'package:phum_kasikors/core/routes/app_routes.dart';
import 'package:phum_kasikors/model/farmer/earnings_model.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';
import 'package:phum_kasikors/view/farmer/weather/farmer_weather_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  late final WeatherController weatherController;
  late final EarningsController earningsController;

  // ============================================================
  // STATE
  // ============================================================

  bool isLoading = false;

  String farmerName = 'Farmer';
  String farmName = 'My Farm';

  int fieldCount = 0;
  int cropCount = 0;
  int productCount = 0;
  int inventoryCount = 0;

  int totalOrderCount = 0;
  int actionOrderCount = 0;
  int lowStockCount = 0;

  EarningsModel? earnings;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    Get.put(FarmController(), permanent: true);

    Get.put(CropController(), permanent: true);

    weatherController = Get.put(WeatherController(), permanent: false);

    earningsController = Get.put(EarningsController(), permanent: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDashboard();
    });
  }

  // ============================================================
  // DASHBOARD LOADING
  // ============================================================

  Future<void> loadDashboard() async {
    if (isLoading) return;

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      await _loadProfile();
      await _loadFarm();

      await Future.wait([
        _loadProducts(),
        _loadOrders(),
        _loadInventory(),
        _loadCrops(),
        _loadFields(),
        weatherController.loadWeather(),
      ]);

      await earningsController.refreshEarnings();

      if (mounted) {
        setState(() {
          earnings = earningsController.earnings.value;
        });
      }
    } catch (e) {
      debugPrint('Farmer dashboard error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final response = await ApiClient.get('farmer/profile');

      if (response is Map) {
        final data = response['data'] is Map ? response['data'] : response;

        if (data is Map) {
          farmerName = (data['name'] ?? data['display_name'] ?? 'Farmer')
              .toString();
        }
      }
    } catch (e) {
      debugPrint('Profile loading error: $e');
    }
  }

  // ============================================================
  // FARM
  // ============================================================

  Future<void> _loadFarm() async {
    try {
      final farmController = Get.find<FarmController>();

      await farmController.loadFarm();

      final farm = farmController.farm.value;

      if (farm == null) {
        debugPrint('Farm loading error: No farm returned for current farmer.');
        return;
      }

      farmName = farm.farmName;

      debugPrint('CURRENT FARM ID: ${farm.id}');
      debugPrint('CURRENT FARM USER ID: ${farm.userId}');
    } catch (e) {
      debugPrint('Farm loading error: $e');
    }
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  Future<void> _loadProducts() async {
    try {
      final farmController = Get.find<FarmController>();
      final farmId = farmController.farm.value?.id;

      if (farmId == null || farmId.isEmpty) {
        debugPrint('Products loading skipped: Farm ID is missing.');
        return;
      }

      final response = await ApiClient.get('farmer/farms/$farmId/products');

      dynamic data = response;

      if (response is Map) {
        if (response['data'] is List) {
          data = response['data'];
        } else if (response['products'] is List) {
          data = response['products'];
        }
      }

      if (data is List) {
        productCount = data.length;
      }

      debugPrint('HOME PRODUCT COUNT: $productCount');
    } catch (e) {
      debugPrint('Products loading error: $e');
    }
  }

  // ============================================================
  // ORDERS
  // ============================================================

  Future<void> _loadOrders() async {
    try {
      final response = await ApiClient.get('farmer/orders');

      dynamic data = response;

      if (response is Map && response['data'] != null) {
        data = response['data'];
      }

      if (data is List) {
        totalOrderCount = data.length;

        actionOrderCount = data.where((order) {
          if (order is! Map) return false;

          final status = order['status']?.toString().toLowerCase();

          return status == 'pending' ||
              status == 'confirmed' ||
              status == 'packed' ||
              status == 'dispatched' ||
              status == 'out_for_delivery';
        }).length;
      }
    } catch (e) {
      debugPrint('Orders loading error: $e');
    }
  }

  // ============================================================
  // INVENTORY
  // ============================================================

  Future<void> _loadInventory() async {
    try {
      final farmController = Get.find<FarmController>();
      final farmId = farmController.farm.value?.id;

      if (farmId == null || farmId.isEmpty) {
        debugPrint('Inventory loading skipped: Farm ID is missing.');
        return;
      }

      final response = await ApiClient.get('farmer/farms/$farmId/inventory');

      dynamic data = response;

      if (response is Map) {
        if (response['data'] is List) {
          data = response['data'];
        } else if (response['inventory'] is List) {
          data = response['inventory'];
        } else if (response['items'] is List) {
          data = response['items'];
        }
      }

      if (data is List) {
        inventoryCount = data.length;

        lowStockCount = data.where((item) {
          if (item is! Map) return false;

          final quantity = _safeDouble(item['quantity']);

          final minimum = _safeDouble(
            item['minimum_stock'] ?? item['minimum_quantity'] ?? 0,
          );

          return minimum > 0 && quantity <= minimum;
        }).length;
      }

      debugPrint('HOME INVENTORY COUNT: $inventoryCount');
    } catch (e) {
      debugPrint('Inventory loading error: $e');
    }
  }

  // ============================================================
  // CROPS
  // ============================================================

  Future<void> _loadCrops() async {
    try {
      final farmController = Get.find<FarmController>();
      final farmId = farmController.farm.value?.id;

      if (farmId == null || farmId.isEmpty) {
        debugPrint('Crops loading skipped: Farm ID is missing.');
        return;
      }

      final response = await ApiClient.get('farmer/farms/$farmId/crops');

      dynamic data = response;

      if (response is Map) {
        if (response['data'] is List) {
          data = response['data'];
        } else if (response['crops'] is List) {
          data = response['crops'];
        }
      }

      if (data is List) {
        cropCount = data.length;
      }

      debugPrint('HOME CROP COUNT: $cropCount');
    } catch (e) {
      debugPrint('Crops loading error: $e');
    }
  }

  // ============================================================
  // FIELDS
  // ============================================================

  Future<void> _loadFields() async {
    try {
      final farmController = Get.find<FarmController>();
      final farmId = farmController.farm.value?.id;

      if (farmId == null || farmId.isEmpty) {
        debugPrint('Fields loading skipped: Farm ID is missing.');
        return;
      }

      final response = await ApiClient.get('farmer/farms/$farmId/fields');

      dynamic data = response;

      if (response is Map) {
        if (response['data'] is List) {
          data = response['data'];
        } else if (response['fields'] is List) {
          data = response['fields'];
        }
      }

      if (data is List) {
        fieldCount = data.length;
      }

      debugPrint('HOME FIELD COUNT: $fieldCount');
    } catch (e) {
      debugPrint('Fields loading error: $e');
    }
  }

  // ============================================================
  // SAFE CONVERSION
  // ============================================================

  int _safeInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _safeDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerDesign.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: FarmerDesign.primary,
          onRefresh: loadDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ==================================================
              // HEADER
              // ==================================================

              SliverToBoxAdapter(child: _buildHeader()),

              // ==================================================
              // FARM HERO
              // ==================================================
              SliverToBoxAdapter(child: _buildFarmHero()),

              // ==================================================
              // REAL FARM WEATHER
              // ==================================================
              SliverToBoxAdapter(child: _buildWeatherCard()),

              // ==================================================
              // OVERVIEW
              // ==================================================
              SliverToBoxAdapter(child: _buildOverview()),

              // ==================================================
              // EARNINGS
              // ==================================================
              SliverToBoxAdapter(child: _buildEarnings()),

              // ==================================================
              // ATTENTION
              // ==================================================
              SliverToBoxAdapter(child: _buildAttention()),

              // ==================================================
              // FARM MANAGEMENT
              // ==================================================
              SliverToBoxAdapter(child: _buildFarmManagement()),

              // ==================================================
              // QUICK ACTIONS
              // ==================================================
              SliverToBoxAdapter(child: _buildQuickActions()),

              // ==================================================
              // FARM SNAPSHOT
              // ==================================================
              SliverToBoxAdapter(child: _buildFarmSnapshot()),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting(), style: FarmerDesign.caption),
                const SizedBox(height: 5),
                Text(
                  farmerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FarmerDesign.heading1,
                ),
              ],
            ),
          ),

          _HeaderButton(
            icon: Icons.refresh_rounded,
            onTap: isLoading ? null : loadDashboard,
          ),

          const SizedBox(width: 8),

          _HeaderButton(
            icon: Icons.person_outline_rounded,
            onTap: () {
              Get.toNamed('/farmer/profile');
            },
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 17) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }

  // ============================================================
  // FARM HERO
  // ============================================================

  Widget _buildFarmHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [FarmerDesign.primary, FarmerDesign.primaryDark],
          ),
          borderRadius: BorderRadius.circular(FarmerDesign.radiusXLarge),
          boxShadow: FarmerDesign.cardShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .07),
                ),
              ),
            ),

            Positioned(
              right: 20,
              bottom: -85,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .05),
                ),
              ),
            ),

            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.agriculture_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MY FARM',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        farmName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        '$fieldCount fields • '
                        '$cropCount crops • '
                        '$productCount products',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                _HeroArrowButton(
                  onTap: () {
                    Get.toNamed(AppRoutes.farmerFarmProfile);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WEATHER
  // ============================================================

  Widget _buildWeatherCard() {
    return Obx(() {
      final weather = weatherController.weather.value;

      final loading = weatherController.isLoading.value;

      if (loading && weather == null) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: FarmerDesign.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: FarmerDesign.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: FarmerDesign.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farm weather',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Getting the latest weather...',
                      style: FarmerDesign.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      if (weather == null) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: FarmerDesign.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: FarmerDesign.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.cloud_off_outlined,
                  color: FarmerDesign.primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farm weather',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Weather is not available yet.',
                      style: FarmerDesign.caption,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: FarmerDesign.secondaryText,
              ),
            ],
          ),
        );
      }

      return GestureDetector(
        onTap: () {
          Get.to(() => FarmerWeatherScreen());
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8F5E9), Color(0xFFF4FAF4)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFFD7EBD9)),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .75),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Center(
                  child: Text(
                    weatherController.weatherIcon,
                    style: const TextStyle(fontSize: 34),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.farm.name ?? farmName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: FarmerDesign.text,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Farm weather',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Text(
                          '${weather.current.temperatureC?.toStringAsFixed(0) ?? '--'}°C',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: FarmerDesign.primaryDark,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            weatherController.weatherDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${weather.current.humidityPercent?.toStringAsFixed(0) ?? '--'}% humidity'
                      '  •  '
                      '${weather.current.windKmh?.toStringAsFixed(0) ?? '--'} km/h wind',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: FarmerDesign.primary,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 27, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Today at a glance', style: FarmerDesign.heading2),
              ),

              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: FarmerDesign.primary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.shopping_bag_outlined,
                  iconColor: FarmerDesign.info,
                  value: '$actionOrderCount',
                  label: 'Need action',
                  helper: '$totalOrderCount total orders',
                  onTap: () {
                    Get.toNamed('/farmer/orders');
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _StatCard(
                  icon: Icons.storefront_outlined,
                  iconColor: FarmerDesign.primary,
                  value: '$productCount',
                  label: 'Products',
                  helper: 'Listed for sale',
                  onTap: () {
                    Get.toNamed('/farmer/products');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EARNINGS
  // ============================================================

  Widget _buildEarnings() {
    final current = earningsController.earnings.value;

    final total = current?.totalEarnings ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 27, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: FarmerDesign.cardDecoration(radius: 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: FarmerDesign.primaryLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: FarmerDesign.primary,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Earnings', style: FarmerDesign.bodyMedium),
                      SizedBox(height: 3),
                      Text(
                        'Your sales performance',
                        style: FarmerDesign.caption,
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    earningsController.refreshEarnings();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: FarmerDesign.text,
                ),
              ),
            ),

            const SizedBox(height: 3),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Total earnings', style: FarmerDesign.caption),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ATTENTION
  // ============================================================

  Widget _buildAttention() {
    final hasOrders = actionOrderCount > 0;

    final hasLowStock = lowStockCount > 0;

    if (!hasOrders && !hasLowStock) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 27, 20, 0),
        child: _GoodStatusCard(),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 27, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Needs your attention', style: FarmerDesign.heading2),

          const SizedBox(height: 13),

          if (hasOrders)
            _AttentionCard(
              icon: Icons.notifications_active_outlined,
              iconColor: FarmerDesign.warning,
              backgroundColor: FarmerDesign.warningLight,
              title: actionOrderCount == 1
                  ? '1 order needs attention'
                  : '$actionOrderCount orders need attention',
              subtitle: 'Review and update your customer orders.',
              buttonText: 'View',
              onTap: () {
                Get.toNamed('/farmer/orders');
              },
            ),

          if (hasOrders && hasLowStock) const SizedBox(height: 10),

          if (hasLowStock)
            _AttentionCard(
              icon: Icons.inventory_2_outlined,
              iconColor: FarmerDesign.error,
              backgroundColor: FarmerDesign.errorLight,
              title: lowStockCount == 1
                  ? '1 item is low in stock'
                  : '$lowStockCount items are low in stock',
              subtitle: 'Check your inventory and update stock levels.',
              buttonText: 'Check',
              onTap: () {
                Get.toNamed('/farmer/inventory');
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // FARM MANAGEMENT
  // ============================================================

  Widget _buildFarmManagement() {
    final FarmController farmController = Get.find<FarmController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Farm management', style: FarmerDesign.heading2),
                    SizedBox(height: 4),
                    Text(
                      'Manage your farm from one place',
                      style: FarmerDesign.caption,
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: FarmerDesign.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '6 tools',
                  style: TextStyle(
                    color: FarmerDesign.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              // ==================================================
              // MY FARM
              // ==================================================

              _ManagementCard(
                icon: Icons.agriculture_outlined,
                title: 'My Farm',
                subtitle: 'Farm profile',
                color: FarmerDesign.primary,
                onTap: () {
                  // CORRECT ROUTE
                  Get.toNamed(AppRoutes.farmerFarmProfile);
                },
              ),

              // ==================================================
              // FIELDS
              // ==================================================
              _ManagementCard(
                icon: Icons.grid_view_rounded,
                title: 'Fields',
                subtitle: '$fieldCount fields',
                color: const Color(0xFF5D7A3A),
                onTap: () {
                  Get.toNamed(AppRoutes.farmerFields);
                },
              ),

              // ==================================================
              // CROPS
              // ==================================================
              _ManagementCard(
                icon: Icons.eco_outlined,
                title: 'Crops',
                subtitle: '$cropCount crops',
                color: const Color(0xFF388E3C),
                onTap: () {
                  Get.toNamed('/farmer/crops');
                },
              ),

              // ==================================================
              // WATERING
              // ==================================================
              _ManagementCard(
                icon: Icons.water_drop_outlined,
                title: 'Watering',
                subtitle: 'Water logs',
                color: const Color(0xFF1976D2),
                onTap: () {
                  Get.toNamed('/farmer/watering');
                },
              ),

              // ==================================================
              // HARVEST
              // ==================================================
              _ManagementCard(
                icon: Icons.agriculture_rounded,
                title: 'Harvest',
                subtitle: 'Harvest logs',
                color: const Color(0xFFE68A00),
                onTap: () {
                  final farmId = farmController.farm.value?.id;

                  if (farmId == null || farmId.isEmpty) {
                    Get.snackbar(
                      'Farm Required',
                      'Please create or load your farm first.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  Get.toNamed('/farmer/harvest', arguments: {'farmId': farmId});
                },
              ),

              // ==================================================
              // INVENTORY
              // ==================================================
              _ManagementCard(
                icon: Icons.inventory_2_outlined,
                title: 'Inventory',
                subtitle: '$inventoryCount items',
                color: const Color(0xFF8E5A2A),
                showBadge: lowStockCount > 0,
                onTap: () {
                  // INVENTORY ONLY
                  Get.toNamed('/farmer/inventory');
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ======================================================
          // IDENTITY VERIFICATION
          // ======================================================
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () {
                Get.toNamed('/farmer/verification');
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: FarmerDesign.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: FarmerDesign.primary,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 13),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Identity verification',
                            style: FarmerDesign.bodyMedium,
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Verify your National ID',
                            style: FarmerDesign.caption,
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: FarmerDesign.secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick actions', style: FarmerDesign.heading2),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Add product',
                  subtitle: 'Start selling',
                  onTap: () {
                    Get.toNamed('/farmer/products/add');
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _QuickAction(
                  icon: Icons.receipt_long_outlined,
                  title: 'Orders',
                  subtitle: '$totalOrderCount orders',
                  onTap: () {
                    Get.toNamed('/farmer/orders');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FARM SNAPSHOT
  // ============================================================

  Widget _buildFarmSnapshot() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 27, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: FarmerDesign.cardDecoration(radius: 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: FarmerDesign.primaryLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.eco_outlined,
                    color: FarmerDesign.primary,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Farm snapshot', style: FarmerDesign.bodyMedium),
                      SizedBox(height: 3),
                      Text(
                        'Your farm at a glance',
                        style: FarmerDesign.caption,
                      ),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.farmerFarmProfile);
                  },
                  child: const Text('Manage'),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _FarmMetric(
                    icon: Icons.grid_view_rounded,
                    value: '$fieldCount',
                    label: 'Fields',
                  ),
                ),

                const _VerticalDivider(),

                Expanded(
                  child: _FarmMetric(
                    icon: Icons.eco_outlined,
                    value: '$cropCount',
                    label: 'Crops',
                  ),
                ),

                const _VerticalDivider(),

                Expanded(
                  child: _FarmMetric(
                    icon: Icons.inventory_2_outlined,
                    value: '$inventoryCount',
                    label: 'Stock',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// HEADER BUTTON
// ================================================================

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: FarmerDesign.border),
          ),
          child: Icon(icon, size: 20, color: FarmerDesign.text),
        ),
      ),
    );
  }
}

// ================================================================
// HERO ARROW
// ================================================================

class _HeroArrowButton extends StatelessWidget {
  const _HeroArrowButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const Padding(
          padding: EdgeInsets.all(11),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// STAT CARD
// ================================================================

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.helper,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String helper;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: FarmerDesign.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 17,
                    color: FarmerDesign.secondaryText,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: FarmerDesign.text,
                ),
              ),

              const SizedBox(height: 2),

              Text(label, style: FarmerDesign.bodyMedium),

              const SizedBox(height: 2),

              Text(
                helper,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FarmerDesign.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// MANAGEMENT CARD
// ================================================================

class _ManagementCard extends StatelessWidget {
  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: FarmerDesign.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .025),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),

                  const Spacer(),

                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: FarmerDesign.text,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FarmerDesign.caption,
                  ),
                ],
              ),

              if (showBadge)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: FarmerDesign.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// QUICK ACTION
// ================================================================

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FarmerDesign.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: FarmerDesign.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),

              const SizedBox(height: 13),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ATTENTION CARD
// ================================================================

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FarmerDesign.caption,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          TextButton(onPressed: onTap, child: Text(buttonText)),
        ],
      ),
    );
  }
}

// ================================================================
// GOOD STATUS
// ================================================================

class _GoodStatusCard extends StatelessWidget {
  const _GoodStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: FarmerDesign.primaryLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: FarmerDesign.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Everything looks good',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3),
                Text(
                  'No urgent farm tasks right now.',
                  style: FarmerDesign.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// FARM METRIC
// ================================================================

class _FarmMetric extends StatelessWidget {
  const _FarmMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: FarmerDesign.primary, size: 21),

        const SizedBox(height: 7),

        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: FarmerDesign.text,
          ),
        ),

        const SizedBox(height: 2),

        Text(label, style: FarmerDesign.caption),
      ],
    );
  }
}

// ================================================================
// VERTICAL DIVIDER
// ================================================================

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 45, color: FarmerDesign.border);
  }
}
