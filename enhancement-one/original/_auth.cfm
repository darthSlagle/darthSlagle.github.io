<!--- ================================================================================
     Author:      Scott Slagle
     File:        _auth.cfm
     Application: 84 Community Food Pantry - Test Site (Admin)
     Created:     02/14/2026

     Purpose:
     This program is the shared authentication guard included at the top of every admin page.  Checks for a valid admin session and redirects 
     unauthenticated users to login.cfm before any page content is processed.

     Changelog:
     02/14/2026 - Initial Development - created shared admin authentication guard.
     ================================================================================ --->
<cfif NOT structKeyExists(session, "admin") OR NOT session.admin.isLoggedIn>                                    <!--- Redirect to login if the admin session key is missing or the user is not logged in --->
  <cflocation url="login.cfm" addtoken="false">                                                                 <!--- Send unauthenticated users to the login page — addtoken=false keeps the URL clean --->
</cfif>
