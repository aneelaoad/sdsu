@isTest(SeeAllData=false)
public with sharing class TX_TestCommunities {

    public static testMethod void testCommunitiesLoginController () {
       TX_CommunitiesLoginController controller = new TX_CommunitiesLoginController();
       System.assertNotEquals(null, controller.forwardToAuthPage());         
    }

    public static testMethod void testCommunitiesSelfRegController() {
        TX_CommunitiesSelfRegController controller = new TX_CommunitiesSelfRegController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        
        Account a = new Account(Name='Test') ;
        insert a ;
        controller.accountId = a.Id ;

        System.assert(controller.registerUser() == null);

        TX_SiteLoginController s = new TX_SiteLoginController ();
        s.username = 'test@salesforce.com';
        s.password = '123456'; 
                
        System.assertEquals(s.login(),null);  

    }

    public static testMethod void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        TX_CommunitiesLandingController controller = new TX_CommunitiesLandingController();
        system.assertNotEquals(null,controller.forwardToStartPage());
    }

    public static testMethod void testForgotPasswordController() {
        // Instantiate a new controller with all parameters in the page
        TX_ForgotPasswordController controller = new TX_ForgotPasswordController();
        controller.username = 'test@salesforce.com';        
    
        System.assertEquals(controller.forgotPassword(),null); 
    }

    public static testMethod void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        TX_ChangePasswordController controller = new TX_ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }

    public static testMethod void testMyProfileSetContactFields() {
        User u = [select title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
                           FROM User WHERE id =: UserInfo.getUserId()];

        Contact c = new Contact();

        TX_MyProfilePageController.setContactFields(c, u);
        System.assertEquals(c.firstname, u.firstname, 'firstname should have been set as the firstname of the user for the contact');
        System.assertEquals(c.lastname, u.lastname, 'lastname should have been set as the lastname of the user for the contact');
    }

    public static testMethod void testMyProfileSave() {
        // Modify the test to query for a portal user that exists in your org
        List<User> existingPortalUsers = [SELECT id, profileId, userRoleId FROM User WHERE UserRoleId <> null AND UserType='CustomerSuccess'];

        if (existingPortalUsers.isEmpty()) {
            User currentUser = [select id, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
                                FROM User WHERE id =: UserInfo.getUserId()];
            TX_MyProfilePageController controller = new TX_MyProfilePageController();
            System.assertEquals(currentUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
            System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
            controller.edit();
            System.assert(controller.getIsEdit() == true);
            controller.cancel();
            System.assert(controller.getIsEdit() == false);

            Contact c = new Contact();
            c.LastName = 'TestContact';
            insert c;

            c.title = currentUser.title;
            c.firstname = currentUser.firstname;
            c.lastname = currentUser.lastname;
            c.email = currentUser.email;
            c.phone = currentUser.phone;
            c.mobilephone = currentUser.mobilephone;
            c.fax = currentUser.fax;
            c.mailingstreet = currentUser.street;
            c.mailingcity = currentUser.city;
            c.mailingstate = currentUser.state;
            c.mailingpostalcode = currentUser.postalcode;
            c.mailingcountry = currentUser.country;
            controller.save();
            System.assert(Page.TX_ChangePassword.getUrl().equals(controller.changePassword().getUrl()));
        } else {
            User existingPortalUser = existingPortalUsers[0];
            String randFax = Math.rint(Math.random() * 1000) + '5551234';

            System.runAs(existingPortalUser) {
                TX_MyProfilePageController controller = new TX_MyProfilePageController();
                System.assertEquals(existingPortalUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
                System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
                controller.edit();
                System.assert(controller.getIsEdit() == true);

                controller.cancel();
                System.assert(controller.getIsEdit() == false);

                controller.getUser().Fax = randFax;
                controller.save();
                System.assert(controller.getIsEdit() == false);
            }

            // verify that the user and contact were updated
            existingPortalUser = [Select id, fax, Contact.Fax from User where id =: existingPortalUser.Id];
            System.assert(existingPortalUser.fax == randFax);
            System.assert(existingPortalUser.Contact.fax == randFax);
        }
    }

    public static testMethod void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        TX_SiteLoginController controller = new TX_SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);

        PageReference pageRef = Page.TX_SiteLogin;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('startURL','testurl');
        System.PageReference selfRegURL = controller.getSelfRegURL();
        System.assert(selfRegURL != null);
    }
    
    public static testMethod void testMore() {
        ApexPages.currentPage().getParameters().put('username', 'test') ;

        TX_CommunitiesSelfRegController src = new TX_CommunitiesSelfRegController() ;
        src = new TX_CommunitiesSelfRegController(new TargetX_Base.TX_CommunitiesBase()) ;

        Account a = new Account(Name='Test') ;
        insert a ;

        src.firstName = 'FirstNames';
        src.lastName = 'LastName';
        src.email = 'test@force.com';

        src.insertContactFirst() ;

        src.password = 'abcd1234';
        src.confirmPassword = 'abcd1234';
        src.communityNickname = '' ;
        src.accountId = a.Id ;

        System.assert(src.registerUser() == null);

        // We can't actually assert the welcome email sending, but we can test the class
        TX_CommunitiesSelfRegConfirmController asdf = new TX_CommunitiesSelfRegConfirmController() ;
        TX_CommunitiesSelfRegConfirmController asdf2 = new TX_CommunitiesSelfRegConfirmController(new TargetX_Base.TX_CommunitiesBase()) ;
    }

    public static testMethod void testDupe() {
        Profile[] profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator'] ;

        User u = new User() ;
        u.Alias                 = 'Admin' ;
        u.LastName              = 'Admin' ;
        u.Email                 = 'testDupe@test.test' ;
        u.Username              = 'testDupe@test.test' ;
        u.CommunityNickname     = 'TestCodeAdmin' ;
        u.ProfileId             = profiles[0].Id ;
        u.TimeZoneSidKey        = 'America/New_York' ;
        u.LocaleSidKey          = 'en_US' ;
        u.EmailEncodingKey      = 'ISO-8859-1' ;
        u.LanguageLocaleKey     = 'en_US' ;
        insert u ;


        TX_CommunitiesSelfRegController controller = new TX_CommunitiesSelfRegController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'testDupe@test.test';
        controller.communityNickname = 'test';
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        
        Account a = new Account(Name='Test') ;
        insert a ;
        controller.accountId = a.Id ;

        System.assert(controller.registerUser() == null);
        System.assertEquals(ApexPages.getMessages()[0].getDetail(), Label.Duplicate_User_Exists) ;
    }

    public static testMethod void testNoRole() {
        Profile[] profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator'] ;

        User u = new User() ;
        u.Alias                 = 'Admin' ;
        u.LastName              = 'Admin' ;
        u.Email                 = 'noRole@test.test' ;
        u.Username              = 'noRole@test.test' ;
        u.CommunityNickname     = 'TestCodeAdmin' ;
        u.ProfileId             = profiles[0].Id ;
        u.TimeZoneSidKey        = 'America/New_York' ;
        u.LocaleSidKey          = 'en_US' ;
        u.EmailEncodingKey      = 'ISO-8859-1' ;
        u.LanguageLocaleKey     = 'en_US' ;
        insert u ;


        TX_CommunitiesSelfRegController controller = new TX_CommunitiesSelfRegController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'testDupe@test.test';
        controller.communityNickname = 'test';
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        
        Account a = new Account(Name='Test') ;
        a.OwnerId = u.Id ;
        insert a ;
        // this should help people who have a workflow set up to make HEDA work
        a.OwnerId = u.Id ;
        update a ;
        controller.accountId = a.Id ;

        System.assert(controller.registerUser() == null);
        Boolean foundError = false;
        for(ApexPages.Message message: ApexPages.getMessages()) {
            if(message.getDetail() == 'Account Owner Missing Role') {
                foundError = true;
                break;
            }
        }
        System.assert(foundError, '\'Account Owner Missing Role\' error not found') ;
    }

    public static testMethod void testUpdateContactAccount() {
        TX_CommunitiesSelfRegController controller = new TX_CommunitiesSelfRegController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'testDupe@test.test';
        controller.communityNickname = 'test';
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd1234';
        
        Account a = new Account(Name='Test') ;
        insert a ;
        controller.accountId = a.Id ;

        Account b = new Account(Name='Test2') ;
        insert b ;

        Contact c = new Contact(AccountId=b.Id, LastName='LastTest', Email='testDupe@test.test') ;
        insert c ;

        System.assert(controller.registerUser() == null);

        // Can't actually assert this because the database ends up getting rolled back
        //Contact c2 = [SELECT Id, AccountId FROM Contact WHERE Email = 'testDupe@test.test'][0] ;
        //System.assertEquals(c2.AccountId, a.Id) ;
    }
}