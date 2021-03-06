USE master;
CREATE TABLE dbo.DatabaseIntegrityCheckConfig
(
[Databases] varchar(max) NOT NULL,
CheckCommands varchar(34) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_CheckCommands DEFAULT 'CHECKDB',
PhysicalOnly char(1) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_PhysicalOnly DEFAULT 'N',
NoIndex char(1) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_NoIndex DEFAULT 'N',
ExtendedLogicalChecks char(1) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_ExtendedLogicalChecks DEFAULT 'N',
[TabLock] char(1) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_TabLock DEFAULT 'N',
[FileGroups] varchar(max) NULL,
[Objects] varchar(max) NULL,
[MaxDOP] int NULL,
AvailabilityGroups varchar(max) NULL,
AvailabilityGroupReplicas varchar(9) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_AvailabilityGroupReplicas DEFAULT 'ALL',
Updateability varchar(10) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_Updateability DEFAULT 'ALL',
LockTimeout int NULL,
LogToTable char(1) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_LogToTable DEFAULT 'N',
[Execute] char(1) NOT NULL CONSTRAINT DF_DatabaseIntegrityCheck_Execute DEFAULT 'Y'
);
GO

INSERT INTO dbo.DatabaseIntegrityCheckConfig ([Databases])
VALUES ('USER_DATABASES'),
 ('SYSTEM_DATABASES');

