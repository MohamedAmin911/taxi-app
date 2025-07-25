import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_app/bloc/auth/auth_cubit.dart';
import 'package:taxi_app/bloc/home/home_cubit.dart';
import 'package:taxi_app/bloc/home/home_states.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadMap(),
      child: Scaffold(
        drawer: _buildAppDrawer(),
        body: Builder(builder: (context) {
          return BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return Stack(
                children: [
                  // --- Google Map ---
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      // Default location, e.g., Cairo
                      target: LatLng(30.0444, 31.2357),
                      zoom: 12,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: (controller) {
                      context.read<HomeCubit>().onMapCreated(controller);
                    },
                    markers: state is HomeMapReady ? state.markers : {},
                  ),

                  // --- Loading Indicator ---
                  if (state is HomeLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),

                  // --- Error Message ---
                  if (state is HomeError)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.black.withOpacity(0.7),
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // --- UI Elements on Top of the Map ---

                  // --- Top Bar with Menu Icon ---
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () {
                                // Open Drawer
                                Scaffold.of(context).openDrawer();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- "Where to?" Panel at the Bottom ---
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildWhereToPanel(),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildWhereToPanel() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Placeholder for the destination search bar
            InkWell(
              onTap: () {
                // TODO: Navigate to search screen
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.black54),
                    SizedBox(width: 12),
                    Text(
                      "Where to?",
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder for saved locations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSavedLocationButton(Icons.home, "Home"),
                _buildSavedLocationButton(Icons.work, "Work"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSavedLocationButton(IconData icon, String label) {
    return InkWell(
      onTap: () {
        // TODO: Handle saved location tap
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAppDrawer() {
    // A Builder is used here to ensure the context has a Scaffold ancestor
    return Builder(builder: (context) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Taxi App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                // TODO: Navigate to Profile Screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payment'),
              onTap: () {
                // TODO: Navigate to Payment Screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Ride History'),
              onTap: () {
                // TODO: Navigate to Ride History Screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                // Call the signOut method from the AuthCubit
                context.read<AuthCubit>().signOut();
              },
            ),
          ],
        ),
      );
    });
  }
}
