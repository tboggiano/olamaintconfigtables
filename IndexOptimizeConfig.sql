USE master;
CREATE TABLE dbo.IndexOptimizeConfig
(
    ID INT IDENTITY(1, 1) NOT NULL
  , [Databases] NVARCHAR(MAX) NOT NULL
  , FragmentationLow NVARCHAR(MAX) NULL
  , FragmentationMedium NVARCHAR(MAX) NOT NULL CONSTRAINT DF_IndexOptimize_FragmentationMedium DEFAULT 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'
  , FragmentationHigh NVARCHAR(MAX) NOT NULL CONSTRAINT DF_IndexOptimize_FragmentationHigh DEFAULT 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'
  , FragmentationLevel1 INT NOT NULL CONSTRAINT DF_IndexOptimize_FragmentationLevel1 DEFAULT 5
  , FragmentationLevel2 INT NOT NULL CONSTRAINT DF_IndexOptimize_FragmentationLevel2 DEFAULT 30
  , MinNumberOfPages INT NOT NULL CONSTRAINT DF_IndexOptimize_PageCountLevel DEFAULT 1000
  , MaxNumberOfPages INT NULL
  , SortInTempdb CHAR(1) NOT NULL CONSTRAINT DF_IndexOptimize_SortInTempdb DEFAULT 'N'
  , [MaxDOP] INT NULL
  , [FillFactor] INT NULL
  , PadIndex NVARCHAR(MAX) NULL
  , LOBCompaction NVARCHAR(MAX) NOT NULL CONSTRAINT DF_IndexOptimize_LOBCompaction DEFAULT 'Y'
  , UpdateStatistics NVARCHAR(MAX) NULL
  , OnlyModifiedStatistics NVARCHAR(MAX) NOT NULL CONSTRAINT DF_IndexOptimize_OnlyModifiedStatistics DEFAULT 'N'
  , StatisticsModificationLevel INT NULL
  , StatisticsSample INT NULL
  , StatisticsResample NVARCHAR(MAX) NOT NULL CONSTRAINT DF_IndexOptimize_StatisticsResample DEFAULT 'N'
  , PartitionLevel NVARCHAR(MAX) NOT NULL CONSTRAINT DF_IndexOptimize_PartitionLevel DEFAULT 'Y'
  , MSShippedObjects NVARCHAR(MAX) NOT NULL CONSTRAINT DF_IndexOptimize_MSShippedObjects DEFAULT 'N'
  , [Indexes] NVARCHAR(MAX) NULL
  , TimeLimit INT NULL
  , [Delay] INT NULL
  , WaitAtLowPriorityMaxDuration INT NULL
  , WaitAtLowPriorityAbortAfterWait NVARCHAR(MAX) NULL
  , [Resumable] NVARCHAR(MAX) NOT NULL CONSTRAINT DF_IndexOptimize_Resumable DEFAULT 'N'
  , AvailabilityGroups NVARCHAR(MAX) NULL
  , LockTimeout INT NULL
  , LockMessageSeverity INT NOT NULL CONSTRAINT DF_IndexOptimize_LockMessageSeverity DEFAULT 16
  , StringDelimiter NVARCHAR(MAX) NOT NULL CONSTRAINT DF_IndexOptimize_StringDelimiter DEFAULT ','
  , DatabaseOrder NVARCHAR(MAX) NULL
  , DatabasesInParallel NVARCHAR(MAX) NOT NULL CONSTRAINT DF_IndexOptimize_DatabasesInParallel DEFAULT 'N'
  , ExecuteAsUser NVARCHAR(MAX) NULL
  , LogToTable NVARCHAR(MAX) NOT NULL CONSTRAINT DF_IndexOptimize_LogToTable DEFAULT 'N'
  , [Execute] NVARCHAR(MAX) NOT NULL CONSTRAINT DF_IndexOptimize_Execute DEFAULT 'Y'
        CONSTRAINT PK_DatabaseIndexOptimizeConfig
        PRIMARY KEY CLUSTERED (ID ASC)
        WITH (FILLFACTOR = 100, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF
            , ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
             ) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
INSERT INTO dbo.IndexOptimizeConfig ([Databases])
VALUES ('USER_DATABASES');