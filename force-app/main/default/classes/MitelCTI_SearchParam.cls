public class MitelCTI_SearchParam {

    public String entityName;
    public List<Properties> properties;

    public class Properties {
        public String displayName;
        public String apiName;
    }

    
    public static List<MitelCTI_SearchParam> parse(String json) {
        return (List<MitelCTI_SearchParam>) System.JSON.deserialize(json, List<MitelCTI_SearchParam>.class);
    }
}