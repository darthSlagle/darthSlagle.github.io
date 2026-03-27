<!--- ================================================================================
     Author:      Scott Slagle
     File:        admin/index.cfm
     Application: 84 Community Food Pantry - Test Site
     Created:     02/07/2026

     Purpose:
     This program serves as the admin dashboard for the 84 Community Food Pantry site.  It requires an authenticated admin session, summarizes key operational counts
     (people, unread contact requests, and current distribution registration metrics), and renders trend charts for recent registrations and monthly distribution snapshots.
     The dashboard determines the active/open distribution by status and date, then calculates registration window state (OPEN, UPCOMING, or PREP) for display.

     Changelog:
     02/07/2026 - Initial Development - created admin dashboard with summary metrics.
     02/14/2026 - Updated current/open distribution logic to use status/date, added
                  registration window state display, scoped registration counts to the
                  current distribution, and added unread contact notice + chart updates.
     ================================================================================ --->

<cfinclude template="_auth.cfm">                                                                                <!--- Require a valid admin session before loading dashboard data --->
<cfsetting showdebugoutput="false">                                                                             <!--- Suppress ColdFusion debug output in the browser --->

<cfquery name="PeopleTotal" datasource="84-pantry">                                                            <!--- Count all people records for the Total People dashboard metric --->
  SELECT COUNT(*) AS totalPeople
  FROM dbo.tbl_People
</cfquery>

<cfquery name="PeopleActive" datasource="84-pantry">                                                           <!--- Count active people (excluding status 3 / Inactive) for eligibility metrics --->
  SELECT COUNT(*) AS activePeople
  FROM dbo.tbl_People
  WHERE isActive <> 3
</cfquery>

<cfquery name="ContactUnread" datasource="84-pantry">                                                          <!--- Count unread contact requests to highlight admin follow-up work --->
  SELECT COUNT(*) AS unreadCount
  FROM dbo.tbl_ContactRequests
  WHERE status = 'unread'
</cfquery>
<cfset contactUnread = val(ContactUnread.unreadCount)>                                                         <!--- Normalize unread count to numeric for display logic and badge rendering --->

<cfquery name="OpenDist" datasource="84-pantry">                                                               <!--- Select the next OPEN distribution by date (independent of registration window timing) --->
  SELECT TOP 1 distributionID, title, distributionDate, regWindowStart, regWindowEnd, status
  FROM dbo.tbl_Distributions
  WHERE status = 'OPEN'
    AND distributionDate >= CAST(GETDATE() AS date)
  ORDER BY distributionDate ASC, distributionID ASC
</cfquery>

<cfset hasOpenDist = (OpenDist.recordCount EQ 1)>                                                              <!--- True only when one open distribution was found for dashboard context --->


<cfset regWindowState = "NONE">                                                                                 <!--- Default state when no open distribution exists or window is unavailable --->
<cfset hasRegOpen = false>                                                                                      <!--- Boolean helper for open-window checks (reserved for future UI branching) --->

<cfif hasOpenDist>
  <cfif now() GTE OpenDist.regWindowStart AND now() LTE OpenDist.regWindowEnd>
    <cfset regWindowState = "OPEN">                                                                             <!--- Accepting Registrations --->
    <cfset hasRegOpen = true>
  <cfelseif now() LT OpenDist.regWindowStart>
    <cfset regWindowState = "UPCOMING">                                                                         <!--- Opens Soon --->
  <cfelse>
    <cfset regWindowState = "PREP">                                                                             <!--- Preparing for Distribution --->
  </cfif>
</cfif>

<cfset regTotal = 0>                                                                                            <!--- Total active registrations for the selected open distribution --->
<cfset regUniquePhones = 0>                                                                                     <!--- Unique phone count used as the primary registered-household metric --->
<cfset regMatchedPeople = 0>                                                                                    <!--- Registrations that match an existing person record by normalized phone --->
<cfset regPct = 0>                                                                                              <!--- Percent of active people represented by registered unique phones --->

<cfif hasOpenDist>
  <cfquery name="RegCounts" datasource="84-pantry">                                                            <!--- Aggregate registration totals scoped to the currently selected distributionID --->
    SELECT
      COUNT(*) AS regTotal,
      COUNT(DISTINCT r.phone) AS regUniquePhones,
      SUM(CASE WHEN p.personID IS NOT NULL THEN 1 ELSE 0 END) AS regMatchedPeople
    FROM dbo.tbl_Registrations r
    LEFT JOIN dbo.tbl_People p ON p.phone = r.phone
    WHERE r.isCancelled = 0
      AND r.distributionID = <cfqueryparam value="#OpenDist.distributionID#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfset regTotal = val(RegCounts.regTotal)>                                                                   <!--- Convert query aggregate values to numeric form for chart/UI output --->
  <cfset regUniquePhones = val(RegCounts.regUniquePhones)>                                                     <!--- Convert query aggregate values to numeric form for chart/UI output --->
  <cfset regMatchedPeople = val(RegCounts.regMatchedPeople)>                                                   <!--- Convert query aggregate values to numeric form for chart/UI output --->

  <cfif val(PeopleActive.activePeople) GT 0>
    <cfset regPct = (regUniquePhones / val(PeopleActive.activePeople)) * 100>                                  <!--- Calculate percent registered against the active-person baseline --->
  <cfelse>
    <cfset regPct = 0>                                                                                          <!--- Guard against divide-by-zero when no active people exist --->
  </cfif>
</cfif>


<cfquery name="RegLast7" datasource="84-pantry">                                                               <!--- Last 7 days registrations (trend) - tbl_Registrations (not cancelled) --->
  ;WITH days AS (
    SELECT CAST(CONVERT(date, DATEADD(day, -6, GETDATE())) AS date) AS d
    UNION ALL SELECT DATEADD(day, 1, d) FROM days WHERE d < CAST(GETDATE() AS date)
  )
  SELECT
    d.d AS regDate,
    ISNULL((
      SELECT COUNT(*)
      FROM dbo.tbl_Registrations r
      WHERE r.isCancelled = 0
        AND CAST(r.regDateTime AS date) = d.d
    ), 0) AS regCount
  FROM days d
  OPTION (MAXRECURSION 100);
</cfquery>

<!--- =========================================================
     Distribution Snapshot (Last 12 Months)
     - Current month is the last bar (right side)
     - For each month: find a distribution in that month (OPEN or CLOSED)
     - Count:
         CLOSED => tbl_DistributionRegistrations rows (snapshot)
         OPEN   => tbl_Registrations distinct phones for that distributionID
     - If no distribution found for a month => 0
========================================================= --->

<cfset snapLabels = []>
<cfset snapCounts = []>                                                                                         <!--- Parallel array of monthly registration counts for the 12-month snapshot chart --->

<cfscript>
  monthStarts = [];                                                                                             // First day of each month across the last 12 months, oldest to newest
  for (i = 11; i >= 0; i--) {
    d = dateAdd("m", -i, now());
    dStart = createDate(year(d), month(d), 1);
    arrayAppend(monthStarts, dStart);
    arrayAppend(snapLabels, dateFormat(dStart, "mmm yyyy"));                                                    // Human-readable month label used on the x-axis
  }
</cfscript>

<cfquery name="SnapDists" datasource="84-pantry">                                                              <!--- Load distributions that fall inside the 12-month chart window --->
  SELECT distributionID, distributionDate, status
  FROM dbo.tbl_Distributions
  WHERE distributionDate >= <cfqueryparam value="#monthStarts[1]#" cfsqltype="cf_sql_date">
    AND distributionDate <  <cfqueryparam value="#dateAdd('m', 1, monthStarts[arrayLen(monthStarts)])#" cfsqltype="cf_sql_date">
</cfquery>

<cfscript>
  distByMonth = structNew();                                                                                    // Map key format: YYYY-MM -> distribution metadata for that month
  for (row=1; row <= SnapDists.recordCount; row++) {
    dd = SnapDists.distributionDate[row];
    key = dateFormat(dd, "yyyy-mm");                                                                            // Stable month key for mapping distributions to chart periods
    distByMonth[key] = {
      distributionID = SnapDists.distributionID[row],
      distributionDate = dd,
      status = SnapDists.status[row]
    };
  }

  
  for (ms in monthStarts) {                                                                                     // For each month in the chart window, compute the registration/snapshot count.
    key = dateFormat(ms, "yyyy-mm");
    cnt = 0;

    if (structKeyExists(distByMonth, key)) {
      dist = distByMonth[key];

      
      if (dist.status == "CLOSED") {                                                                            // Use snapshot rows for CLOSED distributions; otherwise use live tbl_Registrations distinct phones.
        q = queryExecute(
          "SELECT COUNT(*) AS c
           FROM dbo.tbl_DistributionRegistrations
           WHERE distributionID = :id",
          { id = { value = dist.distributionID, cfsqltype = "cf_sql_integer" } },
          { datasource = "84-pantry" }
        );
        cnt = val(q.c[1]);
      } else {
        q = queryExecute(
          "SELECT COUNT(DISTINCT phone) AS c
           FROM dbo.tbl_Registrations
           WHERE isCancelled = 0
             AND distributionID = :id",
          { id = { value = dist.distributionID, cfsqltype = "cf_sql_integer" } },
          { datasource = "84-pantry" }
        );
        cnt = val(q.c[1]);
      }
    }

    arrayAppend(snapCounts, cnt);
  }
</cfscript>

<cfset last7Labels = []>                                                                                        <!--- Day labels (MM/DD) for the 7-day registrations chart --->
<cfset last7Counts = []>                                                                                        <!--- Registration count values aligned with last7Labels --->
<cfloop query="RegLast7">
  <cfset arrayAppend(last7Labels, dateFormat(RegLast7.regDate,"mm/dd"))>                                       <!--- Append display label for each day in the 7-day rolling window --->
  <cfset arrayAppend(last7Counts, val(RegLast7.regCount))>                                                     <!--- Append numeric registration count for each matching day label --->
</cfloop>

<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>84 Pantry Admin - Dashboard</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>                                                 <!--- Chart.js library for rendering the trend charts --->                        

  <style>                                                                                                       <!--- Page specific CSS styling for the admin dashboard --->
    * { box-sizing: border-box; }
    body { font-family: Arial, sans-serif; background:#f6f7f8; margin:0; padding:20px; }
    .wrap { max-width:1200px; margin:0 auto; }
    .card { background:#fff; border:1px solid #e6e6e6; border-radius:12px; padding:18px; box-shadow:0 2px 10px rgba(0,0,0,.04); }
    .top { display:flex; justify-content:space-between; align-items:center; gap:12px; flex-wrap:wrap; }

    .btn { display:inline-block; padding:10px 12px; border-radius:10px; background:#546e7a; color:#fff; text-decoration:none; font-weight:700; }
    .btn.green { background:#2f7d32; }

    
    .btn.notice {
      background:#8a6a12; 
      position:relative;
      animation: noticePulse 1.8s ease-in-out infinite;
    }
    .btn.notice:hover { background:#6f540e; }
    .btn .countBadge{
      display:inline-block;
      margin-left:8px;
      padding:2px 8px;
      border-radius:999px;
      font-size:12px;
      font-weight:900;
      background:#fff;
      color:#6f540e;
    }
    @keyframes noticePulse{
      0%   { box-shadow: 0 0 0 0 rgba(138,106,18,0.35); }
      60%  { box-shadow: 0 0 0 10px rgba(138,106,18,0.00); }
      100% { box-shadow: 0 0 0 0 rgba(138,106,18,0.00); }
    }

    .grid { display:grid; grid-template-columns: repeat(4, 1fr); gap:14px; margin-top:14px; }
    @media (max-width: 1050px) { .grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 620px) { .grid { grid-template-columns: 1fr; } }

    .stat { border:1px solid #eee; border-radius:12px; padding:14px; background:#fafafa; }
    .stat .label { color:#666; font-weight:700; font-size:13px; }
    .stat .value { font-size:28px; font-weight:800; margin-top:8px; }
    .stat .sub { color:#777; margin-top:6px; font-size:13px; }

    .section { margin-top:18px; display:grid; grid-template-columns: 1fr 1fr; gap:14px; }
    @media (max-width: 950px) { .section { grid-template-columns: 1fr; } }
    .chartCard { border:1px solid #eee; border-radius:12px; padding:14px; background:#fff; }
    .muted { color:#777; }

    .badge { display:inline-block; padding:2px 8px; border-radius:999px; font-size:12px; font-weight:800; border:1px solid #ddd; background:#fff; }
    .badge.open { border-color:#c8e6c9; background:#e8f5e9; color:#1b5e20; }
    .badge.prep { border-color:#ffe0b2; background:#fff3e0; color:#7a4f00; }
    .badge.upcoming { border-color:#bbdefb; background:#e3f2fd; color:#0d47a1; }

    .row { margin-top:10px; padding:12px; border:1px solid #eee; border-radius:12px; background:#fff; }
    .row h3 { margin:0 0 6px; }

    .headerLeft { display:flex; align-items:center; gap:12px; }
    .logo { height:62px; width:auto; display:block; }
  </style>
</head>

<body>
  <div class="wrap">                                                                                            <!--- Outer page wrapper for dashboard layout width and spacing --->

    <div class="card">                                                                                          <!--- Main admin dashboard card containing stats, status, and charts --->
      <div class="top">                                                                                         <!--- Top bar with dashboard identity and primary navigation actions --->
        <div class="headerLeft">                                                                                <!--- Left side of top bar: logo and dashboard heading --->
          <img src="../img/logo.png" alt="84 Food Pantry" class="logo" />
          <div>
            <h2 style="margin:0;">Admin Dashboard</h2>
            <div class="muted">Distribution Status</div>
          </div>
        </div>

        <div style="display:flex; gap:10px; flex-wrap:wrap;">                                                   <!--- Right side of top bar: quick links for admin workflows --->
          <a class="btn" href="people.cfm">People</a>
          <a class="btn" href="distributions.cfm">Distributions</a>

          <cfoutput>                                                                                            <!--- Contact Requests button shows unread badge and notice styling when needed --->
            <a class="btn #contactUnread GT 0 ? 'notice' : ''#"
               href="contact_requests.cfm">
              Contact Requests
              <cfif contactUnread GT 0>
                <span class="countBadge">#contactUnread#</span>
              </cfif>
            </a>
          </cfoutput>

          <a class="btn green" href="../register.cfm" target="_blank">Registration Page</a>
        </div>
      </div>

      <div class="grid">                                                                                        <!--- Four headline stat tiles for high-level dashboard monitoring --->
        <div class="stat">                                                                                      <!--- total people count --->
          <div class="label">Total People</div>
          <div class="value"><cfoutput>#PeopleTotal.totalPeople#</cfoutput></div>
          <div class="sub">All recipients in the People list</div>
        </div>

        <div class="stat">                                                                                      <!--- active people count --->
          <div class="label">Active People</div>
          <div class="value"><cfoutput>#PeopleActive.activePeople#</cfoutput></div>
          <div class="sub">Eligible recipients (not disabled)</div>
        </div>

        <div class="stat">                                                                                      <!--- whether an open distribution currently exists --->
          <div class="label">Next Open Distribution</div>
          <div class="value"><cfif hasOpenDist>Yes<cfelse>No</cfif></div>
          <div class="sub">
            <cfif hasOpenDist>
              <cfoutput>
                #encodeForHTML(OpenDist.title)#:<br />
                #dateFormat(OpenDist.distributionDate,"mmmm d, yyyy")#
              </cfoutput>
            <cfelse>
              No OPEN distributions scheduled
            </cfif>
          </div>
        </div>

        <div class="stat">                                                                                      <!--- registration penetration for the current open distribution --->
          <div class="label">Registered (This Distribution)</div>
          <div class="value"><cfoutput>#hasOpenDist ? regUniquePhones : 0#</cfoutput></div>
          <div class="sub">
            <cfif hasOpenDist>
              <cfoutput>% Registered: #numberFormat(regPct,"0.0")#%</cfoutput>
            <cfelse>
              —
            </cfif>
          </div>
        </div>
      </div>

      <cfif hasOpenDist>                                                                                        <!--- The current open distribution detail row only when one is available --->
        <div class="row">                                                                                       <!--- Detail row with window state badge, dates, and action links --->
          <h3 style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
            <span>Current Open Distribution</span>

            <cfif regWindowState EQ "OPEN">
              <span class="badge open">ACCEPTING REGISTRATIONS</span>
            <cfelseif regWindowState EQ "UPCOMING">
              <span class="badge upcoming">REGISTRATION OPENS SOON</span>
            <cfelse>
              <span class="badge prep">PREPARING</span>
            </cfif>
          </h3>

          <div class="muted">
            <cfoutput>
              <strong>#encodeForHTML(OpenDist.title)#</strong> —
              #dateFormat(OpenDist.distributionDate,"mmmm d, yyyy")#<br>
              Window: #dateTimeFormat(OpenDist.regWindowStart,"mm/dd/yyyy hh:nn tt")# →
              #dateTimeFormat(OpenDist.regWindowEnd,"mm/dd/yyyy hh:nn tt")#
            </cfoutput>
          </div>

          <div style="margin-top:10px; display:flex; gap:14px; flex-wrap:wrap;">
            <div class="badge">Total registrations: <cfoutput>#regTotal#</cfoutput></div>
            <div class="badge">Unique phones: <cfoutput>#regUniquePhones#</cfoutput></div>
            <div class="badge">Matched to People: <cfoutput>#regMatchedPeople#</cfoutput></div>
            <a class="btn" href="distribution_view.cfm?id=<cfoutput>#OpenDist.distributionID#</cfoutput>">View</a>
            <a class="btn" href="distribution_print.cfm?id=<cfoutput>#OpenDist.distributionID#</cfoutput>" target="_blank">Print</a>
          </div>
        </div>
      </cfif>

      <div class="section">                                                                                     <!--- Two chart panels for short-term trend and long-term distribution snapshot --->
        <div class="chartCard">                                                                                 <!--- Chart panel: registrations by day over the last 7 days --->
          <h3 style="margin:0 0 8px;">Registrations (Last 7 Days)</h3>
          <div class="muted" style="margin-bottom:10px;">Counts of registrations per day</div>
          <canvas id="chartLast7" height="140"></canvas>
        </div>

        <div class="chartCard">                                                                                 <!--- Chart panel: monthly snapshot counts over the last 12 months --->
          <h3 style="margin:0 0 8px;">Distribution Snapshot (Last 12 Months)</h3>
          <div class="muted" style="margin-bottom:10px;">Number of People Registered for Distribution</div>
          <canvas id="chartSnapshot" height="140"></canvas>
        </div>
      </div>

    </div>
  </div>

  <cfoutput>                                                                                                    <!--- Serialize server-side arrays into JavaScript to render Chart.js visualizations --->
  <script>
    const last7Labels = #serializeJSON(last7Labels)#;
    const last7Counts = #serializeJSON(last7Counts)#;

    const snapLabels = #serializeJSON(snapLabels)#;
    const snapCounts = #serializeJSON(snapCounts)#;

    new Chart(document.getElementById("chartLast7"), {
      type: "line",
      data: {
        labels: last7Labels,
        datasets: [{
          label: "Registrations",
          data: last7Counts,
          tension: 0.25
        }]
      },
      options: {
        responsive: true,
        plugins: { legend: { display: true } },
        scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
      }
    });

    new Chart(document.getElementById("chartSnapshot"), {
      type: "bar",
      data: {
        labels: snapLabels,
        datasets: [{
          label: "Registered",
          data: snapCounts
        }]
      },
      options: {
        responsive: true,
        plugins: { legend: { display: true } },
        scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
      }
    });
  </script>
  </cfoutput>

</body>
</html>
