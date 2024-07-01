/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public without sharing class TX_CommunitiesSelfRegController {
    public String defaultAccountId {get; private set;}
    public String accountId {get;set;}
    public String firstName {get; set {firstName = value == null ? value : value.trim(); } } 

public String lastName {get; set {lastName = value == null ? value : value.trim(); } } 

public String email {get; set {email = value == null ? value : value.trim(); } }
   
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    
    public Boolean isCaptchaEnabled {get; set;} 
    public String tokenValue {get; set;} 

    public TX_CommunitiesSelfRegController(TargetX_Base.TX_CommunitiesBase controller) {
        defaultAccountId = null; // To be filled in by customer. (if school picker is on page this will default the value)
        accountid = defaultAccountId;
    }
    public TX_CommunitiesSelfRegController() {}

    private boolean isValidPassword() {
        return password == confirmPassword;
    }

    public PageReference registerUser() {
        //uncomment below line if using reCaptcha
        isCaptchaEnabled = true;
        
        if(isCaptchaEnabled != null && isCaptchaEnabled && !Test.isRunningTest()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid recaptcha response.');
            if(String.isNotBlank(tokenValue)){
                String response = TargetX_Base.CaptchaController.captchaVerify(tokenValue);
                if(response != 'true'){
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            else {
                ApexPages.addMessage(msg);
                return null;
            } 
        }
        
        SavePoint sp = Database.setSavePoint();
        try{

            //Uncomment below to make school picker required
            /*
            if (String.isBlank(accountId)) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select A School');
                ApexPages.addMessage(msg);
                return null;
            }
            */

            if (!isValidPassword()) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
                ApexPages.addMessage(msg);
                return null;
            }

            String profileId = null; // To be filled in by customer.
            String roleEnum = null; // To be filled in by customer.
              system.debug('check email='+email);
            system.debug('check account ID='+ accountid);
            // match existing contact
            Contact[] cs = [select id, accountid, account.ownerid, account.owner.userRoleId from Contact where email = :email];

            // Uncomment the following line if you want to use HEDA's administrative accounts.
            // NOTE: You will also need to make sure you have some way for account to be set to an owner with a role
            // on creation. By default, accounts will be created by the guest user and fail.
            //if(cs.size() == 0 && !hasDuplicateUser(email)) cs = insertContactFirst() ;
            system.debug('accountId='+accountId);
            if(String.isNotBlank(accountId)){
                for (Account a : [select Id, Owner.UserRoleId from Account where Id = :accountId]) {
                    if(a.Owner.UserRoleId == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account Owner Missing Role'));
                        return null;
                    }
                }
            }

            // move contact to selected account if it's not the original and not default
            if (String.isNotBlank(accountId) && !cs.isEmpty() && cs[0].AccountId != defaultAccountId && cs[0].AccountId != accountId) {
                update new Contact(Id=cs[0].Id, AccountId=accountId);
                system.debug('check contact'+cs[0].Id);
                      system.debug('check Account'+AccountId);
            }

            if(!hasDuplicateUser(email)){

                String userName = email;

                User u = new User();
                u.Username = userName;
                u.Email = email;
                u.FirstName = firstName;
                u.LastName = lastName;
                u.CommunityNickname = TX_UniqueNicknameHelper.getUniqueNickname(u);
                u.ProfileId = profileId;
                if(!cs.isEmpty()){
                    u.ContactId = cs[0].Id;
                    accountId = String.isBlank(accountId) ? cs[0].AccountId : accountId;
                }

                String userId = Site.createPortalUser(u, String.isBlank(accountId) ? null : accountId, password);
                   system.debug('check userid='+userId);
                if (userId != null) {
                    if (password != null && password.length() > 1) {
                        return Site.login(userName, password, ApexPages.currentPage().getParameters().get('startURL'));
                    }
                    else {
                        PageReference page = System.Page.TX_CommunitiesSelfRegConfirm;
                        page.setRedirect(true);
                        return page;
                    }
                }
            }
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
        }
        Database.rollback(sp);
        return null;
    }

    private static Boolean hasDuplicateUser(String email){
        Boolean hasDupe = [SELECT Count() FROM User WHERE UserName = :email] > 0;
        if(hasDupe){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Duplicate_User_Exists);
            ApexPages.addMessage(msg);
        }
        return hasDupe;
    }

  // Uncomment the following line if you want to use HEDA's administrative accounts.
            // NOTE: You will also need to make sure you have some way for account to be set to an owner with a role
            // on creation. By default, accounts will be created by the guest user and fail.  

   public Contact[] insertContactFirst() {
        Contact c = new Contact() ;
        c.FirstName = firstName ;
        c.LastName = lastName ;
        c.Email = email ;
     
        insert c ;

        return [SELECT Id, AccountId, Account.OwnerId, Account.Owner.UserRoleId FROM Contact WHERE Id = :c.Id] ;
    }  
}