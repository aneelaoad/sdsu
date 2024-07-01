public with sharing class schoolPickerController
{
	public string objectToLookup			{ get; set; }	//	used to store what object to search against
	public string accType					{ get; set; }	//	used to filter accounts by type
	public string displayColumn				{ get; set; }	//	used to store columns to display
	public String secondDisplayColumn		{ get; set; }
	public String thirdDisplayColumn		{ get; set; }
	public String newLookupReturnData 		{ get; set; }	//	the data to return.
	 
	public void doSearch()
	{
		accType = ApexPages.currentPage().getParameters().get('type');
		String term = ApexPages.currentPage().getParameters().get('term');
		if(term == null)
		{
			return;
		}
		term = String.escapeSingleQuotes(term);
		
		objectToLookup = 'Account';
		displayColumn = 'name';
		secondDisplayColumn = 'BillingCity';
		thirdDisplayColumn = 'BillingState';
		
		List<Sobject> records;
		records = getRecords(term);
		
		newLookupReturnData='[';
		if (records != null && !records.isEmpty())
		{
			string displayCol = null;
			string val2 = null;
			string val3 = null;
			for (Sobject o : records) {
				if (newLookupReturnData!= '[')
				{
					newLookupReturnData = newLookupReturnData + ',';
				}
				displayCol = (String) o.get(displayColumn);
				val2 = (String) o.get(secondDisplayColumn);
				val3 = (String) o.get(thirdDisplayColumn);
			
				String label = displayCol;
				if(val2 != null && val3 != null)
				{
					label = displayCol + ' (' + val2 + ', ' + val3 + ')';
				}
				else if(val2 != null && val3 == null)
				{
					label = displayCol + ' (' + val2 + ')';
				}
				else if(val2 == null && val3 != null)
				{
					label = displayCol + ' (' + val3 + ')';
				}
				newLookupReturnData = newLookupReturnData + '{"label":"' + label + '","value":"' + label + '","id":"'+o.get('Id')+'"}';
			}
		}
		newLookupReturnData = newLookupReturnData + ']';
	}
	
	public List<SObject> getRecords(String filter)
	{
		transient List<SObject> records = new List<SObject>();
		transient List<SObject> leadMatch = new List<SObject>() ;
		transient List<SObject> anyMatch = new List<SObject>() ;
		String leadingMatchQuery;
		string anyMatchQuery;
		Integer limitNum = 120 ;
		String limitClause = ' limit ' + limitNum ;
		
		if(filter.length() <= 3)
		{
			//	Allow only 50 if it's 3 or less search characters
			limitClause = ' limit 50';
		}
		
		if (filter.trim().length() > 0)
		{
			transient string selectClause = 'select id, '+displayColumn+', '+secondDisplayColumn+', '+thirdDisplayColumn;
			transient string fromClause = ' from ' + objectToLookup;
			transient string whereClause =  ' where ' + displayColumn + ' like \'' + filter + '%\'' ;
			transient string whereAllClause = ' where ' + displayColumn + ' like \'%' + filter + '%\'';
			transient string whereNotLeadClause ='';
			transient string whereTypeClause='';
			transient string orderByClause = ' order by Name asc';
			
			if(accType != null && accType != '')
			{
				transient string typeField = 'type';
				ep_settings__c sett = [SELECT School_Filter_Field__c FROM ep_settings__c WHERE Name = 'default' limit 1] ;
				if(sett != null)
				{
					if(sett.School_Filter_Field__c != null)
					{
						typeField = sett.School_Filter_Field__c ;
					}
				}
	            List<String> types = accType.split(';') ;
            	whereTypeClause += ' AND ' + typeField + ' in :types' ;
			}
			leadingMatchQuery=selectClause+fromClause+whereClause+whereTypeClause+orderByClause+limitClause;
			
			leadMatch = Database.query(leadingMatchQuery) ;
			Integer numLeadMatch;
			if (leadMatch==null)
			{
				numLeadMatch = 0;
			}
			else
			{
				numLeadMatch = leadMatch.size();
			}
			
			if(numLeadMatch > 0) {
				whereNotLeadClause+= ' and id not in (' ;
				for(SObject i: leadMatch) {
					whereNotLeadClause += '\'' + i.id + '\',' ;
				}
				whereNotLeadClause = whereNotLeadClause.substring(0,whereNotLeadClause.length()-1) ; // get rid of that pesky trailing comma
				whereNotLeadClause += ') ' ;
			}
			
			limitClause = ' limit ' + String.valueOf(limitNum - numLeadMatch) ;
			if(filter.length() <= 3) {
				limitClause = ' limit 50';
			}
			anyMatchQuery=selectClause+fromClause+whereAllClause+whereTypeClause+whereNotLeadClause+orderByClause+limitClause;
			anyMatch = Database.query(anyMatchQuery);
			
			records.addAll(leadMatch) ;
			records.addAll(anyMatch) ;
			
			String unknownSchoolQ = selectClause + ' from Account Where Name like \'Unknown School\' limit 1' ;
			List<SObject> unknown = Database.query(unknownSchoolQ) ;
			if(!unknown.isEmpty())
			{
				records.addAll(unknown) ;
			}
		}
		return records;
	}
	
	// Returns the JSON result string
	public String getResult()
	{
		return newLookupReturnData;
	}
}