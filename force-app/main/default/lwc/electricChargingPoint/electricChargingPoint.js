import { LightningElement, api, wire, track } from 'lwc';
import getContacts from '@salesforce/apex/ElectricChargingPoint.getContacts';
import getGeoLocation from '@salesforce/apex/ElectricChargingPoint.getGeoLocation';
import getElectricChargingPoint from '@salesforce/apex/ElectricChargingPoint.getElectricChargingPoint';

export default class ElectricChargingPoint extends LightningElement {
    @api recordId;
    address;
    latitude;
    longitude;
    @track mapMarkers = [];
    loader = false;
    addLine1;
    city;
    state;
    postcode;
    country;
    showMessage = false;

    handleInputChange(event) {
        let { name, value } = event.target;
        if (name === 'add') {
            this.addLine1 = value;
        } else if (name === 'city') {
            this.city = value;
        } else if (name === 'state') {
            this.state = value;
        } else if (name === 'postcode') {
            this.postcode = value;
        } else if (name === 'country') {
            this.country = value;
        }
    }

    handleClick() {
        if (this.addLine1 !== undefined && this.city !== undefined && this.state !== undefined && this.country !== undefined && this.postcode !== undefined) {
            this.address = this.addLine1 + ' ' + this.city + ' ' + this.state + ' ' + this.country +  ' ' + this.postcode;
            this.loader = true;
        }
    }

    @wire(getContacts, { recordIdContact: '$recordId' })
    contacts({data, error}) {
        if (data) {
            this.loader = true;
            if (data[0].MailingLatitude !== undefined && data[0].MailingLatitude !== null && data[0].MailingLongitude !== undefined && data[0].MailingLongitude !== null) {
                this.latitude = data[0].MailingLatitude;
                this.longitude = data[0].MailingLongitude;
            } else if (data[0].MailingAddress !== undefined && data[0].MailingAddress.street !== undefined && data[0].MailingAddress.street !== null) {
                this.address = data[0].MailingAddress.street;
            } else {
                this.loader = false;
                this.showMessage = true;
            }
        } else if (error) {
            console.log('error: ', error);
        }
    }

    @wire(getGeoLocation, { address: '$address' })
    geoLocation({data, error}) {
        if (data) {
            if (data.results !== undefined && data.results !== null && data.results.length > 0) {
                this.latitude = data.results[0].lat;
                this.longitude = data.results[0].lon;
            } else {
                this.loader = false;
                this.showMessage = true;
            }
        } else if (error) {
            console.log('error: ', error);
        }
    }

    @wire(getElectricChargingPoint, { latitude: '$latitude', longitude: '$longitude' })
    electricChargingStation({data, error}) {
        if (data) {
            if (data !== undefined && data !== null && data.length > 0) {
                this.mapMarkers = data.map((element) => {
                    return {
                        location: {
                            City: element.AddressInfo.Town,
                            Country: element.AddressInfo.Country,
                            PostalCode: element.AddressInfo.Postcode,
                            State: element.AddressInfo.StateOrProvince,
                            Street: element.AddressInfo.AddressLine1,
                        },
                        title: element.AddressInfo.Title
                    };
                });
            } else {
                this.loader = false;
                this.showMessage = true;
            }
        } else if (error) {
            console.log('error: ', error);
        }
    }

    get recordPage() {
        if (this.recordId !== undefined) {
            return true;
        } else {
            return false;
        }
    }

    get hasData() {
        if ((this.address !== undefined || this.latitude !== undefined && this.longitude !== undefined) && this.mapMarkers !== undefined && this.mapMarkers.length > 0) {
            this.loader = false;
            return true;
        } else {
            return false;
        }
    }
}