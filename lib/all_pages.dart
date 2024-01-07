import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:newmeals_api/all_page_items.dart';
import 'package:newmeals_api/classes.dart';

import 'Place.dart';

class AllPages extends StatefulWidget {
  AllPages({Key? key, this.meals}) : super(key: key);

  List<Datum>? meals;

  @override
  State<AllPages> createState() {
    return _AllPagesState();
  }
}

class _AllPagesState extends State<AllPages> {
  List<String> categoryFilters = ['Chicken', 'Pizza', 'Burger', 'Tea', 'Dosa'];
  String _responseBody = '';
  PlaceLocation? _pickedLocation;
  TextEditingController _searchController = TextEditingController();
  List<Datum>? _filteredMeals;

  @override
  void initState() {
    super.initState();
    _filteredMeals = widget.meals;
  }

  void _filterMeals(String query) {
    List<Datum>? filteredList;
    if (query.isEmpty) {
      filteredList = widget.meals;
    } else {
      filteredList = widget.meals
          ?.where((meal) =>
          meal.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredMeals = filteredList;
    });
  }


  Future<void> postData() async {
    final apiUrl = Uri.parse(
        'https://theoptimiz.com/restro/public/api/get_resturants');

    Map<String, dynamic> data = {
      'lat': 25.22,
      'lng': 45.32,
    };

    try {
      final http.Response response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final welcome = welcomeFromJson(response.body);

        setState(() {
          _responseBody = response.body;
          widget.meals = welcome.data;
        });
      } else {
        setState(() {
          _responseBody = 'Error: ${response.statusCode}';
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        _responseBody = 'Error: $error';
      });
    }
  }

  Future<void> _savePlace(
      double latitude, double longitude, String address) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=Api_key');

    final response = await http.get(url);
    final resData = json.decode(response.body);
    final addressFromAPI =
    resData['results'][0]['formatted_address'] as String?;
    print('Address: $addressFromAPI');

    setState(() {
      _pickedLocation = PlaceLocation(
          latitude: latitude,
          longitude: longitude,
          address: addressFromAPI ?? 'Unknown Address');
    });
    print('Address: $addressFromAPI');
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    print('Service Enabled: $serviceEnabled');
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    print('Permission Granted: $permissionGranted');
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    if (locationData != null &&
        locationData.latitude != null &&
        locationData.longitude != null) {
      final lat = 25.22; //locationData.latitude!;
      final lng = 45.32; // locationData.longitude!;
      final address = await _getAddressFromCoordinates(lat, lng);
      _savePlace(lat, lng, address);

      setState(() {
        _pickedLocation =
            PlaceLocation(latitude: lat, longitude: lng, address: address);
      });
    }
  }

  Future<String> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=Api_key');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final resData = json.decode(response.body);
      final results = resData['results'] as List<dynamic>;
      if (results.isNotEmpty) {
        return results[0]['formatted_address'];
      }
    }

    return 'Unknown Address';
  }

  String _selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    int currentTab = 0;
    final List<Widget> screens = [
      // Dashboard(), ........
    ];
    final PageStorageBucket bucket = PageStorageBucket();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_pickedLocation?.address ?? 'Choose your location'),
        actions: [IconButton(onPressed: _getCurrentLocation, icon: const Icon(Icons.location_on))],
      ),
      body: PageStorage(
        bucket: bucket,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, bottom: 14,),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  controller: _searchController,
                  onChanged: _filterMeals,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.name,
                  autocorrect: true,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search Food Items',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(21),
                      borderSide: BorderSide(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(21),
                      borderSide: BorderSide(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(21),
                      borderSide: BorderSide(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryFilters.length,
                itemBuilder: (context, index) {
                  String category = categoryFilters[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        // Apply your filtering logic based on the selected category here
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: _selectedCategory == category
                            ? Colors.red
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: _selectedCategory == category
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_filteredMeals != null && _filteredMeals!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredMeals!.length,
                  itemBuilder: (context, index) {
                    final meal = _filteredMeals![index];
                    return RestaurantItem(meal: meal);
                  },
                ),
              )
            else
              Center(child: Text('No Record found')),
            if (_filteredMeals == null || _filteredMeals!.isEmpty)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    postData();
                  },
                  icon: Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Transform.scale(
        scale: 1.2,
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          onPressed: () {},
          child: Icon(Icons.qr_code_scanner_outlined, color: Colors.white,),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Transform.scale(
        scale: 1,
        child: BottomAppBar(
          notchMargin: 10,
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentTab = 0;
                        });
                      },
                      child: Container(
                        height: 50,
                        child: MaterialButton(
                          minWidth: 40,
                          onPressed: () {
                            setState(() {
                              currentTab = 0;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.dashboard,
                                color: currentTab == 0 ? Colors.red : Colors.red[300],),
                              Text('Home', style: TextStyle(color: currentTab == 0 ? Colors.red : Colors.red[300],
                                  fontSize: 11),)
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      child: MaterialButton(
                        minWidth: 40,
                        onPressed: () {
                          setState(() {
                            currentTab = 1;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_settings,
                              color: currentTab == 1 ? Colors.red : Colors.red[300],),
                            Text('Watch list', style: TextStyle(color: currentTab == 1 ? Colors.red : Colors.red[300],
                                fontSize: 11),),
                            if (currentTab == 1)
                              Text('Watch list', style: TextStyle(color: currentTab == 1 ? Colors.red : Colors.red[300],),)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      child: MaterialButton(
                        minWidth: 40,
                        onPressed: () {
                          setState(() {
                            currentTab = 3;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save,
                              color: currentTab == 3 ? Colors.red : Colors.red[300],),
                            Text('Dashboard', style: TextStyle(color: currentTab == 3 ? Colors.red : Colors.red[300],
                                fontSize: 11),)
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      child: MaterialButton(
                        minWidth: 40,
                        onPressed: () {
                          setState(() {
                            currentTab = 4;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.contacts_outlined,
                              color: currentTab == 4 ? Colors.red : Colors.red[300],),
                            Text('Profile', style: TextStyle(color: currentTab == 4 ? Colors.red : Colors.red[300],
                                fontSize: 11),)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
