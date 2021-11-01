﻿USE master;
CREATE TABLE dbo.DatabaseIntegrityCheckConfig
(
[Databases] nvarchar(max) NOT NULL,
CheckCommands nvarchar(max) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_CheckCommands DEFAULT 'CHECKDB',
PhysicalOnly nvarchar(max) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_PhysicalOnly DEFAULT 'N',
DataPurity nvarchar(max) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_DataPurity DEFAULT 'N',
NoIndex nvarchar(max) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_NoIndex DEFAULT 'N',
ExtendedLogicalChecks nvarchar(max) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_ExtendedLogicalChecks DEFAULT 'N',
[TabLock] nvarchar(max) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_TabLock DEFAULT 'N',
[FileGroups] nvarchar(max) NULL,
[Objects] nvarchar(max) NULL,
[MaxDOP] int NULL,
AvailabilityGroups nvarchar(max) NULL,
AvailabilityGroupReplicas nvarchar(max) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_AvailabilityGroupReplicas DEFAULT 'ALL',
Updateability nvarchar(max) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_Updateability DEFAULT 'ALL',
TimeLimit INT NULL,
LockMessageSeverity INT NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_LockMessageSeverity DEFAULT 16,
StringDelimiter nvarchar(max) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_StringDelimiter DEFAULT ',',
DatabaseOrder nvarchar(max) NULL,
DatabasesInParallel nvarchar(max) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_DatabasesInParallel DEFAULT 'N',
LogToTable nvarchar(max) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_LogToTable DEFAULT 'N',
[Execute] nvarchar(max) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_Execute DEFAULT 'Y'
);
GO

INSERT INTO dbo.DatabaseIntegrityCheckConfig ([Databases])
VALUES ('USER_DATABASES'),
 ('SYSTEM_DATABASES');

