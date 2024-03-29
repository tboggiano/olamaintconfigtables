USE [msdb]
GO
IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = 'DatabaseIntegrityCheck - USER_DATABASES')
BEGIN
	EXEC msdb.dbo.sp_delete_job @job_name=N'DatabaseIntegrityCheck - USER_DATABASES', @delete_unused_schedule=1
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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseIntegrityCheck - USER_DATABASES', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseIntegrityCheck - USER_DATABASES', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @Databases nvarchar(max) = ''USER_DATABASES'',
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

USE [msdb]
GO
IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = 'DatabaseIntegrityCheck - SYSTEM_DATABASES')
BEGIN
	EXEC msdb.dbo.sp_delete_job @job_name=N'DatabaseIntegrityCheck - SYSTEM_DATABASES', @delete_unused_schedule=1
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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DatabaseIntegrityCheck - SYSTEM_DATABASES', 
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DatabaseIntegrityCheck - SYSTEM_DATABASES', 
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
	@Databases nvarchar(max),
	@CheckCommands varchar(34),
	@PhysicalOnly char(1),
	@NoIndex char(1),
	@ExtendedLogicalChecks char(1),
	@TabLock char(1),
	@FileGroups nvarchar(max),
	@Objects nvarchar(max),
	@MaxDOP int,
	@AvailabilityGroups nvarchar(max),
	@AvailabilityGroupReplicas nvarchar(max),
	@Updateability nvarchar(max),
	@LockTimeout int,
	@LogToTable char(1),
	@Execute char(1);

SELECT 
	@Databases = [Databases],
	@CheckCommands = CheckCommands,
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
FROM dbo.DatabaseIntegrityCheckConfig
WHERE [Databases] =''SYSTEM_DATABASES''

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
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\DatabaseIntegrityCheck_$(ESCAPE_SQUOTE(JOBID))_$(ESCAPE_SQUOTE(STEPID))_$(ESCAPE_SQUOTE(STRTDT))_$(ESCAPE_SQUOTE(STRTTM)).txt', 
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





