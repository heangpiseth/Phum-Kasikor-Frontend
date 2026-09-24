abstract class AppRoutes {
  AppRoutes._();

  // ==========================================================
  // AUTH / ONBOARDING
  // ==========================================================

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const roleSelection = '/role-selection';
  static const verification = '/verification';
  static const profileSetup = '/profile-setup';
  static const locationSetup = '/location-setup';
  static const welcome = '/welcome';

  // ==========================================================
  // CUSTOMER
  // ==========================================================

  static const costumerHomescreen =
      '/costumer/homescreen';

  static const costumerExplorescreen =
      '/costumer/explorescreen';

  static const costumerSearchFilterscreen =
      '/costumer/search-filterscreen';

  static const costumerProductDetailscreen =
      '/costumer/product-detailscreen';

  static const costumerCartscreen =
      '/costumer/cartscreen';

  static const costumerCheckoutscreen =
      '/costumer/checkoutscreen';

  static const costumerPaymentscreen =
      '/costumer/paymentscreen';

  static const costumerOrderSuccessscreen =
      '/costumer/order-successscreen';

  static const costumerOrderTrackingscreen =
      '/costumer/order-tracking';

  static const costumerFarmDetailscreen =
      '/costumer/farm-detailscreen';

  static const costumerFarmMapscreen =
      '/costumer/farm-mapscreen';

  static const costumerFarmProductsscreen =
      '/costumer/farm-products';

  static const costumerProfilescreen =
      '/costumer/profile';

  static const aiAssistant =
      '/ai-assistant';

  // ==========================================================
  // FARMER
  // ==========================================================

  // ----------------------------------------------------------
  // Home
  // ----------------------------------------------------------

  static const farmerHome =
      '/farmer/home';

  // ----------------------------------------------------------
  // Orders
  // ----------------------------------------------------------

  static const farmerOrders =
      '/farmer/orders';

  static const farmerOrderDetail =
      '/farmer/orders/detail';

  // ----------------------------------------------------------
  // Products
  // ----------------------------------------------------------

  static const farmerProducts =
      '/farmer/products';

  static const farmerAddProduct =
      '/farmer/products/add';

  static const farmerEditProduct =
      '/farmer/products/edit';

  static const farmerProductPreview =
      '/farmer/products/detail';

  // ----------------------------------------------------------
  // Inventory
  // ----------------------------------------------------------

  static const farmerInventory =
      '/farmer/inventory';

  static const farmerInventoryAddEdit =
      '/farmer/inventory/add-edit';

  // ----------------------------------------------------------
  // Farm
  // ----------------------------------------------------------

  static const farmerFarmProfile =
      '/farmer/farm-profile';

  static const farmerFields =
      '/farmer/fields';

  static const farmerAddEditField =
      '/farmer/fields/add-edit';

  static const farmerCrops =
      '/farmer/crops';

  static const farmerWateringRecommendation =
    '/farmer/watering-recommendation';

  static const farmerAddCrop =
      '/farmer/crops/add';

  static const farmerCropDetail =
      '/farmer/crops/detail';

  static const farmerWatering =
      '/farmer/watering';

  static const farmerHarvest =
      '/farmer/harvest';

  // ----------------------------------------------------------
  // Earnings
  // ----------------------------------------------------------

  static const farmerEarnings =
      '/farmer/earnings';

  // ----------------------------------------------------------
  // Profile
  // ----------------------------------------------------------

  static const farmerProfile =
      '/farmer/profile';

  static const farmerEditProfile =
      '/farmer/profile/edit';

  static const farmerVerification =
      '/farmer/profile/verification';

  // ==========================================================
  // OPTIONAL ALIASES
  // ==========================================================

  static const main =
      costumerHomescreen;

  static const orderTracking =
      costumerOrderTrackingscreen;

  static const productDetail =
      costumerProductDetailscreen;
}