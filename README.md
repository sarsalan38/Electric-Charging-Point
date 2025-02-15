# Electric Charging Point

The **Electric Charging Point** app allows users to search for electric charging stations using the contact's address or manually entering an address. The app leverages external APIs for geolocation and charging station data, integrating seamlessly with Salesforce via Lightning Web Components and Apex.

## Features
- **Search by Contact Address** or **Manual Input**.
- **Displays results on a map** using `lightning-map`.
- **API integration** using Named Credentials and Custom Metadata for secure API keys.

## Installation
1. Install the unmanaged package: [Install Here](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tJ3000000gNqb)
2. Follow the **Post-Installation Process** below.

## Post-Installation Process
1. Navigate to **Setup → External Credentials**.
2. Enable **System Admin** or desired profile access for External Credentials.
3. Add the **Electric Charging Point** component to the Contact Record Page:
    - Go to **Contact Record Page** → **Edit Page**.
    - Add a **Custom Tab** beside **Details**, name it, and drag the component into the tab.
    - Save the layout.

## Usage
- **Record Page**: Uses the contact's address to find nearby charging stations.
- **Standalone**: Allows manual entry of address details.

## Components
- **Apex Class**: Manages API calls to fetch geolocation and charging station data.
- **LWC**: Displays input fields and map results, works in both record page and standalone mode.
