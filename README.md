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
  <h2>Enhancement One — Software Design and Engineering</h2>

  <p>
    The artifact I selected for the Software Design and Engineering category is my <strong>84 Community Food
    Pantry Web Application</strong>, a full-stack web application I developed to support the operations of my
    local community food pantry. The application manages recipient contact information, recipient
    registration tasks, distribution tracking, and administrative functions used by the volunteers
    during food distribution events. The system was originally developed as a solution for the pantry;
    I cloned and purged the production system for use in my capstone project so enhancements could be
    implemented without affecting the live system. These enhancements will be integrated into the live
    system upon my completion of this course.
  </p>

  <p>
    I selected this artifact for my ePortfolio because it demonstrates several important software
    engineering principles including secure system design, database-driven application architecture,
    and maintainable authentication logic. The system is actively used in a real community environment,
    which requires the software to be reliable, secure, and adaptable as operational needs change.
    This made this artifact a strong example of applied software design.
  </p>

  <p>
    The enhancement implemented for this milestone was the development of a Role-Based Access Control
    system, or RBAC, for the administration portal. Based on the original design of the application,
    all administrative functions were handled by a small group of volunteers. Because of this, an
    unauthenticated page was created which would accept a username and password, hash the password and
    insert the username and hashed password into the database. This method, although acceptable for
    initial setup and first admin creation, if not addressed, poses a significant security vulnerability
    if it were discovered. To address this, I redesigned the authorization structure so that
    administrative permissions are defined in the database and enforced by the application logic. This
    required creating a new roles table, modifying the admin users table to include a role reference,
    and updating the authentication module to dynamically evaluate user permissions when pages are
    visited.
  </p>

  <p>
    Implementing Role Based Access Control significantly improved the system architecture. This
    improvement separates user identity from permission definitions, which follows standard software
    engineering practices for secure system design (Ferraiolo et al., 2001). This approach allows
    additional roles to be introduced in the future without rewriting application logic, improving
    both maintainability and scalability. I also added safeguards in the administrative user
    management interface to prevent administrators from accidentally disabling their own accounts or
    modifying their own privilege level.
  </p>

  <p>
    Through this enhancement process, I demonstrated skills aligned with several program outcomes,
    particularly the ability to design and implement computing solutions using established software
    engineering practices. The redesign required the modification of both the database schema and the
    application authentication flow, while maintaining compatibility with the remaining application
    pages. I also considered security implications during development, ensuring that restricted pages
    could not be accessed through direct URL entry by unauthorized users.
  </p>

  <p>
    While working on this enhancement, I was reminded of the importance of designing systems that
    anticipate unforeseen or altered requirements. Although the original version functions correctly
    for its intended purpose, choosing to not structure the system for role management has
    inadvertently caused the implementation to be more difficult and left a significant security
    vulnerability. By introducing a normalized role structure and database-driven permission checks,
    the system is now more robust and easier to maintain. This experience strengthened my understanding
    of how thoughtful software architecture decisions can improve both security and long-term
    scalability of real-world applications.
  </p>

  <h3>Screenshots</h3>

  <h4>Admin Dashboard — Before &amp; After</h4>
  <p>
    The original dashboard provided no access controls.  All navigation options were available
    to any authenticated user.  The enhanced dashboard conditionally shows the
    <strong>User Manager</strong> navigation item only to users assigned the Global Admin role.
  </p>
  <table>
    <thead>
      <tr>
         <th>Original</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td align="center">
          <img src="https://slaglecloud.net/ePortfolio/ORIGINAL-AdminDashboard.png" width="100%" alt="Original Admin Dashboard — no User Manager navigation" />
          <br /><em>No User Manager link visible</em>
        </td>
      </tr>
    </tbody>
  </table>
  <table>
   <thead>
      <tr>
         <th>Enhanced</th>
      </tr>
   </thead>
   <tbody>
      <tr>
        <td align="center">
          <img src="https://slaglecloud.net/ePortfolio/ENHANCED-AdminDashboard.png" width="100%" alt="Enhanced Admin Dashboard — User Manager navigation added" />
          <br /><em>User Manager link visible for Global Admin role</em>
        </td>
      </tr>
    </tbody>
  </table>

  <h4>User Manager</h4>
  <p>
    The User Manager, only accessible to the Global Admin role, displays all
    administrative accounts with their assigned role, status, and last login.  Role badges
    visually distinguish Global Admin from Pantry Admin accounts, and the currently logged-in
    user is identified with a "You" badge to support the safeguard preventing self-modification.
  </p>
  <p align="center">
    <img src="https://slaglecloud.net/ePortfolio/ENHANCED-AdminUserManager.png" width="860" alt="Enhanced Admin User Manager — role and status display" />
  </p>

  <h4>Add Admin User</h4>
  <p>
    New administrator accounts require a username, password, and role assignment at creation.
     Roles are populated dynamically from the database, ensuring that any roles added in the
    future automatically appear in this interface without code changes.
  </p>
  <p align="center">
    <img src="https://slaglecloud.net/ePortfolio/ENHANCED-AddAdminuser.png" width="860" alt="Enhanced Add Admin User form with role selection" />
  </p>

  <h4>Edit Admin User</h4>
  <p>
    The edit interface allows a Global Admin to change another user's role, reset their
    password, or deactivate their account.  Safeguards in the application logic prevent an
    administrator from modifying their own role or deactivating their own account from this screen.
  </p>
  <p align="center">
    <img src="https://slaglecloud.net/ePortfolio/ENHANCED-EditAdminuser.png" width="860" alt="Enhanced Edit Admin User interface with role, password, and status controls" />
  </p>

  <h3>Artifact Files</h3>
    <table>
      <thead>
        <tr>
           <th>File</th>
           <th>Description</th>
        </tr>
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
    The artifact I selected for the Algorithms and Data Structures category is the <strong>income eligibility
    determination engine</strong> developed for the 84 Community Food Pantry web application.  This component
    evaluates a household's reported income and household size against Federal Poverty Level guidelines
    and assigns an eligibility tier used to determine qualification for participation in pantry
    distributions.  The original version of the application was designed primarily to track recipients
    and distributions, and eligibility determinations were performed manually by reviewing printed
    guideline tables received by the regional Food Bank, for us it's the Greater Pittsburgh Community
    Food Bank.  The enhanced artifact introduces an automated decision-making component that improves
    consistency, efficiency, and accuracy when determining eligibility.  The eligibility engine was
    implemented as a modular component using structured decision logic and database-driven threshold
    values to ensure that eligibility determinations are applied uniformly across all recipients.
  </p>

  <p>
    I selected this artifact for inclusion in my ePortfolio because it demonstrates practical
    application of algorithmic thinking and structured data evaluation in a real-world environment.
    The eligibility engine transforms regulatory guidance into a deterministic classification process
    that evaluates numeric inputs and produces consistent results. This enhancement highlights my
    ability to translate policy requirements into a logical algorithm that uses defined data structures
    to guide decision-making. The component also demonstrates how structured lookup tables can be used
    to drive classification logic rather than relying on hard-coded values, allowing the system to
    adapt easily as poverty guideline thresholds change annually. By storing guideline thresholds and
    eligibility tiers in the database, the algorithm separates reference data from procedural logic,
    improving maintainability and scalability.
  </p>

  <p>
    The enhanced artifact applies a step-by-step algorithm that accepts household size and annual income
    as input, retrieves the corresponding Federal Poverty Level threshold from the database, calculates
    the household's percentage of the poverty level, and assigns an eligibility tier based on defined
    ranges. This deterministic approach ensures that identical inputs always produce the same output,
    which is critical when implementing systems that must follow regulatory guidelines. The algorithm
    relies on structured data relationships and conditional evaluation logic to determine eligibility
    classification. The modular design of the eligibility_engine.cfm file also allows the logic to be
    reused across multiple application workflows, including initial registration and periodic income
    updates. This demonstrates how separating algorithmic logic into reusable components improves
    maintainability and reduces redundancy within the application.
  </p>

  <p>
    Through this enhancement, I demonstrated skills aligned with course outcomes related to algorithm
    design, structured problem solving, and implementation of computing solutions that address
    real-world needs. Designing the eligibility determination process required careful consideration
    of how to structure reference data efficiently, how to minimize repeated calculations, and how to
    ensure the logic remained adaptable as guidelines evolve. The use of database-driven thresholds
    provides flexibility and prevents the need for code changes when regulatory values are updated.
    This design decision reflects an understanding of how appropriate data structures can improve both
    efficiency and long-term sustainability of a system.
  </p>

  <p>
    During my work on enhancing this artifact, my primary challenge was understanding and interpreting
    into code how the algorithm should evaluate household size when an exact guideline match was not
    available. The Federal Poverty Level guidelines are published with defined income thresholds based
    on specific household sizes. However, real-world data does not always align perfectly with
    predefined values, requiring thoughtful handling of boundary conditions. I needed to determine
    whether the algorithm should require an exact match to a stored household size value or dynamically
    evaluate the closest applicable guideline range. This required careful consideration of how the
    lookup logic should behave when handling households larger than the maximum defined guideline value.
    I implemented logic that ensures the algorithm consistently applies the correct threshold by
    selecting the appropriate guideline entry and applying a structured comparison method. This
    experience reinforced the importance of clearly defining algorithm boundaries and ensuring
    predictable behavior when processing real-world data that may not always align perfectly with
    structured datasets.
  </p>

  <p>
    This enhancement strengthened my understanding of how algorithms and data structures support
    reliable decision-making in software systems. By implementing a structured eligibility
    determination process, I was able to demonstrate how computer science principles can be applied
    to improve operational efficiency while ensuring compliance with established guidelines. The
    resulting component provides a repeatable, transparent, and scalable method of determining
    eligibility that improves both administrative efficiency and data consistency within the food
    pantry system.
  </p>

  <h3>Screenshots</h3>

  <h4>People List — Before &amp; After</h4>
  <p>
    The original People list displayed only name, phone, status, and actions. The enhanced version
    adds a <strong>Tier</strong> column showing each recipient's calculated eligibility tier directly
    in the list, giving volunteers immediate visibility into eligibility status without opening
    individual records.
  </p>
  <table>
    <thead>
      <tr>
         <th>Original</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td align="center">
          <img src="https://slaglecloud.net/ePortfolio/ORIGINAL-People.png" width="100%" alt="Original People list — no Tier column" />
          <br /><em>No eligibility tier displayed</em>
        </td>
      </tr>
    </tbody>
  </table>
   <table>
    <thead>
      <tr>
         <th>Enhanced</th>
       </tr>
    </thead>
    <tbody>
      <tr>
        <td align="center">
          <img src="https://slaglecloud.net/ePortfolio/ENHANCED-People.png" width="100%" alt="Enhanced People list — Tier column added" />
          <br /><em>Eligibility tier badge displayed for each recipient</em>
        </td>
      </tr>
    </tbody>
  </table>

  <h4>Add Person — Eligibility Engine Integration</h4>
  <p>
    The Add Person form was updated to collect household size and annual gross income at the time of
    registration. When the record is saved, the eligibility engine runs automatically and assigns
    the appropriate tier before the record is committed, ensuring every new recipient enters the
    system with a calculated eligibility result.
  </p>
  <table>
    <thead>
      <tr>
         <th>Before Save</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td align="center">
          <img src="https://slaglecloud.net/ePortfolio/ENHANCED-AddPerson-SavetoRunEligibilityEngine.png" width="100%" alt="Add Person form with household size and income fields ready to save" />
          <br /><em>Household size and income entered — Save triggers the engine</em>
        </td>
      </tr>
    </tbody>
  </table>
  <table>
    <thead>
      <tr>
         <th>After Save</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td align="center">
          <img src="https://slaglecloud.net/ePortfolio/ENHANCED-AddPerson-EligibilityEngineCompleted.png" width="100%" alt="People list after add — new recipient shown with Tier badge" />
          <br /><em>Recipient added with eligibility tier automatically assigned</em>
        </td>
      </tr>
    </tbody>
  </table>

  <h4>Edit Person — Eligibility Results</h4>
  <p>
    The Edit Person view surfaces the full eligibility determination result inline, displaying the
    assigned tier, FPL percentage, FPL threshold amount, and the timestamp of the last calculation.
    Saving any change to household size or income reruns the engine and updates the result
    automatically.
  </p>
  <p align="center">
    <img src="https://slaglecloud.net/ePortfolio/ENHANCED-EditPerson-ShowsResults-SavetoRerunEngine.png" width="100%" alt="Edit Person view showing Eligibility Results section with tier, FPL percentage, FPL amount, and last calculated timestamp" />
  </p>

  <h3>Artifact Files</h3>
  <table>
    <thead>
      <tr>
         <th>File</th>
         <th>Description</th>
      </tr>
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
    The artifact I selected for the Databases category is the <strong>database schema</strong> supporting the 84 Community
    Food Pantry web application.  The application manages recipient records, food distribution scheduling
    and tracking, registration workflows, and administrative functions used by pantry volunteers.  The
    database schema used for this system was originally created by me in February, 2026, alongside the
    application itself.
  </p>

  <p>
    I selected this artifact because it gave me the opportunity to demonstrate real database design skills
    in a context where the decisions I made would have a direct, meaningful impact on a system that is
    actively used in my community.  The changes made to this schema are being made in a test environment
    for this course; however, they are being deployed to the production system when this course is
    complete.  That responsibility shaped how I thought about every design decision, from constraint
    definitions to the structure of audit records.
  </p>

  <p>
    The two SQL scripts submitted for this milestone, RBAC_Deployment.sql and
    Eligibility_Engine_Deployment.sql, represent two distinct but complementary database enhancements.
     The RBAC script introduces a role-based security structure by creating a tbl_Roles table and linking
    it to the existing tbl_AdminUsers table through a foreign key relationship.  This design separates role
    definitions from user records, enforces reference integrity at the database level, and allows the
    system to support additional roles in the future without requiring additional changes to the schema
    (Ferraiolo et al., 2001).  The script was written to be safe for deployment into an existing live
    system; existing user records were updated with appropriate role assignments before the NOT NULL
    constraint was enforced on the RoleID column, which prevented data integrity violations during
    migration.
  </p>

  <p>
    The Eligibility Engine script addresses the database layer of the income eligibility determination
    system developed in Milestone Three.  It extends the tbl_People table with eligibility-related columns,
    creates a tbl_FPL_Guidelines table seeded with 2026 Federal Poverty Level data published by the
    Department of Health and Human Services (Office of the Assistant Secretary for Planning and Evaluation,
    2023), and creates a tbl_EligibilityAudit table that records a history of every eligibility calculation
    performed for each recipient.  The FPL guidelines table includes a unique constraint on the combination
    of year and household size, which prevents duplicate guideline records from being inserted during
    repeated deployments.  The audit table is linked to tbl_People through a foreign key, ensuring that
    audit records can only reference valid recipient records.
  </p>

  <p>
    Both scripts were written and commented with production safety in mind.  Deployment considerations were
    included to ensure duplication of the schema changes happen safely without loss of data.  This approach
    reflects an understanding that database changes in a live system carry risk, and that a well-written
    deployment script is as important as the schema itself.
  </p>

  <p>
    Through this enhancement, I made meaningful progress toward several of the program's course outcomes.
     The design and implementation of the FPL guidelines table and its relationship to the eligibility
    engine demonstrates my ability to design computing solutions using appropriate data structures and
    algorithmic principles.  Storing threshold values in a normalized, database-driven table rather than
    hard-coding them in application logic is a deliberate architectural decision that improves
    maintainability and ensures the system can adapt to annual guideline changes without code
    modifications.  The role-based security schema demonstrates a security mindset applied at the data
    layer, enforcing access control definitions in the database rather than relying solely on application
    logic to manage permissions.  Both enhancements together show an ability to use well-founded database
    design techniques to implement solutions that deliver real operational value.
  </p>

  <p>
    The course outcomes I planned to address were the ability to demonstrate database design skills,
    security-conscious schema architecture, and the use of data structures to support algorithmic
    decision-making.  I believe both scripts satisfy these outcomes.
  </p>

  <p>
    Reflecting on the process of building these enhancements, the most valuable learning came from working
    through the practical constraints of modifying a live schema safely.  I have worked with databases
    professionally for many years, but this project pushed me to be more deliberate and disciplined in how
    I documented my intentions and structured my deployment approach.  Writing scripts that can be run
    safely against an existing system, accounting for existing data, enforcing integrity without breaking
    production, required me to think carefully about order of operations in a way that typical development
    work sometimes misses.
  </p>

  <p>
    The eligibility audit table prompted some interesting design thinking.  I had to decide whether to track
    every recalculation or only changes, and whether to store the FPL threshold value at the time of
    calculation or rely on the guidelines table for historical reference.  I chose to store the FPL amount
    and percent directly into the audit record so that a historical calculation would always reflect the
    guideline values that were in effect at that time, even if the guidelines table is updated in a future
    year.  That decision felt insignificant at the time; reflecting on that decision shows an understanding
    of how audit data needs to be treated differently than transactional data.
  </p>

  <p>
    Overall, this enhancement reinforced that good database design is as much about anticipating how data
    will be used and maintained over time as it is about getting the structure right for the current
    requirement.  I came away from this milestone with a clearer appreciation for the discipline that
    thoughtful schema design demands.
  </p>

   <h3>Screenshots</h3>

   <h4>Database Relationship Diagram — Before &amp; After</h4>
   <p>
     The diagrams below show the database schema before and after the enhancements implemented across
     both milestones.  The original schema contains no role structure linked to administrative users,
     and tbl_People contains only basic recipient contact fields with no eligibility-related columns.
      The enhanced schema reflects both the RBAC and eligibility engine additions in full.
   </p>
   <table>
     <thead>
       <tr>
          <th>Original</th>
       </tr>
     </thead>
     <tbody>
       <tr>
         <td align="center">
           <img src="https://slaglecloud.net/ePortfolio/ORIGINAL-TableSchemaDiagram.png" width="100%" alt="Original database schema — no roles table, no eligibility columns" />
           <br /><em>No role structure, no eligibility columns on tbl_People, no audit table</em>
         </td>
       </tr>
     </tbody>
   </table>
   
   <table>
     <thead>
       <tr>
          <th>Enhanced</th>
       </tr>
     </thead>
     <tbody>
         <td align="center">
           <img src="https://slaglecloud.net/ePortfolio/ENHANCED-TableSchemaDiagram.png" width="100%" alt="Enhanced database schema — roles, eligibility columns, and audit table added" />
           <br /><em>tbl_Roles linked to tbl_AdminUsers, tbl_People expanded, tbl_EligibilityAudit added</em>
         </td>
       </tr>
     </tbody>
   </table>
   
   <h4>Deployment Flow Diagrams</h4>
   <p>
     The diagrams below illustrate the ordered sequence of operations executed by each deployment
     script.  Both scripts were written with production safety in mind, ensuring that schema changes
     could be applied to a live system without data loss or integrity violations.
   </p>
   <p>
     The RBAC deployment flow (left) shows the deliberate order of operations, creating the roles
     table first, adding the RoleID column to tbl_AdminUsers, updating existing user records with
     appropriate role assignments, and only then enforcing the foreign key constraint.  This sequence
     was critical to prevent data integrity violations against existing records during migration.
   </p>
   <p>
     The eligibility engine deployment flow (right) shows the creation of the FPL guidelines and
     eligibility tiers reference tables, followed by the audit table, before foreign key constraints
     are applied, ensuring all referenced tables exist before relationships are enforced.
   </p>
   <p align="center">
     <img src="https://slaglecloud.net/ePortfolio/ENHANCED-DeploymentFlowDiagram.png" width="100%" alt="Deployment flow diagrams for RBAC and eligibility engine SQL scripts showing order of operations" />
   </p>

  <h3>Artifact Files</h3>
  <table>
    <thead>
      <tr>
         <th>File</th>
         <th>Description</th>
      </tr>
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
