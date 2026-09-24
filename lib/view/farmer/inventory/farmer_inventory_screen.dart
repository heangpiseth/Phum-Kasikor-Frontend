import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';

import 'package:phum_kasikors/controller/farmer/farm_controller.dart';
import 'package:phum_kasikors/controller/farmer/inventory_category_controller.dart';
import 'package:phum_kasikors/controller/farmer/inventory_controller.dart';
import 'package:phum_kasikors/model/farmer/inventory_category_model.dart';
import 'package:phum_kasikors/model/farmer/inventory_model.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerInventoryScreen extends StatefulWidget {
  const FarmerInventoryScreen({
    super.key,
    this.farmId,
  });

  final String? farmId;

  @override
  State<FarmerInventoryScreen> createState() =>
      _FarmerInventoryScreenState();
}

class _FarmerInventoryScreenState
    extends State<FarmerInventoryScreen> {
  late final InventoryController inventoryController;
  late final InventoryCategoryController categoryController;
  late final FarmController farmController;

  String farmId = '';
  bool _initializing = true;

  @override
  void initState() {
    super.initState();

    inventoryController =
        Get.isRegistered<InventoryController>()
            ? Get.find<InventoryController>()
            : Get.put(InventoryController());

    categoryController =
        Get.isRegistered<InventoryCategoryController>()
            ? Get.find<InventoryCategoryController>()
            : Get.put(InventoryCategoryController());

    farmController =
        Get.isRegistered<FarmController>()
            ? Get.find<FarmController>()
            : Get.put(FarmController());

    _initialize();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initialize() async {
    try {
      String? resolvedFarmId;

      // ----------------------------------------------------------
      // 1. Widget farm ID
      // ----------------------------------------------------------

      if (widget.farmId != null &&
          widget.farmId!.trim().isNotEmpty) {
        resolvedFarmId = widget.farmId!.trim();
      }

      // ----------------------------------------------------------
      // 2. Get.arguments
      // ----------------------------------------------------------

      if (resolvedFarmId == null) {
        final arguments = Get.arguments;

        if (arguments is String &&
            arguments.trim().isNotEmpty) {
          resolvedFarmId = arguments.trim();
        }

        if (arguments is Map) {
          final value =
              arguments['farmId']?.toString().trim();

          if (value != null && value.isNotEmpty) {
            resolvedFarmId = value;
          }
        }
      }

      // ----------------------------------------------------------
      // 3. FarmController fallback
      // ----------------------------------------------------------

      if (resolvedFarmId == null) {
        debugPrint(
          'INVENTORY: No farm ID supplied. Resolving farm...',
        );

        resolvedFarmId =
            await farmController.ensureFarmId();
      }

      // ----------------------------------------------------------
      // 4. Validate farm ID
      // ----------------------------------------------------------

      if (resolvedFarmId == null ||
          resolvedFarmId.trim().isEmpty) {
        debugPrint(
          'INVENTORY: Could not resolve farm ID.',
        );

        if (mounted) {
          setState(() {
            farmId = '';
          });
        }

        return;
      }

      farmId = resolvedFarmId.trim();

      debugPrint(
        '========== FARMER INVENTORY ==========',
      );
      debugPrint(
        'Resolved farmId: "$farmId"',
      );
      debugPrint(
        '=======================================',
      );

      // ----------------------------------------------------------
      // 5. Load inventory and categories
      // ----------------------------------------------------------

      await Future.wait([
        inventoryController.loadInventory(farmId),
        categoryController.loadCategories(farmId),
      ]);
    } catch (e) {
      debugPrint(
        'INVENTORY INITIALIZATION ERROR: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _loadData() async {
    if (farmId.trim().isEmpty) {
      final resolvedFarmId =
          await farmController.ensureFarmId();

      if (resolvedFarmId == null ||
          resolvedFarmId.trim().isEmpty) {
        inventoryController.errorMessage.value =
            farmController.errorMessage.value.isNotEmpty
                ? farmController.errorMessage.value
                : 'Farm ID is missing.';
        return;
      }

      farmId = resolvedFarmId.trim();
    }

    await Future.wait([
      inventoryController.loadInventory(farmId),
      categoryController.loadCategories(farmId),
    ]);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerDesign.background,
      appBar: AppBar(
        backgroundColor: FarmerDesign.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Inventory',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (_initializing) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (farmId.isEmpty) {
          return _buildFarmErrorState();
        }

        if (inventoryController.isLoading.value &&
            inventoryController.items.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (inventoryController.errorMessage.value.isNotEmpty &&
            inventoryController.items.isEmpty) {
          return _buildErrorState();
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              100,
            ),
            children: [
              _buildSummary(),
              const SizedBox(height: 20),
              _buildSectionHeader(),
              const SizedBox(height: 12),
              _buildInventoryList(),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(
        () => farmId.isEmpty
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                onPressed:
                    inventoryController.isSaving.value
                        ? null
                        : _showAddInventoryDialog,
                backgroundColor:
                    FarmerDesign.primary,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.inventory_2_outlined,
              title: 'Total Items',
              value:
                  '${inventoryController.items.length}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              icon:
                  Icons.warning_amber_outlined,
              title: 'Low Stock',
              value:
                  '${inventoryController.lowStockCount}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              icon:
                  Icons.remove_circle_outline,
              title: 'Out',
              value:
                  '${inventoryController.outOfStockCount}',
            ),
          ),
        ],
      );
    });
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Inventory Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Obx(
          () => Text(
            '${inventoryController.items.length} items',
            style: TextStyle(
              color:
                  FarmerDesign.secondaryText,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INVENTORY LIST
  // ============================================================

  Widget _buildInventoryList() {
    return Obx(() {
      final items = inventoryController.items;

      if (items.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        children: items.map((item) {
          return Padding(
            padding:
                const EdgeInsets.only(bottom: 12),
            child: _InventoryCard(
              item: item,
              onEdit: () =>
                  _showEditItemDialog(item),
              onDelete: () =>
                  _confirmDelete(item),
            ),
          );
        }).toList(),
      );
    });
  }

  // ============================================================
  // ADD INVENTORY
  // ============================================================

  Future<void> _showAddInventoryDialog() async {
    final nameController =
        TextEditingController();

    final quantityController =
        TextEditingController();

    final unitController =
        TextEditingController();

    final minimumController =
        TextEditingController();

    InventoryCategoryModel? selectedCategory;

    bool saving = false;

    final result = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (
          context,
          setDialogState,
        ) {
          return AlertDialog(
            title: const Text(
              'Add Inventory Item',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  TextField(
                    controller:
                        nameController,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        const InputDecoration(
                      labelText: 'Item Name',
                      hintText:
                          'e.g. Fertilizer',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(() {
                    final categories =
                        categoryController
                            .categories;

                    return DropdownButtonFormField<
                        InventoryCategoryModel>(
                      value:
                          selectedCategory,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Category',
                        border:
                            OutlineInputBorder(),
                      ),
                      items: categories
                          .map(
                            (category) =>
                                DropdownMenuItem<
                                    InventoryCategoryModel>(
                              value: category,
                              child: Text(
                                category.name,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: saving
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedCategory =
                                    value;
                              });
                            },
                    );
                  }),
                  const SizedBox(height: 14),
                  TextField(
                    controller:
                        quantityController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText: 'Quantity',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller:
                        unitController,
                    decoration:
                        const InputDecoration(
                      labelText: 'Unit',
                      hintText:
                          'kg, bags, bottles...',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller:
                        minimumController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Minimum Stock',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving
                    ? null
                    : () {
                        Get.back(
                          result: false,
                        );
                      },
                child:
                    const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        setDialogState(() {
                          saving = true;
                        });

                        final success =
                            await _createItem(
                          nameController:
                              nameController,
                          quantityController:
                              quantityController,
                          unitController:
                              unitController,
                          minimumController:
                              minimumController,
                          selectedCategory:
                              selectedCategory,
                        );

                        if (!context.mounted) {
                          return;
                        }

                        if (!success) {
                          setDialogState(() {
                            saving = false;
                          });
                        }
                      },
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    minimumController.dispose();

    if (result == true) {
      await inventoryController
          .loadInventory(farmId);

      if (!mounted) {
        return;
      }

      Get.snackbar(
        'Success',
        'Inventory item added successfully.',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // CREATE ITEM
  // ============================================================

  Future<bool> _createItem({
    required TextEditingController
        nameController,
    required TextEditingController
        quantityController,
    required TextEditingController
        unitController,
    required TextEditingController
        minimumController,
    required InventoryCategoryModel?
        selectedCategory,
  }) async {
    final name =
        nameController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter an item name.',
        snackPosition:
            SnackPosition.BOTTOM,
      );
      return false;
    }

    final quantity =
        _parseNullableDouble(
      quantityController.text,
    );

    final minimumStock =
        _parseNullableDouble(
      minimumController.text,
    );

    if (quantityController.text
            .trim()
            .isNotEmpty &&
        quantity == null) {
      Get.snackbar(
        'Invalid quantity',
        'Please enter a valid quantity.',
        snackPosition:
            SnackPosition.BOTTOM,
      );
      return false;
    }

    if (minimumController.text
            .trim()
            .isNotEmpty &&
        minimumStock == null) {
      Get.snackbar(
        'Invalid minimum stock',
        'Please enter a valid minimum stock.',
        snackPosition:
            SnackPosition.BOTTOM,
      );
      return false;
    }

    final status = _calculateStatus(
      quantity: quantity,
      minimumStock: minimumStock,
    );

    debugPrint(
      '========== CREATE INVENTORY ==========',
    );
    debugPrint(
      'farmId: "$farmId"',
    );
    debugPrint(
      'name: "$name"',
    );
    debugPrint(
      'categoryId: "${selectedCategory?.id}"',
    );
    debugPrint(
      'quantity: $quantity',
    );
    debugPrint(
      'unit: "${_nullableText(unitController.text)}"',
    );
    debugPrint(
      'minimumStock: $minimumStock',
    );
    debugPrint(
      'status: "$status"',
    );
    debugPrint(
      '======================================',
    );

    final success =
        await inventoryController.createItem(
      farmId: farmId,
      categoryId:
          selectedCategory?.id,
      name: name,
      quantity: quantity,
      unit:
          _nullableText(
        unitController.text,
      ),
      minimumStock: minimumStock,
      status: status,
    );

    debugPrint(
      'CREATE RESULT: $success',
    );

    if (!success) {
      Get.snackbar(
        'Error',
        inventoryController
            .errorMessage.value,
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return false;
    }

    Get.back(result: true);

    return true;
  }

  // ============================================================
  // EDIT INVENTORY
  // ============================================================

  Future<void> _showEditItemDialog(
    InventoryModel item,
  ) async {
    final nameController =
        TextEditingController(
      text: item.name,
    );

    final quantityController =
        TextEditingController(
      text:
          item.quantity?.toString() ?? '',
    );

    final unitController =
        TextEditingController(
      text: item.unit ?? '',
    );

    final minimumController =
        TextEditingController(
      text:
          item.minimumStock?.toString() ??
              '',
    );

    InventoryCategoryModel?
        selectedCategory;

    try {
      selectedCategory =
          categoryController.categories
              .cast<InventoryCategoryModel?>()
              .firstWhere(
                (category) =>
                    category?.id ==
                    item.categoryId,
                orElse: () => null,
              );
    } catch (_) {
      selectedCategory = null;
    }

    bool saving = false;

    final result = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (
          context,
          setDialogState,
        ) {
          return AlertDialog(
            title: const Text(
              'Edit Inventory Item',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  TextField(
                    controller:
                        nameController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Item Name',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(() {
                    return DropdownButtonFormField<
                        InventoryCategoryModel>(
                      value:
                          selectedCategory,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Category',
                        border:
                            OutlineInputBorder(),
                      ),
                      items:
                          categoryController
                              .categories
                              .map(
                                (category) =>
                                    DropdownMenuItem<
                                        InventoryCategoryModel>(
                                  value: category,
                                  child: Text(
                                    category.name,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: saving
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedCategory =
                                    value;
                              });
                            },
                    );
                  }),
                  const SizedBox(height: 14),
                  TextField(
                    controller:
                        quantityController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Quantity',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller:
                        unitController,
                    decoration:
                        const InputDecoration(
                      labelText: 'Unit',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller:
                        minimumController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Minimum Stock',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving
                    ? null
                    : () {
                        Get.back(
                          result: false,
                        );
                      },
                child:
                    const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        final name =
                            nameController
                                .text
                                .trim();

                        if (name.isEmpty) {
                          Get.snackbar(
                            'Required',
                            'Please enter an item name.',
                            snackPosition:
                                SnackPosition
                                    .BOTTOM,
                          );
                          return;
                        }

                        final quantity =
                            _parseNullableDouble(
                          quantityController
                              .text,
                        );

                        final minimumStock =
                            _parseNullableDouble(
                          minimumController
                              .text,
                        );

                        if (quantityController
                                .text
                                .trim()
                                .isNotEmpty &&
                            quantity == null) {
                          Get.snackbar(
                            'Invalid quantity',
                            'Please enter a valid quantity.',
                            snackPosition:
                                SnackPosition
                                    .BOTTOM,
                          );
                          return;
                        }

                        if (minimumController
                                .text
                                .trim()
                                .isNotEmpty &&
                            minimumStock == null) {
                          Get.snackbar(
                            'Invalid minimum stock',
                            'Please enter a valid minimum stock.',
                            snackPosition:
                                SnackPosition
                                    .BOTTOM,
                          );
                          return;
                        }

                        setDialogState(() {
                          saving = true;
                        });

                        final status =
                            _calculateStatus(
                          quantity:
                              quantity,
                          minimumStock:
                              minimumStock,
                        );

                        final success =
                            await inventoryController
                                .updateItem(
                          farmId: farmId,
                          itemId: item.id,
                          categoryId:
                              selectedCategory
                                  ?.id,
                          name: name,
                          quantity:
                              quantity,
                          unit:
                              _nullableText(
                            unitController
                                .text,
                          ),
                          minimumStock:
                              minimumStock,
                          status: status,
                        );

                        if (!success) {
                          if (context.mounted) {
                            setDialogState(() {
                              saving = false;
                            });
                          }

                          Get.snackbar(
                            'Error',
                            inventoryController
                                .errorMessage
                                .value,
                            snackPosition:
                                SnackPosition
                                    .BOTTOM,
                          );

                          return;
                        }

                        Get.back(
                          result: true,
                        );
                      },
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    minimumController.dispose();

    if (result == true) {
      await inventoryController
          .loadInventory(farmId);

      if (!mounted) {
        return;
      }

      Get.snackbar(
        'Success',
        'Inventory item updated successfully.',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _confirmDelete(
    InventoryModel item,
  ) async {
    final confirmed =
        await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          'Delete Inventory Item',
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child:
                const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.red,
              foregroundColor:
                  Colors.white,
            ),
            child:
                const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final success =
        await inventoryController.deleteItem(
      farmId: farmId,
      itemId: item.id,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Get.snackbar(
        'Deleted',
        'Inventory item deleted successfully.',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        inventoryController
            .errorMessage.value,
        snackPosition:
            SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding:
          const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color:
                FarmerDesign.secondaryText,
          ),
          const SizedBox(height: 16),
          const Text(
            'No inventory items',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first inventory item.',
            style: TextStyle(
              color:
                  FarmerDesign.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load inventory',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              inventoryController
                  .errorMessage.value,
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              child:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FARM ERROR STATE
  // ============================================================

  Widget _buildFarmErrorState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.home_work_outlined,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not find your farm',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              farmController
                      .errorMessage.value
                      .isNotEmpty
                  ? farmController
                      .errorMessage.value
                  : 'No farm was found for your account.',
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _initializing = true;
                });

                _initialize();
              },
              child:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double? _parseNullableDouble(
    String value,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    return double.tryParse(text);
  }

  String? _nullableText(
    String value,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  String _calculateStatus({
    required double? quantity,
    required double? minimumStock,
  }) {
    if (quantity == null ||
        quantity <= 0) {
      return 'out_of_stock';
    }

    if (minimumStock != null &&
        quantity <= minimumStock) {
      return 'low_stock';
    }

    return 'in_stock';
  }
}

// ==================================================================
// INVENTORY CARD
// ==================================================================

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final InventoryModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration:
                  BoxDecoration(
                color:
                    FarmerDesign.primaryLight,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color:
                    FarmerDesign.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.categoryName !=
                      null)
                    Text(
                      item.categoryName!,
                      style: TextStyle(
                        color: FarmerDesign
                            .secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    _quantityText(),
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _StatusBadge(
                    text:
                        item.displayStatus,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                }

                if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder:
                  (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child:
                      Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child:
                      Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _quantityText() {
    final quantity =
        item.quantity;

    if (quantity == null) {
      return 'Quantity not set';
    }

    final unit =
        item.unit ?? '';

    return '$quantity $unit'.trim();
  }
}

// ==================================================================
// STATUS BADGE
// ==================================================================

class _StatusBadge
    extends StatelessWidget {
  const _StatusBadge({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color:
            FarmerDesign.primaryLight,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color:
              FarmerDesign.primaryDark,
          fontSize: 11,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}

// ==================================================================
// SUMMARY CARD
// ==================================================================

class _SummaryCard
    extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
                FarmerDesign.primary,
            size: 22,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style:
                const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}