@IsTest

private with sharing class MitelCTITest {

   static Integer parseJsonString(String jsonStr) {
        JSONParser parser = JSON.createParser(jsonStr);
        Integer objCount = 0;
        Integer startObj = 0;
        while (parser.nextToken() != null) {
           if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
               startObj++;
               if (startObj == 1) {
                   objCount++;
               }
           } else if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
               startObj--;
           }
        }
        System.debug('objCount: ' + objCount);
        return objCount;
    }
    
    static testMethod void testSOSL() {

        Integer objectListInputSize = 0;
        Integer objectListOutputSize = 0;
        List<Id> fixedSearchResults = new List<Id>();
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 2; i++) {
            Account newAccount = new Account(Name = 'Max' + i + 'Account');
            accounts.add(newAccount);
            objectListInputSize++;
        }
        insert accounts;  
        System.debug('testSOSL - accounts: ' + accounts);
        
        list<Id> TestAccountIds = new List<Id>();
        for (Account a : accounts) {
            testAccountIds.add(a.Id);
        }
        System.debug('testSOSL - accountIds: ' + TestAccountIds);
        fixedSearchResults.addAll(TestAccountIds);

        List<Contact> contacts = new List<Contact>(); 
        for(Integer i = 0; i < 2; i++){ 
            Contact newContact = new Contact(FirstName = 'Test', LastName = 'Contact' + i, Phone = '777777' + i); 
            newContact.AccountId = accounts[1].Id;
            System.debug('***Contact FirstName: ' + newContact.FirstName + 'LastName: ' + newContact.LastName + 'Phone: ' + newContact.Phone + 'AccountId: ' + newContact.AccountId);
            contacts.add(newContact); 
            objectListInputSize++;
        }             
        insert contacts;
        System.debug('testSOSL - contacts: ' + contacts); 
        
        list<Id> TestContactIds = new List<Id>(); 
        for (Contact c : contacts) {
            testContactIds.add(c.Id);
        }
        System.debug('testSOSL - contactIds: ' + TestContactIds);
        fixedSearchResults.addAll(TestContactIds);

        Schema.SObjectType targetType;
        targetType = Schema.getGlobalDescribe().get('Lead');
        if (targetType != null) {
            List<sObject> leads = new List<sObject>();
            for(Integer i = 0; i < 2; i++){
                sObject newLead = targetType.newSObject();
                newLead.put('FirstName', 'Test');
                newLead.put('LastName', 'Lead' + i);
                newLead.put('Company', 'Test Company' + i);                
                leads.add(newLead);
                objectListInputSize++;
            }
            insert leads; 
            System.debug('testSOSL - leads: ' + leads);

            List<Id> TestLeadIds = new List<Id>();
            for (sObject mylead : leads) {
                TestLeadIds.add(mylead.Id);
            }
            System.debug('testSOSL - leadIds: ' + TestLeadIds);
            fixedSearchResults.addAll(TestLeadIds);            
        }
        
        String userid = UserInfo.getUserID();
        List<Id> TestUserIds = new List<Id>();   
        TestUserIds.add(userid);
        objectListInputSize++;
        System.debug('testSOSL - userIds: ' + TestUserIds);
        fixedSearchResults.addAll(TestUserIds);
         

        //Search for the objects we just created.
        //Any Salesforce Object Search Language (SOSL) query that is added to an Apex test method 
        //returns an empty set of search results when the test method executes
        //You need to use the Test.setFixedSearchResults() method inside your unit test to set 
        //a subset of available data to the SOSL query. This method will open up these records 
        //so that they can be searched on by the SOSL in your unit test.
        //http://corycowgill.blogspot.ca/2012/01/executing-sosl-in-unit-tests.html
   
        System.debug('testSOSL - fixedSearchResults: ' + fixedSearchResults);        
        Test.setFixedSearchResults(fixedSearchResults);     
        
        String nameResult = MitelCTI.searchByNameOrNumber('Test',100,'[]');
        System.debug('testSOSL - SearchByName: ' + nameResult);
        objectListOutputSize = parseJsonString(nameResult);
        System.debug('objectListOutputSize: ' + objectListOutputSize + ', objectListInputSize: '+ objectListInputSize);        
        System.assertEquals(objectListOutputSize, objectListInputSize);

        objectListOutputSize = 0;
        
        String numberResult = MitelCTI.searchByNameOrNumber('123',100,'[]');
        System.debug('testSOSL - SearchByNumber: ' + numberResult);
        objectListOutputSize = parseJsonString(numberResult); 
        System.assertEquals(objectListOutputSize, objectListInputSize); 
        
        
        String searchParams = '[{\"entityName\":\"Account\",\"properties\":[{\"displayName\":\"Account Name\",\"apiName\":\"Name\"}]},{\"entityName\":\"Contact\",\"properties\":[{\"displayName\":\"Name\",\"apiName\":\"Name\"}]},{\"entityName\":\"Lead\",\"properties\":[{\"displayName\":\"Name\",\"apiName\":\"Name\"}]}]';
        
        nameResult = MitelCTI.searchByNameOrNumber('Test',100, searchParams);
        System.debug('testSOSL[CUST] - SearchByName: ' + nameResult);
        objectListOutputSize = parseJsonString(nameResult);
        System.debug('objectListOutputSize: ' + objectListOutputSize + ', objectListInputSize: '+ objectListInputSize);        
        System.assertEquals(objectListOutputSize, objectListInputSize);

        objectListOutputSize = 0;
        
        numberResult = MitelCTI.searchByNameOrNumber('123',100, searchParams);
        System.debug('testSOSL[CUST] - SearchByNumber: ' + numberResult);
        objectListOutputSize = parseJsonString(numberResult); 
        System.assertEquals(objectListOutputSize, objectListInputSize); 
        
        
        String selectParams = '[{\"entityName\":\"Contact\",\"properties\":[{\"displayName\":\"Name\",\"apiName\":\"Name\"}]}]';
        
        nameResult = MitelCTI.selectById('00Q2000000fHI5cEAG', selectParams);
        System.debug('testSOSL[CUST] - SelectById: ' + nameResult);
        objectListOutputSize = parseJsonString(nameResult);
        System.debug('objectListOutputSize: ' + objectListOutputSize + ', objectListInputSize: '+ objectListInputSize);        
        //System.assertEquals(objectListOutputSize, objectListInputSize);

    }

}