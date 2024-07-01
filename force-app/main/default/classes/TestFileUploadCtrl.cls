@isTest
public class TestFileUploadCtrl {
	
    private static Attachment c_Attachment;
    
    public static void Setup()
    {
        Lead l = new Lead();
        l.LastName = 'Akh';
        l.Company = 'Test Inc.';
        insert l;
        c_Attachment = new Attachment();
        c_Attachment.ParentId = l.Id; 
        c_Attachment.Body = blob.valueOf('TEST');
        c_Attachment.Name = 'test.txt';
        insert c_Attachment;
    }
    
    public static testMethod void testExecuteBatch()
    {
        Setup();
        
        Test.startTest();
        
        FileUploadCtrl ctrl = new FileUploadCtrl();
        ctrl.AttachmentId = c_Attachment.Id; 
		
        ctrl.ExecuteBatch();
        
        Test.stopTest();
    }
    
    public static testMethod void testGetAttachment()
    {
        Setup();
        
        Test.startTest();
        
        FileUploadCtrl ctrl = new FileUploadCtrl();
        ctrl.AttachmentId = c_Attachment.Id;
        ctrl.GetAttachment();
        
        Test.stopTest();
    }
    
    public static testMethod void testUpload()
    {
        Setup();
        
        Test.startTest();
        
        FileUploadCtrl ctrl = new FileUploadCtrl();
        ctrl.AttachmentId = c_Attachment.Id;
        ctrl.GetAttachment();
        
        system.debug('JMA::DEBUG:: ctr.Attachment :' + ctrl.AttachmentId);
        system.debug('JMA::DEBUG:: ctr.Attachment :' + ctrl.Attachment);
        
        ctrl.fileUploader.m_FileUploadSetting.Delete_Attachments__c = false;
        ctrl.fileUploader.m_FileUploadSetting.Log_Already_Uploaded_Files__c = true;
                
        ctrl.Upload();
        
        ctrl.GetAttachment();        
      
        
        ctrl.Upload();
        
        Test.stopTest();
    }
    
    
}