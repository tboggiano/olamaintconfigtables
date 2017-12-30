USE master;
CREATE TABLE dbo.IndexOptimizeConfig
(
[Databases] varchar(max) NOT NULL,
FragmentationLow varchar(59) NULL,
FragmentationMedium varchar(59) NOT NULL CONSTRAINT DF_IndexOptimize_FragmentationMedium DEFAULT 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
FragmentationHigh varchar(59) NOT NULL CONSTRAINT DF_IndexOptimize_FragmentationHigh DEFAULT 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
FragmentationLevel1 int NOT NULL CONSTRAINT DF_IndexOptimize_FragmentationLevel1 DEFAULT 5,
FragmentationLevel2 int NOT NULL CONSTRAINT DF_IndexOptimize_FragmentationLevel2 DEFAULT 30,
PageCountLevel int NOT NULL CONSTRAINT DF_IndexOptimize_PageCountLevel DEFAULT 1000,
SortInTempdb char(1) NOT NULL CONSTRAINT DF_IndexOptimize_SortInTempdb DEFAULT 'N',
[MaxDOP] int NULL,
[FillFactor] int NULL,
PadIndex varchar(max) NULL,
LOBCompaction char(1) NOT NULL CONSTRAINT DF_IndexOptimize_LOBCompaction DEFAULT 'Y',
UpdateStatistics varchar(7) NULL,
OnlyModifiedStatistics char(1) NOT NULL CONSTRAINT DF_IndexOptimize_OnlyModifiedStatistics DEFAULT 'N',
StatisticsSample int NULL,
StatisticsResample char(1) NOT NULL CONSTRAINT DF_IndexOptimize_StatisticsResample DEFAULT 'N',
PartitionLevel char(1) NOT NULL CONSTRAINT DF_IndexOptimize_PartitionLevel DEFAULT 'Y',
MSShippedObjects char(1) NOT NULL CONSTRAINT DF_IndexOptimize_MSShippedObjects DEFAULT 'N',
[Indexes] varchar(max) NULL,
TimeLimit int NULL,
[Delay] int NULL,
WaitAtLowPriorityMaxDuration int NULL,
WaitAtLowPriorityAbortAfterWait varchar(8) NULL,
AvailabilityGroups varchar(max) NULL,
LockTimeout int NULL,
LogToTable char(1) NOT NULL CONSTRAINT DF_IndexOptimize_LogToTable DEFAULT 'N',
[Execute] char(1) NOT NULL CONSTRAINT DF_IndexOptimize_Execute DEFAULT 'Y'
)
GO
INSERT INTO dbo.IndexOptimizeConfig ([Databases])
VALUES ('USER_DATABASES');
