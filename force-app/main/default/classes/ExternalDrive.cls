public abstract class ExternalDrive {
	
    //public HttpResponse LastResponse {get;set;}
    
    public class UploadStatus{
        public boolean Uploaded{get; private set;}
        public string FileUrl {get; private set;}
        public string FileId {get; private set;}
        public string FolderUrl {get; private set;}
        public string FolderId {get; private set;}
        public string Response {get; private set;}
        public integer HTTPStatus {get; private set;}
        public UploadStatus(boolean aIsUploaded, string aFileUrl, string aUploadedFileId, string aFolderUrl, string aFolderId, string aResponse, integer aHttpStatus)
        {
            Uploaded = aIsUploaded;
            FileUrl = aFileUrl;
            FileId = aUploadedFileId;
            FolderUrl = aFolderUrl;
            FolderId = aFolderId;
            Response = aResponse;
            HttpStatus = aHttpStatus;
        }
    }
    
    public string NamedCredential{get; private set;}
    
    public ExternalDrive(string aCredential)
    {
        NamedCredential = aCredential;
    }
    
    public abstract boolean FolderExist(string aFolder);
    
	public abstract boolean CreateFolder(string aFolder);
    
    public abstract boolean ChangeFolder(string aFolder);
    
    public abstract UploadStatus UploadFile(string aFileName, blob aContent, string aContentType, string aFolderId);
    
}