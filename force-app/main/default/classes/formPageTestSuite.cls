@isTest
private class formPageTestSuite {

    static testMethod void testMainController() {
    	Test.setMock(HttpCalloutMock.class, new mockFAresponse());
        formController controller = new formController();
        controller.getFormDetails();
        controller.downloadForm(); 
    }
    static testMethod void testSchoolPicker() {
    	schoolPickerController controller = new schoolPickerController();
    	ApexPages.currentPage().getParameters().put('term','burl');
    	controller.doSearch();
    	ApexPages.currentPage().getParameters().put('otl','Account');
    	ApexPages.currentPage().getParameters().put('dc','Name');
    	ApexPages.currentPage().getParameters().put('filterstring','');
    	controller.doSearch();
    }
    static testMethod void testErrorBuilding()
    {
    	Test.setMock(HttpCalloutMock.class, new mockFAresponse());
    	ApexPages.currentPage().getParameters().put('cid','c');
    	ApexPages.currentPage().getParameters().put('formid','c');
    	formController controller = new formController();
        system.assertNotEquals(controller.buildError('testing error'),null);
    }
    
    /***************************************** mocks a return from FA *************************************/
	class mockFAresponse implements HttpCalloutMock {
    	public HTTPResponse respond(HTTPRequest req)
    	{
	        HttpResponse res = new HttpResponse();
	        //res.setHeader('Content-Type', 'application/json');
	        res.setBody('This is form data');
	        res.setStatusCode(200);
	        return res;
	    }
	}
    
}