USE master;
CREATE TABLE dbo.DatabaseIntegrityCheckConfig
(
    ID INT IDENTITY(1, 1) NOT NULL
  , [Databases] NVARCHAR(MAX) NOT NULL
  , CheckCommands NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_CheckCommands DEFAULT 'CHECKDB'
  , PhysicalOnly NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_PhysicalOnly DEFAULT 'N'
  , DataPurity NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_DataPurity DEFAULT 'N'
  , NoIndex NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_NoIndex DEFAULT 'N'
  , ExtendedLogicalChecks NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_ExtendedLogicalChecks DEFAULT 'N'
  , [TabLock] NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_TabLock DEFAULT 'N'
  , [FileGroups] NVARCHAR(MAX) NULL
  , [Objects] NVARCHAR(MAX) NULL
  , [MaxDOP] INT NULL
  , AvailabilityGroups NVARCHAR(MAX) NULL
  , AvailabilityGroupReplicas NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_AvailabilityGroupReplicas DEFAULT 'ALL'
  , Updateability NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_Updateability DEFAULT 'ALL'
  , TimeLimit INT NULL
  , LockTimeout INT NULL
  , LockMessageSeverity INT NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_LockMessageSeverity DEFAULT 16
  , StringDelimiter NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_StringDelimiter DEFAULT ','
  , DatabaseOrder NVARCHAR(MAX) NULL
  , DatabasesInParallel NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_DatabasesInParallel DEFAULT 'N'
  , LogToTable NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_LogToTable DEFAULT 'N'
  , [Execute] NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_Execute DEFAULT 'Y'
        CONSTRAINT PK_DatabaseIntegrityCheckConfig
        PRIMARY KEY CLUSTERED (ID ASC)
        WITH (FILLFACTOR = 100, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF
            , ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
             ) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO

INSERT INTO dbo.DatabaseIntegrityCheckConfig ([Databases])
VALUES ('USER_DATABASES'),
 ('SYSTEM_DATABASES');