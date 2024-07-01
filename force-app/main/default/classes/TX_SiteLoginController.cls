/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class TX_SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}

    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, startUrl);
    }

    global PageReference getSelfRegUrl() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        if(startUrl == null) { startUrl = ''; }
    	return new PageReference(Site.getBaseUrl() + '/TX_CommunitiesSelfReg?startURL=' + EncodingUtil.urlEncode(startUrl,'UTF-8'));
    }
    
    global TX_SiteLoginController () {}
}