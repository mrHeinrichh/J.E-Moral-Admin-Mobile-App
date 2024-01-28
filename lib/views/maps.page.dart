import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class MapsPage extends StatefulWidget {
  final String transactionId;
  final String deliveryLocation;
  MapsPage({
    required this.transactionId,
    required this.deliveryLocation, // Add this line
  });

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late String deliveryLocation;
  List<LatLng> routePoints = [];
  bool isLoading = true;
  late Timer timer; // Declare a Timer variable
  Map<String, dynamic>? riderData; // Add this line to store rider data

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      fetchData(widget.transactionId);
    }
    deliveryLocation = widget.deliveryLocation;

    timer = Timer.periodic(
      Duration(seconds: 10),
      (Timer t) {
        fetchData(widget.transactionId);
      },
    );
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
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'In Transit',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (isLoading)
                Center(child: CircularProgressIndicator())
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
                  child: Icon(
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

        // Call the method to convert the address to coordinates
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
        // setState(() {
        //   isLoading = false; // Set isLoading to false in case of an error
        // });
      }
    } catch (e) {
      print('Error fetching additional data: $e');
      setState(() {
        isLoading = false; // Set isLoading to false in case of an error
      });
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

        // Now, you can use the start and end coordinates to fetch routing information
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

        // Try to parse waypoints
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
      routePoints.clear(); // Clear existing points before adding new ones

      List<dynamic> segments =
          routingData['features'][0]['geometry']['coordinates'];

      for (var segment in segments) {
        List<LatLng> segmentPoints = [];
        for (var coordinate in segment) {
          double latitude = coordinate[1].toDouble();
          double longitude = coordinate[0].toDouble();
          segmentPoints.add(LatLng(latitude, longitude));
        }
        routePoints.addAll(segmentPoints);
      }

      // Only update the relevant parts of the UI
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
  const double paddingFactor = 1.1; // Adjust this to add padding around markers
  double latRange = (maxLat - minLat) * paddingFactor;
  double lngRange = (maxLng - minLng) * paddingFactor;

  double diagonal = math.sqrt(latRange * latRange + lngRange * lngRange);

  // 256 is the default tile size
  double zoom =
      (math.log(360.0 / 256.0 * (EarthRadius * math.pi) / diagonal) / math.ln2)
          .floorToDouble();

  return zoom;
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
      // Handle the case where launching is not supported
      print('Could not launch $url');
      // You can show a dialog, display a toast, or take any other appropriate action.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if riderDetails is not null and contains the necessary data
    if (riderDetails != null && riderDetails!['status'] == 'success') {
      final Map<String, dynamic> userData = riderDetails!['data']['user'];

      return Positioned(
        bottom: 20,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            width: 375.0,
            height: 250.0,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Rider Details',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage('${userData['image']}'),
                  radius: 40.0, // Adjust the radius as needed
                ),
                SizedBox(height: 8.0),
                Text('Name: ${userData['name']}'),
                Text('Contact Number: ${userData['contactNumber']}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _launchCaller(userData['contactNumber']);
                      },
                      child: Text('Call Driver'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final contactNumber = userData['contactNumber'];
                        if (await canLaunch('sms:$contactNumber')) {
                          await launch('sms:$contactNumber');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Unable to launch messaging app'),
                            ),
                          );
                        }
                      },
                      child: Text('Message'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // If riderDetails is null or status is not 'success', display a placeholder or handle the error
      return Positioned(
        bottom: 20,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            width: 350.0,
            height: 200.0,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rider Details',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text('fetching rider details'),
                // Handle error message or display a placeholder
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
      // Add a newline character after the specified length
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
            width: 385.0, // Adjust the width as needed
            height: 70.0, // Adjust the height as needed
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(truncatedLocation,
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
                Image.network(
                  'https://raw.githubusercontent.com/mrHeinrichh/J.E-Moral-cdn/main/assets/png/location-arrow-circle-icon.png', // Replace with your image URL
                  width: 30.0, // Adjust the width as needed
                  height: 30.0, // Adjust the height as needed
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
