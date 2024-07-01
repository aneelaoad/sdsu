@isTest(SeeAllData=false)
private class AccountMigrationCsvUploadControllerTest {

    @isTest static void processCsv_NoFileSelectedTest() {
        AccountMigrationCsvUploadController controller = new AccountMigrationCsvUploadController();

        System.Test.startTest();
            controller.processCsv();
        System.Test.stopTest();

        System.assertNotEquals(0, ApexPages.getMessages().size());
    }

    @isTest static void processCsv_NotCSVFileTest() {
        AccountMigrationCsvUploadController controller = new AccountMigrationCsvUploadController();
        controller.strCsv = 'test.txt';

        System.Test.startTest();
            controller.processCsv();
        System.Test.stopTest();

        System.assertNotEquals(0, ApexPages.getMessages().size());
    }

    @isTest static void processCsv_PositiveTest() {
        AccountMigrationCsvUploadController controller = new AccountMigrationCsvUploadController();
        controller.strCsv = 'test.csv';
        String csvString = 'DeletedAccountID,SurvivingAccountID\r\n1,2\r\n';
        controller.blobCsvFileBody = Blob.valueOf(csvString);
        controller.intFileSizeVal = controller.blobCsvFileBody.size();

        System.Test.startTest();
            controller.processCsv();
        System.Test.stopTest();

        System.assertNotEquals(null, controller.batchId);
    }
    
    @isTest static void checkBatchStatus_AbortTest() {
        AccountMigrationCsvUploadController controller = new AccountMigrationCsvUploadController();
        controller.strCsv = 'test.csv';
        String csvString = 'DeletedAccountID,SurvivingAccountID\r\n1,2\r\n';
        controller.blobCsvFileBody = Blob.valueOf(csvString);
        controller.intFileSizeVal = controller.blobCsvFileBody.size();

        System.Test.startTest();
            controller.processCsv();
            System.AbortJob(controller.batchId);
            controller.checkBatchStatus();
        System.Test.stopTest();

        System.assertEquals(AccountMigrationCsvUploadController.STRABORTED, controller.strBatchStatus);
    }
    
    @isTest static void processCsv_FileSizeTest() {
        AccountMigrationCsvUploadController controller = new AccountMigrationCsvUploadController();
        controller.strCsv = 'test.csv';
        controller.intFileSizeVal = 44444444;

        System.Test.startTest();
            controller.processCsv();
        System.Test.stopTest();

        System.assertNotEquals(0, ApexPages.getMessages().size());
    }
    
    @isTest static void showFileSizeErrorTest() {
        AccountMigrationCsvUploadController controller = new AccountMigrationCsvUploadController();

        System.Test.startTest();
            controller.showFileSizeError();
        System.Test.stopTest();

        System.assertNotEquals(0, ApexPages.getMessages().size());
    }
    
}