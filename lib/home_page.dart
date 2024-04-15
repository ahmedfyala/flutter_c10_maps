import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  CameraPosition? mylocation;
  StreamSubscription <LocationData>? streamLocation;

//29.9610721,31.2605734
  static const CameraPosition routeMaadi = CameraPosition(
      //bearing: 120.8334901395799,
      target: LatLng(29.9610721, 31.2605734),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  Set<Marker> markers = {};

  //[1,1,2,3,5,4,6]
  //{1,2,3,4,5,6}
  int index=0;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    streamLocation?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    canAccessLocation();
    return Scaffold(
      body: mylocation == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              markers: markers,
              onLongPress: (argument) {

              },
              onTap: (argument) {
                markers.add(Marker(markerId: MarkerId("user${index++}"),position: argument));
                setState(() {

                });

              },
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              cameraTargetBounds: CameraTargetBounds(
                LatLngBounds(
                    southwest: LatLng(22.0, 24.7),
                    northeast: LatLng(31.7, 36.9)),
              ),
              initialCameraPosition: mylocation!,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the route!'),
        icon: const Icon(Icons.ad_units),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(routeMaadi));
  }

  LocationData? locationData;

  Location location = new Location();

  canAccessLocation() async {
    bool permissionGranted = await isPermissionGranted();

    if (!permissionGranted) {
      return;
    }
    bool serviceEnabled = await isServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    locationData = await location.getLocation();
    location.changeSettings(
      distanceFilter: 5,
      interval: 1000 * 5,
      accuracy: LocationAccuracy.high,
    );

    streamLocation = location.onLocationChanged.listen((event) {
      locationData = event;
      mylocation = CameraPosition(
        target:
        LatLng(event.latitude ?? 0.0, event.longitude ?? 0.0),
        zoom: 18,
      );

      markers.add(Marker(
        markerId: MarkerId("mylocation"),
        position:
        LatLng(event.latitude ?? 0.0, event.longitude ?? 0.0),
      ));
      setState(() {
      });
    });

    setState(() {});

    print("lat${locationData?.latitude} -lon ${locationData?.longitude}");
  }

  PermissionStatus _permissionGranted = PermissionStatus.denied;

  Future<bool> isPermissionGranted() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }
    return _permissionGranted == PermissionStatus.granted;
  }

  bool serviceEnable = false;

  Future<bool> isServiceEnabled() async {
    serviceEnable = await location.serviceEnabled();
    if (!serviceEnable) {
      serviceEnable = await location.requestService();
    }
    return serviceEnable;
  }
}
