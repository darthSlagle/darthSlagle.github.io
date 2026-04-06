<html lang="en">
<body>
<div>
   <!-- Table of Contents -->
  <nav>
    <h2>Table of Contents</h2>
    <ol>
      <li><a href="#self-assessment">Self-Assessment</a></li>
      <li><a href="#code-review">Code Review</a></li>
      <li><a href="#artifact-overview">Artifact Overview</a></li>
      <li><a href="#enhancement-one--software-design-and-engineering">Enhancement One — Software Design and Engineering</a></li>
      <li><a href="#enhancement-two--algorithms-and-data-structures">Enhancement Two — Algorithms and Data Structures</a></li>
      <li><a href="#enhancement-three--databases">Enhancement Three — Databases</a></li>
      <li><a href="references">References</a></li>
    </ol>
  </nav>

  <!-- Professional Self-Assessment -->
  <section>
    <h2>Self-Assessment</h2>
    <span>Coming Soon</span>
  </section>

  <!-- Code Review -->
  <section>
    <h2>Code Review</h2>
    <p>
      Before any enhancements were made, I conducted a structured code review of my selected artifact.
      The review walks through existing functionality, identifies areas for improvement in structure,
      logic, efficiency, security, and documentation, and outlines the planned enhancements mapped
      to the five course outcomes.
    </p>
    <p align="center">
      <a href="https://slaglecloud.net/ePortfolio/MilestoneOne-CodeReview.mp4" target="_blank">
        <img src="https://slaglecloud.net/ePortfolio/video-icon.png" width="200">
      </a>
      <br />
      Watch my code review video!
    </p>
  </section>

  <!-- Artifact Overview -->
  <section>
    <h2>Artifact Overview</h2>
   <p>
      The artifact used across all three enhancement categories in this ePortfolio is the 
      <strong>84 Community Food Pantry Web Application</strong>, a full-stack web application 
      developed to support the operations of a local community food pantry.  The application 
      manages recipient contact information, registration tasks, distribution scheduling and 
      tracking, and administrative functions used by volunteers during food distribution events. 
       The system was originally developed as a production solution for the pantry and was cloned 
      and purged for use in this capstone project so enhancements could be implemented without 
      affecting the live environment.  These improvements will be integrated into the production 
      system upon completion of this course.
   </p>
  </section>

  <!-- Enhancement One -->
  <section>
   <h2>Software Design and Engineering Artifact</h2>

   <p>
      This artifact was selected for the Software Design and Engineering category because it 
      demonstrates several important software engineering principles, including secure system 
      design, database-driven application architecture, and maintainable authentication logic. 
       Because the system is actively used in a real community environment, the software must be 
      reliable, secure, and adaptable as operational needs evolve.  These requirements make this 
      artifact a strong representation of applied software design principles.
   </p>
   
   <p>
      The enhancement implemented for this milestone was the development of a 
      <strong>Role-Based Access Control System</strong> for the administration portal. 
       In the original version of the application, administrative functions were handled by me.
      During initial setup, an unauthenticated page was created to allow the creation of the first 
      administrator account by accepting a username and password, hashing the password, and storing 
      the credentials in the database.  While functional for initial configuration, this approach presented
      a security vulnerability if the page were discovered or left accessible.
   </p>
   
   <p>
      To improve system security and align with standard software engineering practices, the 
      authorization structure was redesigned so that permissions are defined within the database 
      and enforced through application logic.  This enhancement required the creation of a roles 
      table, modification of the administrative users table to include a role reference, and 
      updates to the authentication module to dynamically evaluate user permissions when 
      protected pages are accessed.
   </p>
   
   <p>
      Implementing RBAC improved the overall system architecture by separating user identity 
      from permission definitions, a design approach consistent with established secure system 
      design practices (Ferraiolo et al., 2001).  This structure allows additional roles to be 
      introduced in the future without requiring significant changes to application logic, 
      thereby improving both maintainability and scalability.  Additional safeguards were also 
      implemented within the administrative user management interface to prevent administrators 
      from unintentionally disabling their own accounts or modifying their own privilege levels.
   </p>
   
   <p>
      Through this enhancement process, I demonstrated the ability to design and implement 
      computing solutions using established software engineering principles.  The redesign 
      required coordinated changes to both the database schema and authentication workflow 
      while maintaining compatibility with the rest of the application.  Security considerations 
      were also incorporated to ensure restricted pages cannot be accessed through direct URL 
      navigation by unauthorized users.
   </p>
   
   <p>
      This enhancement reinforced the importance of designing systems that anticipate evolving 
      requirements.  Although the original system functioned as intended, the lack of a structured 
      role management framework made later modifications more complex and introduced potential 
      security risks. By implementing a normalized role structure and database-driven permission 
      validation, the system is now more secure, flexible, and maintainable.  This experience 
      strengthened my understanding of how thoughtful architectural decisions improve both the 
      security and long-term scalability of real-world applications.
   </p>

  <h3>Artifact Files</h3>
    <table>
      <thead>
        <tr><th>File</th><th>Description</th></tr>
      </thead>
      <tbody>
        <tr>
          <td><a href="enhancement-one/enhanced/_auth.cfm">_auth.cfm (Enhanced)</a></td>
          <td>Authentication guard with role loading and page-level access control</td>
        </tr>
        <tr>
          <td><a href="enhancement-one/enhanced/index.cfm">index.cfm (Enhanced)</a></td>
          <td>Admin dashboard with conditional User Manager navigation for Global Admin</td>
        </tr>
        <tr>
          <td><a href="enhancement-one/enhanced/users.cfm">users.cfm (Enhanced)</a></td>
          <td>User management module &mdash; restricted to Global Admin role</td>
        </tr>
        <tr>
          <td><a href="enhancement-one/original/_auth.cfm">_auth.cfm (Original)</a></td>
          <td>Original authentication guard before RBAC implementation</td>
        </tr>
        <tr>
          <td><a href="enhancement-one/original/index.cfm">index.cfm (Original)</a></td>
          <td>Original admin dashboard before RBAC implementation</td>
        </tr>
      </tbody>
    </table>
  </section>

<!-- Enhancement Two -->
<section>
  <h2>Enhancement Two — Algorithms and Data Structures</h2>
  <p>
    The artifact selected for this category is the <strong>income eligibility determination engine</strong>
    developed for the 84 Community Food Pantry web application.  This component evaluates a household's
    reported income and household size against Federal Poverty Level guidelines and assigns an eligibility
    tier used to determine qualification for participation in pantry distributions.  Prior to this enhancement,
    eligibility determinations were performed manually by reviewing printed guideline tables from the
    Greater Pittsburgh Community Food Bank.  The enhanced artifact introduces an automated decision-making
    component that improves consistency, efficiency, and accuracy.
  </p>

  <p>
    This artifact was selected because it demonstrates practical application of algorithmic thinking and
    structured data evaluation in a real-world environment.  The eligibility engine transforms regulatory
    guidance into a deterministic classification process, highlighting the ability to translate policy
    requirements into logical algorithms backed by defined data structures.  By storing Federal Poverty Level
    thresholds and eligibility tiers in the database rather than hard-coding them, the algorithm separates
    reference data from procedural logic, improving maintainability and allowing annual guideline updates
    without code changes.
  </p>

  <p>
    The enhanced artifact applies a step-by-step algorithm that accepts household size and annual income as
    input, retrieves the corresponding FPL threshold from the database, calculates the household's percentage
    of the poverty level, and assigns an eligibility tier based on defined ranges.  The modular design of
    eligibility_engine.cfm allows this logic to be reused across multiple workflows, including
    initial registration and periodic income updates.  This demonstrates how separating algorithmic logic into
    reusable components reduces redundancy and improves long-term maintainability.
  </p>

  <p>
    The primary challenge during this enhancement was handling boundary conditions when an exact household
    size match was not available in the stored guidelines.  Real-world data does not always align perfectly
    with predefined values, requiring thoughtful logic to determine whether to require an exact match or
    dynamically evaluate the closest applicable guideline range, particularly for households larger than
    the maximum defined value.  Implementing consistent and predictable behavior in these cases
    reinforced the importance of clearly defining algorithm boundaries when processing real-world data.
  </p>

  <p>
    This enhancement strengthened the understanding of how algorithms and data structures support reliable
    decision-making in software systems.  The resulting component provides a repeatable, transparent, and
    scalable method of determining eligibility that improves both administrative efficiency and data
    consistency within the food pantry system.
  </p>

  <h3>Artifact Files</h3>
  <table>
    <thead>
      <tr><th>File</th><th>Description</th></tr>
    </thead>
    <tbody>
      <tr>
        <td><a href="enhancement-two/enhanced/eligibility_engine.cfm">eligibility_engine.cfm (Enhanced)</a></td>
        <td>Modular eligibility determination engine using database-driven FPL thresholds</td>
      </tr>
       <tr>
        <td><a href="enhancement-two/enhanced/people.cfm">people.cfm (Enhanced)</a></td>
        <td>Recipient management module updated to integrate automated eligibility determination</td>
      </tr>
      <tr>
        <td><a href="enhancement-two/original/people.cfm">people.cfm (Original)</a></td>
        <td>OOriginal recipient management module before eligibility engine integration</td>
      </tr>
    </tbody>
  </table>
</section>

<!-- Enhancement Three -->
<section>
  <h2>Enhancement Three — Databases</h2>
  <p>
    The artifact selected for the Databases category is the <strong>database schema</strong> supporting the
    84 Community Food Pantry web application. The schema manages recipient records, food distribution
    scheduling and tracking, registration workflows, and administrative functions used by pantry volunteers.
    The original schema was created alongside the application in February 2026. The changes implemented for
    this milestone were developed in a test environment and will be deployed to the production system upon
    course completion.
  </p>

  <p>
    Two SQL deployment scripts represent two distinct but complementary enhancements.
    <strong>RBAC_Deployment.sql</strong> introduces a role-based security structure by creating a
    <code>tbl_Roles</code> table and linking it to the existing <code>tbl_AdminUsers</code> table through
    a foreign key relationship. This design separates role definitions from user records, enforces
    referential integrity at the database level, and supports additional roles in the future without schema
    changes (Ferraiolo et al., 2001). Existing user records were assigned appropriate roles before the
    <code>NOT NULL</code> constraint was enforced on the <code>RoleID</code> column, preventing data
    integrity violations during migration.
  </p>

  <p>
    <strong>Eligibility_Engine_Deployment.sql</strong> addresses the database layer of the income
    eligibility determination system. It extends <code>tbl_People</code> with eligibility-related columns,
    creates a <code>tbl_FPL_Guidelines</code> table seeded with 2026 Federal Poverty Level data published
    by the Department of Health and Human Services (ASPE, 2023), and creates a
    <code>tbl_EligibilityAudit</code> table that records a history of every eligibility calculation
    performed for each recipient. A unique constraint on the combination of year and household size prevents
    duplicate guideline records during repeated deployments. The audit table stores the FPL threshold and
    percentage directly at the time of calculation — ensuring historical records always reflect the
    guideline values in effect at that moment, even as the guidelines table is updated in future years.
  </p>

  <p>
    Both scripts were written and commented with production safety in mind. Deployment considerations were
    included to ensure schema changes apply cleanly to an existing live system without data loss. This
    reflects an understanding that database changes in production environments carry real risk, and that a
    well-structured deployment script is as important as the schema design itself.
  </p>

  <p>
    This enhancement demonstrated database design skills, security-conscious schema architecture, and the
    use of normalized data structures to support algorithmic decision-making. Storing FPL threshold values
    in a database-driven table rather than hard-coding them in application logic is a deliberate
    architectural decision that improves maintainability and allows annual guideline updates without code
    modifications. Together, the two scripts show how well-founded database design delivers real operational
    value while enforcing integrity at the data layer.
  </p>

  <h3>Artifact Files</h3>
  <table>
    <thead>
      <tr><th>File</th><th>Description</th></tr>
    </thead>
    <tbody>
      <tr>
        <td><a href="enhancement-three/original/Schema Export - Original.txt">Schema Export — Original</a></td>
        <td>Baseline database schema export prior to any enhancements</td>
      </tr>
      <tr>
        <td><a href="enhancement-three/enhanced/Schema Export - Enhanced.txt">Schema Export — Enhanced</a></td>
        <td>Full database schema export reflecting all enhancements applied across milestones</td>
      </tr>
      <tr>
        <td><a href="enhancement-three/original/RBAC_Deployment.sql">RBAC_Deployment.sql</a></td>
        <td>Deployment script creating the roles table and linking it to the admin users table</td>
      </tr>
      <tr>
        <td><a href="enhancement-three/original/Eligibility_Engine_Deployment.sql">Eligibility_Engine_Deployment.sql</a></td>
        <td>Deployment script adding FPL guidelines, eligibility audit table, and recipient eligibility columns</td>
      </tr> 
    </tbody>
  </table>
</section>

<!-- References -->
<section>
  <h2>References</h2>
  <p>
    Ferraiolo, D. F., Sandhu, R., Gavrila, S., Kuhn, D. R., &amp; Chandramouli, R. (2001).
    Proposed NIST standard for role-based access control.
    <em>ACM Transactions on Information and System Security, 4</em>(3), 224–274.
    <a href="https://doi.org/10.1145/501978.501980">https://doi.org/10.1145/501978.501980</a>
  </p>
  <p>
    Office of the Assistant Secretary for Planning and Evaluation. (2023, January 19).
    <em>Poverty guidelines.</em> ASPE; U.S. Department of Health and Human Services.
    <a href="https://aspe.hhs.gov/topics/poverty-economic-mobility/poverty-guidelines">https://aspe.hhs.gov/topics/poverty-economic-mobility/poverty-guidelines</a>
  </p>
  <p>
    Video Icon Pictures PNG Transparent Background, Free Download #8044 - FreeIconsPNG. (2016). Freeiconspng.com.
    <a href="https://www.freeiconspng.com/img/8044">https://www.freeiconspng.com/img/8044</a>
  </p>
</section>
</div>

</body>
</html>
