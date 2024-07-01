public with sharing class TX_CommunitiesProvisionController
{
	private Contact theContact ;
	public Boolean showLogin		{ get; set; }

	public void makeRedirCookie()
	{
		// We need to strip the site prefix off the startURL (if there is one). Otherwise,
		// we will end up with the prefix doubled in the resulting URL.
		String startURL = ApexPages.currentPage().getParameters().get('startURL') ;
		if(Site.getPathPrefix() != null && startURL != null)
		{
			startURL = startURL.replaceFirst(Site.getPathPrefix(), '') ;
		}
		String cookieVal = Site.getBaseURL() + startURL ;
		Cookie oreo = new Cookie('targetxCommunityRedirect',cookieVal,null,-1,false) ;
		ApexPages.currentPage().setCookies(new Cookie[]{oreo}) ;
	}

	public TX_CommunitiesProvisionController(TargetX_Base.TX_CommunitiesBase controller)
	{
		String cid = ApexPages.currentPage().getParameters().get('cid') ;
		String accessKey = ApexPages.currentPage().getParameters().get('k') ;
		showLogin = false ;

		if(cid == null || accessKey == null)
		{
			// If we don't have contact params, act as a login page
			showLogin = true ;
		}
		else
		{
			Contact[] cons = com_sudo.matchOnEmail(cid, accessKey) ;

			if(cons.size() > 0)
			{
				theContact = cons[0] ;
				User[] communityUser = [SELECT Id FROM User WHERE ContactId = :theContact.Id LIMIT 1] ;

				if(communityUser.size() > 0)
				{
					// If they already have a user, show the login
					showLogin = true ;
				}
			}
			else
			{
				// If we can't find a contact, act as a login page
				showLogin = true ;
			}
		}
	}

	public void createCommunityUser()
	{
		makeRedirCookie() ;

		String cmtyNickname = String.valueOf(theContact.FirstName.substring(0,1)
								+ theContact.LastName + Datetime.now().getTime());
		
		User u = new User();
		u.Username = theContact.Email;
		u.Email = theContact.Email;
		u.FirstName = theContact.FirstName;
		u.LastName = theContact.LastName;
		u.CommunityNickname = cmtyNickname;
		
		String userId = Site.createPortalUser(u, theContact.AccountId, null);
		return ;
	}

	public void resendConf()
	{
		Site.forgotPassword(theContact.Email) ;
	}
}