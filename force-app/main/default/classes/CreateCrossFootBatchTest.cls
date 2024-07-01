@isTest 
public class CreateCrossFootBatchTest{
    @testSetup
    static void testAccAndContRecs() {
        
        Integer limitVal = 200;
        
        // Accounts
        List<Account> accLst = new List<Account>();
        for(Integer i=1;i<=limitVal;i++){
            Account accRec = new Account();
            accRec.Name = 'Test Account '+i;
            accRec.JIHIRCRM__AccountID__c = i+1;
            accLst.add(accRec);
        }
        insert accLst;
        
        //Contacts
        List<Contact> conLst = new List<Contact>();
        for(Integer i=1;i<=limitVal;i++){
            Contact conObj = new Contact();
            conObj.LastName = 'Test LastName '+i;
            conLst.add(conObj);
        }
        insert conLst;
    }
    static testMethod void validateCreateExternalRecordsForAccount() {
       System.debug('Number of accounts-->'+[Select Id From Account].size());
       Test.startTest();
       Id batchJobId1 = Database.executeBatch(new CreatecrossfootBatch('Account'), 200);
       Test.stopTest();
    }
    static testMethod void validateCreateExternalRecordsForContact() {
       System.debug('Number of accounts-->'+[Select Id From Account].size());
       Test.startTest();
       Id batchJobId2 = Database.executeBatch(new CreatecrossfootBatch('Contact'), 200);
       Test.stopTest();
    }
}