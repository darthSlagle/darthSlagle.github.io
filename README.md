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
    <span>Coming Soon</span>
  </section>

  <!-- Enhancement One -->
  <section id="enhancement-one">
    <h2>Enhancement One &mdash; Software Design and Engineering</h2>
    <h3>Artifact Description</h3>
    <p>
      The artifact selected for this enhancement is the <strong>84 Community Food Pantry Web Application</strong>,
      a full-stack web application developed to support the operations of a local community food pantry.
      The application manages recipient contact information, registration tasks, distribution tracking,
      and administrative functions used by volunteers during food distribution events. The system was
      originally developed as a production solution for the pantry; it was cloned and purged for use
      in this capstone project so enhancements could be implemented without affecting the live system.
      These enhancements will be integrated into the live system upon completion of this course.
    </p>
    <h3>Justification</h3>
    <p>
      This artifact was selected because it demonstrates several important software engineering principles
      including secure system design, database-driven application architecture, and maintainable
      authentication logic. The system is actively used in a real community environment, which requires
      it to be reliable, secure, and adaptable as operational needs change.
    </p>
    <p>
      The enhancement implemented for this milestone was the development of a
      <strong>Role-Based Access Control (RBAC) system</strong> for the administration portal.
      In the original design, an unauthenticated setup page was used to create the first admin account &mdash;
      a method that, if left unaddressed, poses a significant security vulnerability.
      To address this, the authorization structure was redesigned so that administrative permissions
      are defined in the database and enforced by the application logic. This required creating a new
      roles table, modifying the admin users table to include a role reference, and updating the
      authentication module to dynamically evaluate user permissions on every page request.
    </p>
    <p>
      Implementing RBAC significantly improved the system architecture by separating user identity
      from permission definitions, which follows standard software engineering practices for secure
      system design (Ferraiolo et al., 2001). This approach allows additional roles to be introduced
      in the future without rewriting application logic, improving both maintainability and scalability.
      Safeguards were also added to prevent administrators from accidentally disabling their own
      accounts or modifying their own privilege level.
    </p>
    <h3>Reflection</h3>
    <p>
      Through this enhancement, skills were demonstrated aligned with several program outcomes,
      particularly the ability to design and implement computing solutions using established software
      engineering practices. The redesign required modification of both the database schema and the
      application authentication flow while maintaining compatibility with all existing pages.
      Security implications were considered throughout, ensuring that restricted pages could not be
      accessed through direct URL entry by unauthorized users.
    </p>
    <p>
      This experience reinforced the importance of designing systems that anticipate future requirements.
      Although the original version functioned correctly for its intended purpose, the lack of a role
      management structure inadvertently made the eventual implementation more difficult and left a
      meaningful security gap. Introducing a normalized role structure and database-driven permission
      checks made the system more robust and easier to maintain, and strengthened the understanding
      of how thoughtful software architecture decisions improve both security and long-term scalability.
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
    <p>Coming Soon</p>
  </section>

  <!-- Enhancement Three -->
  <section>
    <h2>Enhancement Three — Databases</h2>
    <p>Coming Soon</p>
  </section>

   <!-- References -->
  <section>
    <h2>References</h2>
    <p>Video Icon Pictures PNG Transparent Background, Free Download #8044 - FreeIconsPNG. (2016). Freeiconspng.com. https://www.freeiconspng.com/img/8044‌</p>
  </section>
</div>

</body>
</html>
