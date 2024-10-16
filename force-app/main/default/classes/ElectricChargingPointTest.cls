/************************************************************************************************************************
Apex Class Name : ElectricChargingPointTest 
Purpose         : Test class for ElectricChargingPointTest.

History:                                                            
-------                                                            
VERSION  AUTHOR             DATE          DETAIL                                             TICKET REFERENCE/ NO.
1.       Shakeeb Arsalan    15/10/2024    Created to cover the code coverage.

*************************************************************************************************************************/
@isTest
public with sharing class ElectricChargingPointTest {

    /******************************************************
    * Method Name   :  setupData
    * Description   :  Setup method where all test prerequisites are initialised.
    * Return Type   :  void
    * Parameters    :  none
    *******************************************************/
    @testSetup
    static void setupData() {
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            MailingStreet = '123 Test Street',
            MailingCity = 'Test City',
            MailingState = 'Test State',
            MailingPostalCode = '12345',
            MailingCountry = 'Test Country'
        );
        insert testContact;
    }

    /*************************************************************
    * Method Name  : testGetContacts
    * Description  : Get the contact from record id.
    * Return Type  : void
    * Parameters   : none
    **************************************************************/
    @isTest
    static void testGetContacts() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        List<Contact> contacts = ElectricChargingPoint.getContacts(testContact.Id);
        Test.stopTest();
        
        Assert.areEqual(1, contacts.size(), 'Should return 1 contact');
        Assert.areEqual(testContact.Id, contacts[0].Id, 'Returned contact ID should match test contact ID');
    }

    /*************************************************************
    * Method Name  : testGetGeoLocation
    * Description  : Get the location from address.
    * Return Type  : void
    * Parameters   : none
    **************************************************************/
    @isTest
    static void testGetGeoLocation() {
        ElectricChargingPointTest.MockHttpResponseGeoLocation mockGeoLocation = new ElectricChargingPointTest.MockHttpResponseGeoLocation();
        Test.setMock(HttpCalloutMock.class, mockGeoLocation);
        
        Test.startTest();
        Map<String, Object> geoLocationResponse = (Map<String, Object>) ElectricChargingPoint.getGeoLocation('123 Test Street');
        List<Object> geoLocList = (List<Object>) geoLocationResponse.get('results');
        Map<String, Object> result = (Map<String, Object>) geoLocList[0];
        Test.stopTest();
        
        Assert.isNotNull(geoLocationResponse, 'GeoLocation response should not be null');
        Assert.areEqual(45.519, result.get('lat'), 'Country code should match the mock response');
    }

    /*************************************************************
    * Method Name  : testGetElectricChargingPoint
    * Description  : Get the Electric Charging Point from CountryCode, Latitude and Longitude.
    * Return Type  : void
    * Parameters   : none
    **************************************************************/
    @isTest
    static void testGetElectricChargingPoint() {
        Double latitude = 45.519294183673466;
        Double longitude = -122.67742142857142;
        ElectricChargingPointTest.MockHttpResponseChargingPoint mockChargingPoint = new ElectricChargingPointTest.MockHttpResponseChargingPoint();
        Test.setMock(HttpCalloutMock.class, mockChargingPoint);
        
        Test.startTest();
        List<Object> chargingPoints = ElectricChargingPoint.getElectricChargingPoint(latitude, longitude);
        Test.stopTest();
        
        Assert.isNotNull(chargingPoints, 'Charging Points response should not be null');
        Assert.areEqual(2, chargingPoints.size(), 'Mock should return 2 charging points');
    }

    /*************************************************************
    * Method Name  : MockHttpResponseGeoLocation
    * Description  : Generate the Mock Callout Data for getGeoLocation method.
    * Return Type  : void
    * Parameters   : none
    **************************************************************/
    private class MockHttpResponseGeoLocation implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"results": [{"lat": 45.519, "lon": -122.677}]}');
            return res;
        }
    }

    /*************************************************************
    * Method Name  : MockHttpResponseChargingPoint
    * Description  : Generate the Mock Callout Data for getElectricChargingPoint method.
    * Return Type  : void
    * Parameters   : none
    **************************************************************/
    private class MockHttpResponseChargingPoint implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('[{"ID": 1, "AddressInfo": {"Title": "Station 1", "Town": "Portland", "StateOrProvince": "OR"}},'
                       + '{"ID": 2, "AddressInfo": {"Title": "Station 2", "Town": "Portland", "StateOrProvince": "OR"}}]');
            return res;
        }
    }
}
