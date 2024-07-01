public with sharing class TX_AutocompleteController {
	/*
	*Change these values to modify behaviour
	*/
	private static FINAL String SOBJECTNAME = 'Account';
	private static FINAL String LABELFIELD = 'Name';
	private static FINAL String VALUEFIELD = 'Id';
	private static FINAL String WHERECLAUSE = '';
	private static FINAL Integer MAXRECORDS = 100;
	//Query Template (Don't Change)
	private static FINAL String QUERYBASE = 'SELECT {0} FROM {1} WHERE Id != NULL';
	private static FINAL String QUERYTEMPLATE = QUERYBASE + ' AND {2} LIKE {3} {4} LIMIT '+MAXRECORDS;

	private Object modelVar;

	public void setModelVar(Object modelVar){
		if(this.modelVar != modelVar){
			this.modelVar = modelVar;
		}
	}

	public Object getModelVar(){
		return this.modelVar;
	}

	public String getLabelField(){
		return LABELFIELD;
	}

	public String getValueField(){
		return VALUEFIELD;
	}

	@RemoteAction
	public static List<sObject> getRecordByValueField(String v){
		return  Database.query(prepareQuery(QUERYBASE,null)+' AND '+VALUEFIELD+'=\''+v+'\' LIMIT 1');
	}

	@RemoteAction
	public static List<sObject> getData(String term){
		return Database.query(prepareQuery(QUERYTEMPLATE,term));
	}

	private static String prepareQuery(String tmpl,String term){
		Set<String> fields = new Set<String>{
			LABELFIELD.toLowerCase(),
			VALUEFIELD.toLowerCase()
		};
		return String.format(tmpl,new List<String>{
			String.join(new List<String>(fields),','),
			SOBJECTNAME,
			LABELFIELD,
			'\'%'+term+'%\'',
			String.isBlank(WHERECLAUSE) ? '' : ' AND '+WHERECLAUSE
		});
	}

}