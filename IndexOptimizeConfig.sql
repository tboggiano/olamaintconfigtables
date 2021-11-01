USE master;
CREATE TABLE dbo.IndexOptimizeConfig
(
[Databases] nvarchar(max) NOT NULL,
FragmentationLow nvarchar(max) NULL,
FragmentationMedium nvarchar(max) NOT NULL CONSTRAINT DF_IndexOptimize_FragmentationMedium DEFAULT 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
FragmentationHigh nvarchar(max) NOT NULL CONSTRAINT DF_IndexOptimize_FragmentationHigh DEFAULT 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
FragmentationLevel1 int NOT NULL CONSTRAINT DF_IndexOptimize_FragmentationLevel1 DEFAULT 5,
FragmentationLevel2 int NOT NULL CONSTRAINT DF_IndexOptimize_FragmentationLevel2 DEFAULT 30,
MinNumberOfPages int NOT NULL CONSTRAINT DF_IndexOptimize_PageCountLevel DEFAULT 1000,
MaxNumberOfPages int NULL,
SortInTempdb char(1) NOT NULL CONSTRAINT DF_IndexOptimize_SortInTempdb DEFAULT 'N',
[MaxDOP] int NULL,
[FillFactor] int NULL,
PadIndex nvarchar(max) NULL,
LOBCompaction nvarchar(max) NOT NULL CONSTRAINT DF_IndexOptimize_LOBCompaction DEFAULT 'Y',
UpdateStatistics nvarchar(max) NULL,
OnlyModifiedStatistics nvarchar(max) NOT NULL CONSTRAINT DF_IndexOptimize_OnlyModifiedStatistics DEFAULT 'N',
StatisticsModificationLevel INT NULL,
StatisticsSample int NULL,
StatisticsResample nvarchar(max) NOT NULL CONSTRAINT DF_IndexOptimize_StatisticsResample DEFAULT 'N',
PartitionLevel nvarchar(max) NOT NULL CONSTRAINT DF_IndexOptimize_PartitionLevel DEFAULT 'Y',
MSShippedObjects nvarchar(max) NOT NULL CONSTRAINT DF_IndexOptimize_MSShippedObjects DEFAULT 'N',
[Indexes] nvarchar(max) NULL,
TimeLimit int NULL,
[Delay] int NULL,
WaitAtLowPriorityMaxDuration int NULL,
WaitAtLowPriorityAbortAfterWait nvarchar(max) NULL,
[Resumable] nvarchar(max) NOT NULL CONSTRAINT DF_IndexOptimize_Resumable DEFAULT 'N',
AvailabilityGroups nvarchar(max) NULL,
LockTimeout int NULL,
LockMessageSeverity int NOT NULL CONSTRAINT DF_IndexOptimize_LockMessageSeverity DEFAULT 16,
StringDelimiter nvarchar(max) NOT NULL CONSTRAINT DF_IndexOptimize_StringDelimiter DEFAULT ',',
DatabaseOrder nvarchar(max) NULL,
DatabasesInParallel nvarchar(max) NOT NULL CONSTRAINT DF_IndexOptimize_DatabasesInParallel DEFAULT 'N',
ExecuteAsUser nvarchar(max) NULL,
LogToTable nvarchar(max) NOT NULL CONSTRAINT DF_IndexOptimize_LogToTable DEFAULT 'N',
[Execute] nvarchar(max) NOT NULL CONSTRAINT DF_IndexOptimize_Execute DEFAULT 'Y'
)
GO
INSERT INTO dbo.IndexOptimizeConfig ([Databases])
VALUES ('USER_DATABASES');
