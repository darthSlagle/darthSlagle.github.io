<!--- ================================================================================
     Author:      Scott Slagle
     File:        users.cfm 
     Application: 84 Community Food Pantry - Test Site (Admin)
     Created:     03/14/2026

     Purpose:
     This program is the admin user management module for the 84 Community Food Pantry admin portal.  It is restricted to Global Admin role and provides the ability to list all admin users, add new
     admin accounts, change role assignments, reset passwords, and activate or deactivate accounts.

     Guards enforced in the code:
       - A Global Admin may not deactivate their own account.
       - A Global Admin may not change their own role assignment.

     Changelog:
     03/14/2026 - Initial Development - created user administration module as part of Role Based Access Controls implementation.
     ================================================================================ --->

<cfinclude template="_auth.cfm">                                                                                <!--- Require a valid admin session and enforce Global Admin restriction before processing --->
<cfsetting showdebugoutput="false">                                                                             <!--- Suppress ColdFusion debug output in the browser --->

<cfparam name="url.action" default="list">                                                                      <!--- list | add | edit --->
<cfparam name="url.id" default="">                                                                              <!--- adminID used for the edit view --->
<cfparam name="url.msg" default="">                                                                             <!--- Status message token rendered as a banner after redirects --->

<cfif NOT listFindNoCase("list,add,edit", url.action)>                                                          <!--- Whitelist action parameter to valid values; default to list, prevents invalid actions --->
  <cfset url.action = "list">
</cfif>

<cfparam name="form.adminID" default="">                                                                        <!--- Define the defaults for adminID for edit/toggle/reset actions --->
<cfparam name="form.username" default="">                                                                       <!--- Define the default for the username on the add form --->
<cfparam name="form.password" default="">                                                                       <!--- Define the default for the password on add or reset password forms --->
<cfparam name="form.roleID" default="">                                                                         <!--- Define the default roleID for add and change-role actions --->

<cfset errors = []>                                                                                             <!--- Initialize the error list for when form input is invalid --->
<cfset errorMsg = "">                                                                                           <!--- Initialize the error message for database exceptions --->


<cfquery name="getRoles" datasource="84-pantry">                                                                <!--- Load all roles to be used in dropdowns on the add and edit forms --->
  SELECT RoleID, RoleName
  FROM tbl_Roles
  ORDER BY RoleName
</cfquery>


<!--- -----------------------------------------------------------------------
     Create new admin user
     ----------------------------------------------------------------------- --->
<cfif cgi.request_method EQ "POST" AND structKeyExists(form, "btnCreateUser")>                                  <!--- Ensure only available if the Create User button is clicked --->

  <cfset user = lcase(trim(form.username))>                                                                     <!--- Normalize username to lowercase with no whitespace --->
  <cfset passwd = form.password>                                                                                <!--- Capture the plain text password, hashed before storing into the databse --->
  <cfset role = trim(form.roleID)>                                                                              <!--- RoleID selected from the role dropdown --->

  <cfif len(user) LT 3>                                                                                         <!--- Enforce a minimum username length of 3 characters --->
     <cfset arrayAppend(errors, "Username must be at least 3 characters.")>
  </cfif>
  <cfif len(passwd) LT 10>                                                                                      <!--- Enforce a minimum password length of 10 characters --->
    <cfset arrayAppend(errors, "Password must be at least 10 characters.")>
  </cfif>
  <cfif NOT isNumeric(role) OR val(role) LTE 0>                                                                 <!--- Validate that a role was selected from the dropdown --->
    <cfset arrayAppend(errors, "A valid role must be selected.")>
  </cfif>

  <cfif arrayLen(errors) EQ 0>
    <cftry>
      <cfquery name="CheckExists" datasource="84-pantry">                                                        <!--- Check if the username exists before attempting the INSERT --->
        SELECT COUNT(*) AS count
        FROM tbl_AdminUsers
        WHERE username = <cfqueryparam value="#user#" cfsqltype="cf_sql_varchar" maxlength="50">
      </cfquery>

      <cfif val(CheckExists.count) GT 0>
        <cfset arrayAppend(errors, "That username is already taken.")>
      <cfelse>                                                                                                  <!--- Username is available, proceed with creating the new admin user, hash the password and insert into the database --->
                                                                                                                <!--- Hash the new password using PBKDF2WithHmacSHA256 --->
        <cfset iters = 210000>                                                                                  <!--- PBKDF2 iteration count — 210,000 per NIST SP 800-132 recommendation for SHA-256 --->
        <cfset keyBits = 256>                                                                                   <!--- Derived key length in bits --->
        <cfset saltHex = left(lcase(hash(createUUID() & now() & rand(), "SHA-256")), 32)>                       <!--- Generate a 16-byte (32 hex char) random salt --->
        <cfset saltBytes = binaryDecode(saltHex, "hex")>                                                        <!--- Decode hex salt to raw bytes for the Java key spec --->

        <cfset factory = createObject("java","javax.crypto.SecretKeyFactory").getInstance("PBKDF2WithHmacSHA256")> <!--- Obtain a PBKDF2WithHmacSHA256 key factory via the Java crypto API --->
        <cfset spec = createObject("java","javax.crypto.spec.PBEKeySpec").init( passwd.toCharArray(), saltBytes, javacast("int", iters), javacast("int", keyBits) )>
        <cfset derived = factory.generateSecret(spec).getEncoded()>                                             <!--- Derive the raw key bytes by running PBKDF2 with the supplied spec --->
        <cfset hash = lcase(binaryEncode(derived, "hex"))>                                                      <!--- Encode derived key bytes as lowercase hex string for storage --->

        <cfquery datasource="84-pantry">                                                                        <!--- Insert the new admin user with hashed password, salt, iteration count, and assigned role --->
          INSERT INTO tbl_AdminUsers (username, passwordHash, passwordSalt, passwordIters, isActive, RoleID)
          VALUES (
            <cfqueryparam value="#user#" cfsqltype="cf_sql_varchar"  maxlength="50">,
            <cfqueryparam value="#hash#" cfsqltype="cf_sql_varchar"  maxlength="255">,
            <cfqueryparam value="#saltHex#" cfsqltype="cf_sql_varchar" maxlength="64">,
            <cfqueryparam value="#iters#" cfsqltype="cf_sql_integer">,
            1,
            <cfqueryparam value="#val(role)#" cfsqltype="cf_sql_integer">
          )
        </cfquery>

        <cfquery datasource="84-pantry">                                                                        <!--- Add user creation event to the audit log --->
          INSERT INTO tbl_AdminAudit (username, eventType, ipAddress, details)
          VALUES (
            <cfqueryparam value="#session.admin.username#" cfsqltype="cf_sql_varchar" maxlength="50">,
            'USER_CREATED',
            <cfqueryparam value="#cgi.remote_addr#" cfsqltype="cf_sql_varchar" maxlength="45">,
            <cfqueryparam value="Created admin user: #user#" cfsqltype="cf_sql_varchar" maxlength="500">
          )
        </cfquery>

        <cflocation url="users.cfm?msg=created" addtoken="false">                                               <!--- Redirect to the user list with a success message after creation --->    
      </cfif>

      <cfcatch>                                                                                                 <!--- Catch unexpected database errors --->
        <cfset errorMsg = "Create failed: " & cfcatch.message>
        <cflog file="84FoodPantry" type="error"                                                                 <!--- Log the error details for troubleshooting --->
               text="users.cfm create failed. by=#session.admin.username# error=#cfcatch.message# detail=#cfcatch.detail#">
      </cfcatch>
    </cftry>
  </cfif>

  <cfset url.action = "add">                                                                                    <!--- Stay on the add view so validation errors are displayed with the form fields still populated --->
</cfif>


<!--- -----------------------------------------------------------------------
     Change role assignment for an admin user
     ----------------------------------------------------------------------- --->
<cfif cgi.request_method EQ "POST" AND structKeyExists(form, "btnChangeRole")>                                  <!--- Ensure only available if the Change Role button is clicked --->

  <cfif NOT structKeyExists(form,"adminID") OR NOT isNumeric(form.adminID) OR val(form.adminID) LTE 0>
    <cfset errorMsg = "Invalid admin user ID.">
  <cfelseif NOT isNumeric(form.roleID) OR val(form.roleID) LTE 0>
    <cfset errorMsg = "A valid role must be selected.">
  <cfelseif val(form.adminID) EQ session.admin.adminID>                                                         <!--- Guared enforced - a Global Admin may not change their own role --->
    <cfset errorMsg = "You cannot change your own role assignment.">
  <cfelse>
    <cftry>
      <cfquery datasource="84-pantry">                                                                          <!--- Update the role assignment for the target admin user --->
        UPDATE tbl_AdminUsers
        SET RoleID = <cfqueryparam value="#val(form.roleID)#" cfsqltype="cf_sql_integer">
        WHERE adminID = <cfqueryparam value="#val(form.adminID)#" cfsqltype="cf_sql_integer">
      </cfquery>

      <cfquery datasource="84-pantry">                                                                          <!--- Write role change event to audit log --->
        INSERT INTO tbl_AdminAudit (username, eventType, ipAddress, details)
        VALUES (
          <cfqueryparam value="#session.admin.username#" cfsqltype="cf_sql_varchar" maxlength="50">,
          'ROLE_CHANGED',
          <cfqueryparam value="#cgi.remote_addr#" cfsqltype="cf_sql_varchar" maxlength="45">,
          <cfqueryparam value="Changed role for adminID=#val(form.adminID)#" cfsqltype="cf_sql_varchar" maxlength="500">
        )
      </cfquery>

      <cflocation url="users.cfm?action=edit&id=#val(form.adminID)#&msg=rolechanged" addtoken="false">          <!--- Redirect back to the edit view with a success message after changing the role assignment --->

      <cfcatch>                                                                                                 <!--- Catch unexpected database errors --->
        <cfset errorMsg = "Role change failed: " & cfcatch.message>
        <cflog file="84FoodPantry" type="error"
               text="users.cfm role change failed. by=#session.admin.username# target=#val(form.adminID)# error=#cfcatch.message# detail=#cfcatch.detail#">
      </cfcatch>
    </cftry>
  </cfif>

  <cfset url.action = "edit">                                                                                   <!--- Stay on the edit view so errors are displayed with the form fields still populated --->
</cfif>


<!--- -----------------------------------------------------------------------
     Reset password for an admin user
     ----------------------------------------------------------------------- --->
<cfif cgi.request_method EQ "POST" AND structKeyExists(form, "btnResetPassword")>                               <!--- Ensure only available if the Reset Password button is clicked --->

  <cfif NOT structKeyExists(form,"adminID") OR NOT isNumeric(form.adminID) OR val(form.adminID) LTE 0>
    <cfset errorMsg = "Invalid admin user ID.">
  <cfelseif len(trim(form.password)) LT 10>
    <cfset errorMsg = "New password must be at least 10 characters.">
  <cfelse>
    <cftry>
      <cfset passwd = form.password>                                                                            <!--- Capture the new raw password for hashing --->

                                                                                                                <!--- Hash the new password using PBKDF2WithHmacSHA256 --->
      <cfset iters = 210000>                                                                                    <!--- PBKDF2 iteration count — 210,000 per NIST SP 800-132 recommendation for SHA-256 --->
      <cfset keyBits = 256>                                                                                     <!--- Derived key length in bits --->
      <cfset saltHex = left(lcase(hash(createUUID() & now() & rand(), "SHA-256")), 32)>                         <!--- Generate a fresh 16-byte random salt for the new password --->
      <cfset saltBytes = binaryDecode(saltHex, "hex")>                                                          <!--- Decode hex salt to raw bytes for the Java key spec --->

      <cfset factory = createObject("java","javax.crypto.SecretKeyFactory").getInstance("PBKDF2WithHmacSHA256")>
      <cfset spec = createObject("java","javax.crypto.spec.PBEKeySpec").init( passwd.toCharArray(), saltBytes, javacast("int", iters), javacast("int", keyBits) )>
      <cfset derived = factory.generateSecret(spec).getEncoded()>                                               <!--- Run PBKDF2 to derive the key bytes from the new password --->
      <cfset hash = lcase(binaryEncode(derived, "hex"))>                                                        <!--- Encode derived key bytes as lowercase hex for storage --->

      <cfquery datasource="84-pantry">                                                                          <!--- Update the admin user's password information with the new hashed value --->
        UPDATE tbl_AdminUsers
        SET passwordHash = <cfqueryparam value="#hash#" cfsqltype="cf_sql_varchar"  maxlength="255">,
            passwordSalt = <cfqueryparam value="#saltHex#" cfsqltype="cf_sql_varchar" maxlength="64">,
            passwordIters = <cfqueryparam value="#iters#" cfsqltype="cf_sql_integer">
        WHERE adminID = <cfqueryparam value="#val(form.adminID)#" cfsqltype="cf_sql_integer">
      </cfquery>

      <cfquery datasource="84-pantry">                                                                          <!--- Write password change event to the audit log --->
        INSERT INTO tbl_AdminAudit (username, eventType, ipAddress, details)
        VALUES (
          <cfqueryparam value="#session.admin.username#" cfsqltype="cf_sql_varchar" maxlength="50">,
          'PASSWORD_RESET',
          <cfqueryparam value="#cgi.remote_addr#" cfsqltype="cf_sql_varchar" maxlength="45">,
          <cfqueryparam value="Password reset for adminID=#val(form.adminID)#" cfsqltype="cf_sql_varchar" maxlength="500">
        )
      </cfquery>

      <cflocation url="users.cfm?action=edit&id=#val(form.adminID)#&msg=pwreset" addtoken="false">              <!--- Redirect back to the edit view with a success message after updating the password --->

      <cfcatch>                                                                                                 <!--- Catch unexpected database errors --->                        
        <cfset errorMsg = "Password reset failed: " & cfcatch.message>
        <cflog file="84FoodPantry" type="error"
               text="users.cfm password reset failed. by=#session.admin.username# target=#val(form.adminID)# error=#cfcatch.message# detail=#cfcatch.detail#">
      </cfcatch>
    </cftry>
  </cfif>

  <cfset url.action = "edit">                                                                                   <!--- Stay on the edit view so the error is displayed --->
</cfif>


<!--- -----------------------------------------------------------------------
     Deactivete or reactivate an admin user
     ----------------------------------------------------------------------- --->
<cfif cgi.request_method EQ "POST" AND structKeyExists(form, "btnToggleStatus")>                                <!--- Ensure only available if the Deactivate or Activate button is clicked --->

  <cfif NOT structKeyExists(form,"adminID") OR NOT isNumeric(form.adminID) OR val(form.adminID) LTE 0>
    <cfset errorMsg = "Invalid admin user ID.">
  <cfelse>
    <cftry>
      <cfquery name="getCurrent" datasource="84-pantry">                                                        <!--- Load the current activation state before computing the toggle --->
        SELECT adminID, isActive, username
        FROM tbl_AdminUsers
        WHERE adminID = <cfqueryparam value="#val(form.adminID)#" cfsqltype="cf_sql_integer">
      </cfquery>

      <cfif getCurrent.recordCount EQ 0>
        <cfset errorMsg = "User not found.">
      <cfelseif val(form.adminID) EQ session.admin.adminID AND getCurrent.isActive EQ 1>                        <!--- Guared enforced - a Global Admin may not deactivate their own account --->
        <cfset errorMsg = "You cannot deactivate your own account.">
      <cfelse>
        <cfset newStatus = (getCurrent.isActive EQ 1) ? 0 : 1>                                                  <!--- Change the activation state: 1 becomes 0, 0 becomes 1 --->
        <cfset eventType = (newStatus EQ 1) ? "USER_ACTIVATED" : "USER_DEACTIVATED">                            <!--- Resolve the audit event label from the new status value --->

        <cfquery datasource="84-pantry">                                                                        <!--- Write the toggled activation state back to tbl_AdminUsers --->
          UPDATE tbl_AdminUsers
          SET isActive = <cfqueryparam value="#newStatus#" cfsqltype="cf_sql_bit">
          WHERE adminID = <cfqueryparam value="#val(form.adminID)#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfquery datasource="84-pantry">                                                                        <!--- Write status change to the audit log --->
          INSERT INTO tbl_AdminAudit (username, eventType, ipAddress, details)
          VALUES (
            <cfqueryparam value="#session.admin.username#" cfsqltype="cf_sql_varchar" maxlength="50">,
            <cfqueryparam value="#eventType#" cfsqltype="cf_sql_varchar" maxlength="50">,
            <cfqueryparam value="#cgi.remote_addr#" cfsqltype="cf_sql_varchar" maxlength="45">,
            <cfqueryparam value="#eventType# for adminID=#val(form.adminID)#" cfsqltype="cf_sql_varchar" maxlength="500">
          )
        </cfquery>

        <cflocation url="users.cfm?action=edit&id=#val(form.adminID)#&msg=statuschanged" addtoken="false">      <!--- Redirect back to the edit view with a success message after changing the activation state --->
      </cfif>

      <cfcatch>                                                                                                 <!--- Catch unexpected database errors --->
        <cfset errorMsg = "Status toggle failed: " & cfcatch.message>
        <cflog file="84FoodPantry" type="error"
               text="users.cfm status toggle failed. by=#session.admin.username# target=#val(form.adminID)# error=#cfcatch.message# detail=#cfcatch.detail#">
      </cfcatch>
    </cftry>
  </cfif>

  <cfset url.action = "edit">                                                                                   <!--- Stay on the edit view so the error is displayed --->
</cfif>


<!--- -----------------------------------------------------------------------
     Load data for the edit view
     ----------------------------------------------------------------------- --->
<cfif url.action EQ "edit">

  <cfif NOT isNumeric(url.id) OR val(url.id) LTE 0>                                                             <!--- Reject non-numeric or zero IDs immediately --->
    <cflocation url="users.cfm?msg=badid" addtoken="false">
  </cfif>

  <cfquery name="targetUser" datasource="84-pantry">                                                            <!--- Load the target admin user with their current role for the edit form --->
    SELECT usr.adminID, usr.username, usr.isActive, usr.lastLoginAt, usr.RoleID, role.RoleName
    FROM tbl_AdminUsers usr
    INNER JOIN tbl_Roles role ON role.RoleID = usr.RoleID
    WHERE  usr.adminID = <cfqueryparam value="#val(url.id)#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfif targetUser.recordCount NEQ 1>                                                                           <!--- Redirect if the user was not found to prevent rendering an empty edit form --->
    <cflocation url="users.cfm?msg=notfound" addtoken="false">
  </cfif>

</cfif>

<!--- -----------------------------------------------------------------------
     Load admin user list
     ----------------------------------------------------------------------- --->
<cfquery name="allUsers" datasource="84-pantry">                                                                  <!--- Load all admin users with their role names for the user list table --->
  SELECT usr.adminID, usr.username, usr.isActive, usr.lastLoginAt, usr.RoleID, role.RoleName
  FROM tbl_AdminUsers  usr
  INNER JOIN tbl_Roles role ON role.RoleID = usr.RoleID
  ORDER BY usr.username
</cfquery>


<!doctype html>
<html>                                                                                                          <!--- Admin user management page: list, add, and edit views for admin accounts --->
<head>
  <meta charset="utf-8">
  <title>Admin Users | 84 Food Pantry Admin</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>                                                                                                       <!--- Page-specific CSS for the admin user management interface --->
    * { box-sizing: border-box; }
    body { font-family: Arial, sans-serif; background:#f6f7f8; margin:0; padding:20px; }
    .wrap { max-width:980px; margin:0 auto; }
    .card { background:#fff; border:1px solid #e6e6e6; border-radius:12px; padding:18px; box-shadow:0 2px 10px rgba(0,0,0,.04); }
    .top { display:flex; justify-content:space-between; align-items:center; gap:12px; flex-wrap:wrap; }
    .headerLeft { display:flex; align-items:center; gap:12px; }
    .logo { height:62px; width:auto; display:block; }
    .muted { color:#777; }
    .rowbtns { display:flex; gap:8px; flex-wrap:wrap; }
    .btn { display:inline-block; padding:10px 12px; border-radius:10px; background:#2f7d32; color:#fff; text-decoration:none; font-weight:700; border:none; cursor:pointer; font-size:14px; }
    .btn.gray { background:#546e7a; }
    .btn.blue { background:#1565c0; }
    .btn.red { background:#c62828; }
    .btn.orange { background:#ef6c00; }
    .btn.sm { padding:6px 10px; font-size:13px; }
    table { width:100%; border-collapse:collapse; margin-top:14px; }
    th, td { text-align:left; padding:10px; border-bottom:1px solid #eee; vertical-align:middle; }
    th { background:#fafafa; font-weight:700; }
    .badge { display:inline-block; padding:2px 8px; border-radius:999px; font-size:12px; font-weight:700; }
    .badge.active { background:#e8f5e9; color:#1b5e20; border:1px solid #c8e6c9; }
    .badge.inactive { background:#ffebee; color:#b71c1c; border:1px solid #ffcdd2; }
    .badge.role { background:#e3f2fd; color:#0d47a1; border:1px solid #bbdefb; }
    .badge.you { background:#fff8e1; color:#8a6d00; border:1px solid #ffe0b2; }
    .ok { background:#e8f5e9; border:1px solid #c8e6c9; padding:10px; border-radius:10px; color:#1b5e20; margin:10px 0; }
    .bad { background:#ffebee; border:1px solid #ffcdd2; padding:10px; border-radius:10px; color:#b71c1c; margin:10px 0; }
    .section-divider { border:none; border-top:1px solid #eee; margin:18px 0; }
    .editSection { border:1px solid #eee; border-radius:12px; padding:14px; margin-top:14px; background:#fafafa; }
    .editSection h3 { margin:0 0 12px; font-size:15px; }
    label { display:block; font-weight:600; margin:10px 0 4px; }
    input[type=text], input[type=password], select { width:100%; padding:10px; font-size:15px; border:1px solid #cfd6dd; border-radius:10px; background:#fff; }
    input[type=text]:focus, input[type=password]:focus, select:focus { outline:none; border-color:#1565c0; }
    .selfNote { color:#ef6c00; font-size:13px; margin-top:6px; }
  </style>
</head>
<body>

<div class="wrap">                                                                                              <!--- Outer page wrapper for centered admin content --->
  <div class="card">                                                                                            <!--- Main user management card containing toolbar, forms, and user list --->

    <div class="top">                                                                                           <!--- Top header row with branding and page-level action buttons --->
      <div class="headerLeft">                                                                                  <!--- Left side: logo link and page title --->
        <a href="index.cfm">
          <img src="../img/logo.png" alt="84 Food Pantry" class="logo">
        </a>
        <div>
          <h2 style="margin:0;">Admin Users</h2>
          <div class="muted">
            <cfif url.action EQ "add">
              Add new admin account
            <cfelseif url.action EQ "edit">
              <cfoutput>Edit: #encodeForHTML(targetUser.username)#</cfoutput>
            <cfelse>
              Manage admin user accounts and roles
            </cfif>
          </div>
        </div>
      </div>

      <div class="rowbtns">                                                                                     <!--- Right side: navigation and add-user action buttons --->
        <a class="btn gray" href="index.cfm">Admin Home</a>
        <cfif url.action NEQ "add">
          <a class="btn" href="users.cfm?action=add">Add User</a>
        </cfif>
        <cfif url.action NEQ "list">
          <a class="btn gray" href="users.cfm">Reset View</a>
        </cfif>
      </div>
    </div>

    
    <cfif url.msg EQ "created">                                                                                 <!--- Status and error message banners --->
      <div class="ok">Admin user created successfully.</div>
    <cfelseif url.msg EQ "rolechanged">
      <div class="ok">Role updated successfully.</div>
    <cfelseif url.msg EQ "pwreset">
      <div class="ok">Password reset successfully.</div>
    <cfelseif url.msg EQ "statuschanged">
      <div class="ok">Account status updated.</div>
    <cfelseif url.msg EQ "badid">
      <div class="bad">Invalid user ID.</div>
    <cfelseif url.msg EQ "notfound">
      <div class="bad">Admin user not found.</div>
    </cfif>

    <cfif len(errorMsg)>                                                                                        <!--- Show the error when a database or validation exception occurred --->
      <div class="bad"><cfoutput>#encodeForHTML(errorMsg)#</cfoutput></div>
    </cfif>

    <cfif arrayLen(errors) GT 0>                                                                                <!--- Show the full validation error list when form input is invalid --->
      <div class="bad">
        Please fix:
        <ul style="margin:8px 0 0 18px;">
          <cfloop array="#errors#" index="e">
            <li><cfoutput>#encodeForHTML(e)#</cfoutput></li>
          </cfloop>
        </ul>
      </div>
    </cfif>


    <!--- ===================================================================
         VIEW: New admin user creation
         =================================================================== --->
    <cfif url.action EQ "add">

      <hr class="section-divider">
      <h3 style="margin:0 0 12px;">Add Admin User</h3>

      <form method="post" action="users.cfm?action=add" autocomplete="off">                                     <!--- Add user form posts to the same endpoint with action=add --->

        <label for="username">Username</label>
        <input id="username" name="username" type="text"
               value="<cfoutput>#encodeForHTMLAttribute(form.username)#</cfoutput>"
               maxlength="50" required>

        <label for="password">Password <span class="muted" style="font-weight:normal;">(min 10 characters)</span></label>
        <input id="password" name="password" type="password" minlength="10" required>

        <label for="roleID">Role</label>
        <select id="roleID" name="roleID" required>
          <option value="">— select a role —</option>
          <cfoutput query="getRoles">
            <option value="#RoleID#"
              <cfif toString(form.roleID) EQ toString(RoleID)> selected</cfif>>#encodeForHTML(RoleName)#</option>
          </cfoutput>
        </select>

        <div class="rowbtns" style="margin-top:14px;">
          <button class="btn" type="submit" name="btnCreateUser" value="1">Create User</button>
          <a class="btn gray" href="users.cfm">Cancel</a>
        </div>

      </form>

    </cfif>


    <!--- ===================================================================
         VIEW: Change role, reset password, status
         =================================================================== --->
    <cfif url.action EQ "edit">

      <hr class="section-divider">

      
      <cfoutput>                                                                                                <!--- Current user summary --->
        <p style="margin:0 0 12px;">
          <strong>#encodeForHTML(targetUser.username)#</strong>
          &nbsp;<span class="badge role">#encodeForHTML(targetUser.RoleName)#</span>
          &nbsp;<cfif targetUser.isActive EQ 1>
                  <span class="badge active">Active</span>
                <cfelse>
                  <span class="badge inactive">Inactive</span>
                </cfif>
          <cfif targetUser.adminID EQ session.admin.adminID>
            &nbsp;<span class="badge you">You</span>
          </cfif>
          <br><span class="muted" style="font-size:13px;">
            Last login:
            <cfif NOT isNull(targetUser.lastLoginAt) AND len(trim(toString(targetUser.lastLoginAt)))>
              #dateFormat(targetUser.lastLoginAt,"mm/dd/yyyy")# #timeFormat(targetUser.lastLoginAt,"h:nn tt")#
            <cfelse>
              Never
            </cfif>
          </span>
        </p>
      </cfoutput>

      <div class="editSection">                                                                                 <!--- Role assignment section — disabled for self to prevent privilege self-escalation --->
        <h3>Change Role</h3>

        <cfif targetUser.adminID EQ session.admin.adminID>                                                      <!--- SAFETY GUARD: hide the change-role form for the currently logged in user --->
          <div class="selfNote">&#9888; You cannot change your own role assignment.</div>
        <cfelse>
          <form method="post" action="users.cfm?action=edit&id=<cfoutput>#targetUser.adminID#</cfoutput>" autocomplete="off">
            <input type="hidden" name="adminID" value="<cfoutput>#targetUser.adminID#</cfoutput>">

            <label for="roleID_edit">Role</label>
            <select id="roleID_edit" name="roleID">
              <cfoutput query="getRoles">
                <option value="#RoleID#" <cfif RoleID EQ targetUser.RoleID> selected</cfif>>#encodeForHTML(RoleName)#</option>
              </cfoutput>
            </select>

            <div style="margin-top:12px;">
              <button class="btn blue" type="submit" name="btnChangeRole" value="1">Save Role</button>
            </div>
          </form>
        </cfif>
      </div>

      <div class="editSection">                                                                                 <!--- Password reset section — available for any user including self --->
        <h3>Reset Password</h3>

        <form method="post" action="users.cfm?action=edit&id=<cfoutput>#targetUser.adminID#</cfoutput>" autocomplete="off">
          <input type="hidden" name="adminID" value="<cfoutput>#targetUser.adminID#</cfoutput>">

          <label for="newPassword">New Password <span class="muted" style="font-weight:normal;">(min 10 characters)</span></label>
          <input id="newPassword" name="password" type="password" minlength="10" required>

          <div style="margin-top:12px;">
            <button class="btn orange" type="submit" name="btnResetPassword" value="1"
                    onclick="return confirm('Reset the password for this user?');">Reset Password</button>
          </div>
        </form>
      </div>

      <div class="editSection">                                                                                 <!--- Status toggle section — blocked for self-deactivation at the server level --->
        <h3>Account Status</h3>

        <cfif targetUser.adminID EQ session.admin.adminID>                                                      <!--- Guard enforced - display informational note, can't change own status --->
          <div class="selfNote">&#9888; You cannot deactivate your own account.</div>
        <cfelse>
          <form method="post" action="users.cfm?action=edit&id=<cfoutput>#targetUser.adminID#</cfoutput>">
            <input type="hidden" name="adminID" value="<cfoutput>#targetUser.adminID#</cfoutput>">

            <cfif targetUser.isActive EQ 1>
              <p class="muted" style="margin:0 0 10px; font-size:13px;">This account is currently <strong>Active</strong>.  Deactivating it will prevent login.</p>
              <button class="btn red" type="submit" name="btnToggleStatus" value="1"
                      onclick="return confirm('Deactivate this admin user account?');">Deactivate Account</button>
            <cfelse>
              <p class="muted" style="margin:0 0 10px; font-size:13px;">This account is currently <strong>Inactive</strong>.</p>
              <button class="btn" type="submit" name="btnToggleStatus" value="1">Activate Account</button>
            </cfif>
          </form>
        </cfif>
      </div>

    </cfif>


    <!--- ===================================================================
         List all admin users with their username, role, status, last login, and edit link
         =================================================================== --->
    <hr class="section-divider">
    <h3 style="margin:0 0 10px;">All Admin Users</h3>

    <table>                                                                                                     <!--- Admin user list table showing username, role, status, last login, and edit link --->
      <thead>
        <tr>
          <th>Username</th>
          <th>Role</th>
          <th>Status</th>
          <th>Last Login</th>
          <th style="width:90px;">Actions</th>
        </tr>
      </thead>
      <tbody>
        <cfoutput query="allUsers">
          <tr>
            <td>
              #encodeForHTML(username)#
              <cfif adminID EQ session.admin.adminID>
                &nbsp;<span class="badge you">You</span>
              </cfif>
            </td>
            <td><span class="badge role">#encodeForHTML(RoleName)#</span></td>
            <td>
              <cfif isActive EQ 1>
                <span class="badge active">Active</span>
              <cfelse>
                <span class="badge inactive">Inactive</span>
              </cfif>
            </td>
            <td class="muted" style="font-size:13px;">
              <cfif NOT isNull(lastLoginAt) AND len(trim(toString(lastLoginAt)))>
                #dateFormat(lastLoginAt,"mm/dd/yyyy")# #timeFormat(lastLoginAt,"h:nn tt")#
              <cfelse>
                Never
              </cfif>
            </td>
            <td>
              <a class="btn gray sm" href="users.cfm?action=edit&id=#adminID#">Edit</a>
            </td>
          </tr>
        </cfoutput>
        <cfif allUsers.recordCount EQ 0>
          <tr><td colspan="5" class="muted">No admin users found.</td></tr>
        </cfif>
      </tbody>
    </table>

  </div>
</div>

</body>
</html>
