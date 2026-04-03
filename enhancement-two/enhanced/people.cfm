<!--- ================================================================================
    Author:      Scott Slagle
    File:        people.cfm
    Application: 84 Community Food Pantry - Test Site (Admin)
    Created:     02/07/2026

    Purpose:
      This program manages recipient records in tbl_People for admin users.  It supports list, add, edit, soft-delete (set Inactive), and print workflows with validation,
      safe parameterized SQL, and status-filtered print output.

    Changelog:
    02/07/2026 - Initial Development - created people admin management page.
    02/14/2026 - Added print view and actions; implemented soft-delete by setting status to Inactive.
    03/21/2026 - Added householdSize, annualIncome fields; added eligibility_engine.cfm to calculate eligibility tier for every add and edit.
                 Added eligibility tier to printed people list with color formatting for each tier, changed notes to be a blank space.
    ================================================================================ --->

<cfinclude template="_auth.cfm">                                                                                <!--- Require a valid admin session before allowing people management access --->
<cfsetting showdebugoutput="false">                                                                             <!--- Suppress ColdFusion debug output in the browser --->

<cfparam name="url.action" default="list">                                                                      <!--- list | add | edit | print --->
<cfparam name="url.id" default="">                                                                              <!--- Optional personID used for edit mode --->
<cfparam name="url.msg" default="">                                                                             <!--- Optional status message token rendered as a banner --->
<cfparam name="url.filter" default="all">                                                                       <!--- all | notext --->


<cfif NOT listFindNoCase("list,add,edit,print", url.action)>                                                    <!--- Ensure valid values; default to list --->  
  <cfset url.action = "list">
</cfif>


<cfif NOT listFindNoCase("all,notext", url.filter)>                                                             <!--- Ensure valid view action; default to all --->          
  <cfset url.filter = "all">
</cfif>

<cfparam name="form.personID" default="">                                                                       <!--- Hidden personID field used on edit/delete POST actions --->
<cfparam name="form.firstName" default="">                                                                      <!--- Submitted first name field --->
<cfparam name="form.lastName" default="">                                                                       <!--- Submitted last name field --->
<cfparam name="form.phone" default="">                                                                          <!--- Submitted phone field (normalized to digits before save) --->

<cfparam name="form.isActive" default="1">                                                                      <!--- Submitted status field; defaults to 1 --->
<cfparam name="form.householdSize" default="">                                                                  <!--- Submitted household size field --->
<cfparam name="form.annualIncome" default="">                                                                   <!--- Submitted annual gross income field --->


<cfset errors = []>                                                                                             <!--- Validation error list rendered for add/edit form submissions --->
<cfset errorMsg = "">                                                                                           <!--- Single error message for save/delete exceptions --->


<cfif cgi.request_method EQ "POST" AND structKeyExists(form, "btnSave")>                                        <!--- Save action triggered by btnSave on the form --->    

  <cfset fName = trim(form.firstName)>
  <cfset lName = trim(form.lastName)>
  <cfset pDigits = rereplace(trim(form.phone), "[^0-9]", "", "all")>
  <cfset status = trim(toString(form.isActive))>
  <cfset fHouseholdSize = trim(form.householdSize)>                                                             <!--- Trimmed household size from form submission --->
  <cfset fAnnualIncome = trim(form.annualIncome)>                                                               <!--- Trimmed annual income from form submission --->


  <cfif len(fName) EQ 0>                                                                                        <!--- Input validation with friendly error messages added to the errors array --->
    <cfset arrayAppend(errors, "First name is required.")>
  </cfif>
  <cfif len(lName) EQ 0>
    <cfset arrayAppend(errors, "Last name is required.")>
  </cfif>
  <cfif len(pDigits) NEQ 10>
    <cfset arrayAppend(errors, "Phone number must be 10 digits.")>
  </cfif>
  <cfif NOT isNumeric(fHouseholdSize) OR val(fHouseholdSize) LT 1 OR val(fHouseholdSize) GT 20>                 <!--- Verify householdSize must be a whole number from 1 to 20 --->
    <cfset arrayAppend(errors, "Household size must be a number between 1 and 20.")>
  </cfif>
  <cfif NOT isNumeric(fAnnualIncome) OR val(fAnnualIncome) LT 0>                                                <!--- Verify annualIncome must be a non-negative number --->
    <cfset arrayAppend(errors, "Annual income must be a number greater than or equal to 0.")>
  </cfif>


  <cfif NOT listFind("1,2,3", status)>                                                                          <!--- Validate status against allowed values (1=Active, 2=No Text, 3=Inactive) --->
     <cfset arrayAppend(errors, "Invalid status value.")>   
    <cfset arrayAppend(errors, "Invalid status value.")>
  </cfif>


  <cfif url.action EQ "edit" AND (NOT structKeyExists(form,"personID") OR NOT isNumeric(form.personID) OR val(form.personID) LTE 0)>  <!--- Additional validation for edit action to ensure a valid personID is provided --->
     <cfset arrayAppend(errors, "Invalid person ID.")>
    <cfset arrayAppend(errors, "Invalid person ID.")>
  </cfif>

  <cfif arrayLen(errors) EQ 0>                                                                                  <!--- Only attempt database save if validation passed with no errors --->      
    <cftry>
      <cfif url.action EQ "add">
        <cfquery name="NewID" datasource="84-pantry">
          INSERT INTO dbo.tbl_People (firstName, lastName, phone, isActive, householdSize, annualIncome, createdAt)
          OUTPUT INSERTED.personID
          VALUES (
            <cfqueryparam value="#fName#" cfsqltype="cf_sql_varchar" maxlength="50">,
            <cfqueryparam value="#lName#" cfsqltype="cf_sql_varchar" maxlength="50">,
            <cfqueryparam value="#pDigits#" cfsqltype="cf_sql_varchar" maxlength="10">,
            <cfqueryparam value="#val(status)#" cfsqltype="cf_sql_tinyint">,
            <cfqueryparam value="#val(fHouseholdSize)#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#val(fAnnualIncome)#" cfsqltype="cf_sql_decimal">,
            <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
          )
        </cfquery>
        <cfset eligibility_personID = val(NewID.personID)>                                                      <!--- Pass the new personID to the eligibility engine include --->
        <cfinclude template="eligibility_engine.cfm">                                                           <!--- Run eligibility calculation immediately after insert --->
        <cfif eligibility_success>
          <cflocation url="people.cfm?msg=added" addtoken="false">
        <cfelse>
          <cfset errorMsg = "Person added but eligibility could not be calculated.">
        </cfif>

      <cfelseif url.action EQ "edit">
        <cfquery datasource="84-pantry">                                                                        <!--- Update the person record --->
          UPDATE dbo.tbl_People
          SET
            firstName = <cfqueryparam value="#fName#" cfsqltype="cf_sql_varchar" maxlength="50">,
            lastName = <cfqueryparam value="#lName#" cfsqltype="cf_sql_varchar" maxlength="50">,
            phone = <cfqueryparam value="#pDigits#" cfsqltype="cf_sql_varchar" maxlength="10">,
            isActive = <cfqueryparam value="#val(status)#" cfsqltype="cf_sql_tinyint">,
            householdSize = <cfqueryparam value="#val(fHouseholdSize)#" cfsqltype="cf_sql_integer">,
            annualIncome = <cfqueryparam value="#val(fAnnualIncome)#" cfsqltype="cf_sql_decimal">,
            updatedAt = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
          WHERE personID = <cfqueryparam value="#val(form.personID)#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset eligibility_personID = val(form.personID)>                                                       <!--- Pass the existing personID to the eligibility engine include --->
        <cfinclude template="eligibility_engine.cfm">                                                           <!--- Re-run eligibility calculation after every edit save --->
        <cfif eligibility_success>
          <cflocation url="people.cfm?msg=updated" addtoken="false">
        <cfelse>
          <cfset errorMsg = "Person updated but eligibility could not be calculated.">
        </cfif>
      </cfif>

      <cfcatch>                                                                                                 <!--- Catch any exceptions during database operations and log the error details --->
         <cfset errorMsg = "Save failed: " & cfcatch.message> 
        <cfset errorMsg = "Save failed: " & cfcatch.message>
        <cflog file="84FoodPantry" type="error"
               text="People save failed. action=#url.action# id=#form.personID# error=#cfcatch.message# detail=#cfcatch.detail#">
      </cfcatch>
    </cftry>
  </cfif>
</cfif>


<cfif cgi.request_method EQ "POST" AND structKeyExists(form, "btnDelete")>                                      <!--- Delete action triggered by btnDelete on the form; set isActive to 3 --->
  <cfif NOT structKeyExists(form,"personID") OR NOT isNumeric(form.personID) OR val(form.personID) LTE 0>
    <cfset errorMsg = "Invalid person ID.">
  <cfelse>
    <cftry>
      <cfquery datasource="84-pantry">
        UPDATE dbo.tbl_People
	SET isActive = 3, updatedAt = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
        WHERE personID = <cfqueryparam value="#val(form.personID)#" cfsqltype="cf_sql_integer">
      </cfquery>
      <cflocation url="people.cfm?msg=deleted" addtoken="false">

      <cfcatch>                                                                                                 <!--- Catch any exceptions during the delete operation and log the error details --->
         <cfset errorMsg = "Set inactive failed: " & cfcatch.message>
        <cfset errorMsg = "Set inactive failed: " & cfcatch.message>
        <cflog file="84FoodPantry" type="error"
               text="People set inactive failed. id=#form.personID# error=#cfcatch.message# detail=#cfcatch.detail#">
      </cfcatch>
    </cftry>
  </cfif>
</cfif>


<cfif url.action EQ "edit">                                                                                     <!--- Edit action - load the existing record to prepopulate the form --->
  <cfif NOT isNumeric(url.id) OR val(url.id) LTE 0>
    <cflocation url="people.cfm?msg=badid" addtoken="false">
  </cfif>

  <cfquery name="getOne" datasource="84-pantry">                                                                <!--- Load the existing person record for the provided ID --->
    SELECT personID, firstName, lastName, phone, isActive,
           householdSize, annualIncome, eligibilityTier, eligibleFlag, FPL_Percent, FPL_Amt, eligibilityUpdatedAt
    FROM dbo.tbl_People
    WHERE personID = <cfqueryparam value="#val(url.id)#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfif getOne.recordCount NEQ 1>                                                                               <!--- Abort if the record was not found to prevent rendering the edit form with empty data --->
     <cflocation url="people.cfm?msg=notfound" addtoken="false">
  </cfif>

  
  <cfif cgi.request_method EQ "GET">                                                                            <!--- Only prepopulate the form fields on a GET request to avoid overwriting submitted values after a failed validation on POST --->
    <cfset form.personID = getOne.personID>
    <cfset form.firstName = getOne.firstName>
    <cfset form.lastName = getOne.lastName>
    <cfset form.phone = getOne.phone>
    <cfset form.isActive = getOne.isActive>
    <cfset form.householdSize = getOne.householdSize>                                                           <!--- Prepopulate householdSize from the existing record on GET --->
    <cfset form.annualIncome = getOne.annualIncome>                                                             <!--- Prepopulate annualIncome from the existing record on GET --->

  </cfif>
</cfif>



<cfquery name="getPeople" datasource="84-pantry">                                                               <!--- Main list for screen all people --->
  SELECT personID, firstName, lastName, phone, isActive, eligibilityTier
  FROM dbo.tbl_People
  ORDER BY lastName, firstName
</cfquery>


<cfif url.action EQ "print">                                                                                    <!--- Print action uses a different query and structure for printer-friendly output --->     
  <cfquery name="printList" datasource="84-pantry">
    SELECT personID, firstName, lastName, phone, isActive, eligibilityTier
    FROM dbo.tbl_People
    WHERE 1=1
    <cfif url.filter EQ "notext">
      AND isActive = 2
    </cfif>
    ORDER BY lastName, firstName
  </cfquery>

  <!doctype html>
  <html>
  <head>
    <meta charset="utf-8">
    <title>People - Print</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>                                                                                                     <!--- Styles specific to the print view --->
      body { font-family: Arial, sans-serif; margin: 18px; color:#111; }
      h1 { margin: 0; font-size: 20px; }
      .sub { margin: 6px 0 14px; color:#444; font-size: 13px; }
      table { width:100%; border-collapse: collapse; }
      th, td { padding: 8px 10px; border-bottom: 1px solid #ddd; font-size: 13px; }
      th { text-align:left; background:#f3f3f3; }
      .right { text-align:right; }
      .muted { color:#666; }
      @media print {
        body { margin: 0.5in; }
        .noprint { display:none !important; }
      }
    </style>
  </head>
  <body>
    <div class="noprint" style="margin-bottom:10px;">                                                           <!--- Print toolbar hidden by @media print for clean printout --->
      <button onclick="window.print();">Print</button>
      <button onclick="window.close();">Close</button>
    </div>

    <cfoutput>
      <h1>
        #(url.filter EQ "notext" ? "People List - No Text (Call These People)" : "People List - All")#
      </h1>
      <div class="sub">
        Printed: #dateFormat(now(),"mmmm d, yyyy")# #timeFormat(now(),"h:nn tt")#
        &nbsp;|&nbsp; Total: #printList.recordCount#
      </div>
    </cfoutput>

    <table>
      <thead>
        <tr>
          <th style="width:38%;">Name</th>
          <th style="width:22%;">Phone</th>
          <th style="width:20%;">Status</th>
          <th style="width:20%;">Eligibility Tier</th>
          <th class="right" style="width:20%;">Notes</th>
        </tr>
      </thead>
      <tbody>
        <cfoutput query="printList">
          <tr>
            <td>#encodeForHTML(lastName)#, #encodeForHTML(firstName)#</td>
            <td>#encodeForHTML(phone)#</td>
            <td>
              <cfif isActive EQ 1>
                Active
              <cfelseif isActive EQ 2>
                No Text
              <cfelse>
                Inactive
              </cfif>
            </td>
            <td>
              <cfif NOT len(trim(toString(eligibilityTier)))>                                                   <!--- Eligibility Tier Results formatted for print output --->
                Pending
              <cfelseif eligibilityTier EQ 1>
                <font color="green">Tier 1</font>
              <cfelseif eligibilityTier EQ 2>
                <font color="blue">Tier 2</font>
              <cfelseif eligibilityTier EQ 3>
                <font color="orange">Tier 3</font>
              <cfelse>
                <font color="red">Not Eligible</font>
              </cfif>
            </td>
            <td class="right muted">&nbsp;</td>
          </tr>
        </cfoutput>
        <cfif printList.recordCount EQ 0>
          <tr><td colspan="4" class="muted">No records found.</td></tr>
        </cfif>
      </tbody>
    </table>

    <script>
      window.onload = function(){ window.print(); };                                                            // Auto-open print dialog when page loads
    </script>
  </body>
  </html>

  <cfabort>
</cfif>

<!doctype html>
<html>                                                                                                          <!--- Main HTML structure for list/add/edit views --->
  <head>
    <meta charset="utf-8">
    <title>People</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>                                                                                                     <!--- Page-specific CSS for the admin people management interface --->
      * { box-sizing: border-box; }
      body { font-family: Arial, sans-serif; background:#f6f7f8; margin:0; padding:20px; }
      .wrap { max-width:980px; margin:0 auto; }
      .card { background:#fff; border:1px solid #e6e6e6; border-radius:12px; padding:18px; box-shadow:0 2px 10px rgba(0,0,0,.04); }
      .top { display:flex; justify-content:space-between; align-items:center; gap:12px; flex-wrap:wrap; }
      .btn { display:inline-block; padding:10px 12px; border-radius:10px; background:#2f7d32; color:#fff; text-decoration:none; font-weight:700; border:none; cursor:pointer; }
      .btn.gray { background:#546e7a; }
      .btn.blue { background:#1565c0; }
      .btn.orange { background:#ef6c00; }
      .btn.red { background:#c62828; }
      table { width:100%; border-collapse: collapse; margin-top:14px; }
      th, td { text-align:left; padding:10px; border-bottom:1px solid #eee; }
      th { background:#fafafa; }
      .muted { color:#777; }
      .badge { display:inline-block; padding:2px 8px; border-radius:999px; font-size:12px; font-weight:700; }

      .on { background:#e8f5e9; color:#1b5e20; border:1px solid #c8e6c9; }
      .notext { background:#fff8e1; color:#8a6d00; border:1px solid #ffe0b2; }
      .off { background:#ffebee; color:#b71c1c; border:1px solid #ffcdd2; }
      .headerLeft { display:flex; align-items:center; gap:12px; }
      .logo { height:62px; width:auto; display:block; }
      .rowbtns { display:flex; gap:8px; flex-wrap:wrap; }
      .alert {}
    </style>
</head>
<body>
<div class="wrap">                                                                                              <!--- Outer page wrapper for centered admin content --->
  <div class="card">                                                                                            <!--- Main People management card containing toolbar, forms, and list --->

    <div class="top">                                                                                           <!--- Top header row with logo and page-level actions --->
      <div class="headerLeft">                                                                                  <!--- Left side: logo link and page title --->
        <a href="index.cfm">
          <img src="../img/logo.png" alt="84 Food Pantry" class="logo">
        </a>
        <div>
          <h2 style="margin:0;">People</h2>
          <div class="muted">Add / edit recipients</div>
        </div>
      </div>

      <div class="rowbtns">                                                                                     <!--- Right side: navigation and print action buttons --->
        <a class="btn gray" href="index.cfm">Admin Home</a>
        <a class="btn" href="people.cfm?action=add">Add Person</a>
        <a class="btn blue" href="people.cfm?action=print&filter=all" target="_blank" rel="noopener">Print All</a>
        <a class="btn orange" href="people.cfm?action=print&filter=notext" target="_blank" rel="noopener">Print "No Text"</a>
      </div>
    </div>

    
    <cfif url.msg EQ "added">                                                                                   <!--- Show status messages based on the msg URL parameter after actions --->
      <div class="alert ok">Person added.</div>
    <cfelseif url.msg EQ "updated">
      <div class="alert ok">Person updated.</div>
    <cfelseif url.msg EQ "deleted">
      <div class="alert ok">Person set to Inactive.</div>
    <cfelseif url.msg EQ "badid">
      <div class="alert bad">Invalid person ID.</div>
    <cfelseif url.msg EQ "notfound">
      <div class="alert bad">Person not found.</div>
    </cfif>

    <cfif len(errorMsg)>                                                                                        <!--- Show operational errors such as query failures --->
      <div class="alert bad"><cfoutput>#encodeForHTML(errorMsg)#</cfoutput></div>
    </cfif>

    <cfif arrayLen(errors) GT 0>                                                                                <!--- Show validation error list when form input is invalid --->
      <div class="alert bad">
        Please fix:
        <ul style="margin:8px 0 0 18px;">
          <cfloop array="#errors#" index="e">
            <li><cfoutput>#encodeForHTML(e)#</cfoutput></li>
          </cfloop>
        </ul>
      </div>
    </cfif>

    
    <cfif url.action EQ "add" OR url.action EQ "edit">                                                          <!--- Show the add/edit form when in add or edit mode --->
      <hr style="margin:16px 0; border:none; border-top:1px solid #eee;">

      <h3 style="margin:0 0 10px;">
        <cfoutput>#(url.action EQ "add" ? "Add Person" : "Edit Person")#</cfoutput>
      </h3>

      <form method="post" action="people.cfm?action=<cfoutput>#url.action#</cfoutput><cfif url.action EQ 'edit'>&id=<cfoutput>#url.id#</cfoutput></cfif>"> <!--- Add/Edit form posts back to same endpoint with action context --->
        <input type="hidden" name="personID" value="<cfoutput>#encodeForHTMLAttribute(form.personID)#</cfoutput>">

        <div class="grid">
          <div>
            <label for="firstName">First Name</label>
            <input id="firstName" name="firstName" value="<cfoutput>#encodeForHTMLAttribute(form.firstName)#</cfoutput>" required>
          </div>
          <div>
            <label for="lastName">Last Name</label>
            <input id="lastName" name="lastName" value="<cfoutput>#encodeForHTMLAttribute(form.lastName)#</cfoutput>" required>
          </div>
          <div>
            <label for="phone">Phone (10 digits)</label>
            <input id="phone" name="phone" inputmode="numeric" value="<cfoutput>#encodeForHTMLAttribute(form.phone)#</cfoutput>" placeholder="4125551234" required>
          </div>
          <div>
            <label for="householdSize">Household Size (1&ndash;20)</label>
            <input id="householdSize" name="householdSize" type="number" min="1" max="20" inputmode="numeric" value="<cfoutput>#encodeForHTMLAttribute(form.householdSize)#</cfoutput>" required>
          </div>
          <div>
            <label for="annualIncome">Annual Gross Income ($)</label>
            <input id="annualIncome" name="annualIncome" type="number" min="0" step="0.01" inputmode="decimal" value="<cfoutput>#encodeForHTMLAttribute(form.annualIncome)#</cfoutput>" placeholder="0.00" required>
          </div>
        </div>

        <div style="margin-top:12px;">
          <label for="isActive">Status</label>
          <select id="isActive" name="isActive">
            <option value="1" <cfif toString(form.isActive) EQ "1">selected</cfif>>Active</option>
            <option value="2" <cfif toString(form.isActive) EQ "2">selected</cfif>>No Text</option>
            <option value="3" <cfif toString(form.isActive) EQ "3">selected</cfif>>Inactive</option>
          </select>
          <div class="muted" style="font-size:12px; margin-top:6px;">
            No Text = does not receive SMS and must be called.
          </div>
        </div>

        <cfif url.action EQ "edit" AND len(trim(toString(getOne.eligibilityUpdatedAt)))>                        <!--- Eligibility Tier Results formatted for display --->
          <hr style="margin:16px 0; border:none; border-top:1px solid #eee;">
          <h4 style="margin:0 0 8px; color:#444;">Eligibility Results</h4>
          <cfoutput>
          <table style="width:auto; margin:0;">
            <tbody>
              <tr>
                <td style="padding:6px 16px 6px 0; color:##555; font-size:13px;">Eligibility Tier</td>
                <td style="padding:6px 0;">
                  <cfif getOne.eligibilityTier EQ 1>                                                                                
                    <span class="badge" style="background:##e8f5e9; color:##1b5e20; border:1px solid ##c8e6c9;">Tier 1</span>
                  <cfelseif getOne.eligibilityTier EQ 2>
                    <span class="badge" style="background:##fff8e1; color:##8a6d00; border:1px solid ##ffe0b2;">Tier 2</span>
                  <cfelseif getOne.eligibilityTier EQ 3>
                    <span class="badge" style="background:##fff3e0; color:##bf360c; border:1px solid ##ffccbc;">Tier 3</span>
                  <cfelse>
                    <span class="badge off">Not Eligible</span>
                  </cfif>
                </td>
              </tr>
              <tr>
                <td style="padding:6px 16px 6px 0; color:##555; font-size:13px;">FPL Percentage</td>
                <td style="padding:6px 0;">#numberFormat(getOne.FPL_Percent, "9,999.99")#%</td>
              </tr>
              <tr>
                <td style="padding:6px 16px 6px 0; color:##555; font-size:13px;">FPL Amount</td>
                <td style="padding:6px 0;">$#numberFormat(getOne.FPL_Amt, "9,999,999.99")#</td>
              </tr>
              <tr>
                <td style="padding:6px 16px 6px 0; color:##555; font-size:13px;">Last Calculated</td>
                <td style="padding:6px 0;">#dateFormat(getOne.eligibilityUpdatedAt, "mm/dd/yyyy")# #timeFormat(getOne.eligibilityUpdatedAt, "h:nn tt")#</td>
              </tr>
            </tbody>
          </table>
          </cfoutput>
        </cfif>

        <div class="rowbtns" style="margin-top:14px;">
          <button class="btn" type="submit" name="btnSave" value="1">Save</button>
          <a class="btn gray" href="people.cfm">Cancel</a>

          <cfif url.action EQ "edit">
            <button class="btn red" type="submit" name="btnDelete" value="1"
                    onclick="return confirm('Set this person to Inactive?');">
              Set Inactive
            </button>
          </cfif>
        </div>
      </form>
    </cfif>

    
    <hr style="margin:16px 0; border:none; border-top:1px solid #eee;">                                       <!--- Separator between form and list; also visually separates the print view when toggled from the same page ---> 

    <h3 style="margin:0 0 10px;">All People</h3>

    <table>                                                                                                     <!--- Primary people table with status and edit actions --->
      <thead>
        <tr>
          <th>Name</th>
          <th>Phone</th>
          <th>Status</th>
          <th>Tier</th>
          <th style="width:120px;">Actions</th>
        </tr>
      </thead>
      <tbody>
        <cfoutput query="getPeople">
          <tr>
            <td>#encodeForHTML(lastName)#, #encodeForHTML(firstName)#</td>
            <td>#encodeForHTML(phone)#</td>
            <td>
              <cfif isActive EQ 1>
                <span class="badge on">Active</span>
              <cfelseif isActive EQ 2>
                <span class="badge notext">No Text</span>
              <cfelse>
                <span class="badge off">Inactive</span>
              </cfif>
            </td>
            <td>
              <cfif NOT len(trim(toString(eligibilityTier)))>                                                   <!--- Eligibility Tier Results formatted for display --->
                <span class="badge" style="background:##f5f5f5; color:##555; border:1px solid ##ddd;">Pending</span>
              <cfelseif eligibilityTier EQ 1>
                <span class="badge" style="background:##e8f5e9; color:##1b5e20; border:1px solid ##c8e6c9;">Tier 1</span>
              <cfelseif eligibilityTier EQ 2>
                <span class="badge" style="background:##fff8e1; color:##8a6d00; border:1px solid ##ffe0b2;">Tier 2</span>
              <cfelseif eligibilityTier EQ 3>
                <span class="badge" style="background:##fff3e0; color:##bf360c; border:1px solid ##ffccbc;">Tier 3</span>
              <cfelse>
                <span class="badge off">Not Eligible</span>
              </cfif>
            </td>
            <td>
              <a class="btn gray" style="padding:6px 10px;" href="people.cfm?action=edit&id=#personID#">Edit</a>
            </td>
          </tr>
        </cfoutput>
      </tbody>
    </table>

  </div>
</div>
</body>
</html>
