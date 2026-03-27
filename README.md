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
  <h2>Software Design and Engineering Artifact</h2>

  <p>
    The artifact I selected for the Software Design and Engineering category is my
    <strong>84 Community Food Pantry Web Application</strong>, a full-stack web application
    I developed to support the operations of my local community food pantry. The
    application manages recipient contact information, recipient registration tasks,
    distribution tracking, and administrative functions used by the volunteers during
    food distribution events. The system was originally developed as a solution for the
    pantry; I cloned and purged the production system for use in my capstone project so
    enhancements could be implemented without affecting the live system. These
    enhancements will be integrated into the live system upon my completion of this course.
  </p>

  <p>
    I selected this artifact for my ePortfolio because it demonstrates several important
    software engineering principles including secure system design, database-driven
    application architecture, and maintainable authentication logic. The system is
    actively used in a real community environment, which requires the software to be
    reliable, secure, and adaptable as operational needs change. This made this artifact
    a strong example of applied software design.
  </p>

  <p>
    The enhancement implemented for this milestone was the development of a
    <strong>Role-Based Access Control system (RBAC)</strong> for the administration portal.
    Based on the original design of the application, all administrative functions were
    handled by a small group of volunteers. Because of this, an unauthenticated page was
    created which would accept a username and password, hash the password, and insert the
    username and hashed password into the database. This method, although acceptable for
    initial setup and first admin creation, if not addressed, poses a significant security
    vulnerability if it were discovered. To address this, I redesigned the authorization
    structure so that administrative permissions are defined in the database and enforced
    by the application logic. This required creating a new roles table, modifying the
    admin users table to include a role reference, and updating the authentication module
    to dynamically evaluate user permissions when pages are visited.
  </p>

  <p>
    Implementing Role Based Access Control significantly improved the system architecture.
    This improvement separates user identity from permission definitions, which follows
    standard software engineering practices for secure system design
    (Ferraiolo et al., 2001). This approach allows additional roles to be introduced in
    the future without rewriting application logic, improving both maintainability and
    scalability. I also added safeguards in the administrative user management interface
    to prevent administrators from accidentally disabling their own accounts or modifying
    their own privilege level.
  </p>

  <p>
    Through this enhancement process, I demonstrated skills aligned with several program
    outcomes, particularly the ability to design and implement computing solutions using
    established software engineering practices. The redesign required the modification of
    both the database schema and the application authentication flow, while maintaining
    compatibility with the remaining application pages. I also considered security
    implications during development, ensuring that restricted pages could not be accessed
    through direct URL entry by unauthorized users.
  </p>

  <p>
    While working on this enhancement, I was reminded of the importance of designing
    systems that anticipate unforeseen or altered requirements. Although the original
    version functions correctly for its intended purpose, choosing not to structure the
    system for role management inadvertently caused the implementation to be more difficult
    and left a significant security vulnerability. By introducing a normalized role
    structure and database-driven permission checks, the system is now more robust and
    easier to maintain. This experience strengthened my understanding of how thoughtful
    software architecture decisions can improve both security and long-term scalability of
    real-world applications.
  </p>

  <h2>References</h2>
  <p>
    Ferraiolo, D. F., Sandhu, R., Gavrila, S., Kuhn, D. R., &amp; Chandramouli, R. (2001).
    Proposed NIST standard for role-based access control.
    <em>ACM Transactions on Information and System Security, 4</em>(3), 224–274.
    <a href="https://doi.org/10.1145/501978.501980">https://doi.org/10.1145/501978.501980</a>
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
