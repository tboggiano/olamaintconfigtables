USE [msdb]
GO
IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = 'IndexOptimize - USER_DATABASES')
BEGIN
	EXEC msdb.dbo.sp_delete_job @job_name=N'IndexOptimize - USER_DATABASES', @delete_unused_schedule=1
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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'IndexOptimize - USER_DATABASES', 
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

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'IndexOptimize - USER_DATABASES', 
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
	@FragmentationLow varchar(59),
	@FragmentationMedium varchar(59),
	@FragmentationHigh varchar(59),
	@FragmentationLevel1 int,
	@FragmentationLevel2 int,
	@PageCountLevel int,
	@SortInTempdb char(1),
	@MaxDOP int,
	@FillFactor int,
	@PadIndex varchar(max),
	@LOBCompaction char(1),
	@UpdateStatistics varchar(7),
	@OnlyModifiedStatistics char(1),
	@StatisticsSample int,
	@StatisticsResample char(1),
	@PartitionLevel char(1),
	@MSShippedObjects char(1),
	@Indexes varchar(max),
	@TimeLimit int,
	@Delay int,
	@WaitAtLowPriorityMaxDuration int,
	@WaitAtLowPriorityAbortAfterWait varchar(8),
	@AvailabilityGroups varchar(max),
	@LockTimeout int,
	@LogToTable char(1),
	@Execute char(1);

SELECT 
	@Databases = [Databases],
	@FragmentationLow = FragmentationLow,
	@FragmentationMedium = FragmentationMedium,
	@FragmentationHigh = FragmentationHigh,
	@FragmentationLevel1 = FragmentationLevel1,
	@FragmentationLevel2 = FragmentationLevel2,
	@PageCountLevel = PageCountLevel,
	@SortInTempdb = SortInTempdb,
	@MaxDOP = [MaxDOP],
	@FillFactor = [FillFactor],
	@PadIndex = PadIndex,
	@LOBCompaction = LOBCompaction,
	@UpdateStatistics = UpdateStatistics,
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
FROM dbo.IndexOptimizeConfig
WHERE [Databases] =''USER_DATABASES''

EXECUTE dbo.IndexOptimize 
	@Databases = @Databases,
    @FragmentationLow = @FragmentationLow,
    @FragmentationMedium = @FragmentationMedium,
    @FragmentationHigh = @FragmentationHigh,
    @FragmentationLevel1 = @FragmentationLevel1,
    @FragmentationLevel2 = @FragmentationLevel2,
    @PageCountLevel = @PageCountLevel,
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
    @Execute = @Execute;
', 
		@database_name=N'master', 
		@output_file_name=N'$(ESCAPE_SQUOTE(SQLLOGDIR))\IndexOptimize_$(ESCAPE_SQUOTE(JOBID))_$(ESCAPE_SQUOTE(STEPID))_$(ESCAPE_SQUOTE(STRTDT))_$(ESCAPE_SQUOTE(STRTTM)).txt', 
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

