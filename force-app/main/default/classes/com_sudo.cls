public without sharing class com_sudo {
	/*
	*	This method is run without sharing because it needs to be able to query contacts to find one
	*	with a matching email. No data is ever shown to the user, however
	*/
	public static Contact[] matchOnEmail(String cid, String accessKey)
	{
		return [SELECT Id, FirstName, LastName, Email, AccountId FROM Contact
					WHERE Id = :cid AND TargetX_Base__Access_Key__c = :accessKey
					LIMIT 1] ;
	}
}