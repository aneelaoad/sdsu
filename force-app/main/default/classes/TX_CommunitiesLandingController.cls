/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class TX_CommunitiesLandingController {
	
	private TargetX_Base.TX_CommunitiesBase cont ;
	// Code we will invoke on page load.
	public PageReference forwardToStartPage() {
		// Check to see if they have a redirect cookie. If they do, send them there
		PageReference p = TargetX_Base.BasePackage.checkRedirectCookie() ;
		if(p != null) return p ;
		
		// this may need to be configurable at some point.
		// Apparently, that point is NOW!
		PageReference homepage = cont.getHomepageRef() ;
		if(homepage != null)
		{
			return homepage ;
		}
		else
		{
			return Page.TX_CommunitiesHome ;
		}
	}
	
	public TX_CommunitiesLandingController()
	{
		cont = new TargetX_Base.TX_CommunitiesBase() ;
	}
}