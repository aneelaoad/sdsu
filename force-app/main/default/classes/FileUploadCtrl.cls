public class FileUploadCtrl {

    public String Message { get; set; }
    public String AttachmentId { get; set; }
    public Attachment Attachment {get; set; }
    File_Upload_Log__c m_FileUpload;
    public FileUploadBatch fileUploader;
    
    public void FileUploadCtrl() { 
        AttachmentId = '00PD200000CwYB8';
    }
    
    public void GetAttachment()
    {
        Attachment = [Select Id, Name, ContentType, ParentId, Parent.Type, Description, Body, CreatedDate from Attachment Where Id =: AttachmentId ];
        Message = (Attachment == null) ? 'Attachment Not Found' : 'Attachment Found ' + Attachment;    
        
        m_FileUpload = new File_Upload_Log__c();
        m_FileUpload.Started_At__c = DateTime.Now();
        insert m_FileUpload;
        
        fileUploader = new FileUploadBatch();
        fileUploader.UploadLog = m_FileUpload;
        
        fileUploader.Start(null);
    }
    
    public PageReference Upload() {
       
        List<Attachment> attachments = new List<Attachment>();
        attachments.add(attachment);
        fileUploader.start(null);
        fileUploader.execute(null, attachments);
        fileUploader.finish(null);
        if (fileUploader.TotalUploadedFiles > 0)
            Message = 'Successfully Uploaded';
        else
            Message = 'Failed';
        return null;
    }

    public PageReference ExecuteBatch() {
        FileUploadScheduler scheduler = new FileUploadScheduler();
        scheduler.execute(null);
        return null;
    }
}