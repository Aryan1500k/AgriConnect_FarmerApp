# AgriConnect 

**AgriConnect** is a mobile application developed for the *GramIQ Mobile App Developer Intern Assignment*. It allows field agents to register farmers efficiently, automatically fetches address details using Pin Codes, calculates the distance from the farm to the central market (Kalmeshwar APMC, Nagpur), and stores all data locally for offline access.

## 📱 Features Overview

* **Smart Registration Form:**
    * Captures Farmer Name, Mobile, Crop Details, and Acreage.
    * **Auto-Complete Address:** Automatically fills State, District, and Taluka based on the 6-digit Pin Code using the India Post API.
    * **Validation:** Ensures valid 10-digit mobile numbers and numeric inputs.
* **Location Intelligence:**
    * Uses GPS to capture the user's current location.
    * Calculates the **real-time distance (in Km)** from the farm to *Kalmeshwar APMC Market*.
* **Offline Data Storage:**
    * Uses **SQLite** to store farmer data locally on the device.
    * Data persists even after the app is closed.
* **Dashboard:**
    * Displays a list of all registered farmers with their calculated distance and crop details in a card view.

##  Libraries Used

This project relies on the following Flutter packages:

* **`sqflite`**: For local database storage (SQLite).
* **`path`**: Helper for managing database paths.
* **`http`**: For making API calls to fetch Pin Code details.
* **`geolocator`**: For accessing GPS and calculating distance.
* **`intl`**: For formatting the harvesting date.

##  How to Run the App

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/YourUsername/AgriConnect_FarmerApp.git](https://github.com/YourUsername/AgriConnect_FarmerApp.git)
    cd AgriConnect_FarmerApp
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run on Android Emulator/Device:**
    Ensure you have an Android Emulator running or a physical device connected via USB.
    ```bash
    flutter run
    ```

> **Note:** The app requires Location Permissions. Please allow "Access Location" when prompted to enable distance calculation.

---
**Submitted by:** [Aryan Kahate]