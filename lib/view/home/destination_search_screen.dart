import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:taxi_app/common/api_keys.dart';

import 'package:uuid/uuid.dart';

class DestinationSearchScreen extends StatefulWidget {
  final LatLng currentUserPosition;
  const DestinationSearchScreen({super.key, required this.currentUserPosition});

  @override
  State<DestinationSearchScreen> createState() =>
      _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends State<DestinationSearchScreen> {
  final _searchController = TextEditingController();
  final _places = GoogleMapsPlaces(apiKey: KapiKeys.googeleMapsApiKey);
  List<Prediction> _predictions = [];
  String _sessionToken = const Uuid().v4();

  void _onSearchChanged(String input) async {
    if (input.trim().isEmpty) {
      setState(() => _predictions = []);
      return;
    }

    final response = await _places.autocomplete(
      input,
      sessionToken: _sessionToken,
      location: Location(
          lat: widget.currentUserPosition.latitude,
          lng: widget.currentUserPosition.longitude),
      radius: 30000, // Bias search within a 30km radius
      language: "en",
      components: [
        Component(Component.country, "eg")
      ], // Strongly prefer results in Egypt
    );

    if (mounted && response.isOkay) {
      setState(() => _predictions = response.predictions);
    }
  }

  void _onPlaceSelected(String placeId) async {
    final response =
        await _places.getDetailsByPlaceId(placeId, sessionToken: _sessionToken);

    if (mounted && response.isOkay) {
      final location = response.result.geometry?.location;
      final address = response.result.formattedAddress;

      if (location != null && address != null) {
        final result = {
          'address': address,
          'location': LatLng(location.lat, location.lng)
        };
        Navigator.of(context).pop(result);
      }
    }
    // A session token is used for one search session and must be regenerated.
    setState(() => _sessionToken = const Uuid().v4());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _places.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Destination")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Search for a location...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(prediction.structuredFormatting?.mainText ?? ''),
                  subtitle: Text(
                      prediction.structuredFormatting?.secondaryText ?? ''),
                  onTap: () => _onPlaceSelected(prediction.placeId!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
