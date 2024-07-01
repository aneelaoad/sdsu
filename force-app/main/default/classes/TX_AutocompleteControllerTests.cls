@isTest
private class TX_AutocompleteControllerTests {
	static testMethod void shouldInit(){
		TX_AutocompleteController con = new TX_AutocompleteController();
		System.assert(true);
		con.setModelVar('');
		System.assert(con.getModelVar() == '');
		System.assert(con.getLabelField() != NULL);
		System.assert(con.getValueField() != NULL);
		System.assert(TX_AutocompleteController.getRecordByValueField('') != NULL);
		System.assert(TX_AutocompleteController.getData('A') != NULL);
	}
}