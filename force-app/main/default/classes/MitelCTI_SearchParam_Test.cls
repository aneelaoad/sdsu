@IsTest
public class MitelCTI_SearchParam_Test {
    
    static testMethod void testParse() {
        String json = '[{\"entityName\":\"Account\",\"properties\":[{\"displayName\":\"Account Name\",\"apiName\":\"Name\"}]},{\"entityName\":\"Contact\",\"properties\":[{\"displayName\":\"Name\",\"apiName\":\"Name\"}]},{\"entityName\":\"Lead\",\"properties\":[{\"displayName\":\"Name\",\"apiName\":\"Name\"}]}]';
        List<MitelCTI_SearchParam> obj = MitelCTI_SearchParam.parse(json);
        System.assert(obj != null);
    }
    
    static testMethod void testParseEmpty() {
        String json = '[]';
        List<MitelCTI_SearchParam> obj = MitelCTI_SearchParam.parse(json);
        System.assert(obj != null);
    }    
}