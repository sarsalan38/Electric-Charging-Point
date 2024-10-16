/************************************************************************************************************************
Apex Class Name : ElectricChargingPoint 
Purpose         : Class that is created to pass the Contacts, GeoLocation or ElectricChargingPoint to LWC component.

History:                                                            
-------                                                            
VERSION  AUTHOR             DATE          DETAIL                                             TICKET REFERENCE/ NO.
1.       Shakeeb Arsalan    15/10/2024    Created as a part of ElectricChargingPoint project.

*************************************************************************************************************************/
public with sharing class ElectricChargingPoint {

    /******************************************************
    * Method Name   :  getContacts
    * Description   :  It will return the Contact Id and MailingAddress based on record id.
    * Return Type   :  List<Contact>
    * Parameters    :  String recordIdContact
    *******************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String recordIdContact) {
        return  [SELECT Id, MailingAddress, MailingLatitude, MailingLongitude FROM Contact WHERE Id = :recordIdContact];
    }

    /******************************************************
    * Method Name   :  getGeoLocation
    * Description   :  It will return the GeoLocation based on address.
    * Return Type   :  Map<String, Object>
    * Parameters    :  String address
    *******************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getGeoLocation(String address) {
        String apiKey = API_Key__mdt.getInstance('Geoapify').Key__c;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:GeoLocation/search?text=' + EncodingUtil.urlEncode(address, 'UTF-8') + '&lang=en&limit=1&format=json&apiKey=' + apiKey);
        req.setMethod('GET');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        } else {
            throw new AuraHandledException('Error: ' + res.getBody());
        }
    }

    /******************************************************
    * Method Name   :  getElectricChargingPoint
    * Description   :  It will return the Electric Charging Point based on CountryCode, Latitutde and Longitude.
    * Return Type   :  List<Object>
    * Parameters    :  String countryCode, Double latitude, Double longitude
    *******************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Object> getElectricChargingPoint(Double latitude, Double longitude) {
        String apiKey = API_Key__mdt.getInstance('Open_Charge_Map').Key__c;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ElectricChargingPoint/?output=json&compact=true&maxresults=10&latitude=' + latitude + '&longitude=' + longitude + '&key=' + apiKey);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            return (List<Object>) JSON.deserializeUntyped(res.getBody());
        } else {
            throw new AuraHandledException('Error: ' + res.getBody());
        }
    }
}