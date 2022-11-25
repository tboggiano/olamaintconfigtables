use master;
CREATE TABLE dbo.DatabaseBackupConfig
(
    ID INT IDENTITY(1, 1) NOT NULL
  , [Databases] NVARCHAR(MAX) NULL
  , Directory NVARCHAR(MAX) NULL
  , BackupType NVARCHAR(MAX) NOT NULL
  , Verify NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_Verify DEFAULT 'N'
  , CleanupTime INT NULL
  , CleanupMode NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_CleanupMode DEFAULT 'AFTER_BACKUP'
  , [Compress] NVARCHAR(MAX) NULL
  , CopyOnly NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_CopyOnly DEFAULT 'N'
  , ChangeBackupType NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_ChangeBackupType DEFAULT 'N'
  , BackupSoftware NVARCHAR(MAX) NULL
  , [CheckSum] NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_CheckSum DEFAULT 'N'
  , [BlockSize] INT NULL
  , [BufferCount] INT NULL
  , [MaxTransferSize] INT NULL
  , NumberOfFiles INT NULL
  , MinBackupSizeForMultipleFiles INT NULL
  , MaxFileSize INT NULL
  , CompressionLevel INT NULL
  , [Description] NVARCHAR(MAX) NULL
  , Threads INT NULL
  , Throttle INT NULL
  , Encrypt NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_Encrypt DEFAULT 'N'
  , EncryptionAlgorithm NVARCHAR(MAX) NULL
  , ServerCertificate NVARCHAR(MAX) NULL
  , ServerAsymmetricKey NVARCHAR(MAX) NULL
  , EncryptionKey NVARCHAR(MAX) NULL
  , ReadWriteFileGroups NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_ReadWriteFileGroups DEFAULT 'N'
  , OverrideBackupPreference NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_OverrideBackupPreference DEFAULT 'N'
  , [NoRecovery] NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_NoRecovery DEFAULT 'N'
  , [URL] NVARCHAR(MAX) NULL
  , [Credential] NVARCHAR(MAX) NULL
  , MirrorDirectory NVARCHAR(MAX) NULL
  , MirrorCleanupTime INT NULL
  , MirrorCleanupMode NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_MirrorCleanupMode DEFAULT 'AFTER_BACKUP'
  , MirrorURL NVARCHAR(MAX) NULL
  , AvailabilityGroups NVARCHAR(MAX) NULL
  , Updateability NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_Updateability DEFAULT 'ALL'
  , AdaptiveCompression NVARCHAR(MAX) NULL
  , ModificationLevel INT NULL
  , LogSizeSinceLastLogBackup INT NULL
  , TimeSinceLastLogBackup INT NULL
  , DataDomainBoostHost NVARCHAR(MAX) NULL
  , DataDomainBoostUser NVARCHAR(MAX) NULL
  , DataDomainBoostDevicePath NVARCHAR(MAX) NULL
  , DataDomainBoostLockboxPath NVARCHAR(MAX) NULL
  , DirectoryStructure NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_DirectoryStructure DEFAULT '{ServerName}${InstanceName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Partial}_{CopyOnly}'
  , AvailabilityGroupDirectoryStructure NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_AvailabilityGroupDirectoryStructure DEFAULT '{ClusterName}${AvailabilityGroupName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{Partial}_{CopyOnly}'
  , [FileName] NVARCHAR(MAX) CONSTRAINT DF_DatabaseBackup_FileName NOT NULL DEFAULT '{ServerName}${InstanceName}_{DatabaseName}_{BackupType}_{Partial}_{CopyOnly}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}'
  , AvailabilityGroupFileName NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_AvailabilityGroupFileName DEFAULT '{ClusterName}${AvailabilityGroupName}_{DatabaseName}_{BackupType}_{Partial}_{CopyOnly}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}'
  , FileExtensionFull NVARCHAR(MAX) NULL
  , FileExtensionDiff NVARCHAR(MAX) NULL
  , FileExtensionLog NVARCHAR(MAX) NULL
  , [Init] NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_Init DEFAULT 'N'
  , [Format] NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_Format DEFAULT 'N'
  , ObjectLevelRecoveryMap NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_ObjectLevelRecoveryMap DEFAULT 'N'
  , ExcludeLogShippedFromLogBackup NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_ExcludeLogShippedFromLogBackup DEFAULT 'Y'
  , StringDelimiter NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_StringDelimiter DEFAULT ','
  , DatabaseOrder NVARCHAR(MAX) NULL
  , DatabasesInParallel NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_DatabasesInParallel DEFAULT 'N'
  , LogToTable NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_LogToTable DEFAULT 'N'
  , [Execute] NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DatabaseBackup_Execute DEFAULT 'Y'
  , CONSTRAINT PK_DatabaseBackupConfig
        PRIMARY KEY CLUSTERED (ID ASC)
        WITH (FILLFACTOR = 100, PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF
            , ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
             ) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO

INSERT INTO dbo.DatabaseBackupConfig (Databases, BackupType)
VALUES ('SYSTEM_DATABASES', 'FULL'),
('USER_DATABASES', 'DIFF'),
('USER_DATABASES', 'FULL'),
('USER_DATABASES', 'LOG')