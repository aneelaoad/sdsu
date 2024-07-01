public class GoogleDrive extends ExternalDrive{
	
    public GoogleDrive(string aNamedCredential)
    {
        super(aNamedCredential); 
    }
    
    public override boolean FolderExist(string aFolder)
    {
        return true;
    }
    
    public override boolean CreateFolder(string aFolder)
    {
        return true;
    }
    
    public override boolean ChangeFolder(string aFolder)
    {
        return true;
    }
    
    public override UploadStatus UploadFile(string aFileName, blob aContent, string aContentType, string aFolderId)
    {
/*		String boundary = '----------9889464542212';
        String delimiter = '\r\n--' + boundary +'\r\n';
        String close_delim = '\r\n--' + boundary + '--';
        String bodyEncoded = EncodingUtil.base64Encode(aContent);
        String body=delimiter+'Content-Type: application/json\r\n\r\n'+'{ "title" : "'+ filename+'",'+' "mimeType" : "'+ filetype+ '" }'+delimiter+'Content-Type: ' + filetype + '\r\n'+'Content-Transfer-Encoding: base64\r\n'+'\r\n'+bodyEncoded+close_delim;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/upload/drive/v2/files?uploadType=multipart');
        req.setHeader('Authorization', 'Bearer ' +accessToken);
        req.setHeader('Content-Type', 'multipart/mixed; boundary="'+boundary+'"');
        req.setHeader('Content-length', String.valueOf(body.length()));
        req.setBody(body);
        req.setMethod('POST');
        req.setTimeout(60*1000);
        HttpResponse resp = http.send(req);
        system.debug('@@@@@@@---'+resp.getbody());
        file =null;
        filetype='';
        filename='';
*/        
        String encodedContent = EncodingUtil.base64Encode(aContent);
       
        if (encodedContent.length() > 5000000)
            return new UploadStatus(false, '', '', '', '', '{"Error":"File size is too large (max. 5000000 bytes) : ' + encodedContent.length() + '"}', 500);  
            //return ResumableUpload(aFileName, encodedContent, aContentType);

		//WORKING         String body = '--foo_bar_baz\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n {\r\nname: "'+aFileName+'"\r\n , \r\nparents: ["'+aFolderId+'"]\r\n  }\r\n\r\n--foo_bar_baz\r\nContent-Transfer-Encoding: base64\r\nContent-Type: ' + aContentType + '\r\n\r\n' + encodedContent + '\r\n--foo_bar_baz--';
        
        if (aContentType != null && aContentType.contains('.pdf') == true)
        	aContentType = 'text/html';
        else if (aContentType != null && aContentType.contains('null') == true)
        	aContentType = '';
        else if (aContentType == null)
        	aContentType = '';
        
        String body = '--foo_bar_baz\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n {\r\nname: "'+aFileName+'"\r\n , \r\nparents: ["'+aFolderId+'"]\r\n  }\r\n\r\n--foo_bar_baz\r\nContent-Transfer-Encoding: base64\r\nContent-Type: ' + aContentType + '\r\n\r\n' + encodedContent + '\r\n--foo_bar_baz--';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('callout:Google_Drive_Credentials/upload/drive/v3/files?uploadType=multipart&supportsAllDrives=true');
        request.setEndpoint('callout:'+NamedCredential+'/upload/drive/v3/files?uploadType=multipart&supportsAllDrives=true');
        request.setHeader('Content-Type', 'multipart/related; boundary=foo_bar_baz');
        request.setHeader('Content-Length', Blob.valueOf(body).size() + '');
        request.setMethod('POST');
        request.setBody(body);
        
        system.debug('JMA::DEBUG::request body'+request.getBody());
        
        HttpResponse LastResponse;
        
        if(Test.isRunningTest() == true)
        {
        	LastResponse = new HttpResponse();   
            LastResponse.setStatusCode(200);
            LastResponse.setBody('{"id":"TESTID"}');
        }        
        
        if (Test.isRunningTest() == false)
        	LastResponse = http.send(request);
        system.debug('JMA::DEBUG::response body'+LastResponse.getBody());
        
        string fileId = '';
        string fileUrl = '';
        string folderUrl = '';
        if (LastResponse.getStatusCode() >= 200 && LastResponse.getStatusCode() < 300)
        {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(LastResponse.getBody());
			System.debug('JMA::DEBUG::Uploaded File Id : '+ m.get('id'));
            fileId = string.valueOf(m.get('id'));
            fileUrl = 'https://drive.google.com/open?id=' + fileId;
            folderUrl = 'https://drive.google.com/drive/folders/' + aFolderId;
        }
        
    	return new UploadStatus(LastResponse.getStatusCode() == 200, fileUrl, fileId, folderUrl, aFolderId, LastResponse.getBody(),LastResponse.getStatusCode());    

    }
    /*
    public UploadStatus ResumableUpload(string aFileName, string aBase64EncodedContent, string aContentType, string aFolderId)
    {
        string sessionURL = GetSessionUrl(afileName, aContentType, '');
        system.debug('JMA:DEBUG::sessionUrl:' + sessionUrl);
        
        sessionUrl = sessionUrl.replace('https://www.googleapis.com', 'callout:Google_Drive_Credentials');
        system.debug('JMA::DEBUG::Redefined SessionURL:' + sessionUrl);
        
        blob binaryData = EncodingUtil.base64Decode(aBase64EncodedContent);        
        integer size = binaryData.size();
        system.debug('JMA::DEBUG::aBase64EncodedContent.length:' + size);
        integer chunkSize = 262144; //256KB
        integer count = 1;
        for(integer p = 0; p <= size; p += chunkSize)
        {
            system.debug('JMA::DEBUG::Multipart Request : ' +  count++);
            
            integer endOfData = Math.min(p + chunkSize, size);
            
            string chunk = aBase64EncodedContent.subString(p, endOfData); 
			            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(sessionUrl);
            //request.setHeader('Content-Type', 'multipart/related; boundary=foo_bar_baz');
            request.setHeader('Content-Length', Blob.valueOf(chunk).size() + '');
            //request.setHeader('Consetent-Transfer-Encoding', 'base64');
            request.setHeader('Content-Type', aContentType); // Set the appropriate content type
            string contentRange = 'bytes ' + p + '-' + (p + chunk.length() - 1) + '/' + size;
            system.debug('JMA::DEBUG::ContentRange: ' + contentRange);
            request.setHeader('Content-Range', contentRange);
            request.setMethod('PUT');
            system.debug('JMA::DEBUG::chunk: ' + chunk);
            
            request.setBodyAsBlob(binaryData);
            //request.setBody(chunk);
            //system.debug('JMA::DEBUG::body: ' + request.getBody());
            
            system.debug('JMA::DEBUG::request '+request);
            LastResponse = http.send(request);
            system.debug('JMA::DEBUG::response body'+LastResponse.getBody());
        }
        
        string fileId = '';
        string fileUrl = '';
        string folderUrl = '';
        if (LastResponse.getStatusCode() == 200)
        {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(LastResponse.getBody());
			System.debug('JMA::DEBUG::Uploaded File Id : '+ m.get('id'));
            fileId = string.valueOf(m.get('id'));
            fileUrl = 'https://drive.google.com/open?id=' + fileId;
            folderUrl = 'https://drive.google.com/drive/folders/' + aFolderId;
        }
        
    	return new UploadStatus(LastResponse.getStatusCode() == 200, fileUrl, fileId, folderUrl, afolderId, LastResponse.getBody(),LastResponse.getStatusCode());    
	}
    
    private string GetSessionUrl(string aFileName, string aContentType, string aFolderId)
    {
        String body = '{name: "'+aFileName+'", mimeType:"'+aContentType+'", parents:"'+aFolderId+'"}';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Google_Drive_Credentials/upload/drive/v3/files?uploadType=resumable');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setMethod('POST');
        request.setBody(body);
        system.debug('JMA::DEBUG::GetSessionUrl::request body:'+request.getBody());
        LastResponse = http.send(request);
        system.debug('JMA::DEBUG::response body'+LastResponse.getheaderKeys());
        return LastResponse.getHeader('Location');
    }*/
}