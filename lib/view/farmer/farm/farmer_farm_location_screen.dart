import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:phum_kasikors/controller/farmer/farm_location_controller.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerFarmLocationScreen
    extends StatelessWidget {
  const FarmerFarmLocationScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.location,
  });

  final double? latitude;
  final double? longitude;
  final String? location;

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(
      FarmLocationController(
        initialLatitude: latitude,
        initialLongitude: longitude,
        initialAddress: location,
      ),
    );

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
          'Farm Location',
          style: FarmerDesign.heading2,
        ),
      ),
      body: Stack(
        children: [
          Obx(
            () => GoogleMap(
              initialCameraPosition:
                  CameraPosition(
                target:
                    controller
                        .pickedLocation
                        .value,
                zoom: 16,
              ),
              onMapCreated:
                  controller
                      .onMapCreated,
              onTap:
                  controller
                      .onPinMoved,
              myLocationButtonEnabled:
                  false,
              zoomControlsEnabled:
                  false,
              compassEnabled: true,
              markers: {
                Marker(
                  markerId:
                      const MarkerId(
                    'farm_location',
                  ),
                  position:
                      controller
                          .pickedLocation
                          .value,
                  draggable: true,
                  onDragEnd:
                      controller
                          .onPinMoved,
                ),
              },
            ),
          ),

          // TOP INFORMATION
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _LocationInfoCard(
              controller:
                  controller,
            ),
          ),

          // CURRENT LOCATION BUTTON
          Positioned(
            right: 16,
            bottom: 170,
            child: FloatingActionButton(
              heroTag:
                  'farm-location-map',
              backgroundColor:
                  Colors.white,
              foregroundColor:
                  FarmerDesign.primary,
              onPressed: () {
                Get.snackbar(
                  'Current Location',
                  'Use your device location from the Location Setup screen.',
                  snackPosition:
                      SnackPosition.BOTTOM,
                  margin:
                      const EdgeInsets.all(
                    16,
                  ),
                );
              },
              child: const Icon(
                Icons.my_location_rounded,
              ),
            ),
          ),

          // BOTTOM CONFIRM AREA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                24,
              ),
              decoration:
                  const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(
                    28,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Color(0x18000000),
                    blurRadius: 18,
                    offset:
                        Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Obx(
                  () => Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'Move the pin to your farm',
                        style:
                            TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        controller
                                    .formattedAddress
                                    .value
                                    .isNotEmpty
                            ? controller
                                .formattedAddress
                                .value
                            : 'Tap anywhere on the map to select your farm location.',
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF666666,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width:
                            double.infinity,
                        height: 52,
                        child:
                            FilledButton(
                          onPressed:
                              controller
                                          .latitude
                                          .value ==
                                      null ||
                                  controller
                                          .longitude
                                          .value ==
                                      null
                              ? null
                              : () {
                                  Get.back(
                                    result:
                                        controller
                                            .locationResult,
                                  );
                                },
                          style:
                              FilledButton.styleFrom(
                            backgroundColor:
                                FarmerDesign
                                    .primary,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                14,
                              ),
                            ),
                          ),
                          child:
                              const Text(
                            'Use This Location',
                            style:
                                TextStyle(
                              fontSize:
                                  16,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationInfoCard
    extends StatelessWidget {
  const _LocationInfoCard({
    required this.controller,
  });

  final FarmLocationController
      controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Material(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        elevation: 3,
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                    BoxDecoration(
                  color: FarmerDesign
                      .primaryLight,
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color:
                      FarmerDesign.primary,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected location',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    if (controller
                        .isDetectingAddress
                        .value)
                      const Text(
                        'Detecting address...',
                        style:
                            TextStyle(
                          color:
                              Colors.grey,
                        ),
                      )
                    else
                      Text(
                        controller
                                    .formattedAddress
                                    .value
                                    .isNotEmpty
                            ? controller
                                .formattedAddress
                                .value
                            : 'No address detected',
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}