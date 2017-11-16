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
		@description=N'Source: https://ola.hallengren.com', 
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
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\DatabaseBackup_$(ESCAPE_SQUOTE(JOBID))_$(ESCAPE_SQUOTE(STEPID))_$(ESCAPE_SQUOTE(STRTDT))_$(ESCAPE_SQUOTE(STRTTM)).txt', 
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
		@description=N'Source: https://ola.hallengren.com', 
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
	AND BackupType = ''DIFF''

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
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\DatabaseBackup_$(ESCAPE_SQUOTE(JOBID))_$(ESCAPE_SQUOTE(STEPID))_$(ESCAPE_SQUOTE(STRTDT))_$(ESCAPE_SQUOTE(STRTTM)).txt', 
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
		@description=N'Source: https://ola.hallengren.com', 
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
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\DatabaseBackup_$(ESCAPE_SQUOTE(JOBID))_$(ESCAPE_SQUOTE(STEPID))_$(ESCAPE_SQUOTE(STRTDT))_$(ESCAPE_SQUOTE(STRTTM)).txt', 
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
		@description=N'Source: https://ola.hallengren.com', 
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
	AND BackupType = ''LOG''

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
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\DatabaseBackup_$(ESCAPE_SQUOTE(JOBID))_$(ESCAPE_SQUOTE(STEPID))_$(ESCAPE_SQUOTE(STRTDT))_$(ESCAPE_SQUOTE(STRTTM)).txt', 
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






