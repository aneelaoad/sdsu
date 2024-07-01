public with sharing class formController
{
	public string theForm				{ get; set; }		//HTML code for the Form
	public string formID				{ get; set; }		//Form ID from Form Assembly
	public String endpoint 				{ get; set; }		//URL to fetch the form from
	private string clientPrefix;
	
	public formController()
	{
		getCustomSettings();
		getFormDetails();
		downloadForm();
	}
	
	public void getCustomSettings()
	{
		ep_settings__c settings = new ep_settings__c();
		settings = ep_settings__c.getValues('default');
        clientPrefix = settings.Client_Nickname__c;
	}
	
	public void getFormDetails()
	{
		transient PageReference pageRef = ApexPages.currentPage();
		if (pageRef.getParameters().get('formid')!=null)
		{
			formID = string.escapeSingleQuotes(pageRef.getParameters().get('formid'));
		}
	}
	
	public void downloadForm()
	{
            
		if (clientPrefix!=null)
		{
			PageReference pageRef = ApexPages.currentPage();
			HttpRequest req = new HttpRequest();
			req.setTimeout(30000);
			req.setMethod('GET');
			transient string getString = ' ';
			if(pageRef.getParameters().get('cid') != null && pageRef.getParameters().get('formId') != null)
			{
				getString = '?'; 
				transient string SOQLString = 'SELECT ';
				PrefillMapping__c[] prefillMaps = [SELECT fieldAPIName__c, fieldFAindex__c FROM PrefillMapping__c WHERE formid__c =:string.escapeSingleQuotes(pageRef.getParameters().get('formId'))];
				if (prefillMaps.size()>0)
				{
					for (PrefillMapping__c prefillMap : prefillMaps)
					{
						if (SOQLString != 'SELECT ')
						{
							SOQLString += ',';
						}
						SOQLString+=prefillMap.fieldAPIName__c;
					}
					SOQLString += ' FROM contact WHERE id=\''+string.escapeSingleQuotes(pageRef.getParameters().get('cid'))+'\' LIMIT 1';
					sObject cont = Database.query(SOQLString);
					
					for (PrefillMapping__c prefillMap : prefillMaps)
					{
						getString+='tfa_'+prefillMap.fieldFAindex__c+'='+string.ValueOf(cont.get(prefillMap.fieldAPIName__c)).replace('+','%2B')+'&';
					}
				}
			}
			if (getString==' ')
			{
				getString='?';
			}
			for(String urlKey : pageRef.getParameters().keyset())
			{
				getString += urlKey+'='+string.escapeSingleQuotes(pageRef.getParameters().get(urlKey))+'&';
			}
			
			getString = getString.replace(' ', '+') ;
			
			if(pageRef.getParameters().get('tfa_next') == null)
			{
				endpoint = 'https://'+clientPrefix+'/rest/forms/view/'+formID+getString;
  			}
			else
			{
				endpoint = 'https://'+clientPrefix+'/rest' + string.escapeSingleQuotes(pageRef.getParameters().get('tfa_next'))	;
			}
			req.setEndpoint(endpoint);
		
			Http http = new Http();
			try
			{
				HTTPResponse res = http.send(req);
				theForm = res.getBody();
				theForm = theForm.replace('Need assistance with this form?','');
			}
			catch (system.Calloutexception e)
			{
				theForm = buildError(string.valueOf(e));
			}
		}
		else
		{
			theForm = buildError('No Client URL Prefix is configured.');
		}
	}
	
	public string buildError(string errorMsg)
	{
		transient string formattedError;
		formattedError = '<h3>An Error Has Occurred</h3> <br /><br />';
		formattedError += '<span style="cursor:pointer;" onClick="document.getElementById(\'errorDetails\').style.display=\'inline\';">Show Details</span><br /><br />';
		formattedError += '<div id="errorDetails" style="display:none;">'+errorMsg+'</div>';
		return formattedError;
	}
}