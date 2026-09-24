import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/farm_controller.dart';
import 'package:phum_kasikors/controller/farmer/field_controller.dart';
import 'package:phum_kasikors/model/farmer/field_model.dart';
import 'package:phum_kasikors/view/farmer/farm/farmer_add_edit_field_screen.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerFieldsScreen extends StatefulWidget {
  const FarmerFieldsScreen({
    super.key,
    this.farmId,
  });

  final String? farmId;

  @override
  State<FarmerFieldsScreen> createState() => _FarmerFieldsScreenState();
}

class _FarmerFieldsScreenState extends State<FarmerFieldsScreen> {
  late final FieldController controller;
  late final FarmController farmController;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<FieldController>()
        ? Get.find<FieldController>()
        : Get.put(FieldController());

    farmController = Get.isRegistered<FarmController>()
        ? Get.find<FarmController>()
        : Get.put(FarmController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFields();
    });
  }

  String? get currentFarmId {
    final widgetFarmId = widget.farmId?.trim();

    if (widgetFarmId != null && widgetFarmId.isNotEmpty) {
      return widgetFarmId;
    }

    final farm = farmController.farm.value;
    final farmId = farm?.id;

    if (farmId != null && farmId.isNotEmpty) {
      return farmId;
    }

    return null;
  }

  Future<void> _loadFields() async {
    var farmId = currentFarmId;

    if (farmId == null || farmId.isEmpty) {
      await farmController.loadFarm();
      farmId = currentFarmId;
    }

    if (farmId != null && farmId.isNotEmpty) {
      await controller.loadFields(farmId);
    }
  }

  // ============================================================
  // ADD FIELD
  // ============================================================

  Future<void> _openAddField() async {
    var farmId = currentFarmId;

    if (farmId == null || farmId.isEmpty) {
      await farmController.loadFarm();
      farmId = currentFarmId;
    }

    if (!mounted) return;

    if (farmId == null || farmId.isEmpty) {
      Get.snackbar(
        'Farm Required',
        'Please create your farm profile first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await Get.to(
      () => FarmerAddEditFieldScreen(
        farmId: farmId,
      ),
    );

    if (result == true) {
      await controller.loadFields(farmId);
    }
  }

  // ============================================================
  // EDIT FIELD
  // ============================================================

  Future<void> _openEditField(FieldModel field) async {
    final farmId = currentFarmId;

    if (farmId == null || farmId.isEmpty) {
      Get.snackbar(
        'Farm Required',
        'Farm information is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await Get.to(
      () => FarmerAddEditFieldScreen(
        farmId: farmId,
        fieldId: field.id,
      ),
    );

    if (result == true) {
      await controller.loadFields(farmId);
    }
  }

  // ============================================================
  // DELETE FIELD
  // ============================================================

  Future<void> _deleteField(FieldModel field) async {
    final farmId = currentFarmId;

    if (farmId == null || farmId.isEmpty) {
      Get.snackbar(
        'Farm Required',
        'Farm information is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Field'),
        content: Text(
          'Are you sure you want to delete "${field.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await controller.deleteField(
      farmId: farmId,
      fieldId: field.id,
    );

    if (success) {
      Get.snackbar(
        'Deleted',
        'Field deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        controller.errorMessage.value.isEmpty
            ? 'Unable to delete field.'
            : controller.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerDesign.background,

      appBar: AppBar(
        title: const Text('Fields'),
        backgroundColor: FarmerDesign.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      body: Obx(() {
        final farm = farmController.farm.value;
        final fields = controller.fields;
        final loading = controller.isLoading.value;
        final error = controller.errorMessage.value;

        if (farm == null && farmController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (farm == null) {
          return _MessageState(
            icon: Icons.agriculture_outlined,
            title: 'No Farm Found',
            message:
                'Create your farm profile before adding fields.',
            actionText: 'Refresh',
            onAction: _loadFields,
          );
        }

        if (loading && fields.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (error.isNotEmpty && fields.isEmpty) {
          return _MessageState(
            icon: Icons.error_outline,
            title: 'Unable to Load Fields',
            message: error,
            actionText: 'Try Again',
            onAction: _loadFields,
          );
        }

        if (fields.isEmpty) {
          return _MessageState(
            icon: Icons.grid_view_outlined,
            title: 'No Fields Yet',
            message:
                'Add your first field to start managing your farm.',
            actionText: 'Add Field',
            onAction: _openAddField,
          );
        }

        return RefreshIndicator(
          onRefresh: _loadFields,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: fields.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final field = fields[index];

              return _FieldCard(
                field: field,
                onTap: () => _openEditField(field),
                onDelete: () => _deleteField(field),
              );
            },
          ),
        );
      }),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddField,
        backgroundColor: FarmerDesign.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Field'),
      ),
    );
  }
}

// ============================================================
// FIELD CARD
// ============================================================

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.field,
    required this.onTap,
    required this.onDelete,
  });

  final FieldModel field;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: FarmerDesign.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: FarmerDesign.primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    if (field.area != null)
                      Text(
                        'Area: ${field.area}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),

                    if (field.soilType != null &&
                        field.soilType!.isNotEmpty)
                      Text(
                        'Soil: ${field.soilType}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onTap();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MESSAGE STATE
// ============================================================

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionText,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: FarmerDesign.primary,
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            FilledButton(
              onPressed: onAction,
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }
}