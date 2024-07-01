/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class TX_CommunitiesLoginController {

    global TX_CommunitiesLoginController () {}
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        if(startUrl == null) { startUrl = ''; }
        startUrl = Pattern.matches('(?i)tx_communitieslogin', startUrl) ? '' : startUrl;
        String displayType = System.currentPageReference().getParameters().get('display');
        // return Network.forwardToAuthPage(startUrl, displayType);
        return new PageReference(Site.getBaseUrl() + '/TX_SiteLogin?startURL=' + EncodingUtil.urlEncode(startUrl,'UTF-8'));
    }
}