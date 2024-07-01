global class FileUploadScheduler implements Schedulable {
   
	global void execute(SchedulableContext SC) {
      
    	FileUploadBatch batchFileUpload = new FileUploadBatch();
        Id batchJobId = null;
        
        Files_Upload__mdt setting = null;
        for(Files_Upload__mdt setg : [SELECT Id, Batch_Size__c, Delete_Attachments__c, Named_Credential__c, Lead_Folder_Id__c, Contact_Folder_Id__c, Application_Folder_Id__c, Private_Files_Folder_Id__c, Enable__c, Objects__c, Prior_to_n_Years__c FROM Files_Upload__mdt WHERE Enable__c =: true limit 1])
			setting = setg;
        
        if (setting == null)
            throw new IllegalArgumentException('No active configuration defined in Files_Upload');
        
        integer batchSize = setting == null || setting.Batch_Size__c == null || setting.Batch_Size__c == 0 
            ? 2 : integer.valueOf(setting.Batch_Size__c);
        batchJobId = Database.executeBatch(batchFileUpload, batchsize);
        
        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
                FROM AsyncApexJob WHERE ID =: batchJobId ];
		System.debug('Job Id: ' + batchJobid + ' Status: ' + aaj.Status);
    }
}