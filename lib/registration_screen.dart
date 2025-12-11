import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';
import 'farmers_list_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _pinController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _talukaController = TextEditingController();
  final _villageController = TextEditingController();
  final _cropController = TextEditingController();
  final _dateController = TextEditingController();
  final _acreageController = TextEditingController();

  bool _isLocationDisabled = true;
  bool _isLoading = false;

  // Target Location: Kalmeshwar APMC Market
  final double targetLat = 21.2400895;
  final double targetLng = 78.9009647;

  // --- LOGIC SECTION ---
  Future<void> _fetchPinDetails(String pincode) async {
    if (pincode.length != 6) return;
    final url = Uri.parse('https://api.postalpincode.in/pincode/$pincode');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];
          setState(() {
            _stateController.text = postOffice['State'];
            _districtController.text = postOffice['District'];
            _talukaController.text = postOffice['Block'];
            _isLocationDisabled = true;
          });
        } else {
          setState(() => _isLocationDisabled = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pin code not found. Enter manually.')));
        }
      }
    } catch (e) {
      setState(() => _isLocationDisabled = false);
    }
  }

  Future<double> _calculateDistance() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception('Location permissions are denied');
    }

    Position currentPosition = await Geolocator.getCurrentPosition();
    double distanceInMeters = Geolocator.distanceBetween(
      currentPosition.latitude, currentPosition.longitude, targetLat, targetLng,
    );
    return distanceInMeters / 1000;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        double dist = await _calculateDistance();
        final farmer = Farmer(
          name: _nameController.text,
          mobile: _mobileController.text,
          pincode: _pinController.text,
          state: _stateController.text,
          district: _districtController.text,
          taluka: _talukaController.text,
          village: _villageController.text,
          cropName: _cropController.text,
          harvestingDate: _dateController.text,
          acreage: double.parse(_acreageController.text),
          distanceKm: double.parse(dist.toStringAsFixed(2)),
        );

        await DatabaseHelper.instance.createFarmer(farmer);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Success! Distance: ${dist.toStringAsFixed(2)} km'),
          backgroundColor: Colors.green,
        ));
        Navigator.push(context, MaterialPageRoute(builder: (context) => FarmersListScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- UI DESIGN SECTION ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool enabled = true,
    int? maxLength,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        enabled: enabled,
        maxLength: maxLength,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green[700]),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[200],
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade50, Colors.green.shade100, Colors.white],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.green[800]))
            : SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // --- LOGO SECTION ---
                AgriConnectLogo(),
                SizedBox(height: 10),
                Text("New Farmer Registration",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
                SizedBox(height: 20),
                // --------------------

                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Personal Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[800])),
                          Divider(),
                          SizedBox(height: 10),
                          _buildTextField(
                            controller: _nameController,
                            label: "Full Name",
                            icon: Icons.person,
                            validator: (v) => v!.isEmpty ? "Enter Name" : null,
                          ),
                          _buildTextField(
                            controller: _mobileController,
                            label: "Mobile Number",
                            icon: Icons.phone_android,
                            type: TextInputType.phone,
                            maxLength: 10,
                            validator: (v) => (v!.length != 10) ? "10 digits required" : null,
                          ),

                          SizedBox(height: 10),
                          Text("Address Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[800])),
                          Divider(),
                          SizedBox(height: 10),
                          _buildTextField(
                            controller: _pinController,
                            label: "Pin Code",
                            icon: Icons.pin_drop,
                            type: TextInputType.number,
                            maxLength: 6,
                            onChanged: (val) {
                              if (val.length == 6) _fetchPinDetails(val);
                            },
                            validator: (v) => (v!.length != 6) ? "6 digits required" : null,
                          ),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(controller: _stateController, label: "State", icon: Icons.map, enabled: !_isLocationDisabled)),
                              SizedBox(width: 10),
                              Expanded(child: _buildTextField(controller: _districtController, label: "District", icon: Icons.location_city, enabled: !_isLocationDisabled)),
                            ],
                          ),
                          _buildTextField(controller: _talukaController, label: "Taluka", icon: Icons.account_balance, enabled: !_isLocationDisabled),
                          _buildTextField(controller: _villageController, label: "Village", icon: Icons.home, validator: (v) => v!.isEmpty ? "Enter Village" : null),

                          SizedBox(height: 10),
                          Text("Crop Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[800])),
                          Divider(),
                          SizedBox(height: 10),
                          _buildTextField(controller: _cropController, label: "Crop Name", icon: Icons.grass),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "Harvesting Date",
                                prefixIcon: Icon(Icons.calendar_today, color: Colors.green[700]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context, initialDate: DateTime.now(),
                                    firstDate: DateTime(2000), lastDate: DateTime(2101),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(primary: Colors.green, onPrimary: Colors.white, onSurface: Colors.black),
                                        ),
                                        child: child!,
                                      );
                                    });
                                if (pickedDate != null) {
                                  _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                                }
                              },
                            ),
                          ),

                          _buildTextField(
                            controller: _acreageController,
                            label: "Acreage (Acres)",
                            icon: Icons.landscape,
                            type: TextInputType.number,
                            validator: (v) => double.tryParse(v!) == null ? "Enter number" : null,
                          ),

                          SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 5,
                              ),
                              onPressed: _submitForm,
                              child: Text("REGISTER FARMER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FarmersListScreen())),
                  icon: Icon(Icons.list_alt, color: Colors.green[900]),
                  label: Text("View Registered Farmers", style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- UPDATED LOGO CLASS TO USE IMAGE ---
class AgriConnectLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The Image Logo
        Container(
          width: 120, // Adjusted size for image
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 5,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.png', // Ensure this file exists!
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // If image is missing, show a broken image icon instead of crashing
                return Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey));
              },
            ),
          ),
        ),
        SizedBox(height: 15),

        // The Text Name
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Agri",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                  letterSpacing: 1.0,
                ),
              ),
              TextSpan(
                text: "Connect",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // The Tagline
        Container(
          margin: EdgeInsets.only(top: 5),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "DIGITAL FARMING ASSISTANT",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}