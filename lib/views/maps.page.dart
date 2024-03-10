import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class MapsPage extends StatefulWidget {
  final String transactionId;
  final String deliveryLocation;
  MapsPage({
    required this.transactionId,
    required this.deliveryLocation,
  });

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late String deliveryLocation;
  List<LatLng> routePoints = [];
  bool isLoading = true;
  late Timer timer;
  Map<String, dynamic>? riderData;

  @override
  void initState() {
    super.initState();

    fetchData(widget.transactionId);

    deliveryLocation = widget.deliveryLocation;

    timer = Timer.periodic(const Duration(seconds: 3),
        (Timer t) => fetchData(widget.transactionId));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'In Transit',
          style: TextStyle(
            color: const Color(0xFF050404).withOpacity(0.9),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: const Color(0xFF050404).withOpacity(0.8),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black,
            height: 0.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (isLoading)
                Center(
                  child: LoadingAnimationWidget.flickr(
                    leftDotColor: const Color(0xFF050404).withOpacity(0.8),
                    rightDotColor: const Color(0xFFd41111).withOpacity(0.8),
                    size: 40,
                  ),
                )
              else
                buildMap(),
            ],
          ),
          RiderDetails(riderDetails: riderData),
          LocationDestination(deliveryLocation: deliveryLocation),
        ],
      ),
    );
  }

  Widget buildMap() {
    double minLat = double.infinity;
    double maxLat = double.negativeInfinity;
    double minLng = double.infinity;
    double maxLng = double.negativeInfinity;

    for (LatLng point in routePoints) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }
    LatLng center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    double zoom = calculateZoom(minLat, maxLat, minLng, maxLng);

    return Expanded(
      child: FlutterMap(
        options: MapOptions(
          center: center,
          zoom: zoom,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://maps.geoapify.com/v1/tile/klokantech-basic/{z}/{x}/{y}.png?apiKey=3e4c0fcabf244021845380f543236e29',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 9.0,
                color: Colors.red,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 60.0,
                point:
                    routePoints.isNotEmpty ? routePoints.first : LatLng(0, 0),
                builder: (ctx) => CustomMarker(
                  iconUrl:
                      'https://raw.githubusercontent.com/mrHeinrichh/J.E-Moral-cdn/main/assets/png/motorcycle-pin.png',
                ),
                anchorPos: AnchorPos.align(AnchorAlign.top),
              ),
              Marker(
                width: 70.0,
                height: 40.0,
                point: routePoints.isNotEmpty ? routePoints.last : LatLng(0, 0),
                builder: (ctx) => Container(
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.green,
                    size: 40.0,
                  ),
                ),
                anchorPos: AnchorPos.align(AnchorAlign.top),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> fetchData([String? transactionId]) async {
    if (!isLoading) {
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/transactions/$transactionId',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(response.body);

        final String startLatitude = data['data']['lat'];
        final String startLongitude = data['data']['long'];
        print(
            'START LOCATION Latitude: $startLatitude, Longitude: $startLongitude');

        await getAddressCoordinates(
          deliveryLocation,
          startLatitude,
          startLongitude,
        );

        final String riderId = data['data']['rider'];
        await fetchRiderDetails(riderId);

        setState(() {
          isLoading = false;
        });
      } else {
        print('Failed to load additional data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching additional data: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> fetchRiderDetails(String riderId) async {
    try {
      final riderResponse = await http.get(
        Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/users/$riderId',
        ),
      );

      if (riderResponse.statusCode == 200) {
        setState(() {
          riderData = jsonDecode(riderResponse.body);
        });
        print('Rider details: $riderData');
      } else {
        print('Failed to load rider details: ${riderResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching rider details: $e');
    }
  }

  Future<void> getAddressCoordinates(
      String address, String startLatitude, String startLongitude) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.geoapify.com/v1/geocode/search?text=$address&apiKey=3e4c0fcabf244021845380f543236e29',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final double latitude = data['features'][0]['properties']['lat'];
        final double longitude = data['features'][0]['properties']['lon'];

        print('END LOCATION Latitude: $latitude, Longitude: $longitude');

        await getRoutingInformation(
            '$startLatitude,$startLongitude', '$latitude,$longitude');
      } else {
        print('Failed to get coordinates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting coordinates: $e');
    }
  }

  Future<void> getRoutingInformation(
      String startCoordinates, String endCoordinates) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.geoapify.com/v1/routing?waypoints=$startCoordinates%7C$endCoordinates&mode=motorcycle&apiKey=3e4c0fcabf244021845380f543236e29',
        ),
      );

      print('Start Coordinates: $startCoordinates');
      print('End Coordinates: $endCoordinates');

      if (response.statusCode == 200) {
        final Map<String, dynamic> routingData = jsonDecode(response.body);
        print('Routing Information: $routingData');

        parseWaypoints(routingData);
      } else {
        print('Failed to get routing information: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting routing information: $e');
    }
  }

  void parseWaypoints(Map<String, dynamic> routingData) {
    try {
      routePoints.clear();

      List<dynamic>? segments =
          routingData['features']?[0]['geometry']['coordinates'];

      if (segments != null) {
        for (var segment in segments) {
          List<LatLng> segmentPoints = [];
          for (var coordinate in segment) {
            if (coordinate.length >= 2) {
              double latitude = coordinate[1]?.toDouble() ?? 0.0;
              double longitude = coordinate[0]?.toDouble() ?? 0.0;
              segmentPoints.add(LatLng(latitude, longitude));
            }
          }
          routePoints.addAll(segmentPoints);
        }
      }

      setState(() {});
    } catch (e) {
      print('Error parsing waypoints: $e');
    }
  }
}

class CustomMarker extends StatelessWidget {
  final String iconUrl;

  CustomMarker({required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(iconUrl, width: 40.0, height: 40.0),
    );
  }
}

double calculateZoom(
    double minLat, double maxLat, double minLng, double maxLng) {
  const double paddingFactor = 1.1;
  double latRange = (maxLat - minLat) * paddingFactor;
  double lngRange = (maxLng - minLng) * paddingFactor;

  double diagonal = math.sqrt(latRange * latRange + lngRange * lngRange);

  print('Diagonal: $diagonal');

  if (diagonal != 0) {
    double zoom =
        (math.log(360.0 / 256.0 * (EarthRadius * math.pi) / diagonal) /
            math.ln2);

    print('Calculated Zoom: $zoom');

    return zoom.isFinite ? zoom.floorToDouble() : 10.0;
  } else {
    return 0.0;
  }
}

const double EarthRadius = 150;

class RiderDetails extends StatelessWidget {
  final Map<String, dynamic>? riderDetails;

  RiderDetails({required this.riderDetails});

  Future<void> _launchCaller(String contactNumber) async {
    final url = 'tel:$contactNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (riderDetails != null && riderDetails!['status'] == 'success') {
      final Map<String, dynamic> userData = riderDetails!['data'][0];

      return Positioned(
        bottom: 20,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            width: 375.0,
            height: 250.0,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Rider Details',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage('${userData['image']}'),
                  radius: 40.0,
                ),
                const SizedBox(height: 8.0),
                Text('Name: ${userData['name']}'),
                Text('Mobile Number: ${userData['contactNumber']}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _launchCaller(userData['contactNumber']);
                      },
                      child: const Text('Call Driver'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final contactNumber = userData['contactNumber'];
                        if (await canLaunch('sms:$contactNumber')) {
                          await launch('sms:$contactNumber');
                        } else {
                          showCustomOverlay(
                              context, 'Unable to launch messaging app');
                        }
                      },
                      child: const Text('Message'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Positioned(
        bottom: 20,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            width: 350.0,
            height: 200.0,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rider Details',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text('Unable to fetch rider details'),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class LocationDestination extends StatelessWidget {
  final String deliveryLocation;

  LocationDestination({required this.deliveryLocation});

  String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength) + '\n' + text.substring(maxLength);
    }
  }

  @override
  Widget build(BuildContext context) {
    final truncatedLocation = truncateText(deliveryLocation, 40);

    return Positioned(
      top: 1,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Container(
            width: 385.0,
            height: 70.0,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(truncatedLocation,
                    style: const TextStyle(
                        fontSize: 12.0, fontWeight: FontWeight.bold)),
                Image.network(
                  'https://raw.githubusercontent.com/mrHeinrichh/J.E-Moral-cdn/main/assets/png/location-arrow-circle-icon.png', // Replace with your image URL
                  width: 30.0,
                  height: 30.0,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showCustomOverlay(BuildContext context, String message) {
  final overlay = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.5,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFd41111).withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  Overlay.of(context)!.insert(overlay);

  Future.delayed(const Duration(seconds: 2), () {
    overlay.remove();
  });
}
