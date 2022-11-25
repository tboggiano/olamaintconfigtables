USE [msdb]
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseBackup - SYSTEM_DATABASES - FULL', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseBackup - SYSTEM_DATABASES - FULL', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET QUOTED_IDENTIFIER ON

DECLARE @ExcludeDatabases nvarchar(max) = '','',
	@Databases nvarchar(max) = ''SYSTEM_DATABASES'',
	@Directory nvarchar(max),
	@BackupType nvarchar(max) = ''FULL'',
	@Verify nvarchar(max),
	@CleanupTime int,
	@CleanupMode nvarchar(max),
	@Compress nvarchar(max),
	@CopyOnly nvarchar(max),
	@ChangeBackupType nvarchar(max),
	@BackupSoftware nvarchar(max),
	@CheckSum nvarchar(max),
	@BlockSize int,
	@BufferCount int,
	@MaxTransferSize int,
	@NumberOfFiles int,
	@MinBackupSizeForMultipleFiles int,
	@MaxFileSize int,
	@CompressionLevel int,
	@Description nvarchar(max),
	@Threads int,
	@Throttle int,
	@Encrypt nvarchar(max),
	@EncryptionAlgorithm nvarchar(max),
	@ServerCertificate nvarchar(max),
	@ServerAsymmetricKey nvarchar(max),
	@EncryptionKey nvarchar(max),
	@ReadWriteFileGroups nvarchar(max),
	@OverrideBackupPreference nvarchar(max),
	@NoRecovery nvarchar(max),
	@URL nvarchar(max),
	@Credential nvarchar(max),
	@MirrorDirectory nvarchar(max),
	@MirrorCleanupTime int,
	@MirrorCleanupMode nvarchar(max),
	@MirrorURL nvarchar(max),
	@AvailabilityGroups nvarchar(max),
	@Updateability nvarchar(max),
	@AdaptiveCompression nvarchar(max),
	@ModificationLevel INT,
	@LogSizeSinceLastLogBackup INT,
	@TimeSinceLastLogBackup INT,
	@DataDomainBoostHost nvarchar(max),
	@DataDomainBoostUser nvarchar(max),
	@DataDomainBoostDevicePath nvarchar(max),
	@DataDomainBoostLockboxPath nvarchar(max),
	@DirectoryStructure nvarchar(max),
	@AvailabilityGroupDirectoryStructure nvarchar(max),
	@FileName nvarchar(max),
	@AvailabilityGroupFileName nvarchar(max),
	@FileExtensionFull nvarchar(max),
	@FileExtensionDiff nvarchar(max),
	@FileExtensionLog nvarchar(max),
	@Init nvarchar(max),
	@Format nvarchar(max),
	@ObjectLevelRecoveryMap nvarchar(max),
	@ExcludeLogShippedFromLogBackup nvarchar(max),
	@StringDelimiter nvarchar(max),
	@DatabaseOrder nvarchar(max),
	@DatabasesInParallel nvarchar(max),
	@LogToTable nvarchar(max),
	@Execute nvarchar(max);

SELECT	@Directory = Directory,
	@BackupType = BackupType,
	@Verify = Verify,
	@CleanupTime = CleanupTime,
	@CleanupMode = CleanupMode,
	@Compress = [Compress],
	@CopyOnly = CopyOnly,
	@ChangeBackupType = ChangeBackupType,
	@BackupSoftware = BackupSoftware,
	@CheckSum = [CheckSum],
	@BlockSize = [BlockSize],
	@BufferCount = [BufferCount],
	@MaxTransferSize = [MaxTransferSize],
	@NumberOfFiles = NumberOfFiles,
	@MinBackupSizeForMultipleFiles = MinBackupSizeForMultipleFiles,
	@MaxFileSize = MaxFileSize,
	@CompressionLevel = CompressionLevel,
	@Description = [Description],
	@Threads = Threads,
	@Throttle = Throttle,
	@Encrypt = Encrypt,
	@EncryptionAlgorithm = EncryptionAlgorithm,
	@ServerCertificate = ServerCertificate,
	@ServerAsymmetricKey = ServerAsymmetricKey,
	@EncryptionKey = EncryptionKey,
	@ReadWriteFileGroups = ReadWriteFileGroups,
	@OverrideBackupPreference = OverrideBackupPreference,
	@NoRecovery = [NoRecovery],
	@URL = [URL],
	@Credential = [Credential],
	@MirrorDirectory = MirrorDirectory,
	@MirrorCleanupTime = MirrorCleanupTime,
	@MirrorCleanupMode = MirrorCleanupMode,
	@MirrorURL = MirrorURL,
	@AvailabilityGroups = AvailabilityGroups,
	@Updateability = Updateability,
	@AdaptiveCompression = AdaptiveCompression,
	@ModificationLevel = ModificationLevel,
	@LogSizeSinceLastLogBackup = LogSizeSinceLastLogBackup,
	@TimeSinceLastLogBackup = TimeSinceLastLogBackup,
	@DataDomainBoostHost = DataDomainBoostHost,
	@DataDomainBoostUser = DataDomainBoostUser,
	@DataDomainBoostDevicePath = DataDomainBoostDevicePath,
	@DataDomainBoostLockboxPath = DataDomainBoostLockboxPath,
	@DirectoryStructure = DirectoryStructure,
	@AvailabilityGroupDirectoryStructure = AvailabilityGroupDirectoryStructure,
	@FileName = [FileName],
	@AvailabilityGroupFileName = AvailabilityGroupFileName,
	@FileExtensionFull = FileExtensionFull,
	@FileExtensionDiff = FileExtensionDiff,
	@FileExtensionLog = FileExtensionLog,
	@Init = [Init],
	@Format = [Format],
	@ObjectLevelRecoveryMap = ObjectLevelRecoveryMap,
	@ExcludeLogShippedFromLogBackup = ExcludeLogShippedFromLogBackup,
	@StringDelimiter = StringDelimiter,
	@DatabaseOrder = DatabaseOrder,
	@DatabasesInParallel = DatabasesInParallel,
	@LogToTable = LogToTable,
	@Execute = [Execute]
FROM DBATools.dbo.DatabaseBackupConfig
WHERE [Databases] = @Databases
	AND BackupType = @BackupType

SELECT @ExcludeDatabases = STUFF((SELECT CASE
   WHEN (ag.role = N''PRIMARY'' AND ag.ag_status = N''READ_WRITE'') OR ag.role IS NULL THEN '', -'' + d.name
   ELSE ''''
   END
FROM (SELECT d.name, d.state, d.is_in_standby FROM sys.databases d
    INNER JOIN
    (
        SELECT DISTINCT database_name
        FROM msdb.dbo.backupset
        WHERE backup_finish_date >= CASE WHEN @BackupType = ''FULL'' THEN DATEADD(HOUR, -168, GETDATE())
				  WHEN @BackupType = ''DIFF'' THEN DATEADD(HOUR, -24, GETDATE())
				  END
              AND type = CASE WHEN @BackupType = ''FULL'' THEN ''D''
				  WHEN @BackupType = ''DIFF'' THEN ''I''
				  END
    ) bs
        ON d.name = bs.database_name) d
    OUTER APPLY
        (
        SELECT role = s.role_desc,
            ag_status = DATABASEPROPERTYEX(c.database_name, N''Updateability'')
            FROM sys.dm_hadr_availability_replica_states AS s
            INNER JOIN sys.availability_databases_cluster AS c
            ON s.group_id = c.group_id
            AND d.name = c.database_name
            WHERE s.is_local = 1
        ) AS ag
WHERE d.[state] = 0
    AND d.is_in_standby = 0
ORDER BY d.name
FOR XML PATH(''''), TYPE).value(''text()[1]'',''NVARCHAR(max)''), 1, LEN('',''), '''');

SELECT @Databases = @Databases + CASE WHEN LEN(ISNULL(@ExcludeDatabases, '''')) > 0 THEN  '','' + @ExcludeDatabases END

IF LEN(ISNULL(@ExcludeDatabases, '''')) > 0
EXECUTE dbo.DatabaseBackup 
	@Databases = @Databases,
	@Directory = @Directory,
	@BackupType = @BackupType,
	@Verify = @Verify,
	@CleanupTime = @CleanupTime,
	@CleanupMode = @CleanupMode,
	@Compress = @Compress,
	@CopyOnly = @CopyOnly,
	@ChangeBackupType = @ChangeBackupType,
	@BackupSoftware = @BackupSoftware,
	@CheckSum = @CheckSum,
	@BlockSize = @BlockSize,
	@BufferCount = @BufferCount,
	@MaxTransferSize = @MaxTransferSize,
	@NumberOfFiles = @NumberOfFiles,
	@MinBackupSizeForMultipleFiles = @MinBackupSizeForMultipleFiles,
	@MaxFileSize = @MaxFileSize,
	@CompressionLevel = @CompressionLevel,
	@Description = @Description,
	@Threads = @Threads,
	@Throttle = @Throttle,
	@Encrypt = @Encrypt,
	@EncryptionAlgorithm = @EncryptionAlgorithm,
	@ServerCertificate = @ServerCertificate,
	@ServerAsymmetricKey = @ServerAsymmetricKey,
	@EncryptionKey = @EncryptionKey,
	@ReadWriteFileGroups = @ReadWriteFileGroups,
	@OverrideBackupPreference = @OverrideBackupPreference,
	@NoRecovery = @NoRecovery,
	@URL = @URL,
	@Credential = @Credential,
	@MirrorDirectory = @MirrorDirectory,
	@MirrorCleanupTime = @MirrorCleanupTime,
	@MirrorCleanupMode = @MirrorCleanupMode,
	@MirrorURL = @MirrorURL,
	@AvailabilityGroups = @AvailabilityGroups,
	@Updateability = @Updateability,
	@AdaptiveCompression = @AdaptiveCompression,
	@ModificationLevel = @ModificationLevel,
	@LogSizeSinceLastLogBackup = @LogSizeSinceLastLogBackup,
	@TimeSinceLastLogBackup = @TimeSinceLastLogBackup,
	@DataDomainBoostHost = @DataDomainBoostHost,
	@DataDomainBoostUser = @DataDomainBoostUser,
	@DataDomainBoostDevicePath = @DataDomainBoostDevicePath,
	@DataDomainBoostLockboxPath = @DataDomainBoostLockboxPath,
	@DirectoryStructure = @DirectoryStructure,
	@AvailabilityGroupDirectoryStructure = @AvailabilityGroupDirectoryStructure,
	@FileName = @FileName,
	@AvailabilityGroupFileName = @AvailabilityGroupFileName,
	@FileExtensionFull = @FileExtensionFull,
	@FileExtensionDiff = @FileExtensionDiff,
	@FileExtensionLog = @FileExtensionLog,
	@Init = @Init,
	@Format = @Format,
	@ObjectLevelRecoveryMap = @ObjectLevelRecoveryMap,
	@ExcludeLogShippedFromLogBackup = @ExcludeLogShippedFromLogBackup,
	@StringDelimiter = @StringDelimiter,
	@DatabaseOrder = @DatabaseOrder,
	@DatabasesInParallel = @DatabasesInParallel,
	@LogToTable = @LogToTable,
	@Execute = @Execute;', 
		@database_name=N'master', 
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\DatabaseBackup - SYSTEM_DATABASES - FULL_$(ESCAPE_SQUOTE(DATE))_$(ESCAPE_SQUOTE(TIME)).txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseBackup - USER_DATABASES - DIFF', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DatabaseBackup - USER_DATABASES - DIFF]    Script Date: 11/24/2022 6:42:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseBackup - USER_DATABASES - DIFF', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET QUOTED_IDENTIFIER ON

DECLARE @ExcludeDatabases nvarchar(max) = '','', 
	@Databases nvarchar(max) = ''USER_DATABASES'',
	@Directory nvarchar(max),
	@BackupType nvarchar(max) = ''DIFF'',
	@Verify nvarchar(max),
	@CleanupTime int,
	@CleanupMode nvarchar(max),
	@Compress nvarchar(max),
	@CopyOnly nvarchar(max),
	@ChangeBackupType nvarchar(max),
	@BackupSoftware nvarchar(max),
	@CheckSum nvarchar(max),
	@BlockSize int,
	@BufferCount int,
	@MaxTransferSize int,
	@NumberOfFiles int,
	@MinBackupSizeForMultipleFiles int,
	@MaxFileSize int,
	@CompressionLevel int,
	@Description nvarchar(max),
	@Threads int,
	@Throttle int,
	@Encrypt nvarchar(max),
	@EncryptionAlgorithm nvarchar(max),
	@ServerCertificate nvarchar(max),
	@ServerAsymmetricKey nvarchar(max),
	@EncryptionKey nvarchar(max),
	@ReadWriteFileGroups nvarchar(max),
	@OverrideBackupPreference nvarchar(max),
	@NoRecovery nvarchar(max),
	@URL nvarchar(max),
	@Credential nvarchar(max),
	@MirrorDirectory nvarchar(max),
	@MirrorCleanupTime int,
	@MirrorCleanupMode nvarchar(max),
	@MirrorURL nvarchar(max),
	@AvailabilityGroups nvarchar(max),
	@Updateability nvarchar(max),
	@AdaptiveCompression nvarchar(max),
	@ModificationLevel INT,
	@LogSizeSinceLastLogBackup INT,
	@TimeSinceLastLogBackup INT,
	@DataDomainBoostHost nvarchar(max),
	@DataDomainBoostUser nvarchar(max),
	@DataDomainBoostDevicePath nvarchar(max),
	@DataDomainBoostLockboxPath nvarchar(max),
	@DirectoryStructure nvarchar(max),
	@AvailabilityGroupDirectoryStructure nvarchar(max),
	@FileName nvarchar(max),
	@AvailabilityGroupFileName nvarchar(max),
	@FileExtensionFull nvarchar(max),
	@FileExtensionDiff nvarchar(max),
	@FileExtensionLog nvarchar(max),
	@Init nvarchar(max),
	@Format nvarchar(max),
	@ObjectLevelRecoveryMap nvarchar(max),
	@ExcludeLogShippedFromLogBackup nvarchar(max),
	@StringDelimiter nvarchar(max),
	@DatabaseOrder nvarchar(max),
	@DatabasesInParallel nvarchar(max),
	@LogToTable nvarchar(max),
	@Execute nvarchar(max);

SELECT	@Directory = Directory,
	@BackupType = BackupType,
	@Verify = Verify,
	@CleanupTime = CleanupTime,
	@CleanupMode = CleanupMode,
	@Compress = [Compress],
	@CopyOnly = CopyOnly,
	@ChangeBackupType = ChangeBackupType,
	@BackupSoftware = BackupSoftware,
	@CheckSum = [CheckSum],
	@BlockSize = [BlockSize],
	@BufferCount = [BufferCount],
	@MaxTransferSize = [MaxTransferSize],
	@NumberOfFiles = NumberOfFiles,
	@MinBackupSizeForMultipleFiles = MinBackupSizeForMultipleFiles,
	@MaxFileSize = MaxFileSize,
	@CompressionLevel = CompressionLevel,
	@Description = [Description],
	@Threads = Threads,
	@Throttle = Throttle,
	@Encrypt = Encrypt,
	@EncryptionAlgorithm = EncryptionAlgorithm,
	@ServerCertificate = ServerCertificate,
	@ServerAsymmetricKey = ServerAsymmetricKey,
	@EncryptionKey = EncryptionKey,
	@ReadWriteFileGroups = ReadWriteFileGroups,
	@OverrideBackupPreference = OverrideBackupPreference,
	@NoRecovery = [NoRecovery],
	@URL = [URL],
	@Credential = [Credential],
	@MirrorDirectory = MirrorDirectory,
	@MirrorCleanupTime = MirrorCleanupTime,
	@MirrorCleanupMode = MirrorCleanupMode,
	@MirrorURL = MirrorURL,
	@AvailabilityGroups = AvailabilityGroups,
	@Updateability = Updateability,
	@AdaptiveCompression = AdaptiveCompression,
	@ModificationLevel = ModificationLevel,
	@LogSizeSinceLastLogBackup = LogSizeSinceLastLogBackup,
	@TimeSinceLastLogBackup = TimeSinceLastLogBackup,
	@DataDomainBoostHost = DataDomainBoostHost,
	@DataDomainBoostUser = DataDomainBoostUser,
	@DataDomainBoostDevicePath = DataDomainBoostDevicePath,
	@DataDomainBoostLockboxPath = DataDomainBoostLockboxPath,
	@DirectoryStructure = DirectoryStructure,
	@AvailabilityGroupDirectoryStructure = AvailabilityGroupDirectoryStructure,
	@FileName = [FileName],
	@AvailabilityGroupFileName = AvailabilityGroupFileName,
	@FileExtensionFull = FileExtensionFull,
	@FileExtensionDiff = FileExtensionDiff,
	@FileExtensionLog = FileExtensionLog,
	@Init = [Init],
	@Format = [Format],
	@ObjectLevelRecoveryMap = ObjectLevelRecoveryMap,
	@ExcludeLogShippedFromLogBackup = ExcludeLogShippedFromLogBackup,
	@StringDelimiter = StringDelimiter,
	@DatabaseOrder = DatabaseOrder,
	@DatabasesInParallel = DatabasesInParallel,
	@LogToTable = LogToTable,
	@Execute = [Execute]
FROM DBATools.dbo.DatabaseBackupConfig
WHERE [Databases] = @Databases
	AND BackupType = @BackupType

SELECT @ExcludeDatabases = STUFF((SELECT CASE
   WHEN (ag.role = N''PRIMARY'' AND ag.ag_status = N''READ_WRITE'') OR ag.role IS NULL THEN '', -'' + d.name
   ELSE ''''
   END
FROM (SELECT d.name, d.state, d.is_in_standby FROM sys.databases d
    INNER JOIN
    (
        SELECT DISTINCT database_name
        FROM msdb.dbo.backupset
        WHERE backup_finish_date >= CASE WHEN @BackupType = ''FULL'' THEN DATEADD(HOUR, -168, GETDATE())
				  WHEN @BackupType = ''DIFF'' THEN DATEADD(HOUR, -24, GETDATE())
				  END
              AND type = CASE WHEN @BackupType = ''FULL'' THEN ''D''
				  WHEN @BackupType = ''DIFF'' THEN ''I''
				  END
    ) bs
        ON d.name = bs.database_name) d
    OUTER APPLY
        (
        SELECT role = s.role_desc,
            ag_status = DATABASEPROPERTYEX(c.database_name, N''Updateability'')
            FROM sys.dm_hadr_availability_replica_states AS s
            INNER JOIN sys.availability_databases_cluster AS c
            ON s.group_id = c.group_id
            AND d.name = c.database_name
            WHERE s.is_local = 1
        ) AS ag
WHERE d.[state] = 0
    AND d.is_in_standby = 0
ORDER BY d.name
FOR XML PATH(''''), TYPE).value(''text()[1]'',''NVARCHAR(max)''), 1, LEN('',''), '''');

SELECT @Databases = @Databases + CASE WHEN LEN(ISNULL(@ExcludeDatabases, '''')) > 0 THEN  '','' + @ExcludeDatabases END

IF LEN(ISNULL(@ExcludeDatabases, '''')) > 0
EXECUTE dbo.DatabaseBackup 
	@Databases = @Databases,
	@Directory = @Directory,
	@BackupType = @BackupType,
	@Verify = @Verify,
	@CleanupTime = @CleanupTime,
	@CleanupMode = @CleanupMode,
	@Compress = @Compress,
	@CopyOnly = @CopyOnly,
	@ChangeBackupType = @ChangeBackupType,
	@BackupSoftware = @BackupSoftware,
	@CheckSum = @CheckSum,
	@BlockSize = @BlockSize,
	@BufferCount = @BufferCount,
	@MaxTransferSize = @MaxTransferSize,
	@NumberOfFiles = @NumberOfFiles,
	@MinBackupSizeForMultipleFiles = @MinBackupSizeForMultipleFiles,
	@MaxFileSize = @MaxFileSize,
	@CompressionLevel = @CompressionLevel,
	@Description = @Description,
	@Threads = @Threads,
	@Throttle = @Throttle,
	@Encrypt = @Encrypt,
	@EncryptionAlgorithm = @EncryptionAlgorithm,
	@ServerCertificate = @ServerCertificate,
	@ServerAsymmetricKey = @ServerAsymmetricKey,
	@EncryptionKey = @EncryptionKey,
	@ReadWriteFileGroups = @ReadWriteFileGroups,
	@OverrideBackupPreference = @OverrideBackupPreference,
	@NoRecovery = @NoRecovery,
	@URL = @URL,
	@Credential = @Credential,
	@MirrorDirectory = @MirrorDirectory,
	@MirrorCleanupTime = @MirrorCleanupTime,
	@MirrorCleanupMode = @MirrorCleanupMode,
	@MirrorURL = @MirrorURL,
	@AvailabilityGroups = @AvailabilityGroups,
	@Updateability = @Updateability,
	@AdaptiveCompression = @AdaptiveCompression,
	@ModificationLevel = @ModificationLevel,
	@LogSizeSinceLastLogBackup = @LogSizeSinceLastLogBackup,
	@TimeSinceLastLogBackup = @TimeSinceLastLogBackup,
	@DataDomainBoostHost = @DataDomainBoostHost,
	@DataDomainBoostUser = @DataDomainBoostUser,
	@DataDomainBoostDevicePath = @DataDomainBoostDevicePath,
	@DataDomainBoostLockboxPath = @DataDomainBoostLockboxPath,
	@DirectoryStructure = @DirectoryStructure,
	@AvailabilityGroupDirectoryStructure = @AvailabilityGroupDirectoryStructure,
	@FileName = @FileName,
	@AvailabilityGroupFileName = @AvailabilityGroupFileName,
	@FileExtensionFull = @FileExtensionFull,
	@FileExtensionDiff = @FileExtensionDiff,
	@FileExtensionLog = @FileExtensionLog,
	@Init = @Init,
	@Format = @Format,
	@ObjectLevelRecoveryMap = @ObjectLevelRecoveryMap,
	@ExcludeLogShippedFromLogBackup = @ExcludeLogShippedFromLogBackup,
	@StringDelimiter = @StringDelimiter,
	@DatabaseOrder = @DatabaseOrder,
	@DatabasesInParallel = @DatabasesInParallel,
	@LogToTable = @LogToTable,
	@Execute = @Execute;', 
		@database_name=N'master', 
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\DatabaseBackup - USER_DATABASES - DIFF_$(ESCAPE_SQUOTE(DATE))_$(ESCAPE_SQUOTE(TIME)).txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseBackup - USER_DATABASES - FULL', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseBackup - USER_DATABASES - FULL', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET QUOTED_IDENTIFIER ON

DECLARE @ExcludeDatabases nvarchar(max) = '','', 
	@Databases nvarchar(max) = ''USER_DATABASES'',
	@Directory nvarchar(max),
	@BackupType nvarchar(max) = ''FULL'',
	@Verify nvarchar(max),
	@CleanupTime int,
	@CleanupMode nvarchar(max),
	@Compress nvarchar(max),
	@CopyOnly nvarchar(max),
	@ChangeBackupType nvarchar(max),
	@BackupSoftware nvarchar(max),
	@CheckSum nvarchar(max),
	@BlockSize int,
	@BufferCount int,
	@MaxTransferSize int,
	@NumberOfFiles int,
	@MinBackupSizeForMultipleFiles int,
	@MaxFileSize int,
	@CompressionLevel int,
	@Description nvarchar(max),
	@Threads int,
	@Throttle int,
	@Encrypt nvarchar(max),
	@EncryptionAlgorithm nvarchar(max),
	@ServerCertificate nvarchar(max),
	@ServerAsymmetricKey nvarchar(max),
	@EncryptionKey nvarchar(max),
	@ReadWriteFileGroups nvarchar(max),
	@OverrideBackupPreference nvarchar(max),
	@NoRecovery nvarchar(max),
	@URL nvarchar(max),
	@Credential nvarchar(max),
	@MirrorDirectory nvarchar(max),
	@MirrorCleanupTime int,
	@MirrorCleanupMode nvarchar(max),
	@MirrorURL nvarchar(max),
	@AvailabilityGroups nvarchar(max),
	@Updateability nvarchar(max),
	@AdaptiveCompression nvarchar(max),
	@ModificationLevel INT,
	@LogSizeSinceLastLogBackup INT,
	@TimeSinceLastLogBackup INT,
	@DataDomainBoostHost nvarchar(max),
	@DataDomainBoostUser nvarchar(max),
	@DataDomainBoostDevicePath nvarchar(max),
	@DataDomainBoostLockboxPath nvarchar(max),
	@DirectoryStructure nvarchar(max),
	@AvailabilityGroupDirectoryStructure nvarchar(max),
	@FileName nvarchar(max),
	@AvailabilityGroupFileName nvarchar(max),
	@FileExtensionFull nvarchar(max),
	@FileExtensionDiff nvarchar(max),
	@FileExtensionLog nvarchar(max),
	@Init nvarchar(max),
	@Format nvarchar(max),
	@ObjectLevelRecoveryMap nvarchar(max),
	@ExcludeLogShippedFromLogBackup nvarchar(max),
	@StringDelimiter nvarchar(max),
	@DatabaseOrder nvarchar(max),
	@DatabasesInParallel nvarchar(max),
	@LogToTable nvarchar(max),
	@Execute nvarchar(max);

SELECT	@Directory = Directory,
	@BackupType = BackupType,
	@Verify = Verify,
	@CleanupTime = CleanupTime,
	@CleanupMode = CleanupMode,
	@Compress = [Compress],
	@CopyOnly = CopyOnly,
	@ChangeBackupType = ChangeBackupType,
	@BackupSoftware = BackupSoftware,
	@CheckSum = [CheckSum],
	@BlockSize = [BlockSize],
	@BufferCount = [BufferCount],
	@MaxTransferSize = [MaxTransferSize],
	@NumberOfFiles = NumberOfFiles,
	@MinBackupSizeForMultipleFiles = MinBackupSizeForMultipleFiles,
	@MaxFileSize = MaxFileSize,
	@CompressionLevel = CompressionLevel,
	@Description = [Description],
	@Threads = Threads,
	@Throttle = Throttle,
	@Encrypt = Encrypt,
	@EncryptionAlgorithm = EncryptionAlgorithm,
	@ServerCertificate = ServerCertificate,
	@ServerAsymmetricKey = ServerAsymmetricKey,
	@EncryptionKey = EncryptionKey,
	@ReadWriteFileGroups = ReadWriteFileGroups,
	@OverrideBackupPreference = OverrideBackupPreference,
	@NoRecovery = [NoRecovery],
	@URL = [URL],
	@Credential = [Credential],
	@MirrorDirectory = MirrorDirectory,
	@MirrorCleanupTime = MirrorCleanupTime,
	@MirrorCleanupMode = MirrorCleanupMode,
	@MirrorURL = MirrorURL,
	@AvailabilityGroups = AvailabilityGroups,
	@Updateability = Updateability,
	@AdaptiveCompression = AdaptiveCompression,
	@ModificationLevel = ModificationLevel,
	@LogSizeSinceLastLogBackup = LogSizeSinceLastLogBackup,
	@TimeSinceLastLogBackup = TimeSinceLastLogBackup,
	@DataDomainBoostHost = DataDomainBoostHost,
	@DataDomainBoostUser = DataDomainBoostUser,
	@DataDomainBoostDevicePath = DataDomainBoostDevicePath,
	@DataDomainBoostLockboxPath = DataDomainBoostLockboxPath,
	@DirectoryStructure = DirectoryStructure,
	@AvailabilityGroupDirectoryStructure = AvailabilityGroupDirectoryStructure,
	@FileName = [FileName],
	@AvailabilityGroupFileName = AvailabilityGroupFileName,
	@FileExtensionFull = FileExtensionFull,
	@FileExtensionDiff = FileExtensionDiff,
	@FileExtensionLog = FileExtensionLog,
	@Init = [Init],
	@Format = [Format],
	@ObjectLevelRecoveryMap = ObjectLevelRecoveryMap,
	@ExcludeLogShippedFromLogBackup = ExcludeLogShippedFromLogBackup,
	@StringDelimiter = StringDelimiter,
	@DatabaseOrder = DatabaseOrder,
	@DatabasesInParallel = DatabasesInParallel,
	@LogToTable = LogToTable,
	@Execute = [Execute]
FROM DBATools.dbo.DatabaseBackupConfig
WHERE [Databases] = @Databases
	AND BackupType = @BackupType

SELECT @ExcludeDatabases = STUFF((SELECT CASE
   WHEN (ag.role = N''PRIMARY'' AND ag.ag_status = N''READ_WRITE'') OR ag.role IS NULL THEN '', -'' + d.name
   ELSE ''''
   END
FROM (SELECT d.name, d.state, d.is_in_standby FROM sys.databases d
    INNER JOIN
    (
        SELECT DISTINCT database_name
        FROM msdb.dbo.backupset
        WHERE backup_finish_date >= CASE WHEN @BackupType = ''FULL'' THEN DATEADD(HOUR, -168, GETDATE())
				  WHEN @BackupType = ''DIFF'' THEN DATEADD(HOUR, -24, GETDATE())
				  END
              AND type = CASE WHEN @BackupType = ''FULL'' THEN ''D''
				  WHEN @BackupType = ''DIFF'' THEN ''I''
				  END
    ) bs
        ON d.name = bs.database_name) d
    OUTER APPLY
        (
        SELECT role = s.role_desc,
            ag_status = DATABASEPROPERTYEX(c.database_name, N''Updateability'')
            FROM sys.dm_hadr_availability_replica_states AS s
            INNER JOIN sys.availability_databases_cluster AS c
            ON s.group_id = c.group_id
            AND d.name = c.database_name
            WHERE s.is_local = 1
        ) AS ag
WHERE d.[state] = 0
    AND d.is_in_standby = 0
ORDER BY d.name
FOR XML PATH(''''), TYPE).value(''text()[1]'',''NVARCHAR(max)''), 1, LEN('',''), '''');

SELECT @Databases = @Databases + CASE WHEN LEN(ISNULL(@ExcludeDatabases, '''')) > 0 THEN  '','' + @ExcludeDatabases END

IF LEN(ISNULL(@ExcludeDatabases, '''')) > 0
EXECUTE dbo.DatabaseBackup 
	@Databases = @Databases,
	@Directory = @Directory,
	@BackupType = @BackupType,
	@Verify = @Verify,
	@CleanupTime = @CleanupTime,
	@CleanupMode = @CleanupMode,
	@Compress = @Compress,
	@CopyOnly = @CopyOnly,
	@ChangeBackupType = @ChangeBackupType,
	@BackupSoftware = @BackupSoftware,
	@CheckSum = @CheckSum,
	@BlockSize = @BlockSize,
	@BufferCount = @BufferCount,
	@MaxTransferSize = @MaxTransferSize,
	@NumberOfFiles = @NumberOfFiles,
	@MinBackupSizeForMultipleFiles = @MinBackupSizeForMultipleFiles,
	@MaxFileSize = @MaxFileSize,
	@CompressionLevel = @CompressionLevel,
	@Description = @Description,
	@Threads = @Threads,
	@Throttle = @Throttle,
	@Encrypt = @Encrypt,
	@EncryptionAlgorithm = @EncryptionAlgorithm,
	@ServerCertificate = @ServerCertificate,
	@ServerAsymmetricKey = @ServerAsymmetricKey,
	@EncryptionKey = @EncryptionKey,
	@ReadWriteFileGroups = @ReadWriteFileGroups,
	@OverrideBackupPreference = @OverrideBackupPreference,
	@NoRecovery = @NoRecovery,
	@URL = @URL,
	@Credential = @Credential,
	@MirrorDirectory = @MirrorDirectory,
	@MirrorCleanupTime = @MirrorCleanupTime,
	@MirrorCleanupMode = @MirrorCleanupMode,
	@MirrorURL = @MirrorURL,
	@AvailabilityGroups = @AvailabilityGroups,
	@Updateability = @Updateability,
	@AdaptiveCompression = @AdaptiveCompression,
	@ModificationLevel = @ModificationLevel,
	@LogSizeSinceLastLogBackup = @LogSizeSinceLastLogBackup,
	@TimeSinceLastLogBackup = @TimeSinceLastLogBackup,
	@DataDomainBoostHost = @DataDomainBoostHost,
	@DataDomainBoostUser = @DataDomainBoostUser,
	@DataDomainBoostDevicePath = @DataDomainBoostDevicePath,
	@DataDomainBoostLockboxPath = @DataDomainBoostLockboxPath,
	@DirectoryStructure = @DirectoryStructure,
	@AvailabilityGroupDirectoryStructure = @AvailabilityGroupDirectoryStructure,
	@FileName = @FileName,
	@AvailabilityGroupFileName = @AvailabilityGroupFileName,
	@FileExtensionFull = @FileExtensionFull,
	@FileExtensionDiff = @FileExtensionDiff,
	@FileExtensionLog = @FileExtensionLog,
	@Init = @Init,
	@Format = @Format,
	@ObjectLevelRecoveryMap = @ObjectLevelRecoveryMap,
	@ExcludeLogShippedFromLogBackup = @ExcludeLogShippedFromLogBackup,
	@StringDelimiter = @StringDelimiter,
	@DatabaseOrder = @DatabaseOrder,
	@DatabasesInParallel = @DatabasesInParallel,
	@LogToTable = @LogToTable,
	@Execute = @Execute;', 
		@database_name=N'master', 
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\DatabaseBackup - USER_DATABASES - FULL_$(ESCAPE_SQUOTE(DATE))_$(ESCAPE_SQUOTE(TIME)).txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseBackup - USER_DATABASES - LOG', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseBackup - USER_DATABASES - LOG', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET QUOTED_IDENTIFIER ON

DECLARE @Databases nvarchar(max) = ''USER_DATABASES'',
	@Directory nvarchar(max),
	@BackupType nvarchar(max) = ''LOG'',
	@Verify nvarchar(max),
	@CleanupTime int,
	@CleanupMode nvarchar(max),
	@Compress nvarchar(max),
	@CopyOnly nvarchar(max),
	@ChangeBackupType nvarchar(max),
	@BackupSoftware nvarchar(max),
	@CheckSum nvarchar(max),
	@BlockSize int,
	@BufferCount int,
	@MaxTransferSize int,
	@NumberOfFiles int,
	@MinBackupSizeForMultipleFiles int,
	@MaxFileSize int,
	@CompressionLevel int,
	@Description nvarchar(max),
	@Threads int,
	@Throttle int,
	@Encrypt nvarchar(max),
	@EncryptionAlgorithm nvarchar(max),
	@ServerCertificate nvarchar(max),
	@ServerAsymmetricKey nvarchar(max),
	@EncryptionKey nvarchar(max),
	@ReadWriteFileGroups nvarchar(max),
	@OverrideBackupPreference nvarchar(max),
	@NoRecovery nvarchar(max),
	@URL nvarchar(max),
	@Credential nvarchar(max),
	@MirrorDirectory nvarchar(max),
	@MirrorCleanupTime int,
	@MirrorCleanupMode nvarchar(max),
	@MirrorURL nvarchar(max),
	@AvailabilityGroups nvarchar(max),
	@Updateability nvarchar(max),
	@AdaptiveCompression nvarchar(max),
	@ModificationLevel INT,
	@LogSizeSinceLastLogBackup INT,
	@TimeSinceLastLogBackup INT,
	@DataDomainBoostHost nvarchar(max),
	@DataDomainBoostUser nvarchar(max),
	@DataDomainBoostDevicePath nvarchar(max),
	@DataDomainBoostLockboxPath nvarchar(max),
	@DirectoryStructure nvarchar(max),
	@AvailabilityGroupDirectoryStructure nvarchar(max),
	@FileName nvarchar(max),
	@AvailabilityGroupFileName nvarchar(max),
	@FileExtensionFull nvarchar(max),
	@FileExtensionDiff nvarchar(max),
	@FileExtensionLog nvarchar(max),
	@Init nvarchar(max),
	@Format nvarchar(max),
	@ObjectLevelRecoveryMap nvarchar(max),
	@ExcludeLogShippedFromLogBackup nvarchar(max),
	@StringDelimiter nvarchar(max),
	@DatabaseOrder nvarchar(max),
	@DatabasesInParallel nvarchar(max),
	@LogToTable nvarchar(max),
	@Execute nvarchar(max);

SELECT	@Directory = Directory,
	@BackupType = BackupType,
	@Verify = Verify,
	@CleanupTime = CleanupTime,
	@CleanupMode = CleanupMode,
	@Compress = [Compress],
	@CopyOnly = CopyOnly,
	@ChangeBackupType = ChangeBackupType,
	@BackupSoftware = BackupSoftware,
	@CheckSum = [CheckSum],
	@BlockSize = [BlockSize],
	@BufferCount = [BufferCount],
	@MaxTransferSize = [MaxTransferSize],
	@NumberOfFiles = NumberOfFiles,
	@MinBackupSizeForMultipleFiles = MinBackupSizeForMultipleFiles,
	@MaxFileSize = MaxFileSize,
	@CompressionLevel = CompressionLevel,
	@Description = [Description],
	@Threads = Threads,
	@Throttle = Throttle,
	@Encrypt = Encrypt,
	@EncryptionAlgorithm = EncryptionAlgorithm,
	@ServerCertificate = ServerCertificate,
	@ServerAsymmetricKey = ServerAsymmetricKey,
	@EncryptionKey = EncryptionKey,
	@ReadWriteFileGroups = ReadWriteFileGroups,
	@OverrideBackupPreference = OverrideBackupPreference,
	@NoRecovery = [NoRecovery],
	@URL = [URL],
	@Credential = [Credential],
	@MirrorDirectory = MirrorDirectory,
	@MirrorCleanupTime = MirrorCleanupTime,
	@MirrorCleanupMode = MirrorCleanupMode,
	@MirrorURL = MirrorURL,
	@AvailabilityGroups = AvailabilityGroups,
	@Updateability = Updateability,
	@AdaptiveCompression = AdaptiveCompression,
	@ModificationLevel = ModificationLevel,
	@LogSizeSinceLastLogBackup = LogSizeSinceLastLogBackup,
	@TimeSinceLastLogBackup = TimeSinceLastLogBackup,
	@DataDomainBoostHost = DataDomainBoostHost,
	@DataDomainBoostUser = DataDomainBoostUser,
	@DataDomainBoostDevicePath = DataDomainBoostDevicePath,
	@DataDomainBoostLockboxPath = DataDomainBoostLockboxPath,
	@DirectoryStructure = DirectoryStructure,
	@AvailabilityGroupDirectoryStructure = AvailabilityGroupDirectoryStructure,
	@FileName = [FileName],
	@AvailabilityGroupFileName = AvailabilityGroupFileName,
	@FileExtensionFull = FileExtensionFull,
	@FileExtensionDiff = FileExtensionDiff,
	@FileExtensionLog = FileExtensionLog,
	@Init = [Init],
	@Format = [Format],
	@ObjectLevelRecoveryMap = ObjectLevelRecoveryMap,
	@ExcludeLogShippedFromLogBackup = ExcludeLogShippedFromLogBackup,
	@StringDelimiter = StringDelimiter,
	@DatabaseOrder = DatabaseOrder,
	@DatabasesInParallel = DatabasesInParallel,
	@LogToTable = LogToTable,
	@Execute = [Execute]
FROM DBATools.dbo.DatabaseBackupConfig
WHERE [Databases] = @Databases
	AND BackupType = @BackupType

EXECUTE dbo.DatabaseBackup 
	@Databases = @Databases,
	@Directory = @Directory,
	@BackupType = @BackupType,
	@Verify = @Verify,
	@CleanupTime = @CleanupTime,
	@CleanupMode = @CleanupMode,
	@Compress = @Compress,
	@CopyOnly = @CopyOnly,
	@ChangeBackupType = @ChangeBackupType,
	@BackupSoftware = @BackupSoftware,
	@CheckSum = @CheckSum,
	@BlockSize = @BlockSize,
	@BufferCount = @BufferCount,
	@MaxTransferSize = @MaxTransferSize,
	@NumberOfFiles = @NumberOfFiles,
	@MinBackupSizeForMultipleFiles = @MinBackupSizeForMultipleFiles,
	@MaxFileSize = @MaxFileSize,
	@CompressionLevel = @CompressionLevel,
	@Description = @Description,
	@Threads = @Threads,
	@Throttle = @Throttle,
	@Encrypt = @Encrypt,
	@EncryptionAlgorithm = @EncryptionAlgorithm,
	@ServerCertificate = @ServerCertificate,
	@ServerAsymmetricKey = @ServerAsymmetricKey,
	@EncryptionKey = @EncryptionKey,
	@ReadWriteFileGroups = @ReadWriteFileGroups,
	@OverrideBackupPreference = @OverrideBackupPreference,
	@NoRecovery = @NoRecovery,
	@URL = @URL,
	@Credential = @Credential,
	@MirrorDirectory = @MirrorDirectory,
	@MirrorCleanupTime = @MirrorCleanupTime,
	@MirrorCleanupMode = @MirrorCleanupMode,
	@MirrorURL = @MirrorURL,
	@AvailabilityGroups = @AvailabilityGroups,
	@Updateability = @Updateability,
	@AdaptiveCompression = @AdaptiveCompression,
	@ModificationLevel = @ModificationLevel,
	@LogSizeSinceLastLogBackup = @LogSizeSinceLastLogBackup,
	@TimeSinceLastLogBackup = @TimeSinceLastLogBackup,
	@DataDomainBoostHost = @DataDomainBoostHost,
	@DataDomainBoostUser = @DataDomainBoostUser,
	@DataDomainBoostDevicePath = @DataDomainBoostDevicePath,
	@DataDomainBoostLockboxPath = @DataDomainBoostLockboxPath,
	@DirectoryStructure = @DirectoryStructure,
	@AvailabilityGroupDirectoryStructure = @AvailabilityGroupDirectoryStructure,
	@FileName = @FileName,
	@AvailabilityGroupFileName = @AvailabilityGroupFileName,
	@FileExtensionFull = @FileExtensionFull,
	@FileExtensionDiff = @FileExtensionDiff,
	@FileExtensionLog = @FileExtensionLog,
	@Init = @Init,
	@Format = @Format,
	@ObjectLevelRecoveryMap = @ObjectLevelRecoveryMap,
	@ExcludeLogShippedFromLogBackup = @ExcludeLogShippedFromLogBackup,
	@StringDelimiter = @StringDelimiter,
	@DatabaseOrder = @DatabaseOrder,
	@DatabasesInParallel = @DatabasesInParallel,
	@LogToTable = @LogToTable,
	@Execute = @Execute;', 
		@database_name=N'master', 
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\DatabaseBackup - USER_DATABASES - LOG_$(ESCAPE_SQUOTE(DATE))_$(ESCAPE_SQUOTE(TIME)).txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseIntegrityCheck - ALL_DATABASES', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DatabaseIntegrityCheck - ALL_DATABASES]    Script Date: 11/24/2022 6:42:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseIntegrityCheck - ALL_DATABASES', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @Databases nvarchar(max) = ''ALL_DATABASES'',
	@CheckCommands nvarchar(max),
	@PhysicalOnly nvarchar(max),
	@NoIndex nvarchar(max),
	@ExtendedLogicalChecks nvarchar(max),
	@TabLock nvarchar(max),
	@FileGroups nvarchar(max),
	@Objects nvarchar(max),
	@MaxDOP int,
	@AvailabilityGroups nvarchar(max),
	@AvailabilityGroupReplicas nvarchar(max),
	@Updateability nvarchar(max),
	@LockTimeout int,
	@LogToTable nvarchar(max),
	@Execute nvarchar(max);

SELECT 	@CheckCommands = CheckCommands,
	@PhysicalOnly = PhysicalOnly,
	@NoIndex = NoIndex,
	@ExtendedLogicalChecks = ExtendedLogicalChecks,
	@TabLock = [TabLock],
	@FileGroups = [FileGroups],
	@Objects = [Objects],
	@MaxDOP = [MaxDOP],
	@AvailabilityGroups = AvailabilityGroups,
	@AvailabilityGroupReplicas = AvailabilityGroupReplicas,
	@Updateability = Updateability,
	@LockTimeout = LockTimeout,
	@LogToTable = LogToTable,
	@Execute = [Execute]  
FROM DBATools.dbo.DatabaseIntegrityCheckConfig
WHERE [Databases] = @Databases

EXECUTE dbo.DatabaseIntegrityCheck 
	@Databases = @Databases,
	@CheckCommands = @CheckCommands,
	@PhysicalOnly = @PhysicalOnly,
	@NoIndex = @NoIndex,
	@ExtendedLogicalChecks = @ExtendedLogicalChecks,
	@TabLock = @TabLock,
	@FileGroups = @FileGroups,
	@Objects = @Objects,
	@MaxDOP = @MaxDOP,
	@AvailabilityGroups = @AvailabilityGroups,
	@AvailabilityGroupReplicas = @AvailabilityGroupReplicas,
	@Updateability = @Updateability,
	@LockTimeout = @LockTimeout,
	@LogToTable = @LogToTable,
	@Execute = @Execute;', 
		@database_name=N'master', 
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\DatabaseIntegrityCheck - ALL_DATABASES_$(ESCAPE_SQUOTE(DATE))_$(ESCAPE_SQUOTE(TIME)).txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DatabaseIntegrityCheck - ALL_DATABASES', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190102, 
		@active_end_date=99991231, 
		@active_start_time=110000, 
		@active_end_time=235959, 
		@schedule_uid=N'8ff3ff1d-327a-45d2-b36b-5332e3017359'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [IndexOptimize - ALL_DATABASES]    Script Date: 11/24/2022 6:42:10 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 11/24/2022 6:42:10 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'IndexOptimize - ALL_DATABASES', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [IndexOptimize - ALL_DATABASES]    Script Date: 11/24/2022 6:42:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'IndexOptimize - ALL_DATABASES', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @Databases nvarchar(max) = ''ALL_DATABASES'',
	@FragmentationLow nvarchar(max),
	@FragmentationMedium nvarchar(max),
	@FragmentationHigh nvarchar(max),
	@FragmentationLevel1 int,
	@FragmentationLevel2 int,
	@SortInTempdb nvarchar(max),
	@MaxDOP int,
	@FillFactor int,
	@PadIndex nvarchar(max),
	@LOBCompaction nvarchar(max),
	@UpdateStatistics nvarchar(max),
	@OnlyModifiedStatistics nvarchar(max),
	@StatisticsSample int,
	@StatisticsResample nvarchar(max),
	@PartitionLevel nvarchar(max),
	@MSShippedObjects nvarchar(max),
	@Indexes nvarchar(max),
	@TimeLimit int,
	@Delay int,
	@WaitAtLowPriorityMaxDuration int,
	@WaitAtLowPriorityAbortAfterWait nvarchar(max),
	@AvailabilityGroups nvarchar(max),
	@LockTimeout int,
	@LogToTable nvarchar(max),
	@Execute nvarchar(max);

SELECT 	@FragmentationLow = FragmentationLow,
	@FragmentationMedium = FragmentationMedium,
	@FragmentationHigh = FragmentationHigh,
	@FragmentationLevel1 = FragmentationLevel1,
	@FragmentationLevel2 = FragmentationLevel2,
	@SortInTempdb = SortInTempdb,
	@MaxDOP = [MaxDOP],
	@FillFactor = [FillFactor],
	@PadIndex = PadIndex,
	@LOBCompaction = LOBCompaction,
	@OnlyModifiedStatistics = OnlyModifiedStatistics,
	@StatisticsSample = StatisticsSample,
	@StatisticsResample = StatisticsResample,
	@PartitionLevel = PartitionLevel,
	@MSShippedObjects = MSShippedObjects,
	@Indexes = [Indexes],
	@TimeLimit = TimeLimit,
	@Delay = [Delay],
	@WaitAtLowPriorityMaxDuration = WaitAtLowPriorityMaxDuration,
	@WaitAtLowPriorityAbortAfterWait = WaitAtLowPriorityAbortAfterWait,
	@AvailabilityGroups = AvailabilityGroups,
	@LockTimeout = LockTimeout,
	@LogToTable = LogToTable,
	@Execute = [Execute]
FROM DBATools.dbo.IndexOptimizeConfig
WHERE [Databases] = @Databases
	AND UpdateStatistics IS NULL

EXECUTE dbo.IndexOptimize 
    @Databases = @Databases,
    @FragmentationLow = @FragmentationLow,
    @FragmentationMedium = @FragmentationMedium,
    @FragmentationHigh = @FragmentationHigh,
    @FragmentationLevel1 = @FragmentationLevel1,
    @FragmentationLevel2 = @FragmentationLevel2,
    @SortInTempdb = @SortInTempdb,
    @MaxDOP = @MaxDOP,
    @FillFactor = @FillFactor,
    @PadIndex = @PadIndex,
    @LOBCompaction = @LOBCompaction,
    @UpdateStatistics = @UpdateStatistics,
    @OnlyModifiedStatistics = @OnlyModifiedStatistics,
    @StatisticsSample = @StatisticsSample,
    @StatisticsResample = @StatisticsResample,
    @PartitionLevel = @PartitionLevel,
    @MSShippedObjects = @MSShippedObjects,
    @Indexes = @Indexes,
    @TimeLimit = @TimeLimit,
    @Delay = @Delay,
    @WaitAtLowPriorityMaxDuration = @WaitAtLowPriorityMaxDuration,
    @WaitAtLowPriorityAbortAfterWait = @WaitAtLowPriorityAbortAfterWait,
    @AvailabilityGroups = @AvailabilityGroups,
    @LockTimeout = @LockTimeout,
    @LogToTable = @LogToTable,
    @Execute = @Execute;', 
		@database_name=N'master', 
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\IndexOptimize - ALL_DATABASES_$(ESCAPE_SQUOTE(DATE))_$(ESCAPE_SQUOTE(TIME)).txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'.DBA-IndexOptimize - USER_DATABASES', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=64, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190723, 
		@active_end_date=99991231, 
		@active_start_time=101500, 
		@active_end_time=235959, 
		@schedule_uid=N'91890b6f-d1bb-43aa-9d89-c397ad0926f4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'.DBA-IndexOptimize - USER_DATABASES', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=64, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190723, 
		@active_end_date=99991231, 
		@active_start_time=101500, 
		@active_end_time=235959, 
		@schedule_uid=N'd3c87a86-08f3-48e1-8e43-14935224e21e'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [IndexOptimize - UpdateStatistics - ALL_DATABASES]    Script Date: 11/24/2022 6:42:10 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 11/24/2022 6:42:10 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'IndexOptimize - UpdateStatistics - ALL_DATABASES', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://ola.hallengren.com', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [IndexOptimize - UpdateStatistics - ALL_DATABASES]    Script Date: 11/24/2022 6:42:10 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'IndexOptimize - UpdateStatistics - ALL_DATABASES', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @Databases nvarchar(max) = ''ALL_DATABASES'',
	@FragmentationLow nvarchar(max),
	@FragmentationMedium nvarchar(max),
	@FragmentationHigh nvarchar(max),
	@FragmentationLevel1 int,
	@FragmentationLevel2 int,
	@SortInTempdb nvarchar(max),
	@MaxDOP int,
	@FillFactor int,
	@PadIndex nvarchar(max),
	@LOBCompaction nvarchar(max),
	@UpdateStatistics nvarchar(max) = ''ALL'',
	@OnlyModifiedStatistics nvarchar(max),
	@StatisticsSample int,
	@StatisticsResample nvarchar(max),
	@PartitionLevel nvarchar(max),
	@MSShippedObjects nvarchar(max),
	@Indexes nvarchar(max),
	@TimeLimit int,
	@Delay int,
	@WaitAtLowPriorityMaxDuration int,
	@WaitAtLowPriorityAbortAfterWait nvarchar(max),
	@AvailabilityGroups nvarchar(max),
	@LockTimeout int,
	@LogToTable nvarchar(max),
	@Execute nvarchar(max);

SELECT 	@FragmentationLow = FragmentationLow,
	@FragmentationMedium = FragmentationMedium,
	@FragmentationHigh = FragmentationHigh,
	@FragmentationLevel1 = FragmentationLevel1,
	@FragmentationLevel2 = FragmentationLevel2,
	@SortInTempdb = SortInTempdb,
	@MaxDOP = [MaxDOP],
	@FillFactor = [FillFactor],
	@PadIndex = PadIndex,
	@LOBCompaction = LOBCompaction,
	@OnlyModifiedStatistics = OnlyModifiedStatistics,
	@StatisticsSample = StatisticsSample,
	@StatisticsResample = StatisticsResample,
	@PartitionLevel = PartitionLevel,
	@MSShippedObjects = MSShippedObjects,
	@Indexes = [Indexes],
	@TimeLimit = TimeLimit,
	@Delay = [Delay],
	@WaitAtLowPriorityMaxDuration = WaitAtLowPriorityMaxDuration,
	@WaitAtLowPriorityAbortAfterWait = WaitAtLowPriorityAbortAfterWait,
	@AvailabilityGroups = AvailabilityGroups,
	@LockTimeout = LockTimeout,
	@LogToTable = LogToTable,
	@Execute = [Execute]
FROM DBATools.dbo.IndexOptimizeConfig
WHERE [Databases] = @Databases
	AND UpdateStatistics = @UpdateStatistics

EXECUTE dbo.IndexOptimize 
    @Databases = @Databases,
    @FragmentationLow = @FragmentationLow,
    @FragmentationMedium = @FragmentationMedium,
    @FragmentationHigh = @FragmentationHigh,
    @FragmentationLevel1 = @FragmentationLevel1,
    @FragmentationLevel2 = @FragmentationLevel2,
    @SortInTempdb = @SortInTempdb,
    @MaxDOP = @MaxDOP,
    @FillFactor = @FillFactor,
    @PadIndex = @PadIndex,
    @LOBCompaction = @LOBCompaction,
    @UpdateStatistics = @UpdateStatistics,
    @OnlyModifiedStatistics = @OnlyModifiedStatistics,
    @StatisticsSample = @StatisticsSample,
    @StatisticsResample = @StatisticsResample,
    @PartitionLevel = @PartitionLevel,
    @MSShippedObjects = @MSShippedObjects,
    @Indexes = @Indexes,
    @TimeLimit = @TimeLimit,
    @Delay = @Delay,
    @WaitAtLowPriorityMaxDuration = @WaitAtLowPriorityMaxDuration,
    @WaitAtLowPriorityAbortAfterWait = @WaitAtLowPriorityAbortAfterWait,
    @AvailabilityGroups = @AvailabilityGroups,
    @LockTimeout = @LockTimeout,
    @LogToTable = @LogToTable,
    @Execute = @Execute;', 
		@database_name=N'master', 
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\IndexOptimize - UpdateStatistics - ALL_DATABASES_$(ESCAPE_SQUOTE(DATE))_$(ESCAPE_SQUOTE(TIME)).txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'2 AM', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20221006, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'aa9f3316-1d54-4cc5-8ee9-f9c95c765bfb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

