USE msdb;
IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = 'DatabaseBackup - SYSTEM_DATABASES - FULL')
BEGIN
	EXEC msdb.dbo.sp_delete_job @job_name=N'DatabaseBackup - SYSTEM_DATABASES - FULL', @delete_unused_schedule=1
END

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
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://github.com/tboggiano/olamaintconfigtables', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
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
		@command=N'USE master;
DECLARE 
	@Databases varchar(max),
	@Directory varchar(max),
	@BackupType varchar(4),
	@Verify char(1),
	@CleanupTime int,
	@CleanupMode varchar(13),
	@Compress char(1),
	@CopyOnly char(1),
	@ChangeBackupType char(1),
	@BackupSoftware varchar(10),
	@CheckSum char(1),
	@BlockSize int,
	@BufferCount int,
	@MaxTransferSize int,
	@NumberOfFiles int,
	@CompressionLevel int,
	@Description nvarchar(max),
	@Threads int,
	@Throttle int,
	@Encrypt char(1),
	@EncryptionAlgorithm varchar(15),
	@ServerCertificate varchar(128),
	@ServerAsymmetricKey varchar(128),
	@EncryptionKey varchar(128),
	@ReadWriteFileGroups char(1),
	@OverrideBackupPreference char(1),
	@NoRecovery char(1),
	@URL nvarchar(max),
	@Credential nvarchar(max),
	@MirrorDirectory nvarchar(max),
	@MirrorCleanupTime int,
	@MirrorCleanupMode varchar(13),
	@AvailabilityGroups nvarchar(max),
	@Updateability nvarchar(10),
	@LogToTable char(1),
	@Execute char(1)

SELECT
	@Databases = [Databases],
	@Directory = Directory,
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
	@AvailabilityGroups = AvailabilityGroups,
	@Updateability = Updateability,
	@LogToTable = LogToTable,
	@Execute = [Execute]
FROM dbo.DatabaseBackupConfig
WHERE Databases =''SYSTEM_DATABASES''
	AND BackupType = ''FULL''

EXECUTE dbo.DatabaseBackup 
   @Databases = @Databases ,
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
    @LogToTable = @LogToTable,
    @Execute= @Execute;', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

USE msdb;
IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = 'DatabaseBackup - USER_DATABASES - DIFF')
BEGIN
	EXEC msdb.dbo.sp_delete_job @job_name=N'DatabaseBackup - USER_DATABASES - DIFF', @delete_unused_schedule=1
END

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
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://github.com/tboggiano/olamaintconfigtables', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
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
		@command=N'USE master;
DECLARE 
	@Databases varchar(max),
	@Directory varchar(max),
	@BackupType varchar(4),
	@Verify char(1),
	@CleanupTime int,
	@CleanupMode varchar(13),
	@Compress char(1),
	@CopyOnly char(1),
	@ChangeBackupType char(1),
	@BackupSoftware varchar(10),
	@CheckSum char(1),
	@BlockSize int,
	@BufferCount int,
	@MaxTransferSize int,
	@NumberOfFiles int,
	@CompressionLevel int,
	@Description nvarchar(max),
	@Threads int,
	@Throttle int,
	@Encrypt char(1),
	@EncryptionAlgorithm varchar(15),
	@ServerCertificate varchar(128),
	@ServerAsymmetricKey varchar(128),
	@EncryptionKey varchar(128),
	@ReadWriteFileGroups char(1),
	@OverrideBackupPreference char(1),
	@NoRecovery char(1),
	@URL nvarchar(max),
	@Credential nvarchar(max),
	@MirrorDirectory nvarchar(max),
	@MirrorCleanupTime int,
	@MirrorCleanupMode varchar(13),
	@AvailabilityGroups nvarchar(max),
	@Updateability nvarchar(10),
	@LogToTable char(1),
	@Execute char(1),
	@DBInclude varchar(max),
	@SmartBackup CHAR(1),
	@LogBackupTimeThresholdMin TINYINT,
	@LogBackupSizeThresholdMB SMALLINT,
	@DiffChangePercent DECIMAL(5,2),
	@MajorVersion TINYINT 

SELECT @MajorVersion = CAST(SERVERPROPERTY(''ProductMajorVersion'') AS TINYINT)

--Retrieve values from table
SELECT
	@Databases = [Databases],
	@Directory = Directory,
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
	@AvailabilityGroups = AvailabilityGroups,
	@Updateability = Updateability,
	@LogToTable = LogToTable,
	@Execute = [Execute],
	@SmartBackup = SmartBackup,
	@LogBackupTimeThresholdMin = LogBackupTimeThresholdMin,
	@LogBackupSizeThresholdMB = LogBackupSizeThresholdMB,
	@DiffChangePercent = DiffChangePercent
FROM dbo.DatabaseBackupConfig
WHERE Databases =''USER_DATABASES''
	AND BackupType = ''DIFF''

IF (@MajorVersion >= 14) AND (@SmartBackup = ''Y'')
BEGIN
	CREATE TABLE #temp
	(	DatabaseName sysname NOT NULL,
		DiffChangePercent DECIMAL(5,2) NOT NULL
	)

	DECLARE @SQL NVARCHAR(MAX)
	DECLARE @DBFullBackups NVARCHAR(MAX)
	DECLARE @DBDiffBackups NVARCHAR(MAX)

	SELECT @SQL = REPLACE(REPLACE(
		 ''SELECT DB_NAME(dsu.database_id) AS DBName, 
			CAST(ROUND((SUM(modified_extent_page_count) * 100.0) / SUM(allocated_extent_page_count), 2) AS DECIMAL(5,2)) AS "DiffChangePct"
		FROM sys.databases d
			CROSS APPLY {{DBName}}.sys.dm_db_file_space_usage dsu 
		GROUP BY dsu.database_id''
		,''{{DBName}}'',d.name)
		,''"'','''''''')
		FROM (
		SELECT d.name 
		FROM sys.databases d
		WHERE database_id > 4
	
	INSERT INTO #temp              
	EXEC sys.sp_executesql @SQL

	SELECT @DBFullBackups = COALESCE(@DBFullBackups + '','','''') + d.Name 
	FROM #temp
	WHERE DiffChangePercent >= @DiffChangePercent 

	SELECT @DBDiffBackups = COALESCE(@DBDiffBackups + '','','''') + d.Name 
	FROM #temp
	WHERE DiffChangePercent < @DiffChangePercent 

	DROP TABLE #temp
END
ELSE
BEGIN
	SELECT @DBInclude = @Databases
END

IF @Databases = ''SYSTEM_DATABSES''
BEGIN
	SET @DBInclude += '',-USER_DATABASES'';
	SET @DBFullBackups += '',-USER_DATABASES'';
	SET @DBDiffBackups  += '',-USER_DATABASES'';
END
ELSE IF @Databases = ''USER_DATABASES''
BEGIN
	SET @DBInclude += '',-SYSTEM_DATABASES'';
	SET @DBFullBackups += '',-SYSTEM_DATABASES'';
	SET @DBDiffBackups  += '',-SYSTEM_DATABASES'';
END

--Create description of databases that actually being backed up
SET @Description = CONCAT(@BackupType, N'' backups of '', @Databases, '''', CONVERT(NVARCHAR(30),GETDATE(),9));

IF (@DBInclude IS NOT NULL AND @SmartBackup =''N'') OR (@DBDiffBackups IS NOT NULL AND @SmartBackup = ''Y'')
BEGIN
	IF @SmartBackup = ''Y''
		SET @DBInclude = @DBDiffBackups

	EXECUTE dbo.DatabaseBackup 
		@Databases = @DBInclude,
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
		@AvailabilityGroups = @AvailabilityGroups,
		@Updateability = @Updateability,
		@LogToTable = @LogToTable,
		@Execute= @Execute;
END
ELSE IF @DBFullBackups IS NOT NULL AND @SmartBackup = ''Y''
BEGIN
	SELECT
		@Databases = [Databases],
		@Directory = Directory,
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
		@AvailabilityGroups = AvailabilityGroups,
		@Updateability = Updateability,
		@LogToTable = LogToTable,
		@Execute = [Execute],
		@SmartBackup = SmartBackup,
		@LogBackupTimeThresholdMin = LogBackupTimeThresholdMin,
		@LogBackupSizeThresholdMB = LogBackupSizeThresholdMB,
		@DiffChangePercent = DiffChangePercent
	FROM dbo.DatabaseBackupConfig
	WHERE Databases =''USER_DATABASES''
		AND BackupType = ''FULL''

	SET @DBInclude = @DBFullBackups

	EXECUTE dbo.DatabaseBackup 
		@Databases = @DBInclude,
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
		@AvailabilityGroups = @AvailabilityGroups,
		@Updateability = @Updateability,
		@LogToTable = @LogToTable,
		@Execute= @Execute;
END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

USE msdb;
IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = 'DatabaseBackup - USER_DATABASES - FULL')
BEGIN
	EXEC msdb.dbo.sp_delete_job @job_name=N'DatabaseBackup - USER_DATABASES - FULL', @delete_unused_schedule=1
END

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
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://github.com/tboggiano/olamaintconfigtables', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
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
		@command=N'USE master;
DECLARE 
	@Databases varchar(max),
	@Directory varchar(max),
	@BackupType varchar(4),
	@Verify char(1),
	@CleanupTime int,
	@CleanupMode varchar(13),
	@Compress char(1),
	@CopyOnly char(1),
	@ChangeBackupType char(1),
	@BackupSoftware varchar(10),
	@CheckSum char(1),
	@BlockSize int,
	@BufferCount int,
	@MaxTransferSize int,
	@NumberOfFiles int,
	@CompressionLevel int,
	@Description nvarchar(max),
	@Threads int,
	@Throttle int,
	@Encrypt char(1),
	@EncryptionAlgorithm varchar(15),
	@ServerCertificate varchar(128),
	@ServerAsymmetricKey varchar(128),
	@EncryptionKey varchar(128),
	@ReadWriteFileGroups char(1),
	@OverrideBackupPreference char(1),
	@NoRecovery char(1),
	@URL nvarchar(max),
	@Credential nvarchar(max),
	@MirrorDirectory nvarchar(max),
	@MirrorCleanupTime int,
	@MirrorCleanupMode varchar(13),
	@AvailabilityGroups nvarchar(max),
	@Updateability nvarchar(10),
	@LogToTable char(1),
	@Execute char(1)

SELECT
	@Databases = [Databases],
	@Directory = Directory,
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
	@AvailabilityGroups = AvailabilityGroups,
	@Updateability = Updateability,
	@LogToTable = LogToTable,
	@Execute = [Execute]
FROM dbo.DatabaseBackupConfig
WHERE Databases =''USER_DATABASES''
	AND BackupType = ''FULL''

EXECUTE dbo.DatabaseBackup 
   @Databases = @Databases ,
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
    @LogToTable = @LogToTable,
    @Execute= @Execute;', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


USE msdb;
IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = 'DatabaseBackup - USER_DATABASES - LOG')
BEGIN
	EXEC msdb.dbo.sp_delete_job @job_name=N'DatabaseBackup - USER_DATABASES - LOG', @delete_unused_schedule=1
END

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
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Source: https://github.com/tboggiano/olamaintconfigtables', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
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
		@command=N'USE master;
DECLARE 
	@Databases varchar(max),
	@Directory varchar(max),
	@BackupType varchar(4),
	@Verify char(1),
	@CleanupTime int,
	@CleanupMode varchar(13),
	@Compress char(1),
	@CopyOnly char(1),
	@ChangeBackupType char(1),
	@BackupSoftware varchar(10),
	@CheckSum char(1),
	@BlockSize int,
	@BufferCount int,
	@MaxTransferSize int,
	@NumberOfFiles int,
	@CompressionLevel int,
	@Description nvarchar(max),
	@Threads int,
	@Throttle int,
	@Encrypt char(1),
	@EncryptionAlgorithm varchar(15),
	@ServerCertificate varchar(128),
	@ServerAsymmetricKey varchar(128),
	@EncryptionKey varchar(128),
	@ReadWriteFileGroups char(1),
	@OverrideBackupPreference char(1),
	@NoRecovery char(1),
	@URL nvarchar(max),
	@Credential nvarchar(max),
	@MirrorDirectory nvarchar(max),
	@MirrorCleanupTime int,
	@MirrorCleanupMode varchar(13),
	@AvailabilityGroups nvarchar(max),
	@Updateability nvarchar(10),
	@LogToTable char(1),
	@Execute char(1),
	@DBInclude varchar(max),
	@SmartBackup CHAR(1),
	@LogBackupTimeThresholdMin TINYINT,
	@LogBackupSizeThresholdMB SMALLINT,
	@DiffChangePercent DECIMAL(5,2),
	@MajorVersion TINYINT 

SELECT @MajorVersion = CAST(SERVERPROPERTY(''ProductMajorVersion'') AS TINYINT)

SELECT
	@Databases = [Databases],
	@Directory = Directory,
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
	@AvailabilityGroups = AvailabilityGroups,
	@Updateability = Updateability,
	@LogToTable = LogToTable,
	@Execute = [Execute],
	@SmartBackup = SmartBackup,
	@LogBackupTimeThresholdMin = LogBackupTimeThresholdMin,
	@LogBackupSizeThresholdMB = LogBackupSizeThresholdMB
FROM dbo.DatabaseBackupConfig
WHERE Databases =''USER_DATABASES''
	AND BackupType = ''LOG''

IF (@MajorVersion >= 14) AND (@SmartBackup = ''Y'')
BEGIN
	SELECT @DBInclude = COALESCE(@DBInclude + '','','''') + d.Name 
	FROM sys.databases d
		CROSS APPLY sys.dm_db_log_stats(d.database_id) dls
	WHERE (dls.log_backup_time  >= DATEADD(MINUTE, @LogBackupTimeThresholdMin, GETDATE())
		OR dls.log_backup_time IS NULL)
		AND d.database_id > 4

	SELECT @DBInclude = COALESCE(@DBInclude + '','','''') + d.Name 
	FROM sys.databases d
		CROSS APPLY sys.dm_db_log_stats(d.database_id) dls
	WHERE dls.log_since_last_log_backup_mb >= @LogBackupSizeThresholdMB 
		AND d.database_id > 4
END
ELSE
BEGIN
	SELECT @DBInclude = CONCAT(COALESCE(@DBInclude + '','',''''), name) 
	FROM sys.databases d
	WHERE d.database_id > 4;
END

IF @DBInclude IS NOT NULL
EXECUTE dbo.DatabaseBackup 
   @Databases = @DBInclude ,
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
    @LogToTable = @LogToTable,
    @Execute= @Execute;', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO