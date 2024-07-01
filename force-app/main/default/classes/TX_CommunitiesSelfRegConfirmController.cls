public with sharing class TX_CommunitiesSelfRegConfirmController {

    public TX_CommunitiesSelfRegConfirmController() {
        sendWelcomeEmail();
    }

    public TX_CommunitiesSelfRegConfirmController(TargetX_Base.TX_CommunitiesBase controller) {
        sendWelcomeEmail();
    }
    
    private void sendWelcomeEmail() {
        String userName = ApexPages.currentPage().getParameters().get('username');
        if(String.isNotBlank(username)) Site.forgotPassword(userName);
    }
}