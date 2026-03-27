<!--- ================================================================================
     Author:      Scott Slagle
     File:        _auth.cfm
     Application: 84 Community Food Pantry - Test Site (Admin)
     Created:     02/14/2026

     Purpose:
     This program is the shared authentication guard included at the top of every admin page.  Checks for a valid admin session and redirects 
     unauthenticated users to login.cfm before any page content is processed.  Also performs lazy role-loading into the session struct on the
     first request after login, and enforces page-level role authorization so that pages restricted to Global Admin redirect unauthorized users
     to the dashboard with an access denied notice.

     Changelog:
     02/14/2026 - Initial Development - created shared admin authentication guard.
     03/14/2026 - Added Role Based Access Controls - implemented page-level access restrictions based on admin role, with a switch statement for easy future expansion of roles and permissions.
     ================================================================================ --->
<cfif NOT structKeyExists(session, "admin") OR NOT session.admin.isLoggedIn>                                    <!--- Redirect to login if the admin session key is missing or the user is not logged in --->
  <cflocation url="login.cfm" addtoken="false">                                                                 <!--- Send unauthenticated users to the login page — addtoken=false keeps the URL clean --->
</cfif>

<cfif NOT structKeyExists(session.admin, "roleID") OR NOT structKeyExists(session.admin, "roleName")>           <!--- Load the role into session on first request after login --->

  <cftry>
    <cfquery name="getRole" datasource="84-pantry">                                                             <!--- Try to obtain the role assigned to this user --->
      SELECT users.RoleID, role.RoleName
      FROM   dbo.tbl_AdminUsers users
      INNER JOIN dbo.tbl_Roles role ON role.RoleID = users.RoleID
      WHERE  users.adminID = <cfqueryparam value="#session.admin.adminID#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif getRole.recordCount EQ 1>                                                                             <!--- Cache the resolved role in the session for this admin --->
      <cfset session.admin.roleID   = getRole.RoleID>
      <cfset session.admin.roleName = getRole.RoleName>
    <cfelse>                                                                                                    <!--- No matching role found — redirect to login --->
      <cfset structDelete(session, "admin")>
      <cflocation url="login.cfm" addtoken="false">
    </cfif>

    <cfcatch>                                                                                                   <!--- Role lookup failed - deny access --->
      <cflog file="84FoodPantry" type="error"                                                                   <!--- Log the error details for troubleshooting --->
             text="_auth.cfm role load failed. adminID=#session.admin.adminID# Message=#cfcatch.message# Detail=#cfcatch.detail#">
      <cfset structDelete(session, "admin")>
      <cflocation url="login.cfm" addtoken="false">
    </cfcatch>
  </cftry>

</cfif>

<!--- -----------------------------------------------------------------------
     Page-level role access control
     Defined role tiers:
       Global Admin  — Full access; may manage admin users.
       Pantry Admin  — Access to distributions, people, contacts.
       Ability to add more in the future when needed
     ----------------------------------------------------------------------- --->
<cfset requestedPage = lcase(listLast(cgi.script_name, "/"))>                                                   <!--- Extract the filename from the request path for comparison --->

<!--- Pages restricted to Global Admin only --->
<cfset globalAdminAllowList = "users.cfm">                                                                      <!--- Comma-delimited list of pages accessible only to the Global Admin role --->

<cfswitch expression="#session.admin.roleName#">                                                                <!--- Switch based on the admin's role name to enforce access controls --->

  <cfcase value="Global Admin">                                                                                 <!--- Global Admin has unrestricted access to all admin portal pages --->
    <!--- No restriction check needed — full access granted --->
  </cfcase>

  <cfdefaultcase>                                                                                               <!--- All other roles: block access to Global Admin-only pages --->
    <cfif listFindNoCase(globalAdminAllowList, requestedPage)>                                                  <!--- Current page is restricted — redirect to dashboard with an access denied notice --->
      <cflocation url="index.cfm?msg=accessdenied" addtoken="false">                                            <!--- Redirect unauthorized users to the dashboard with an access denied message --->
    </cfif>
  </cfdefaultcase>

</cfswitch>
