<!--- ================================================================================
    Author:      Scott Slagle
    File:        eligibility_engine.cfm
    Application: 84 Community Food Pantry - Test Site (Admin)
    Created:     03/21/2026

    Purpose: 
      Include eligibility engine called from people.cfm after a person is inserted or updated.  
      Determines the persons FPL eligibility tier based on Federal Poverty Level guidelines stored in tbl_FPL_Guidelines, then writes the result back to tbl_People and appends an audit row to tbl_EligibilityAudit.

    Changelog:
    03/21/2026 - Initial Development - eligibility engine include for FPL tier calculation.
     ================================================================================ --->

<!--- -----------------------------------------------------------------------
     Initialize output variables
     ----------------------------------------------------------------------- --->
<cfset eligibility_success = false>                                                                             <!--- Indicates whether the engine completed successfully --->
<cfset eligibility_result = "">                                                                                 <!--- Result token for people.cfm to evaluate --->
<cfset eligibility_tier = 0>                                                                                    <!--- Calculated eligibility tier --->
<cfset eligibility_FPL_Percent = 0>                                                                             <!--- Annual income expressed as a percentage of the FPL amount --->
<cfset eligibility_FPL_Amt = 0>                                                                                 <!--- FPL guideline dollar amount used in the calculation --->
<cfset eligibility_done = false>                                                                                <!--- Flag used to bypass remaining logic without using cfreturn --->


<cftry>
  <!--- -----------------------------------------------------------------------
     Load householdSize and annualIncome for the person
     ----------------------------------------------------------------------- --->
  <cfquery name="getPerson" datasource="84-pantry">
    SELECT householdSize, annualIncome
    FROM dbo.tbl_People
    WHERE personID = <cfqueryparam value="#val(eligibility_personID)#" cfsqltype="cf_sql_integer">
  </cfquery>

  <!--- -----------------------------------------------------------------------
     Verify the person record exists
     ----------------------------------------------------------------------- --->
  <cfif getPerson.recordCount NEQ 1>                                                                            <!--- Ensure the record exist before proceeding --->
    <cfset eligibility_result = "invalid_person">
    <cfset eligibility_success = false>
    <cfset eligibility_done = true>
  </cfif>


<!--- -----------------------------------------------------------------------
     Validate householdSize
     ----------------------------------------------------------------------- --->
  <cfif NOT eligibility_done>
    <cfif NOT isNumeric(getPerson.householdSize) OR val(getPerson.householdSize) LT 1>                          <!--- Ensure that householdSize is a positive integer to prevent logic errors with FPL lookup --->
      <cfset eligibility_result = "invalid_household_size">
      <cfset eligibility_success = false>
      <cfset eligibility_done = true>
    </cfif>
  </cfif>

<!--- -----------------------------------------------------------------------
     Validate annualIncome
     ----------------------------------------------------------------------- --->
  <cfif NOT eligibility_done>
    <cfif NOT isNumeric(getPerson.annualIncome) OR val(getPerson.annualIncome) LT 0>                            <!--- Ensure that annualIncome is a non-negative number to prevent logic errors with FPL calculation--->
      <cfset eligibility_result = "invalid_annual_income">
      <cfset eligibility_success = false>
      <cfset eligibility_done = true>
    </cfif>
  </cfif>

<!--- -----------------------------------------------------------------------
     Look up FPL guideline for the current year and household size
     ----------------------------------------------------------------------- --->
  <cfif NOT eligibility_done>
    <cfquery name="getEligFPL" datasource="84-pantry">                                                           <!--- lookup year and householdSize; handles households up to maxGuidelineSize --->
      SELECT FPL_Amt, additionalPerPerson, maxGuidelineSize
      FROM dbo.tbl_FPL_Guidelines
      WHERE year = <cfqueryparam value="#year(now())#" cfsqltype="cf_sql_integer">
        AND householdSize = <cfqueryparam value="#val(getPerson.householdSize)#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif getEligFPL.recordCount EQ 1>                                                                          <!--- Exact match found in guidelines table for this household size — use it for the calculation --->
      <cfset local_FPL_Amt = val(getEligFPL.FPL_Amt)>                                                           <!--- Store the guideline amount in a local variable for the calculation --->
    <cfelse>
      <cfquery name="getEligFPLMax" datasource="84-pantry">                                                     <!---No exact match — Get the largest household size to continue --->
        SELECT TOP 1 FPL_Amt, additionalPerPerson, maxGuidelineSize
        FROM dbo.tbl_FPL_Guidelines
        WHERE year = <cfqueryparam value="#year(now())#" cfsqltype="cf_sql_integer">
        ORDER BY householdSize DESC
      </cfquery>

      <cfif getEligFPLMax.recordCount EQ 1 AND val(getPerson.householdSize) GT val(getEligFPLMax.maxGuidelineSize)>  <!--- Household exceeds published guidelines, use the additionalPerPerson value to calculate adjustment --->
        <cfset local_FPL_Amt = val(getEligFPLMax.FPL_Amt)
                               + (val(getPerson.householdSize) - val(getEligFPLMax.maxGuidelineSize))
                                 * val(getEligFPLMax.additionalPerPerson)>
      <cfelse>                                                                                                  <!--- Table has no data for this year; cannot calculate eligibility --->
        <cfset eligibility_result = "invalid_annual_income">
        <cfset eligibility_success = false>
        <cfset eligibility_done = true>
      </cfif>
    </cfif>
  </cfif>

  <cfif NOT eligibility_done>                                                                                   <!--- Ensure that the guideline amount is a positive number to prevent logic errors with FPL calculation --->
    <cfif local_FPL_Amt LTE 0>
      <cfset eligibility_result = "invalid_annual_income">
      <cfset eligibility_success = false>
      <cfset eligibility_done = true>
    </cfif>
  </cfif>

<!--- -----------------------------------------------------------------------
     Calculate tier and eligibility flag based on FPL percentage thresholds
     ----------------------------------------------------------------------- --->
  <cfif NOT eligibility_done>
    <cfset local_FPL_Percent = (val(getPerson.annualIncome) / local_FPL_Amt) * 100>                             <!--- Calculate the annual income as a percentage of the Federal Poverty Level amount --->
    <cfif local_FPL_Percent LTE 100>                                                                            <!--- Assign eligibility tier based on FPL percentage thresholds --->
      <cfset local_tier = 1>                                                                                    <!--- 0-100% FPL — Tier 1 --->                     
      <cfset local_eligible_flag = 1>
    <cfelseif local_FPL_Percent LTE 150>                                                                        <!--- 101-150% FPL — Tier 2 --->
      <cfset local_tier = 2>
      <cfset local_eligible_flag = 1>
    <cfelseif local_FPL_Percent LTE 185>                                                                        <!--- 151-185% FPL — Tier 3 --->
      <cfset local_tier = 3>
      <cfset local_eligible_flag = 1>
    <cfelse>                                                                                                    <!--- Above 185% FPL — Not eligible --->
      <cfset local_tier = 0>
      <cfset local_eligible_flag = 0>
    </cfif>

<!--- -----------------------------------------------------------------------
     Update tbl_People with the computed eligibility data
     ----------------------------------------------------------------------- --->
    <cfquery datasource="84-pantry">                                                                                
      UPDATE dbo.tbl_People
      SET
        eligibilityTier = <cfqueryparam value="#local_tier#" cfsqltype="cf_sql_tinyint">,
        eligibleFlag = <cfqueryparam value="#local_eligible_flag#" cfsqltype="cf_sql_tinyint">,
        FPL_Percent = <cfqueryparam value="#local_FPL_Percent#" cfsqltype="cf_sql_decimal">,
        FPL_Amt = <cfqueryparam value="#local_FPL_Amt#" cfsqltype="cf_sql_decimal">,
        eligibilityUpdatedAt = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
      WHERE personID = <cfqueryparam value="#val(eligibility_personID)#" cfsqltype="cf_sql_integer">
    </cfquery>

<!--- -----------------------------------------------------------------------
     Insert the audit record into tbl_EligibilityAudit
     ----------------------------------------------------------------------- --->
    <cfquery datasource="84-pantry">                                                                            <!--- Add an audit row every time eligibility is recalculated --->
      INSERT INTO dbo.tbl_EligibilityAudit
             (personID, eligibilityTier, eligible_flag, FPL_Percent, FPL_Amt,
              householdSize, annualIncome, calculatedAt)
      VALUES (
        <cfqueryparam value="#val(eligibility_personID)#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#local_tier#" cfsqltype="cf_sql_tinyint">,
        <cfqueryparam value="#local_eligible_flag#" cfsqltype="cf_sql_tinyint">,
        <cfqueryparam value="#local_FPL_Percent#" cfsqltype="cf_sql_decimal">,
        <cfqueryparam value="#local_FPL_Amt#" cfsqltype="cf_sql_decimal">,
        <cfqueryparam value="#val(getPerson.householdSize)#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#val(getPerson.annualIncome)#" cfsqltype="cf_sql_decimal">,
        <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
      )
    </cfquery>

<!--- -----------------------------------------------------------------------
     Return the results to people.cfm for display and further processing
     ----------------------------------------------------------------------- --->
    <cfset eligibility_success = true>                                                                          <!--- Eligibility Engine successful --->
    <cfset eligibility_result = "success">                                                                      <!--- Result token indicating success for people.cfm to evaluate --->         
    <cfset eligibility_tier = local_tier>                                                                       <!--- Eligibility tier assigned --->                   
    <cfset eligibility_FPL_Percent = round(local_FPL_Percent * 100) / 100>                                      <!--- Round to 2 decimal places --->
    <cfset eligibility_FPL_Amt = local_FPL_Amt>                                                                 <!--- FPL Amt used for calculation ---> 

  </cfif>


  <cfcatch>                                                                                                     <!--- Exception handling, return error token --->
    <cfset eligibility_success = false>
    <cfset eligibility_result = "db_error">
    <cflog file="84FoodPantry" type="error"                                                                     <!--- Log the error details for troubleshooting --->
           text="eligibility_engine.cfm failed. personID=#val(eligibility_personID)# error=#cfcatch.message# detail=#cfcatch.detail#">
  </cfcatch>

</cftry>
