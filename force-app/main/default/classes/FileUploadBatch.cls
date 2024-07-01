global class FileUploadBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    private list<string> m_ObjectNames = new list<string>(); 
    public Files_Upload__mdt m_FileUploadSetting;
    public ExternalDrive m_Drive;
    map<string,string> m_FolderIdByObjectType = new map<string,string>();
    public File_Upload_Log__c UploadLog {get;set;}
    private list<File_Upload__c> m_ArchivedFiles;
    private list<Attachment> m_AttachmentsToDelete;
    private string m_Query = 'Select Id, Name, ContentType, ParentId, Parent.Type, Description, Body, CreatedDate from Attachment ';
    private string m_WhereClause = '';
    private string m_OrderClause = '';
    public integer TotalUploadedFiles {get;set;}
    
    public System.Iterable<sObject> start(Database.BatchableContext aInfo){ 
		
        string objectNameClause = '( ';
        for(Files_Upload__mdt setting : [SELECT Id, Log_Already_Uploaded_Files__c, Max_Files_to_Process__c, Batch_Size__c, Delete_Attachments__c, Named_Credential__c, Lead_Folder_Id__c, Contact_Folder_Id__c, Application_Folder_Id__c, Private_Files_Folder_Id__c, Enable__c, Objects__c, Prior_to_n_Years__c FROM Files_Upload__mdt WHERE Enable__c =: true limit 1])
        {
            m_FileUploadSetting = setting;
            
            m_ObjectNames = setting.Objects__c.split(',');
            
            for(string obj : m_ObjectNames) 
            {
            	objectNameClause += ' Parent.Type = \'' + obj.trim() + '\' OR ';    
            }
            
            objectNameClause = objectNameClause.removeEnd('OR ');
            objectNameClause += ' ) '; 
            if (objectNameClause.length() == 0)
            	throw new IllegalArgumentException('No Objects defined in Files_Upload');
            
            m_Drive = new GoogleDrive(setting.Named_Credential__c);
            
            if (setting.Lead_Folder_Id__c == null)
            	throw new IllegalArgumentException('Lead Folder Id not set in Files Upload MDT settings');
            if (setting.Contact_Folder_Id__c == null)
            	throw new IllegalArgumentException('Contact Folder Id not set in Files Upload MDT settings');
            if (setting.Application_Folder_Id__c == null)
            	throw new IllegalArgumentException('Application Folder Id not set in Files Upload MDT settings');
            if (setting.Private_Files_Folder_Id__c == null)
            	throw new IllegalArgumentException('Private Files Folder Id not set in Files Upload MDT settings');
            
            m_FolderIdByObjectType.put('Lead', setting.Lead_Folder_Id__c);
            m_FolderIdByObjectType.put('Contact', setting.Contact_Folder_Id__c);
            m_FolderIdByObjectType.put('TargetX_SRMb__Application__c', setting.Application_Folder_Id__c);
            m_FolderIdByObjectType.put('File__c', setting.Private_Files_Folder_Id__c);
        }        
        
        if (objectNameClause.length() == 0)
        	throw new IllegalArgumentException('No active configuration defined in Files_Upload');

        integer tillYear = Date.today().year() - integer.valueOf( m_FileUploadSetting.Prior_to_n_Years__c);
        integer maxFiles =  m_FileUploadSetting.Max_Files_to_Process__c == null ? 0 : integer.valueof( m_FileUploadSetting.Max_Files_to_Process__c);
        string limitClause = maxFiles == 0 ? ' ' : ' limit ' + maxFiles;
        //return Database.getQueryLocator([Select Id, Name, ContentType, ParentId, ParentId.Type, Description, Body, CreatedDate from Attachment Where Parent.Type = 'Account' limit 1 ]);
        string attachmentsQuery = m_Query.replace('Body,', '');
        m_WhereClause = ' Where ' + objectNameClause + ' AND calendar_year(CreatedDate) <= '+ tillYear;
		m_OrderClause = ' Order By Parent.Type, CreatedDate ' ;        
        
        if(Test.isRunningTest() == false)
            attachmentsQuery += m_WhereClause;
       
        attachmentsQuery += limitClause;
        
        system.debug('JMA::DEBUG:: Query to execute : ' + attachmentsQuery);
        
        List<sObject> records = Database.query(attachmentsQuery);
        
        system.debug('JMA::DEBUG:: records : ' + records);
        system.debug('JMA::DEBUG:: UploadLog : ' + UploadLog);
        
        if (records.size() > 0)
        {
            UploadLog = new File_Upload_Log__c();
            UploadLog.Started_At__c = DateTime.now();
            UploadLog.Files_to_Sync__c = records.size();
            UploadLog.Till_Year__c = tillYear;
            UploadLog.Total_Uploaded__c = 0;
            UploadLog.Total_Failed__c = 0;
            UploadLog.Already_Uploaded_Files__c = 0;
            string settingStr = string.valueOf(m_FileUploadSetting);
            integer sz = settingStr.length() > 131070 ? 131070 : settingStr.length();
            UploadLog.File_Upload_Settings__c = string.valueOf(m_FileUploadSetting).subString(0,sz);
            insert UploadLog;
        }
        return records;
    }
    
    public void execute(Database.BatchableContext aInfo, List<Attachment> aAttachments){
        
        system.debug('JMA::DEBUG:: Attachments received to process : ' + aAttachments.size());
        string inClause = '';
        for(Attachment a: aAttachments)
            inClause += '\'' + a.Id +  '\', ';
	    inClause = '( ' + inClause.removeEnd(', ') + ' ) ';

        system.debug('JMA::DEBUG::IN Clause : ' + inClause);
        
        string whereClause = m_WhereClause;
        
        if (Test.isRunningTest() == true) 
        	whereClause = ' WHERE ' + ' Id IN ' + inClause;
        else
            whereClause = m_WhereClause + ' AND Id IN ' + inClause;
        
        system.debug('JMA::DEBUG::WHERE Clause : ' + whereClause);
        system.debug('JMA::DEBUG::ORDER Clause : ' + m_OrderClause);
        string query = m_Query + (Test.isRunningTest() == true ? '' : whereClause ) + m_OrderClause; 
        system.debug('JMA::DEBUG::Query in Execute() : ' + query);
        aAttachments =  Database.query(query);
        
        system.debug('JMA::DEBUG::Total Attachments after requery : ' + aAttachments.size());
        
        set<Id> attachmentIds = new set<Id>();
        for(Attachment att: aAttachments)
            attachmentIds.add(att.Id);
        list<File_Upload__c> existingSuccessfulUploads = [SELECT Id, File_Name__c, Description__c, Content_Type__c, File__c, File_Id__c, Folder_Id_Name__c, Folder__c, HTTP_Status__c, Attachment_Content_Id__c, Lead__c, Contact__c, Application__c, Private_File__c FROM File_Upload__c WHERE Attachment_Content_Id__c IN: attachmentIds AND Successfully_Uploaded__c =: true order by CreatedDate asc];
        map<Id, File_Upload__c> fileUploadByAttachmentId = new map<Id, File_Upload__c>();
        if ( existingSuccessfulUploads != null)
        {
            for(File_Upload__c file : existingSuccessfulUploads)
            {
                if(fileUploadByAttachmentId.get(file.Attachment_Content_Id__c) == null)
                	fileUploadByAttachmentId.put(file.Attachment_Content_Id__c, file);
            }
        }
        
        TotalUploadedFiles = 0;
        integer TotalFailedUploads = 0;
        integer AlreadyUploadedFiles = 0;
        m_ArchivedFiles = new list<File_Upload__c>();
        m_AttachmentsToDelete = new list<Attachment>();
        
        string failedSkipStatus = '';
        for(Attachment file : aAttachments)
        {
            File_Upload__c alreadyUploaded = fileUploadByAttachmentId.get(file.Id);
            
            File_Upload__c archived = null;
            
            if (alreadyUploaded != null)
            {
                AlreadyUploadedFiles++;
                
                if (m_FileUploadSetting.Log_Already_Uploaded_Files__c == false)
                {
            		system.debug('JMA::DEBUG::Ignore already uploaded attachment. Attachment: ' + file.Id);    	    
                    continue; //continue to next file
                }
        		
                system.debug('JMA::DEBUG::Logging already uplaoded Attachment : ' + file.Id );
                
                archived = alreadyUploaded.clone(false, true);
                
                archived.Already_Uploaded__c = alreadyUploaded.Id;
                archived.File_Upload_Log__c = UploadLog.Id;
                
                archived.File_Name__c = alreadyUploaded.File_Name__c;
                archived.Description__c = alreadyUploaded.Description__c;
                archived.Content_Type__c = alreadyUploaded.Content_Type__c;
                archived.File__c = alreadyUploaded.File__c;
                archived.File_Id__c = alreadyUploaded.File_Id__c;
                archived.Folder_Id_Name__c = alreadyUploaded.Folder_Id_Name__c; 
                archived.Folder__c = alreadyUploaded.Folder__c; 
                archived.HTTP_Status__c = alreadyUploaded.HTTP_Status__c;
                archived.Attachment_Content_Id__c = alreadyUploaded.Attachment_Content_Id__c;
                archived.Lead__c = alreadyUploaded.Lead__c;
                archived.Contact__c = alreadyUploaded.Contact__c;
                archived.Private_File__c = alreadyUploaded.Private_File__c;
                archived.Application__c = alreadyUploaded.Application__c;
            }
            else
            {
                system.debug('JMA::DEBUG::Uploading Attachment : ' + file.Id );
            	archived = UploadAttachment(file);       
                
                if(archived.HTTP_Status__c >= 200 &&  archived.HTTP_Status__c < 300)
                {
                    system.debug('JMA::DEBUG::Successfully Uploaded Attachment : ' + file.Id + ' Archived Status : ' + archived);
                    m_AttachmentsToDelete.add(file);
            		TotalUploadedFiles++;
                }
                else
                {
                    system.debug('JMA::DEBUG::Failed to Upload Attachment : ' + file.Id + ' Archived Status : ' + archived);
                    TotalFailedUploads++;
                }
            }
        	
            if (archived == null)
                continue;
            
            m_ArchivedFiles.add(archived);            
        }  
        
        SavePoint sp = Database.setSavepoint();        
        try
        {
            system.debug('JMA::DEBUG::Total Archived Files : ' + m_ArchivedFiles.size());
            insert m_ArchivedFiles;
            
            UploadLog.Total_Uploaded__c += TotalUploadedFiles;
            UploadLog.Total_Failed__c += TotalFailedUploads;
            UploadLog.Already_Uploaded_Files__c += AlreadyUploadedFiles;
            update UploadLog;
            
            if (m_FileUploadSetting.Delete_Attachments__c == true)
            	delete m_AttachmentsToDelete;
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            system.debug('JMA::DEBUG::Error while saving archived files attachments: ' + ex.getMessage());
            throw ex;
        }
    }
    
    public void finish(Database.BatchableContext info){     
		
    }
    
    public File_Upload__c UploadAttachment(Attachment aAttachment)
    {
        string parentFolderId = m_FolderIdByObjectType.get( aAttachment.Parent.Type);
        parentFolderId = parentFolderId == null ? '' : parentFolderId;
        
        system.debug('JMA::DEBUG::ParentFolder Id : ' + parentFolderId);
        
        m_Drive.ChangeFolder('/');
        CreateAndChangeFolder(aAttachment.Parent.Type, m_Drive);
        CreateAndChangeFolder(aAttachment.ParentId, m_Drive);
        
        string fileName = aAttachment.ParentId + '_' + aAttachment.Name;
		ExternalDrive.UploadStatus uploadStatus = m_Drive.UploadFile(fileName, aAttachment.Body, aAttachment.ContentType, parentFolderId);
        
        if (uploadStatus.Uploaded == false)
        {
            ///TODO: Log the exception and report the error
			system.debug('JMA::DEBUG::Failed to upload the attachment : ' + aAttachment + ' Error : ' + uploadStatus.Response);
        }
        
        File_Upload__c archived = new File_Upload__c();
        archived.File_Upload_Log__c = UploadLog.Id;
        archived.File_Name__c = aAttachment.Name;
        archived.Description__c = aAttachment.Description;
        archived.Content_Type__c = aAttachment.ContentType;
        archived.File__c = uploadStatus.FileUrl;
        archived.File_Id__c = uploadStatus.FileId;
        archived.Folder_Id_Name__c = uploadStatus.FolderId; 
        archived.Folder__c = uploadStatus.FolderUrl; 
        archived.HTTP_Status__c = uploadStatus.HTTPStatus;
        archived.Attachment_Content_Id__c = aAttachment.Id;
        archived.response__c = uploadStatus.response;
        
        if (aAttachment.Parent.Type == 'Lead')
            archived.Lead__c = aAttachment.ParentId;
        else if(aAttachment.Parent.Type == 'Contact')
            archived.Contact__c = aAttachment.ParentId;
        else if(aAttachment.Parent.Type == 'TargetX_SRMb__Application__c')
            archived.Application__c = aAttachment.ParentId;
        else if(aAttachment.Parent.Type == 'File__c')
            archived.Private_File__c = aAttachment.ParentId;
        
        return archived;
    }
    
    private void CreateAndChangeFolder(string aType, ExternalDrive aDrive)
    {
        aDrive.CreateFolder(aType);
        
        aDrive.ChangeFolder(aType);
    }
    
    
}