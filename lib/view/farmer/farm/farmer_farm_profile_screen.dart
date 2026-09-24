import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:phum_kasikors/controller/farmer/farm_controller.dart';
import 'package:phum_kasikors/model/farmer/farm_model.dart';
import 'package:phum_kasikors/view/farmer/farm/farmer_farm_location_screen.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';


class FarmerFarmScreen extends StatelessWidget {
  const FarmerFarmScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.find<FarmController>();

    return Scaffold(
      backgroundColor:
          FarmerDesign.background,
      appBar: AppBar(
        backgroundColor:
            FarmerDesign.background,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Farm',
          style: FarmerDesign.heading2,
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed:
                  controller.isLoading.value
                      ? null
                      : controller.loadFarm,
              icon: const Icon(
                Icons.refresh_rounded,
                color:
                    FarmerDesign.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value &&
              controller.farm.value == null) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color:
                    FarmerDesign.primary,
              ),
            );
          }

          final farm =
              controller.farm.value;

          if (farm == null) {
            return _EmptyFarmState(
              controller: controller,
            );
          }

          return RefreshIndicator(
            color:
                FarmerDesign.primary,
            onRefresh:
                controller.loadFarm,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                32,
              ),
              children: [
                _FarmHero(
                  farm: farm,
                  onEdit: () =>
                      _showEditFarmDialog(
                    context,
                    controller,
                    farm,
                  ),
                ),
                const SizedBox(height: 18),
                _FarmDetailsCard(
                  farm: farm,
                ),
                const SizedBox(height: 16),
                _FarmDescriptionCard(
                  farm: farm,
                ),
                const SizedBox(height: 16),
                _FarmLocationCard(
                  farm: farm,
                ),
                const SizedBox(height: 24),
                _DangerZone(
                  onDelete: () =>
                      _confirmDelete(
                    context,
                    controller,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // EDIT FARM
  // ============================================================

  Future<void> _showEditFarmDialog(
    BuildContext context,
    FarmController controller,
    FarmModel farm,
  ) async {
    final nameController =
        TextEditingController(
      text: farm.farmName,
    );

    final descriptionController =
        TextEditingController(
      text: farm.description ?? '',
    );

    final sizeController =
        TextEditingController(
      text: farm.farmSize?.toString() ?? '',
    );

    String? farmingMethod =
        farm.farmingMethod;

    String selectedLocation =
        farm.location ?? '';

    double? selectedLatitude =
        farm.latitude;

    double? selectedLongitude =
        farm.longitude;

    final result =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setState,
          ) {
            return AlertDialog(
              title:
                  const Text('Edit Farm'),
              content:
                  SingleChildScrollView(
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
                        labelText:
                            'Farm name',
                        prefixIcon:
                            Icon(
                          Icons
                              .agriculture_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    TextField(
                      controller:
                          descriptionController,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Description',
                        prefixIcon:
                            Icon(
                          Icons
                              .description_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ------------------------------------------------
                    // LOCATION PICKER
                    // ------------------------------------------------

                    InkWell(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                      onTap: () async {
                        final result =
                            await Get.to<
                                Map<String,
                                    dynamic>>(
                          () =>
                              FarmerFarmLocationScreen(
                            latitude:
                                selectedLatitude,
                            longitude:
                                selectedLongitude,
                            location:
                                selectedLocation,
                          ),
                        );

                        if (result == null) {
                          return;
                        }

                        final lat =
                            result[
                                'latitude'];

                        final lng =
                            result[
                                'longitude'];

                        final address =
                            result[
                                'location'];

                        setState(() {
                          if (lat is num) {
                            selectedLatitude =
                                lat.toDouble();
                          }

                          if (lng is num) {
                            selectedLongitude =
                                lng.toDouble();
                          }

                          if (address
                              is String) {
                            selectedLocation =
                                address.trim();
                          }
                        });
                      },
                      child:
                          Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .all(15),
                        decoration:
                            BoxDecoration(
                          border: Border.all(
                            color:
                                const Color(
                              0xFFD8DDD6,
                            ),
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration:
                                  BoxDecoration(
                                color: FarmerDesign
                                    .primaryLight,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .location_on_rounded,
                                color:
                                    FarmerDesign
                                        .primary,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  const Text(
                                    'Farm location',
                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    selectedLocation
                                            .isNotEmpty
                                        ? selectedLocation
                                        : 'Tap to choose location on map',
                                    maxLines:
                                        2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        TextStyle(
                                      color:
                                          selectedLocation
                                                  .isNotEmpty
                                              ? FarmerDesign
                                                  .secondaryText
                                              : Colors
                                                  .grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons
                                  .arrow_forward_ios_rounded,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (selectedLatitude !=
                            null &&
                        selectedLongitude !=
                            null) ...[
                      const SizedBox(
                        height: 8,
                      ),
                      Align(
                        alignment:
                            Alignment.centerLeft,
                        child: Text(
                          '${selectedLatitude!.toStringAsFixed(6)}, '
                          '${selectedLongitude!.toStringAsFixed(6)}',
                          style:
                              FarmerDesign
                                  .caption,
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 14,
                    ),

                    TextField(
                      controller:
                          sizeController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Farm size (ha)',
                        prefixIcon:
                            Icon(
                          Icons
                              .straighten_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    DropdownButtonFormField<
                        String>(
                      initialValue:
                          farmingMethod,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Farming method',
                        prefixIcon:
                            Icon(
                          Icons
                              .eco_outlined,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value:
                              'Organic',
                          child:
                              Text(
                            'Organic',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'Conventional',
                          child:
                              Text(
                            'Conventional',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'Mixed',
                          child:
                              Text(
                            'Mixed',
                          ),
                        ),
                      ],
                      onChanged:
                          (value) {
                        setState(() {
                          farmingMethod =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                    false,
                  ),
                  child:
                      const Text('Cancel'),
                ),

                Obx(
                  () => FilledButton(
                    onPressed:
                        controller
                                .isSaving
                                .value
                            ? null
                            : () async {
                                final success =
                                    await controller
                                        .updateFarm(
                                  farmId:
                                      farm.id,
                                  farmName:
                                      nameController
                                          .text,
                                  description:
                                      descriptionController
                                          .text,
                                  location:
                                      selectedLocation,
                                  latitude:
                                      selectedLatitude,
                                  longitude:
                                      selectedLongitude,
                                  farmSize:
                                      double.tryParse(
                                    sizeController
                                        .text
                                        .trim(),
                                  ),
                                  farmingMethod:
                                      farmingMethod,
                                  coverImage:
                                      farm.coverImage,
                                );

                                if (!success) {
                                  if (dialogContext
                                      .mounted) {
                                    Get.snackbar(
                                      'Update failed',
                                      controller
                                          .errorMessage
                                          .value,
                                      snackPosition:
                                          SnackPosition
                                              .BOTTOM,
                                      margin:
                                          const EdgeInsets
                                              .all(
                                        16,
                                      ),
                                      duration:
                                          const Duration(
                                        seconds: 4,
                                      ),
                                    );
                                  }

                                  return;
                                }

                                if (dialogContext
                                    .mounted) {
                                  Navigator.pop(
                                    dialogContext,
                                    true,
                                  );
                                }
                              },
                    child:
                        controller
                                .isSaving
                                .value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'Save',
                              ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    sizeController.dispose();

    if (result == true) {
      Get.snackbar(
        'Farm updated',
        'Your farm information has been saved.',
        snackPosition:
            SnackPosition.BOTTOM,
        margin:
            const EdgeInsets.all(16),
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _confirmDelete(
    BuildContext context,
    FarmController controller,
  ) async {
    final confirmed =
        await Get.dialog<bool>(
      AlertDialog(
        title:
            const Text('Delete farm?'),
        content:
            const Text(
          'This will remove your farm and its related farming data.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Get.back(
              result: false,
            ),
            child:
                const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Get.back(
              result: true,
            ),
            style:
                FilledButton.styleFrom(
              backgroundColor:
                  Colors.red,
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
        await controller.deleteFarm();

    if (success) {
      Get.snackbar(
        'Farm deleted',
        'Your farm has been removed.',
        snackPosition:
            SnackPosition.BOTTOM,
        margin:
            const EdgeInsets.all(16),
      );
    } else {
      Get.snackbar(
        'Unable to delete farm',
        controller.errorMessage.value,
        snackPosition:
            SnackPosition.BOTTOM,
        margin:
            const EdgeInsets.all(16),
      );
    }
  }
}

// ================================================================
// HERO
// ================================================================

class _FarmHero extends StatelessWidget {
  const _FarmHero({
    required this.farm,
    required this.onEdit,
  });

  final FarmModel farm;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(22),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            FarmerDesign.primaryDark,
            FarmerDesign.primary,
          ],
        ),
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x25000000),
            blurRadius: 16,
            offset:
                Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration:
                BoxDecoration(
              color:
                  Colors.white.withValues(
                alpha: 0.16,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child:
                const Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  farm.farmName,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Colors.white,
                  ),
                ),
                if (farm.location !=
                        null &&
                    farm.location!
                        .isNotEmpty) ...[
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    farm.location!,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xD9FFFFFF,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            style:
                IconButton.styleFrom(
              backgroundColor:
                  Colors.white
                      .withValues(
                alpha: 0.14,
              ),
              foregroundColor:
                  Colors.white,
            ),
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// DETAILS
// ================================================================

class _FarmDetailsCard
    extends StatelessWidget {
  const _FarmDetailsCard({
    required this.farm,
  });

  final FarmModel farm;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const _Title(
            icon:
                Icons.agriculture_outlined,
            title:
                'Farm information',
          ),
          const SizedBox(
            height: 14,
          ),
          _Row(
            icon:
                Icons.straighten_outlined,
            title:
                'Farm size',
            value:
                farm.farmSizeLabel,
          ),
          _Row(
            icon:
                Icons.eco_outlined,
            title:
                'Farming method',
            value:
                farm.farmingMethodLabel,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// DESCRIPTION
// ================================================================

class _FarmDescriptionCard
    extends StatelessWidget {
  const _FarmDescriptionCard({
    required this.farm,
  });

  final FarmModel farm;

  @override
  Widget build(BuildContext context) {
    final description =
        farm.description
                ?.trim() ??
            '';

    return _Card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const _Title(
            icon:
                Icons.description_outlined,
            title:
                'Description',
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            description.isEmpty
                ? 'No farm description added yet.'
                : description,
            style:
                FarmerDesign.bodyLarge
                    .copyWith(
              height: 1.5,
              color:
                  FarmerDesign
                      .secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// LOCATION
// ================================================================

class _FarmLocationCard
    extends StatelessWidget {
  const _FarmLocationCard({
    required this.farm,
  });

  final FarmModel farm;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const _Title(
            icon:
                Icons.location_on_outlined,
            title:
                'Farm location',
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            farm.location
                        ?.trim()
                        .isNotEmpty ==
                    true
                ? farm.location!
                : 'Location not specified',
            style:
                FarmerDesign.bodyMedium,
          ),
          if (farm.latitude !=
                  null &&
              farm.longitude !=
                  null) ...[
            const SizedBox(
              height: 8,
            ),
            Text(
              '${farm.latitude!.toStringAsFixed(6)}, '
              '${farm.longitude!.toStringAsFixed(6)}',
              style:
                  FarmerDesign.caption,
            ),
          ],
        ],
      ),
    );
  }
}

// ================================================================
// EMPTY FARM
// ================================================================

class _EmptyFarmState
    extends StatelessWidget {
  const _EmptyFarmState({
    required this.controller,
  });

  final FarmController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration:
                  BoxDecoration(
                color:
                    FarmerDesign.primaryLight,
                borderRadius:
                    BorderRadius.circular(
                  28,
                ),
              ),
              child:
                  const Icon(
                Icons.agriculture_rounded,
                size: 46,
                color:
                    FarmerDesign.primary,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'No farm found',
              style:
                  FarmerDesign.heading3,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              controller
                      .errorMessage
                      .value
                      .isNotEmpty
                  ? controller
                      .errorMessage
                      .value
                  : 'Create your farm profile to start managing your farming information.',
              textAlign:
                  TextAlign.center,
              style:
                  FarmerDesign.bodyMedium,
            ),
            const SizedBox(
              height: 20,
            ),
            FilledButton.icon(
              onPressed: () =>
                  _showCreateFarmDialog(
                context,
                controller,
              ),
              icon:
                  const Icon(Icons.add),
              label:
                  const Text(
                'Create Farm',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateFarmDialog(
    BuildContext context,
    FarmController controller,
  ) async {
    final nameController =
        TextEditingController();

    final sizeController =
        TextEditingController();

    final descriptionController =
        TextEditingController();

    String selectedLocation = '';
    double? selectedLatitude;
    double? selectedLongitude;

    String? farmingMethod;

    await Get.dialog(
      StatefulBuilder(
        builder: (
          context,
          setState,
        ) {
          return AlertDialog(
            title:
                const Text('Create Farm'),
            content:
                SingleChildScrollView(
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
                          'Farm name',
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),

                  // CREATE LOCATION
                  InkWell(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    onTap: () async {
                      final result =
                          await Get.to<
                              Map<String,
                                  dynamic>>(
                        () =>
                            const FarmerFarmLocationScreen(),
                      );

                      if (result == null) {
                        return;
                      }

                      setState(() {
                        if (result[
                                'latitude']
                            is num) {
                          selectedLatitude =
                              (result[
                                      'latitude']
                                  as num)
                              .toDouble();
                        }

                        if (result[
                                'longitude']
                            is num) {
                          selectedLongitude =
                              (result[
                                      'longitude']
                                  as num)
                              .toDouble();
                        }

                        if (result[
                                'location']
                            is String) {
                          selectedLocation =
                              result[
                                  'location'];
                        }
                      });
                    },
                    child: Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets
                              .all(14),
                      decoration:
                          BoxDecoration(
                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFD8DDD6,
                          ),
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons
                                .location_on_rounded,
                            color:
                                FarmerDesign
                                    .primary,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child:
                                Text(
                              selectedLocation
                                      .isNotEmpty
                                  ? selectedLocation
                                  : 'Choose farm location on map',
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons
                                .arrow_forward_ios_rounded,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  TextField(
                    controller:
                        sizeController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Farm size (ha)',
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  DropdownButtonFormField<
                      String>(
                    initialValue:
                        farmingMethod,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Farming method',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value:
                            'Organic',
                        child:
                            Text('Organic'),
                      ),
                      DropdownMenuItem(
                        value:
                            'Conventional',
                        child:
                            Text(
                          'Conventional',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'Mixed',
                        child:
                            Text('Mixed'),
                      ),
                    ],
                    onChanged:
                        (value) {
                      setState(() {
                        farmingMethod =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  TextField(
                    controller:
                        descriptionController,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Description',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Get.back(),
                child:
                    const Text('Cancel'),
              ),
              Obx(
                () => FilledButton(
                  onPressed:
                      controller
                              .isSaving
                              .value
                          ? null
                          : () async {
                              final success =
                                  await controller
                                      .createFarm(
                                farmName:
                                    nameController
                                        .text,
                                location:
                                    selectedLocation,
                                latitude:
                                    selectedLatitude,
                                longitude:
                                    selectedLongitude,
                                description:
                                    descriptionController
                                        .text,
                                farmSize:
                                    double.tryParse(
                                  sizeController
                                      .text
                                      .trim(),
                                ),
                                farmingMethod:
                                    farmingMethod,
                              );

                              if (!success) {
                                Get.snackbar(
                                  'Create failed',
                                  controller
                                      .errorMessage
                                      .value,
                                  snackPosition:
                                      SnackPosition
                                          .BOTTOM,
                                  margin:
                                      const EdgeInsets
                                          .all(
                                    16,
                                  ),
                                );
                                return;
                              }

                              Get.back();

                              Get.snackbar(
                                'Farm created',
                                'Your farm has been created successfully.',
                                snackPosition:
                                    SnackPosition
                                        .BOTTOM,
                                margin:
                                    const EdgeInsets
                                        .all(
                                  16,
                                ),
                              );
                            },
                  child:
                      controller
                              .isSaving
                              .value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'Create',
                            ),
                ),
              ),
            ],
          );
        },
      ),
    );

    nameController.dispose();
    sizeController.dispose();
    descriptionController.dispose();
  }
}

// ================================================================
// COMMON CARD
// ================================================================

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration:
          FarmerDesign.cardDecoration(
        radius:
            FarmerDesign.radiusLarge,
      ),
      child: child,
    );
  }
}

// ================================================================
// TITLE
// ================================================================

class _Title extends StatelessWidget {
  const _Title({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration:
              BoxDecoration(
            color:
                FarmerDesign.primaryLight,
            borderRadius:
                BorderRadius.circular(
              11,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
                FarmerDesign.primary,
          ),
        ),
        const SizedBox(
          width: 11,
        ),
        Text(
          title,
          style:
              FarmerDesign.heading4,
        ),
      ],
    );
  }
}

// ================================================================
// ROW
// ================================================================

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color:
                FarmerDesign.secondaryText,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              title,
              style:
                  FarmerDesign.caption,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  FarmerDesign.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// DANGER ZONE
// ================================================================

class _DangerZone
    extends StatelessWidget {
  const _DangerZone({
    required this.onDelete,
  });

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onDelete,
      style:
          OutlinedButton.styleFrom(
        foregroundColor:
            Colors.red,
        side:
            const BorderSide(
          color: Colors.red,
        ),
        minimumSize:
            const Size.fromHeight(
          52,
        ),
      ),
      icon:
          const Icon(
        Icons.delete_outline_rounded,
      ),
      label:
          const Text(
        'Delete Farm',
      ),
    );
  }
}