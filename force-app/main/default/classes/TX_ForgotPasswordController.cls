/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class TX_ForgotPasswordController {
    public String username {get; set;}   
       
    public TX_ForgotPasswordController(TargetX_Base.TX_CommunitiesBase controller) {}
    public TX_ForgotPasswordController() {}
	
  	public PageReference forgotPassword() {
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.Tx_ForgotPasswordConfirm;
  		pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
  		return null;
  	}
}