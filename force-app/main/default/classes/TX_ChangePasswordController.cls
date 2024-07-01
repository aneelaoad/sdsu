/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class TX_ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    
    public TX_ChangePasswordController(TargetX_Base.TX_CommunitiesBase controller) {}
    public TX_ChangePasswordController() {}
}