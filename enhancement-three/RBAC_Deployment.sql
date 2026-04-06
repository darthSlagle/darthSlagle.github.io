/* ================================================================================
   Author:      Scott Slagle
   File:        RBAC_Deployment.sql
   Application: From the Heart Community Food Pantry - DB Schema Update
   Created:     03/14/2026

   Purpose:
   This script introduces role-based security for the Admin Portal by creating a tbl_Roles table 
   and linking it to tbl_AdminUsers via a foreign key.

   The update supports separation of privileges between Global Admins and Pantry Admins, 
   enabling more granular access control for administrative functions such as user management, 
   distribution management, and contact administration.

   Schema changes being made:
   1. Creates tbl_Roles table with a unique RoleName constraint.
   2. Inserts initial system roles:
        - Global Admin: Full administrative privileges.
        - Pantry Admin: Pantry management privileges without user management rights.
   3. Adds RoleID column to tbl_AdminUsers.
   4. Populates RoleID values for existing users:
        - Assigns Scott Slagle as Global Admin.
        - Assigns remaining users as Pantry Admin.
   5. Enforces NOT NULL constraint on RoleID for future records.
   6. Creates foreign key FK_tbl_AdminUsers_RoleID to enforce referential integrity.
   7. Provides verification query to confirm successful implementation.

   Security Considerations:
   - Ensures consistent role assignment for all admin users.
   - Prevents orphaned role references through foreign key enforcement.
   - Enables future expansion of role-based permissions.
   
   Deployment Considerations
   - Run each query block separately to ensure data integrity.

   Changelog:
   03/14/2026 - Initial creation of role-based authorization structure.
   03/27/2026 - Updated documentation for clarity.
================================================================================ */

-- Create tbl_Roles Table
CREATE TABLE dbo.tbl_Roles (
    RoleID INT IDENTITY(1,1) NOT NULL,
    RoleName NVARCHAR(50)  NOT NULL,
    Description NVARCHAR(255) NULL,

    CONSTRAINT PK_tbl_Roles PRIMARY KEY CLUSTERED (RoleID),
    CONSTRAINT UQ_tbl_Roles_RoleName UNIQUE (RoleName)
);


-- Adding initial roles to the tbl_Roles table
INSERT INTO dbo.tbl_Roles (RoleName, Description)
	VALUES ('Global Admin','Full access to all admin portal features including user administration.');
INSERT INTO dbo.tbl_Roles (RoleName, Description)
    VALUES ('Pantry Admin','Access to distribution, people, and contact management. Cannot manage admin users.');


-- Alter the dbo.tbl_AdminUsers table to add a RoleID column
ALTER TABLE dbo.tbl_AdminUsers
    ADD RoleID INT NULL;


-- Update Scott Slagle's account as a Global Admin
UPDATE dbo.tbl_AdminUsers
    SET RoleID = (
        SELECT RoleID
        FROM dbo.tbl_Roles
        WHERE RoleName = 'Global Admin'
    )
WHERE username = 'sslagle';


-- Update remaining accounts as Pantry Admin
UPDATE dbo.tbl_AdminUsers
    SET RoleID = (
        SELECT RoleID
        FROM dbo.tbl_Roles
        WHERE RoleName = 'Pantry Admin'
    )
WHERE RoleID IS NULL;


-- Enforce NOT NULL on future users
ALTER TABLE dbo.tbl_AdminUsers
    ALTER COLUMN RoleID INT NOT NULL;


-- Add foreign key — enforces referential integrity against tbl_Roles
ALTER TABLE dbo.tbl_AdminUsers
    ADD CONSTRAINT FK_tbl_AdminUsers_RoleID
        FOREIGN KEY (RoleID)
        REFERENCES dbo.tbl_Roles (RoleID);


-- Verification query - view and verify changes have been made
SELECT
    u.adminID,
    u.username,
    u.isActive,
    u.RoleID,
    r.RoleName,
    r.Description
FROM dbo.tbl_AdminUsers u
INNER JOIN dbo.tbl_Roles r ON r.RoleID = u.RoleID
ORDER BY u.adminID;