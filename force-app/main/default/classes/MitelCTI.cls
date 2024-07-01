global with sharing class MitelCTI{
    webService static String searchByNameOrNumber(String sInput, Integer nLimit, String sParams) {        
        List<List<SObject>> searchList;
        
        if (sInput.length() > 1) {
            String query = 'FIND \'' + String.escapeSingleQuotes(sInput) + '*\' ';
    
            if (sInput.isNumeric()) {
                query += 'IN PHONE FIELDS ';
            } else {
                query += 'IN NAME FIELDS ';
            }
            
            String queryEntities = '';
            
            List<MitelCTI_SearchParam> searchParams = MitelCTI_SearchParam.parse(sParams);
            for (MitelCTI_SearchParam searchParam : searchParams) {
                String entityName = searchParam.entityName;

                String queryProps = '';
                
                if (entityName=='Contact') {
                    queryProps = 'Id, Name, Phone, HomePhone, MobilePhone, Account.Name';
                }
                else if (entityName=='Account') {
                    queryProps = 'Id, Name, Phone';
                }                
                else if (entityName=='Lead') {
                    queryProps = 'Id, Name, Phone, MobilePhone, Company';
                }
                else if (entityName=='User') {
                    queryProps = 'Name, Phone, Extension, MobilePhone';
                }
                
                List<MitelCTI_SearchParam.Properties> properties =  searchParam.properties;
                for (MitelCTI_SearchParam.Properties prop : properties) {
                    String displayName = prop.displayName;
                    String apiName = prop.apiName;                
                    if (!queryProps.contains(apiName)) {
                        if (queryProps.length()>0) {
                            queryProps += ', ' + apiName; 
                        }
                        else {
                            queryProps += apiName; 
                        }  
                    }                    
                }

                if (queryProps.length()>0) {
                    if (queryEntities.length()>0) {
                       queryEntities += ', ' + entityName  + '(' + queryProps +')'; 
                    }
                    else {
                       queryEntities += entityName + '(' + queryProps +')'; 
                    }
                }
                                
            }
            
            system.debug('queryEntities=' + queryEntities);
            
            query += 'RETURNING Contact(Id, Name, Phone, HomePhone, MobilePhone, Account.Name),';
            query += 'Account(Id, Name, Phone),';       
            if (leadsEnabled) {
                query += 'Lead(Id, Name, Phone, MobilePhone, Company),';
            }
            query += 'User(Name, Phone, Extension, MobilePhone)';
            
            if (queryEntities.length()>0) {
                query += ',' + queryEntities;
            }
            
            searchList = search.query(query);
        }
        
        String JSONString = JSON.serialize(searchList);
        return JSONString;
    }
    
    static Boolean leadsEnabled {
        get {
            if (leadsEnabled == null) {
                // Determine if current user can read Lead objects.
                Boolean canReadLead = false;
                if (Schema.getGlobalDescribe().containsKey('Lead')) {
                    Schema.DescribeSObjectResult leadDescribe = Schema.getGlobalDescribe().get('Lead').getDescribe();
                    canReadLead = (leadDescribe != null && leadDescribe.isAccessible());
                }
                leadsEnabled = canReadLead; 
            }
            return leadsEnabled;
        }
        private set;
    }     
 
    webService static String selectById(String sId, String sParams) {        
        
        List<sObject> sobjList;
        
        if (sId.length() > 1) {
           
            List<MitelCTI_SearchParam> searchParams = MitelCTI_SearchParam.parse(sParams);
            for (MitelCTI_SearchParam searchParam : searchParams) {
                
                String entityName = searchParam.entityName;
                String entityProps = '';
                
                List<MitelCTI_SearchParam.Properties> properties =  searchParam.properties;
                for (MitelCTI_SearchParam.Properties prop : properties) {
                    String displayName = prop.displayName;
                    String apiName = prop.apiName;                
                    if (!entityProps.contains(apiName)) {
                        if (entityProps.length()>0) {
                            entityProps += ', ' + apiName; 
                        }
                        else {
                            entityProps += apiName; 
                        }  
                    }                    
                }

                String query = 'SELECT ' + entityProps + ' FROM ' + entityName + ' WHERE Id = \''  + sId  + '\'';
                system.debug('query=' + query);
                sobjList = Database.query(query);
            }
        }
        String JSONString = JSON.serialize(sobjList);
        return JSONString;
    }
    
    webService static String getCurrentUser()
    {
        User user = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        String JSONString = JSON.serialize(user);
        return JSONString;
    }
}