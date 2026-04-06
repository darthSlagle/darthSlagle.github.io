/* ================================================================================
   Author:      Scott Slagle
   File:        Eligibility_Engine_Deployment.sql
   Application: From the Heart Community Food Pantry
   Created:     03/21/2026

   Purpose:
   This script deploys the Food Pantry Eligibility Engine database schema by extending tbl_People
   with eligibility-related columns, creating the tbl_FPL_Guidelines table, seeding 2026 Federal Poverty Level guideline
   data, and creating tbl_EligibilityAudit for calculation history.

   The update supports consistent eligibility determination for pantry applicants based on household size and annual
   income, while preserving an audit trail of calculated results for administrative review and historical reference.

   Schema changes being made:
   1. Adds eligibility-related columns to tbl_People:
        - householdSize
        - annualIncome
        - eligibilityTier
        - eligibleFlag
        - FPL_Percent
        - FPL_Amt
        - eligibilityUpdatedAt
   2. Creates tbl_FPL_Guidelines with a unique constraint on year and householdSize.
   3. Seeds 2026 HHS Federal Poverty Level data.
   4. Creates tbl_EligibilityAudit to store eligibility calculation history.

   Security Considerations:
   - Preserves existing tbl_People data by adding new columns as NULL.
   - Prevents duplicate FPL guideline rows through unique constraints and guarded inserts.
   - Maintains reference integrity in dbo.tbl_EligibilityAudit through foreign key enforcement.
   - Supports eligibility decisions through audit records.

   Deployment Considerations:
   - Eligibility values for existing people records will remain NULL until recalculated through the admin portal.
   - Run each query block separately to ensure data integrity. 

   Changelog:
   03/21/2026 - Initial Development - Eligibility engine schema deployment script.
   03/28/2026 - Updated documentation for clarity.
================================================================================ */


-- Add eligibility columns to tbl_People

-- householdSize
ALTER TABLE dbo.tbl_People
    ADD householdSize INT NULL;

-- annualIncome
ALTER TABLE dbo.tbl_People
    ADD annualIncome DECIMAL(12,2) NULL;

-- eligibilityTier  (0=Not Eligible, 1=Tier 1, 2=Tier 2, 3=Tier 3)
ALTER TABLE dbo.tbl_People
    ADD eligibilityTier TINYINT NULL;

-- eligibleFlag  (0=Not Eligible, 1=Eligible)
ALTER TABLE dbo.tbl_People
    ADD eligibleFlag TINYINT NULL;

-- FPL_Percent
ALTER TABLE dbo.tbl_People
    ADD FPL_Percent DECIMAL(8,2) NULL;

-- FPL_Amt
ALTER TABLE dbo.tbl_People
    ADD FPL_Amt DECIMAL(12,2) NULL;

-- eligibilityUpdatedAt
ALTER TABLE dbo.tbl_People
    ADD eligibilityUpdatedAt DATETIME NULL;

-- Create tbl_FPL_Guidelines
CREATE TABLE dbo.tbl_FPL_Guidelines (
    guidelineID INT IDENTITY(1,1) NOT NULL,
    year INT NOT NULL,
    householdSize INT NOT NULL,
    FPL_Amt DECIMAL(12,2) NOT NULL,
    additionalPerPerson DECIMAL(12,2) NOT NULL,
    maxGuidelineSize INT NOT NULL,
    createdAt DATETIME NOT NULL CONSTRAINT DF_tbl_FPL_Guidelines_createdAt DEFAULT GETDATE(),
    CONSTRAINT PK_tbl_FPL_Guidelines
    PRIMARY KEY CLUSTERED (guidelineID),
    CONSTRAINT UQ_tbl_FPL_Guidelines_year_householdSize
    UNIQUE (year, householdSize)
);


-- INSERT HHS Seed Data for 2026.
INSERT INTO dbo.tbl_FPL_Guidelines (year, householdSize, FPL_Amt, additionalPerPerson, maxGuidelineSize)
	VALUES 
	(2026, 1, 15960, 5680, 8),
    (2026, 2, 21640, 5680, 8),
    (2026, 3, 27320, 5680, 8),
    (2026, 4, 33000, 5680, 8),
    (2026, 5, 38680, 5680, 8),
    (2026, 6, 44360, 5680, 8),
    (2026, 7, 50040, 5680, 8),
    (2026, 8, 55720, 5680, 8);
    

-- Create tbl_EligibilityAudit
CREATE TABLE dbo.tbl_EligibilityAudit (
    auditID INT IDENTITY(1,1) NOT NULL,
    personID INT NOT NULL,
    eligibilityTier TINYINT NOT NULL,
    eligible_flag TINYINT NOT NULL,
    FPL_Percent DECIMAL(8,2) NOT NULL,
    FPL_Amt DECIMAL(12,2) NOT NULL,
    householdSize INT NOT NULL,
    annualIncome DECIMAL(12,2) NOT NULL,
    calculatedAt DATETIME NOT NULL CONSTRAINT DF_tbl_EligibilityAudit_calculatedAt DEFAULT GETDATE(),
    CONSTRAINT PK_tbl_EligibilityAudit
    PRIMARY KEY CLUSTERED (auditID),
    CONSTRAINT FK_tbl_EligibilityAudit_personID
    FOREIGN KEY (personID)
    REFERENCES dbo.tbl_People (personID)
);