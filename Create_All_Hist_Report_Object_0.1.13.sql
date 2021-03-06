USE [ClientHealth]
Print '#############################################################################'
Print '##  create or update all Objects for  reporting and long term data.        ##'
Print '##  version 01.13, 03/13/2019                                              ##'
Print '#############################################################################'

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----
--  if the object exist drop the old objects,
-----
IF OBJECT_ID('dbo.T_TB_Clients_U', 'TR') IS NOT NULL 
DROP TRIGGER [dbo].[T_TB_Clients_U]
GO

IF OBJECT_ID('dbo.T_TB_Clients_I', 'TR') IS NOT NULL 
DROP TRIGGER [dbo].[T_TB_Clients_I]
GO

IF OBJECT_ID('dbo.up_GetErrorInfo', 'P') IS NOT NULL 
DROP PROCEDURE [dbo].[up_GetErrorInfo]
GO

IF OBJECT_ID('dbo.up_get_SCCMClientVersion', 'P') IS NOT NULL 
DROP PROCEDURE [dbo].[up_get_SCCMClientVersion]
GO

IF OBJECT_ID('dbo.up_get_OS_Summary_data', 'P') IS NOT NULL 
DROP PROCEDURE [dbo].[up_get_OS_Summary_data]
GO

IF OBJECT_ID('dbo.up_get_ClientMainDiagramData', 'P') IS NOT NULL 
DROP PROCEDURE [dbo].[up_get_ClientMainDiagramData]
GO

IF OBJECT_ID('dbo.up_get_ClientData_flat', 'P') IS NOT NULL 
DROP PROCEDURE [dbo].[up_get_ClientData_flat]
GO

IF OBJECT_ID('dbo.up_get_ClientData_ActionResult', 'P') IS NOT NULL 
DROP PROCEDURE [dbo].[up_get_ClientData_ActionResult]
GO

IF OBJECT_ID('dbo.up_get_Client_Activities', 'P') IS NOT NULL 
DROP PROCEDURE [dbo].[up_get_Client_Activities]
GO

IF OBJECT_ID('dbo.Report_Theme', 'U') IS NOT NULL 
DROP TABLE [dbo].[Report_Theme]
GO

IF OBJECT_ID('dbo.LogMsg', 'U') IS NOT NULL 
DROP TABLE [dbo].[LogMsg]
GO

IF OBJECT_ID('dbo.Clients_Hist', 'U') IS NOT NULL 
DROP TABLE [dbo].[Clients_Hist]
GO

IF OBJECT_ID('dbo.SCCM_Config', 'U') IS NOT NULL 
DROP TABLE [dbo].[SCCM_Config]
GO

IF OBJECT_ID('dbo.v_ClientData_historical', 'V') IS NOT NULL 
DROP VIEW [dbo].[v_ClientData_historical]
GO

IF OBJECT_ID('dbo.v_ClientData_ALL', 'V') IS NOT NULL 
DROP VIEW [dbo].[v_ClientData_ALL]
GO

IF OBJECT_ID('dbo.v_ClientData_Actual', 'V') IS NOT NULL 
DROP VIEW [dbo].[v_ClientData_Actual]
GO

IF OBJECT_ID('dbo.udf_Split', 'TF') IS NOT NULL 
DROP FUNCTION [dbo].[udf_Split]
GO

CREATE FUNCTION [dbo].[udf_Split](@List varchar(8000), @Splitter varchar(20) = ' ')
RETURNS @TB TABLE
(    
  position int IDENTITY PRIMARY KEY,
  value varchar(8000)   
)
AS
BEGIN
DECLARE @index int 
SET @index = -1 
WHILE (LEN(@List) > 0) 
 BEGIN  
    SET @index = CHARINDEX(@Splitter , @List)  
    IF (@index = 0) AND (LEN(@List) > 0)  
      BEGIN   
        INSERT INTO @TB VALUES (@List)
          BREAK  
      END  
    IF (@index > 1)  
      BEGIN   
        INSERT INTO @TB VALUES (LEFT(@List, @index - 1))   
        SET @List = RIGHT(@List, (LEN(@List) - @index))  
      END  
    ELSE 
      SET @List = RIGHT(@List, (LEN(@List) - @index)) 
    END
  RETURN
END

go

/* create now tbl */
CREATE TABLE [dbo].[Clients_Hist](
	[ID] [int] IDENTITY(1,1500) NOT NULL,
	[Hostname] [varchar](100) NULL,
	[OperatingSystem] [varchar](100) NULL,
	[Architecture] [varchar](10) NULL,
	[Build] [varchar](100) NULL,
	[Manufacturer] [varchar](100) NULL,
	[Model] [varchar](100) NULL,
	[InstallDate] [smalldatetime] NULL,
	[OSUpdates] [smalldatetime] NULL,
	[LastLoggedOnUser] [varchar](100) NULL,
	[ClientVersion] [varchar](100) NULL,
	[PSVersion] [float] NULL,
	[PSBuild] [int] NULL,
	[Sitecode] [varchar](3) NULL,
	[Domain] [varchar](100) NULL,
	[MaxLogSize] [int] NULL,
	[MaxLogHistory] [int] NULL,
	[CacheSize] [int] NULL,
	[ClientCertificate] [varchar](50) NULL,
	[ProvisioningMode] [varchar](50) NULL,
	[DNS] [varchar](100) NULL,
	[Drivers] [varchar](100) NULL,
	[Updates] [varchar](100) NULL,
	[PendingReboot] [varchar](50) NULL,
	[LastBootTime] [smalldatetime] NULL,
	[OSDiskFreeSpace] [float] NULL,
	[Services] [varchar](200) NULL,
	[AdminShare] [varchar](50) NULL,
	[StateMessages] [varchar](50) NULL,
	[WUAHandler] [varchar](50) NULL,
	[WMI] [varchar](50) NULL,
	[RefreshComplianceState] [smalldatetime] NULL,
	[ClientInstalled] [smalldatetime] NULL,
	[Version] [varchar](10) NULL,
	[Timestamp] [datetime] NULL,
	[HWInventory] [smalldatetime] NULL,
	[SWMetering] [varchar](50) NULL,
	[BITS] [varchar](50) NULL,
	[PatchLevel] [int] NULL,
	[ClientInstalledReason] [varchar](200) NULL,
	[LOG_Created_Date] [datetime] NULL,
	[LOG_Created_by] [varchar](50) NULL,
	[LOG_Action] [varchar](50) NULL,
 CONSTRAINT [PK__Clients123456789] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[LogMsg](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LogMsg] [nvarchar](max) NOT NULL,
	[Logdate] [datetime] NOT NULL,
 CONSTRAINT [PK_LogMsg] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

CREATE TABLE [dbo].[Report_Theme](
	[Theme] [nvarchar](50) NOT NULL,
	[BG_01] [varchar](20) NOT NULL,
	[FG_01] [varchar](20) NOT NULL,
	[BG_02] [varchar](20) NOT NULL,
	[FG_02] [varchar](20) NOT NULL,
	[BG_03] [varchar](20) NOT NULL,
	[FG_03] [varchar](20) NOT NULL,
	[BG_04] [varchar](20) NOT NULL,
	[FG_04] [varchar](20) NOT NULL,
	[BG_red] [varchar](20) NOT NULL,
	[BG_green] [varchar](20) NOT NULL,
	[BG_header] [varchar](20) NOT NULL,
	[FG_header] [varchar](20) NOT NULL,
	[BG_footer] [varchar](20) NOT NULL,
	[FG_Footer] [varchar](20) NOT NULL,
	[BG_Info] [varchar](20) NULL,
	[BG_State_OK] [varchar](20) NULL,
	[FG_State_OK] [varchar](20) NULL,
	[BG_State_Repair] [varchar](20) NULL,
	[FG_State_Repair] [varchar](20) NULL,
	[BG_State_Error] [varchar](20) NULL,
	[FG_State_Error] [varchar](20) NULL,
 CONSTRAINT [PK_TB_Report_Theme] PRIMARY KEY CLUSTERED 
(
	[Theme] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[SCCM_Config](
	[ID] [bigint] NOT NULL,
	[ConfigItem] [nvarchar](50) NOT NULL,
	[ConfigValue] [nvarchar](2000) NOT NULL,
	[Note] [nvarchar](255) NULL
) ON [PRIMARY]
GO


/* create now views */
CREATE VIEW [dbo].[v_ClientData_Actual]
AS
SELECT        'actual' AS datasource, Hostname, OperatingSystem, Architecture, Build, Manufacturer, Model, InstallDate, OSUpdates, LastLoggedOnUser, ClientVersion, PSVersion, PSBuild, Sitecode, Domain, MaxLogSize, MaxLogHistory, 
                         CacheSize, ClientCertificate, ProvisioningMode, DNS, Drivers, Updates, PendingReboot, LastBootTime, OSDiskFreeSpace, Services, AdminShare, StateMessages, WUAHandler, WMI, RefreshComplianceState, ClientInstalled, 
                         Version, Timestamp, HWInventory, SWMetering, BITS, PatchLevel, ClientInstalledReason
FROM            dbo.Clients
GO

CREATE VIEW [dbo].[v_ClientData_ALL]
AS
SELECT        'actual' AS Datasource, [Hostname], [OperatingSystem], [Architecture], [Build], [Manufacturer], [Model], [InstallDate], [OSUpdates], [LastLoggedOnUser], [ClientVersion], [PSVersion], [PSBuild], [Sitecode], [Domain], [MaxLogSize], 
                         [MaxLogHistory], [CacheSize], [ClientCertificate], [ProvisioningMode], [DNS], [Drivers], [Updates], [PendingReboot], [LastBootTime], [OSDiskFreeSpace], [Services], [AdminShare], [StateMessages], [WUAHandler], [WMI], 
                         [RefreshComplianceState], [ClientInstalled], [Version], [Timestamp], [HWInventory], [SWMetering], [BITS], [PatchLevel], [ClientInstalledReason]
FROM            dbo.clients
UNION
SELECT        'longterm' AS Datasource, tbH.[Hostname], tbH.[OperatingSystem], tbH.[Architecture], tbH.[Build], tbH.[Manufacturer], tbH.[Model], tbH.[InstallDate], tbH.[OSUpdates], tbH.[LastLoggedOnUser], tbH.[ClientVersion], tbH.[PSVersion], 
                         tbH.[PSBuild], tbH.[Sitecode], tbH.[Domain], tbH.[MaxLogSize], tbH.[MaxLogHistory], tbH.[CacheSize], tbH.[ClientCertificate], tbH.[ProvisioningMode], tbH.[DNS], tbH.[Drivers], tbH.[Updates], tbH.[PendingReboot], 
                         tbH.[LastBootTime], tbH.[OSDiskFreeSpace], tbH.[Services], tbH.[AdminShare], tbH.[StateMessages], tbH.[WUAHandler], tbH.[WMI], tbH.[RefreshComplianceState], tbH.[ClientInstalled], tbH.[Version], tbH.[Timestamp], 
                         tbH.[HWInventory], tbH.[SWMetering], tbH.[BITS], tbH.[PatchLevel], tbH.[ClientInstalledReason]
FROM            dbo.clients_hist AS tbH

GO

CREATE VIEW [dbo].[v_ClientData_historical]
AS
	SELECT  ID, Hostname, OperatingSystem, Architecture, Build, Manufacturer, Model, InstallDate, 
			OSUpdates, LastLoggedOnUser, ClientVersion, PSVersion, PSBuild, Sitecode, Domain, MaxLogSize, 
			MaxLogHistory, CacheSize, ClientCertificate, ProvisioningMode, DNS, Drivers, Updates, PendingReboot, 
			LastBootTime, OSDiskFreeSpace, Services, AdminShare, StateMessages, WUAHandler, WMI, 
			RefreshComplianceState, ClientInstalled, Version, Timestamp, HWInventory, SWMetering, BITS, 
			PatchLevel, ClientInstalledReason, LOG_Created_Date, LOG_Created_by, LOG_Action
	FROM    dbo.Clients_Hist
GO

/* create now sp */

/****************************************************************************/
/*** Script Name                  : - up_get_Client_Activities            ***/
/*** Script Version               : - 0.01.10                             ***/
/*** Script Desciption            : - SP for Client Activities            ***/
/*** Script Desciption            : - total / active / non-active         ***/
/*** Script Audience              : -                                     ***/
/*** Script Owner                 : - C-S-L K.Bilger                      ***/
/*** Scripter/Design              : - C-S-L K.Bilger                      ***/
/***                                                                      ***/
/*** Change History *********************************************************/
/*** Version (Old/New)            : - 0.01.10                             ***/
/*** Modification Date            : - 03/04/2019                          ***/
/*** By                           : - Klaus Bilger                        ***/
/*** Reason                       : -                                     ***/
/*** Comments                     : -                                     ***/
/****************************************************************************/
CREATE PROCEDURE [dbo].[up_get_Client_Activities]
	@Para_Actual_Term as int , @Para_Device as Varchar(20) 
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
    SET NOCOUNT ON;
	-- debug declare @Para_Actual_Term as int = 3 , @Para_Device as Varchar(20) = '%'
	declare @InactiveClient as int 
	declare @DateFilter as date = (select dateadd(DAY,-@Para_Actual_Term,getdate()))
	declare @TotalCount as int = (select count(distinct Hostname) from v_ClientData_Actual	where Hostname like @Para_Device )
	declare @ActiveCount as int = (select count(distinct Hostname) from v_ClientData_Actual	where Hostname like @Para_Device and Timestamp >= @DateFilter)
	select 'SCCM Agent' as state, @TotalCount as Total_Count, 
		@ActiveCount as ActiveClients_Count, @TotalCount - @ActiveCount as NonActiveClients_Count

END
GO

/****************************************************************************/
/*** Script Name                  : - up_get_ClientData_ActionResult      ***/
/*** Script Version               : - 03/04/2019                          ***/
/*** Script Desciption            : - SP for Action Result (SUM) Data     ***/
/*** Script Audience              : -                                     ***/
/*** Script Owner                 : - C-S-L K.Bilger                      ***/
/*** Scripter/Design              : - C-S-L K.Bilger                      ***/
/***                                                                      ***/
/*** Change History *********************************************************/
/*** Version (Old/New)            : - 0.01.10                             ***/
/*** Modification Date            : - 03/04/2019                          ***/
/*** By                           : - Klaus Bilger                        ***/
/*** Reason                       : -                                     ***/
/*** Comments                     : -                                     ***/
/****************************************************************************/
CREATE PROCEDURE [dbo].[up_get_ClientData_ActionResult]
	@Para_Actual_Term as int, @Para_Use_Long_Term_Data as int = 0 , @Para_Long_Term as int = 43503, 
	@Para_Device as Varchar(20) = '%'
AS
BEGIN
	SET NOCOUNT ON;

	declare @List_Of_Components as Varchar(500) = (select top 1 ConfigValue from SCCM_Config where ConfigItem = 'List_Of_Components')
	declare @ComponentName as Varchar(50), @OK as varchar(2) = 'OK',@ERROR as varchar(5) = 'error'
	declare @DateFilter as date = (select dateadd(DAY,-@Para_Actual_Term,getdate())), @sql as varchar(2000) 
	declare @ViewName as Varchar(200) = 'v_ClientData_Actual'

	if @Para_Use_Long_Term_Data = 1 -- change View and data to use long term data
	begin
		set @ViewName = 'v_ClientData_ALL'
		set @DateFilter =(select dateadd(DAY,-@Para_Long_Term,getdate())) 
	end 
	declare @SQLCMD as varchar(2000) 

	IF OBJECT_ID('tempdb..#TempResult') IS NOT NULL
    DROP TABLE #TempResult

	CREATE TABLE #TempResult(
		[Compoment_Name] [varchar](50) NOT NULL,
		Component_Count_total [int] NULL,
		[Component_Count_OK] [int] NULL,
		[Component_Count_Error] [int] NULL,
		[Component_Count_Fixed] [int] NULL
		) ON [PRIMARY]

	DECLARE LoC_cursor CURSOR FOR 
	SELECT value FROM [dbo].[udf_Split] (@List_Of_Components,',') order by value 
	OPEN LoC_cursor  
	FETCH NEXT FROM LoC_cursor   
	INTO @ComponentName
  
	WHILE @@FETCH_STATUS = 0  
		BEGIN  
			print @ComponentName
			set @SQLCMD = 'insert into #TempResult 
					(Compoment_Name,Component_Count_total,Component_Count_OK,Component_Count_Error,Component_Count_Fixed) 
					Select ''' + @ComponentName + ''' as Compoment_Name,
					count(''' + @ComponentName + ''' ) as Component_Count_total, 
					sum(case when ' + @ComponentName +' = ''' + @OK + ''' then 1 else 0 end) as Component_Count_OK,
					sum(case when ' + @ComponentName + ' = ''' + @ERROR + ''' then 1 else 0 end) as Component_Count_Error, 
					count(''' + @ComponentName + ''' ) 
						-sum(case when ' + @ComponentName +' = ''' + @OK + ''' then 1 else 0 end) 
						-sum(case when ' + @ComponentName + ' = ''' + @ERROR + ''' then 1 else 0 end)
						as Component_Count_Fixed from '
					 + @ViewName + ' where Hostname like ''' + @Para_Device + ''''
			print (@SQLCMD)
			exec(@SQLCMD)
			FETCH NEXT FROM LoC_cursor   
			INTO @ComponentName
		END   
	CLOSE LoC_cursor;  
	DEALLOCATE LoC_cursor; 

	IF OBJECT_ID('tempdb..#TempResult') IS NOT NULL
	Select * from #TempResult order by Compoment_Name 

end 
GO

/****** Object:  StoredProcedure [dbo].[up_get_ClientData_flat]    Script Date: 3/13/2019 2:54:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************/
/*** Script Name                  : - up_get_ClientData_flat              ***/
/*** Script Version               : - 0.01.10                             ***/
/*** Script Desciption            : - SP for Client data                  ***/
/*** Script Desciption            : - using dyn SQL Query                 ***/
/*** Script Audience              : -                                     ***/
/*** Script Owner                 : - C-S-L K.Bilger                      ***/
/*** Scripter/Design              : - C-S-L K.Bilger                      ***/
/***                                                                      ***/
/*** Change History *********************************************************/
/*** Version (Old/New)            : - 0.01.13                             ***/
/*** Modification Date            : - 03/13/2019                          ***/
/*** By                           : - Klaus Bilger                        ***/
/*** Reason                       : - Bugfix for ListOfComponents Filter  ***/
/*** Comments                     : -                                     ***/
/****************************************************************************/
create PROCEDURE [dbo].[up_get_ClientData_flat]
       @Para_Actual_Term as int = 7, @Para_Use_Long_Term_Data as int = 0, 
       @Para_Long_Term as int = 4300, @Para_Device as Varchar(20) = '%', @Para_OS as varchar(200) = '%', 
       @Para_ClientVersion as varchar(2000),@Para_Actual_Term_without_active_time as bit = 0,
       @Para_ListOfComponentsType as varchar(20)='ok,error,fixed', 
       @Para_ListOfComponents as varchar(2000) =  'ClientCertificate,ProvisioningMode,DNS,Drivers,PendingReboot,Services,AdminShare,StateMessages,WUAHandler,WMI,BITS',
       @Para_ActualRange as varchar(200)='1', @Para_OnlyNonOK_Data as bit = 0
AS
BEGIN
       SET NOCOUNT ON;
	   -- debug info 
       -- declare     @Para_ListOfComponentsType as varchar(200) = 'ok,error,fixed'
       -- declare     @Para_ListOfComponents as varchar(2000)    
	   --			='ClientCertificate,ProvisioningMode,DNS,Drivers,PendingReboot,Services,AdminShare,StateMessages,WUAHandler,WMI,BITS'

       declare @logmsg as varchar(2000) ='',@Filter as varchar(200) ='', @SQLCMD as nvarchar(max) =''
       declare @view as varchar(50) = 'v_ClientData_Actual'
                               
       declare @DateFilter as date = (select dateadd(DAY,-@Para_Actual_Term,getdate()))
       declare @SCCM_Current_ClientVersion as varchar(20) = (select top 1 configvalue from [dbo].[SCCM_Config] where ConfigItem = 'SCCM_Current_ClientVersion')

       set @logmsg = 'Para_Actual_Term [ ' + convert(varchar(20), @Para_Actual_Term ) + '], ' 
       set @logmsg = @logmsg + ' Para_Use_Long_Term_Data [ ' + convert(varchar(20), @Para_Use_Long_Term_Data ) + '], ' 
       set @logmsg = @logmsg + ' Para_Long_Term [ ' + convert(varchar(20), @Para_Long_Term ) + '], ' 
       set @logmsg = @logmsg + ' Para_Device [ ' + @Para_Device + '], ' 
       set @logmsg = @logmsg + ' Para_OS [ ' + @Para_OS + '], ' 
       set @logmsg = @logmsg + ' Para_ClientVersion [ ' + @Para_ClientVersion + '], ' 
       set @logmsg = @logmsg + ' Para_Actual_Term_without_active_time [ ' + convert(varchar(1), @Para_Actual_Term_without_active_time ) + '], ' 
       set @logmsg = @logmsg + ' Para_ListOfComponentsType [ ' + @Para_ListOfComponentsType + '], ' 
       set @logmsg = @logmsg + ' Para_ListOfComponents [ ' + @Para_ListOfComponents + '], ' 
       set @logmsg = @logmsg + ' Para_ActualRange [ ' + convert(varchar(1), @Para_ActualRange ) + '], ' 
	   set @logmsg = @logmsg + ' Para_OnlyNonOK_Data[ ' + convert(varchar(1), @Para_OnlyNonOK_Data ) + '], ' 
       
       INSERT INTO [dbo].[LogMsg] ([LogMsg],[Logdate]) VALUES (@logmsg, getdate())
      
       if @Para_Actual_Term_without_active_time = 1
		begin 
			set @DateFilter =(select dateadd(DAY,-4300,getdate()))
		end
       
       if @Para_Use_Long_Term_Data = 1
		begin
			set @view = 'v_ClientData_ALL'
			set @DateFilter =(select dateadd(DAY,-@Para_Long_Term,getdate()))
		end 
       
	   set @SQLCMD = 'select * from ' + @view + ' where Hostname like '''+  @Para_Device + ''' and OperatingSystem like  '''+  @Para_OS  + ''''

       if (@Para_ActualRange = '2') -- 1=all, 2=active, 3=older
		begin
			set @Filter = ''
			set @Filter =  @Filter + ' and Timestamp > ''' + convert(varchar(20),@DateFilter) + '''  '
			set @SQLCMD = @SQLCMD + @Filter
		end 
       if (@Para_ActualRange = '3') -- 1=all, 2=active, 3=older
		begin
			set @Filter = ''
			set @Filter =  @Filter + ' and Timestamp < ''' + convert(varchar(20),@DateFilter) + '''' 
			set @SQLCMD = @SQLCMD + @Filter
		end 

	   if CHARINDEX('%',@Para_ClientVersion) > 0  -- check if the Client Version '%', Wildcard
		begin
			set @Filter = ''
			set @Filter =  @Filter + ' and ClientVersion like ''%'''
			set @SQLCMD = @SQLCMD + @Filter
		end 
       else
		begin
			set @Filter = ''
			set @Filter =  @Filter + ' and ClientVersion in (''' + REPLACE(@Para_ClientVersion,',',''',''')  + ''')'
			set @SQLCMD = @SQLCMD + @Filter
		end 

	if (@Para_OnlyNonOK_Data = 1) 
		begin
			set @Para_ListOfComponentsType ='error,fixed' 
		end 

if (@Para_ListOfComponentsType = 'ok,error,fixed')  
	and (@Para_ListOfComponents = 'ClientCertificate,ProvisioningMode,DNS,Drivers,PendingReboot,Services,AdminShare,StateMessages,WUAHandler,WMI,BITS')
	begin
		print 'show all Components info, no filter'
	end
else
	begin
	if (@Para_ListOfComponents like '%AdminShare%') 
             or (@Para_ListOfComponents like '%BITS%') or (@Para_ListOfComponents like '%ClientCertificate%')
             or (@Para_ListOfComponents like '%DNS%') or (@Para_ListOfComponents like '%Drivers%') or (@Para_ListOfComponents like '%Services%')
             or (@Para_ListOfComponents like '%StateMessages%') or (@Para_ListOfComponents like '%StateMessages%') or (@Para_ListOfComponents like '%PendingReboot%')
             or (@Para_ListOfComponents like '%ProvisioningMode%') or (@Para_ListOfComponents like '%WUAHandler%') or (@Para_ListOfComponents like '%WMI%')
			 and (@Para_ListOfComponentsType not like 'ok,error,fixed')
       begin
             set @Filter = ''
             set @Filter =  @Filter + ' and ('
             set @SQLCMD = @SQLCMD + @Filter 
       end

       -- Parameter for AdminShare
       if (@Para_ListOfComponents like '%AdminShare%')
       begin
		set @Filter = ''
        print 'working on AdminShare'
        if (@Para_ListOfComponentsType = 'OK')  set @Filter = @Filter + ' AdminShare in (''ok'')'                   
        if (@Para_ListOfComponentsType = 'Error') set @Filter =  @Filter + ' AdminShare in (''Error'')'
		if (@Para_ListOfComponentsType = 'OK,Error') set @Filter =  @Filter + ' AdminShare in (''OK'',''Error'')'
		if (@Para_ListOfComponentsType = 'Error,Fixed') set @Filter =  @Filter + ' AdminShare not in (''OK'')'
		if (@Para_ListOfComponentsType = 'Fixed') set @Filter = @Filter + ' AdminShare not in (''Error'',''OK'')'
		if (@Para_ListOfComponentsType = 'OK,Fixed') set @Filter = @Filter + ' AdminShare not in (''Error'')'
		if (@Para_ListOfComponentsType = 'OK,Error,Fixed') set @Filter = @Filter + ' AdminShare like ''%'''
       set @SQLCMD = @SQLCMD + @Filter 
       End 

       -- Parameter for BITS
       if (@Para_ListOfComponents like '%BITS%') 
       begin
		print 'working on bits'
		set @Filter = ''
		if (@Para_ListOfComponents like '%AdminShare%')
			begin
				set @Filter = ' or '
			end 
		else
			begin
				set @Filter = ''
			end 
		if (@Para_ListOfComponentsType = 'OK') set @Filter = @Filter + 'BITS in (''ok'')'
        if (@Para_ListOfComponentsType = 'Error') set @Filter =  @Filter + 'BITS in (''Error'')'
        if (@Para_ListOfComponentsType = 'OK,Error') set @Filter =  @Filter + 'BITS in (''OK'',''Error'')'
        if (@Para_ListOfComponentsType = 'Error,Fixed') set @Filter =  @Filter + 'BITS not in  (''OK'')'
        if (@Para_ListOfComponentsType = 'Fixed') set @Filter = @Filter + 'BITS not in (''Error'',''OK'')'
        if (@Para_ListOfComponentsType = 'OK,Fixed')  set @Filter = @Filter + 'BITS not in (''Error'')'
		if (@Para_ListOfComponentsType = 'OK,Error,Fixed') set @Filter = @Filter + ' BITS like ''%'''
        set @SQLCMD = @SQLCMD + @Filter 
       End 

       -- Parameter for ClientCertificate
       if (@Para_ListOfComponents like '%ClientCertificate%')
       begin
             print 'working on ClientCertificate'
             set @Filter = ''
             if (@Para_ListOfComponents like '%AdminShare%') or (@Para_ListOfComponents like '%BITS%') 
                    begin
                           set @Filter = ' or '
                    end
             else
                    begin
                           set @Filter = ''
                    end 
             if (@Para_ListOfComponentsType = 'OK') set @Filter = @Filter + 'ClientCertificate in (''ok'')'
             if (@Para_ListOfComponentsType = 'Error') set @Filter =  @Filter + 'ClientCertificate in (''Error'')'
             if (@Para_ListOfComponentsType = 'OK,Error') set @Filter =  @Filter + 'ClientCertificate in (''OK'',''Error'')'
             if (@Para_ListOfComponentsType = 'Error,Fixed') set @Filter =  @Filter + 'ClientCertificate not in (''OK'')'
             if (@Para_ListOfComponentsType = 'Fixed') set @Filter = @Filter + 'ClientCertificate not in (''Error'',''OK'')'
             if (@Para_ListOfComponentsType = 'OK,Fixed') set @Filter = @Filter + 'ClientCertificate not in (''Error'')'
			 if (@Para_ListOfComponentsType = 'OK,Error,Fixed') set @Filter = @Filter + ' ClientCertificate like ''%'''
       set @SQLCMD = @SQLCMD + @Filter 
       End 

       -- Parameter for DNS
       if (@Para_ListOfComponents like '%DNS%')
       begin
             set @Filter = ''
             print 'working on DNS'
             if (@Para_ListOfComponents like '%AdminShare%') or (@Para_ListOfComponents like '%BITS%') or (@Para_ListOfComponents like '%ClientCertificate%')
				begin
					set @Filter = ' or '
				end
             else
				begin
					set @Filter = ''
				end
             if (@Para_ListOfComponentsType = 'OK') set @Filter = @Filter + 'DNS in (''ok'')'
             if (@Para_ListOfComponentsType = 'Error') set @Filter =  @Filter + 'DNS in (''Error'')'
             if (@Para_ListOfComponentsType = 'OK,Error') set @Filter =  @Filter + 'DNS in (''OK'',''Error'')'
             if (@Para_ListOfComponentsType = 'Error,Fixed') set @Filter =  @Filter + 'DNS not in (''OK'')'
             if (@Para_ListOfComponentsType = 'Fixed') set @Filter = @Filter + 'DNS not in (''Error'',''OK'')'
             if (@Para_ListOfComponentsType = 'OK,Fixed') set @Filter = @Filter + 'DNS not in (''Error'')'
			 if (@Para_ListOfComponentsType = 'OK,Error,Fixed') set @Filter = @Filter + ' DNS like ''%'''
       set @SQLCMD = @SQLCMD + @Filter 
       End 

       -- Parameter for Drivers
       if (@Para_ListOfComponents like '%Drivers%')
       begin
             set @Filter = ''
             print 'working on Drivers'
             if (@Para_ListOfComponents like '%AdminShare%') or (@Para_ListOfComponents like '%BITS%')
				or (@Para_ListOfComponents like '%ClientCertificate%') or (@Para_ListOfComponents like '%DNS%')
				begin
					set @Filter = ' or '
				end
             else
				begin
					set @Filter = ''
				end
             if (@Para_ListOfComponentsType = 'OK') set @Filter = @Filter + 'Drivers in (''ok'')'
             if (@Para_ListOfComponentsType = 'Error') set @Filter =  @Filter + 'Drivers in (''Error'')'
             if (@Para_ListOfComponentsType = 'OK,Error') set @Filter =  @Filter + 'Drivers in (''OK'',''Error'')'
             if (@Para_ListOfComponentsType = 'Error,Fixed') set @Filter =  @Filter + 'Drivers not in (''OK'')'
             if (@Para_ListOfComponentsType = 'Fixed') set @Filter = @Filter + 'Drivers not in (''Error'',''OK'')'
             if (@Para_ListOfComponentsType = 'OK,Fixed') set @Filter = @Filter + 'Drivers not in (''Error'')'
			 if (@Para_ListOfComponentsType = 'OK,Error,Fixed') set @Filter = @Filter + ' Drivers like ''%'''
       set @SQLCMD = @SQLCMD + @Filter 
       End 

       -- Parameter for Services
       if (@Para_ListOfComponents like '%Services%')
       begin
             set @Filter = ''
             print 'working on Services'
             if (@Para_ListOfComponents like '%AdminShare%') or (@Para_ListOfComponents like '%BITS%') 
				or (@Para_ListOfComponents like '%ClientCertificate%') or (@Para_ListOfComponents like '%DNS%') or (@Para_ListOfComponents like '%Drivers%')
				begin
					set @Filter = ' or '
				end
             else
				begin
					set @Filter = ''
				end
             if (@Para_ListOfComponentsType = 'OK') set @Filter = @Filter + 'Services in (''ok'')'
             if (@Para_ListOfComponentsType = 'Error') set @Filter =  @Filter + 'Services in (''Error'')'
             if (@Para_ListOfComponentsType = 'OK,Error') set @Filter =  @Filter + 'Services in (''OK'',''Error'')'
             if (@Para_ListOfComponentsType = 'Error,Fixed') set @Filter =  @Filter + 'Services not in (''OK'')'
             if (@Para_ListOfComponentsType = 'Fixed') set @Filter = @Filter + 'Services not in (''Error'',''OK'')'
             if (@Para_ListOfComponentsType = 'OK,Fixed') set @Filter = @Filter + 'Services not in (''Error'')'
			 if (@Para_ListOfComponentsType = 'OK,Error,Fixed') set @Filter = @Filter + ' Services like ''%'''
       set @SQLCMD = @SQLCMD + @Filter 
       End 

       -- Parameter for StateMessages
       if (@Para_ListOfComponents like '%StateMessages%')
       begin
             set @Filter = ''
             print 'working on StateMessages'
             if (@Para_ListOfComponents like '%AdminShare%')or (@Para_ListOfComponents like '%BITS%')
                    or (@Para_ListOfComponents like '%ClientCertificate%') or (@Para_ListOfComponents like '%DNS%')
                    or (@Para_ListOfComponents like '%Drivers%') or (@Para_ListOfComponents like '%Services%')
                    begin
                           set @Filter = ' or '
                    end
             else
                    begin
                           set @Filter = ''
                    end
             if (@Para_ListOfComponentsType = 'OK') set @Filter = @Filter + 'StateMessages in (''ok'')'
             if (@Para_ListOfComponentsType = 'Error') set @Filter =  @Filter + 'StateMessages in (''Error'')'
             if (@Para_ListOfComponentsType = 'OK,Error') set @Filter =  @Filter + 'StateMessages in (''OK'',''Error'')'
             if (@Para_ListOfComponentsType = 'Error,Fixed') set @Filter =  @Filter + 'StateMessages not in (''OK'')'
             if (@Para_ListOfComponentsType = 'Fixed') set @Filter = @Filter + 'StateMessages not in (''Error'',''OK'')'
             if (@Para_ListOfComponentsType = 'OK,Fixed') set @Filter = @Filter + 'StateMessages not in (''Error'')'
			 if (@Para_ListOfComponentsType = 'OK,Error,Fixed') set @Filter = @Filter + ' StateMessages like ''%'''
       set @SQLCMD = @SQLCMD + @Filter 
       End 

       -- Parameter for PendingReboot
       if (@Para_ListOfComponents like '%PendingReboot%')
       begin
             set @Filter = ''
             print 'working on PendingReboot'
             if (@Para_ListOfComponents like '%AdminShare%') or (@Para_ListOfComponents like '%BITS%')
                    or (@Para_ListOfComponents like '%ClientCertificate%') or (@Para_ListOfComponents like '%DNS%')
                    or (@Para_ListOfComponents like '%Drivers%') or (@Para_ListOfComponents like '%Services%') or (@Para_ListOfComponents like '%StateMessages%')
                    begin
                           set @Filter = ' or '
                    end
             else
                    begin
                           set @Filter = ''
                    end 
             if (@Para_ListOfComponentsType = 'OK') set @Filter = @Filter + 'PendingReboot in (''ok'')'
             if (@Para_ListOfComponentsType = 'Error') set @Filter =  @Filter + 'PendingReboot in (''Error'')'
             if (@Para_ListOfComponentsType = 'OK,Error')  set @Filter =  @Filter + 'PendingReboot in (''OK'',''Error'')'
             if (@Para_ListOfComponentsType = 'Error,Fixed') set @Filter =  @Filter + 'PendingReboot not in (''OK'')'
             if (@Para_ListOfComponentsType = 'Fixed') set @Filter = @Filter + 'PendingReboot not in (''Error'',''OK'')'
             if (@Para_ListOfComponentsType = 'OK,Fixed') set @Filter = @Filter + 'PendingReboot not in (''Error'')'
			 if (@Para_ListOfComponentsType = 'OK,Error,Fixed') set @Filter = @Filter + ' PendingReboot like ''%'''
             set @SQLCMD = @SQLCMD + @Filter 
       End 

       -- Parameter for ProvisioningMode
       if (@Para_ListOfComponents like '%ProvisioningMode%')
       begin
             set @Filter = ''
             print 'working on ProvisioningMode'
              if (@Para_ListOfComponents like '%AdminShare%') or (@Para_ListOfComponents like '%BITS%')
                    or (@Para_ListOfComponents like '%ClientCertificate%') or (@Para_ListOfComponents like '%DNS%')
                    or (@Para_ListOfComponents like '%Drivers%') or (@Para_ListOfComponents like '%Services%')
                    or (@Para_ListOfComponents like '%StateMessages%') or (@Para_ListOfComponents like '%PendingReboot%')
                    begin
                           set @Filter = ' or '
                    end
             else
                    begin
                           set @Filter = ''
                    end
             if (@Para_ListOfComponentsType = 'OK') set @Filter = @Filter + 'ProvisioningMode in (''ok'')'
             if (@Para_ListOfComponentsType = 'Error') set @Filter =  @Filter + 'ProvisioningMode in (''Error'')'
             if (@Para_ListOfComponentsType = 'OK,Error') set @Filter =  @Filter + 'ProvisioningMode in (''OK'',''Error'')'
             if (@Para_ListOfComponentsType = 'Error,Fixed')  set @Filter =  @Filter + 'ProvisioningMode not in (''OK'')'
             if (@Para_ListOfComponentsType = 'Fixed') set @Filter = @Filter + 'ProvisioningMode not in (''Error'',''OK'')'
             if (@Para_ListOfComponentsType = 'OK,Fixed') set @Filter = @Filter + 'ProvisioningMode not in (''Error'')'
			 if (@Para_ListOfComponentsType = 'OK,Error,Fixed') set @Filter = @Filter + ' ProvisioningMode like ''%'''
       set @SQLCMD = @SQLCMD + @Filter 
       End 

       -- Parameter for WUAHandler
       if (@Para_ListOfComponents like '%WUAHandler%')
       begin
             set @Filter = ''
             print 'working on WUAHandler'
             if (@Para_ListOfComponents like '%AdminShare%') or (@Para_ListOfComponents like '%BITS%')
                    or (@Para_ListOfComponents like '%ClientCertificate%') or (@Para_ListOfComponents like '%DNS%')
                    or (@Para_ListOfComponents like '%Drivers%') or (@Para_ListOfComponents like '%Services%')
                    or (@Para_ListOfComponents like '%StateMessages%') or (@Para_ListOfComponents like '%PendingReboot%')
                    or (@Para_ListOfComponents like '%ProvisioningMode%')
                    begin
                           set @Filter = ' or '
                    end
             else
                    begin
                           set @Filter = ''
                    end 
             if (@Para_ListOfComponentsType = 'OK') set @Filter = @Filter + 'WUAHandler in (''ok'')'
             if (@Para_ListOfComponentsType = 'Error') set @Filter =  @Filter + 'WUAHandler in (''Error'')'
             if (@Para_ListOfComponentsType = 'OK,Error') set @Filter =  @Filter + 'WUAHandler in (''OK'',''Error'')'
             if (@Para_ListOfComponentsType = 'Error,Fixed') set @Filter =  @Filter + 'WUAHandler not in (''OK'')'
             if (@Para_ListOfComponentsType = 'Fixed') set @Filter = @Filter + 'WUAHandler not in (''Error'',''OK'')'
             if (@Para_ListOfComponentsType = 'OK,Fixed')  set @Filter = @Filter + 'WUAHandler not in (''Error'')'
			 if (@Para_ListOfComponentsType = 'OK,Error,Fixed') set @Filter = @Filter + ' WUAHandler like ''%'''
       set @SQLCMD = @SQLCMD + @Filter 
       End 

       -- Parameter for WMI
       if (@Para_ListOfComponents like '%WMI%')
       begin
             set @Filter = ''
             print 'working on WMI'
             if (@Para_ListOfComponents like '%AdminShare%') 
                    or (@Para_ListOfComponents like '%BITS%') or (@Para_ListOfComponents like '%ClientCertificate%')
                    or (@Para_ListOfComponents like '%DNS%')  or (@Para_ListOfComponents like '%Drivers%')
                    or (@Para_ListOfComponents like '%Services%')  or (@Para_ListOfComponents like '%StateMessages%')
                    or (@Para_ListOfComponents like '%PendingReboot%') or (@Para_ListOfComponents like '%ProvisioningMode%')
                    or (@Para_ListOfComponents like '%WUAHandler%')
                    begin
                           set @Filter = ' or '
                    end
             else
                    begin
                           set @Filter = ''
                    end
             if (@Para_ListOfComponentsType = 'OK')  set @Filter = @Filter + ' WMI in (''ok'')'
             if (@Para_ListOfComponentsType = 'Error') set @Filter =  @Filter + ' WMI in (''Error'')'
             if (@Para_ListOfComponentsType = 'OK,Error') set @Filter =  @Filter + ' WMI in (''OK'',''Error'')'
             if (@Para_ListOfComponentsType = 'Error,Fixed') set @Filter =  @Filter + ' WMI not in (''OK'')'
             if (@Para_ListOfComponentsType = 'Fixed') set @Filter = @Filter + ' WMI not in (''Error'',''OK'')'
             if (@Para_ListOfComponentsType = 'OK,Fixed') set @Filter = @Filter + ' WMI not in (''Error'')'
			 if (@Para_ListOfComponentsType = 'OK,Error,Fixed') set @Filter = @Filter + ' WMI like ''%'''
       set @SQLCMD = @SQLCMD + @Filter 
       End 

       if (@Para_ListOfComponents like '%AdminShare%')
             or (@Para_ListOfComponents like '%BITS%') or (@Para_ListOfComponents like '%ClientCertificate%')
             or (@Para_ListOfComponents like '%DNS%') or (@Para_ListOfComponents like '%Drivers%')
             or (@Para_ListOfComponents like '%Services%') or (@Para_ListOfComponents like '%StateMessages%')
             or (@Para_ListOfComponents like '%StateMessages%') or (@Para_ListOfComponents like '%PendingReboot%')
             or (@Para_ListOfComponents like '%ProvisioningMode%') or (@Para_ListOfComponents like '%WUAHandler%')
             or (@Para_ListOfComponents like '%WMI%')
			 
             begin
                    set @Filter = ''
                    set @Filter =  @Filter + ' )'
                    set @SQLCMD = @SQLCMD + @Filter
             end
	
	-- add sql statemenet to the log (for Debugging...)
    INSERT INTO [dbo].[LogMsg]  ([LogMsg],[Logdate])   VALUES  (@sqlcmd, getdate())

    --- sp_excuteSql is faster as exec (SQL cmd)       
	-- print @sqlcmd --- , only for Debug, Report will not work with printout's
	EXECUTE sp_executesql @sqlcmd 
	end 
end


GO

/****************************************************************************/
/*** Script Name                  : - up_get_ClientMainDiagramData        ***/
/*** Script Version               : - 0.01.10                             ***/
/*** Script Desciption            : - SP for ClientMainDiagramData        ***/
/*** Script Desciption            : - total / active / non-active         ***/
/*** Script Audience              : -                                     ***/
/*** Script Owner                 : - C-S-L K.Bilger                      ***/
/*** Scripter/Design              : - C-S-L K.Bilger                      ***/
/***                                                                      ***/
/*** Change History *********************************************************/
/*** Version (Old/New)            : - 0.01.10                             ***/
/*** Modification Date            : - 03/04/2019                          ***/
/*** By                           : - Klaus Bilger                        ***/
/*** Reason                       : -                                     ***/
/*** Comments                     : -                                     ***/
/****************************************************************************/
CREATE PROCEDURE [dbo].[up_get_ClientMainDiagramData]
	@Para_Actual_Term as int= 8, @Para_Use_Long_Term_Data as int = 0 , 
	@Para_Long_Term as int = 43503,  @Para_Device as Varchar(20)
AS
BEGIN
	SET NOCOUNT ON;
    declare @DateFilter as date 
	-- load default Version for SCCM Client Version (based on the config Tbl)
	declare @SCCM_ClientHealthTargetCount as int = (select top 1 configvalue from [dbo].[SCCM_Config] where ConfigItem = 'SCCM_ClientHealthTargetCount');
	
	declare @ListofClientHealthActions as varchar(max) = (select top 1 configvalue from [dbo].[SCCM_Config] where ConfigItem = 'ClientHealthActions');

	if @Para_Use_Long_Term_Data = 0 
	begin
		set @DateFilter = (select dateadd(DAY,-@Para_Actual_Term,getdate()));
		with cte_Client_OK (ClientOK, Date) as 
		(
			Select count(hostname) as ClientOK, convert(date, Timestamp) as date from v_ClientData_Actual 
			where Hostname like '%' and Timestamp >= @DateFilter
			and Services = 'OK' and WUAHandler = 'OK' and WMI = 'OK' and BITS = 'OK' and DNS = 'OK'
			group by convert(date, Timestamp)
		),
		cte_Client_Fixed (ClientFixed, Date) as 
		(
			Select count(hostname) as ClientFixed, convert(date, Timestamp) as date from v_ClientData_Actual 
			where Hostname like '%' and Timestamp >= @DateFilter
			and 
				(Services in (SELECT distinct (value) FROM [dbo].[udf_Split] (@ListofClientHealthActions, ','))  
				or WUAHandler in (SELECT distinct (value) FROM [dbo].[udf_Split] (@ListofClientHealthActions, ',')) 
				or WMI in (SELECT distinct (value) FROM [dbo].[udf_Split] (@ListofClientHealthActions, ',')) 
				or BITS in (SELECT distinct (value) FROM [dbo].[udf_Split] (@ListofClientHealthActions, ',')) 
				or DNS in (SELECT distinct (value) FROM [dbo].[udf_Split] (@ListofClientHealthActions, ','))
				)
			group by convert(date, Timestamp)
		),
		cte_Client_Error(ClientError, Date) as 
		(
			Select SUM(CASE WHEN hostname IS NULL THEN 1 ELSE 0  END) AS  ClientError,  convert(date, Timestamp) as date from v_ClientData_Actual 
			where Hostname like '%' and Timestamp >= @DateFilter
			and 
				(Services = 'Error'
				or WUAHandler = 'Error'
				or WMI = 'Error'
				or BITS = 'Error'
				or DNS = 'Error'
				)
			group by convert(date, Timestamp)
		),
		cte_Client_ALL (ClientALL, Date) as 
		(
			Select count(hostname) as ClientALL, convert(date, Timestamp) as date from v_ClientData_Actual 
			where Hostname like '%' and Timestamp >= @DateFilter
			group by convert(date, Timestamp)
		) 

		select @SCCM_ClientHealthTargetCount as TargetCount,
			CASE 
				WHEN vAll.ClientALL IS NULL THEN 0
					ELSE vall.ClientALL
				END AS ClientCountAll, 
			case
				WHEN vok.ClientOK IS NULL THEN 0
					ELSE vok.ClientOK
				END AS ClientOK, 
			case
				WHEN vfix.ClientFixed IS NULL THEN 0
					ELSE vfix.ClientFixed
				END AS ClientFixed, 
			case
				WHEN vError.ClientError IS NULL THEN 0
					ELSE vError.ClientError
				END AS ClientError, 
			vall.date as ClientDate
			from cte_Client_ALL as vAll 
			left join cte_Client_OK as vOK on vAll.Date = vOK.Date 
			left join cte_Client_Fixed as VFix on vAll.date = vFix.Date
			left join cte_Client_Error as vError on vAll.Date = vError.date 
	end 
	
	if @Para_Use_Long_Term_Data = 1 -- use actual and historical data  
	begin
		set @DateFilter = (select dateadd(DAY,-@Para_Long_Term,getdate()));
		with cte_Client_OK (ClientOK, Date) as 
		(
			Select count(hostname) as ClientOK, convert(date, Timestamp) as date from v_ClientData_ALL 
			where Hostname like '%' and Timestamp >= @DateFilter
			and Services = 'OK' and WUAHandler = 'OK' and WMI = 'OK' and BITS = 'OK' and DNS = 'OK'
			group by convert(date, Timestamp)
		),
		cte_Client_Fixed (ClientFixed, Date) as 
		(
			Select count(hostname) as ClientFixed, convert(date, Timestamp) as date from v_ClientData_ALL 
			where Hostname like '%' and Timestamp >= @DateFilter
			and 
				(Services in (SELECT distinct (value) FROM [dbo].[udf_Split] (@ListofClientHealthActions, ','))  
				or WUAHandler in (SELECT distinct (value) FROM [dbo].[udf_Split] (@ListofClientHealthActions, ',')) 
				or WMI in (SELECT distinct (value) FROM [dbo].[udf_Split] (@ListofClientHealthActions, ',')) 
				or BITS in (SELECT distinct (value) FROM [dbo].[udf_Split] (@ListofClientHealthActions, ',')) 
				or DNS in (SELECT distinct (value) FROM [dbo].[udf_Split] (@ListofClientHealthActions, ','))
				)
			group by convert(date, Timestamp)
		),
		cte_Client_Error(ClientError, Date) as 
		(
			Select SUM(CASE WHEN hostname IS NULL THEN 1 ELSE 0  END) AS  ClientError,  convert(date, Timestamp) as date from v_ClientData_ALL 
			where Hostname like '%' and Timestamp >= @DateFilter
			and 
				(Services = 'Error'
				or WUAHandler = 'Error'
				or WMI = 'Error'
				or BITS = 'Error'
				or DNS = 'Error'
				)
			group by convert(date, Timestamp)
		),
		cte_Client_ALL (ClientALL, Date) as 
		(
			Select count(hostname) as ClientALL, convert(date, Timestamp) as date from v_ClientData_ALL  
			where Hostname like '%' and Timestamp >= @DateFilter
			group by convert(date, Timestamp)
		) 
		-- output tbl
		select @SCCM_ClientHealthTargetCount as TargetCount,
			CASE 
				WHEN vAll.ClientALL IS NULL THEN 0
					ELSE vall.ClientALL
				END AS ClientCountAll, 
			case
				WHEN vok.ClientOK IS NULL THEN 0
					ELSE vok.ClientOK
				END AS ClientOK, 
			case
				WHEN vfix.ClientFixed IS NULL THEN 0
					ELSE vfix.ClientFixed
				END AS ClientFixed, 
			case
				WHEN vError.ClientError IS NULL THEN 0
					ELSE vError.ClientError
				END AS ClientError, 
			vall.date as ClientDate
			from cte_Client_ALL as vAll 
			left join cte_Client_OK as vOK on vAll.Date = vOK.Date 
			left join cte_Client_Fixed as VFix on vAll.date = vFix.Date
			left join cte_Client_Error as vError on vAll.Date = vError.date
	end
end 
GO
/****************************************************************************/
/*** Script Name                  : - up_get_OS_Summary_data              ***/
/*** Script Version               : - 0.01.10                             ***/
/*** Script Desciption            : - SP for OS Summary Data              ***/
/*** Script Audience              : -                                     ***/
/*** Script Owner                 : - C-S-L K.Bilger                      ***/
/*** Scripter/Design              : - C-S-L K.Bilger                      ***/
/***                                                                      ***/
/*** Change History *********************************************************/
/*** Version (Old/New)            : - 0.01.10                             ***/
/*** Modification Date            : - 03/04/2019                          ***/
/*** By                           : - Klaus Bilger                        ***/
/*** Reason                       : -                                     ***/
/*** Comments                     : -                                     ***/
/***                                                                      ***/
/****************************************************************************/
CREATE PROCEDURE [dbo].[up_get_OS_Summary_data]
	@Para_Actual_Term as int, @Para_Use_Long_Term_Data as int = 0 , 
	@Para_Long_Term as int = 43503,  @Para_Device as Varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	-- debug --
    declare @DateFilter as date = (select dateadd(DAY,-@Para_Actual_Term,getdate()))
	
	-- load default Version for SCCM Client Version (based on the config Tbl)
	declare @SCCM_Current_ClientVersion as varchar(20) = (select top 1 configvalue from [dbo].[SCCM_Config] where ConfigItem = 'SCCM_Current_ClientVersion')
	-- check @UseHistorydate
	if @Para_Use_Long_Term_Data = 1
	begin
		set @DateFilter =(select dateadd(DAY,-@Para_Long_Term,getdate())) 

		SELECT [OperatingSystem],
			Count (HOSTNAME) as TotalCount,
			SUM(Case when ClientCertificate = 'OK' then 1 else 0 end ) as ClientCertificate_OK,
			SUM(Case when ClientCertificate <> 'OK' then 1 else 0 end ) as ClientCertificate_Error, 
			SUM(Case when ClientVersion = @SCCM_Current_ClientVersion then 1 else 0 end ) as ClientVersion_Actual, 
			SUM(Case when ClientVersion > @SCCM_Current_ClientVersion then 1 else 0 end ) as ClientVersion_Newer, 
			SUM(Case when ClientVersion < @SCCM_Current_ClientVersion then 1 else 0 end ) as ClientVersion_Older, 
			SUM(Case when ProvisioningMode = 'OK' then 1 else 0 end ) as ProvisioningMode_OK,
			SUM(Case when ProvisioningMode <> 'OK' then 1 else 0 end ) as ProvisioningMode_Error,
			SUM(Case when DNS = 'OK' then 1 else 0 end ) as DNS_OK,
			SUM(Case when DNS <> 'OK' then 1 else 0 end ) as DNS_Error,
			SUM(Case when Drivers  = 'OK' then 1 else 0 end ) as Drivers_OK,
			SUM(Case when Drivers <> 'OK' then 1 else 0 end ) as Drivers_Error,
			SUM(Case when PendingReboot   = 'OK' then 1 else 0 end ) as PendingReboot_OK,
			SUM(Case when PendingReboot <> 'OK' then 1 else 0 end ) as PendingReboot_Error,
			SUM(Case when Services = 'OK' then 1 else 0 end ) as Services_OK,
			SUM(Case when Services <> 'OK' then 1 else 0 end ) as Services_Error,
			SUM(Case when AdminShare = 'OK' then 1 else 0 end ) as AdminShare_OK,
			SUM(Case when AdminShare <> 'OK' then 1 else 0 end ) as AdminShare_Error,
			SUM(Case when StateMessages = 'OK' then 1 else 0 end ) as StateMessages_OK,
			SUM(Case when StateMessages <> 'OK' then 1 else 0 end ) as StateMessages_Error,
			SUM(Case when WUAHandler = 'OK' then 1 else 0 end ) as WUAHandler_OK,
			SUM(Case when WUAHandler <> 'OK' then 1 else 0 end ) as WUAHandler_Error,
			SUM(Case when WMI = 'OK' then 1 else 0 end ) as WMI_OK,
			SUM(Case when WMI <> 'OK' then 1 else 0 end ) as WMI_Error,
			SUM(Case when BITS = 'OK' then 1 else 0 end ) as BITS_OK,
			SUM(Case when BITS <> 'OK' then 1 else 0 end ) as BITS_Error
		FROM  [dbo].[v_ClientData_ALL]
		where Timestamp > @DateFilter
		and Hostname like @Para_Device
		group by [OperatingSystem]
	end


	if @Para_Use_Long_Term_Data = 0
	begin
		SELECT [OperatingSystem],
			Count (HOSTNAME) as TotalCount,
			SUM(Case when ClientCertificate = 'OK' then 1 else 0 end ) as ClientCertificate_OK,
			SUM(Case when ClientCertificate <> 'OK' then 1 else 0 end ) as ClientCertificate_Error, 
			SUM(Case when ClientVersion = @SCCM_Current_ClientVersion then 1 else 0 end ) as ClientVersion_Actual, 
			SUM(Case when ClientVersion > @SCCM_Current_ClientVersion then 1 else 0 end ) as ClientVersion_Newer, 
			SUM(Case when ClientVersion < @SCCM_Current_ClientVersion then 1 else 0 end ) as ClientVersion_Older, 
			SUM(Case when ProvisioningMode = 'OK' then 1 else 0 end ) as ProvisioningMode_OK,
			SUM(Case when ProvisioningMode <> 'OK' then 1 else 0 end ) as ProvisioningMode_Error,
			SUM(Case when DNS = 'OK' then 1 else 0 end ) as DNS_OK,
			SUM(Case when DNS <> 'OK' then 1 else 0 end ) as DNS_Error,
			SUM(Case when Drivers  = 'OK' then 1 else 0 end ) as Drivers_OK,
			SUM(Case when Drivers <> 'OK' then 1 else 0 end ) as Drivers_Error,
			SUM(Case when PendingReboot   = 'OK' then 1 else 0 end ) as PendingReboot_OK,
			SUM(Case when PendingReboot <> 'OK' then 1 else 0 end ) as PendingReboot_Error,
			SUM(Case when Services = 'OK' then 1 else 0 end ) as Services_OK,
			SUM(Case when Services <> 'OK' then 1 else 0 end ) as Services_Error,
			SUM(Case when AdminShare = 'OK' then 1 else 0 end ) as AdminShare_OK,
			SUM(Case when AdminShare <> 'OK' then 1 else 0 end ) as AdminShare_Error,
			SUM(Case when StateMessages = 'OK' then 1 else 0 end ) as StateMessages_OK,
			SUM(Case when StateMessages <> 'OK' then 1 else 0 end ) as StateMessages_Error,
			SUM(Case when WUAHandler = 'OK' then 1 else 0 end ) as WUAHandler_OK,
			SUM(Case when WUAHandler <> 'OK' then 1 else 0 end ) as WUAHandler_Error,
			SUM(Case when WMI = 'OK' then 1 else 0 end ) as WMI_OK,
			SUM(Case when WMI <> 'OK' then 1 else 0 end ) as WMI_Error,
			SUM(Case when BITS = 'OK' then 1 else 0 end ) as BITS_OK,
			SUM(Case when BITS <> 'OK' then 1 else 0 end ) as BITS_Error
		FROM  [dbo].[v_ClientData_Actual]
		where Timestamp > @DateFilter
		and Hostname like @Para_Device
		group by [OperatingSystem]
	end
END
GO
/****************************************************************************/
/*** Script Name                  : - up_get_SCCMClientVersion		      ***/
/*** Script Version               : - 0.01.10                             ***/
/*** Script Desciption            : - SP for SCCM Client Versions         ***/
/*** Script Audience              : -                                     ***/
/*** Script Owner                 : - C-S-L K.Bilger                      ***/
/*** Scripter/Design              : - C-S-L K.Bilger                      ***/
/***                                                                      ***/
/*** Change History *********************************************************/
/*** Version (Old/New)            : - 0.01.10                             ***/
/*** Modification Date            : - 03/04/2019                          ***/
/*** By                           : - Klaus Bilger                        ***/
/*** Reason                       : -                                     ***/
/*** Comments                     : -                                     ***/
/***                                                                      ***/
/****************************************************************************/
CREATE PROCEDURE [dbo].[up_get_SCCMClientVersion]
	@Para_Use_Long_Term_Data as int = 0 , @Para_Device as Varchar(20)
AS
BEGIN
	SET NOCOUNT ON;
	declare @SCCMClientVersion as Varchar(20) = (select top 1 ConfigValue  from SCCM_Config where ConfigItem = 'SCCM_Current_ClientVersion')

	if @Para_Use_Long_Term_Data = 1 
		begin
			Select ClientVersion, 
				sum(case when ClientVersion =''+ @SCCMClientVersion + '' then 1 else 0 end) as SCCMAgent_Count_OK,
				sum(case when ClientVersion < '' + @SCCMClientVersion  + '' then 1 else 0 end) as SCCMAgent_Count_toOld,
				sum(case when ClientVersion > '' + @SCCMClientVersion  + '' then 1 else 0 end) as SCCMAgent_Count_Newer 
			from v_ClientData_ALL 
			where Hostname like '' +  @Para_Device + '' group by ClientVersion
		end 
	else 
		begin	
			Select ClientVersion, 
				sum(case when ClientVersion =''+ @SCCMClientVersion + '' then 1 else 0 end) as SCCMAgent_Count_OK,
				sum(case when ClientVersion < '' + @SCCMClientVersion  + '' then 1 else 0 end) as SCCMAgent_Count_toOld,
				sum(case when ClientVersion > '' + @SCCMClientVersion  + '' then 1 else 0 end) as SCCMAgent_Count_Newer 
			from v_ClientData_Actual 
			where Hostname like '' +  @Para_Device + '' group by ClientVersion
		end
END
GO
/****************************************************************************/
/*** Script Name                  : - up_GetErrorInfo                     ***/
/*** Script Version               : - 0.01.10                             ***/
/*** Script Desciption            : - erstellt Stored Procedure           ***/
/*** Script Audience              : -                                     ***/
/*** Script Owner                 : - C-S-L K.Bilger                      ***/
/*** Scripter/Design              : - C-S-L K.Bilger                      ***/
/***                                                                      ***/
/*** Change History *********************************************************/
/*** Version (Old/New)            : - 0.01.10                             ***/
/*** Modification Date            : - 03/04/2019                          ***/
/*** By                           : - Klaus Bilger                        ***/
/*** Reason                       : -                                     ***/
/*** Comments                     : -                                     ***/
/****************************************************************************/
CREATE PROCEDURE [dbo].[up_GetErrorInfo]
AS
begin 
 declare @Error_Text as nvarchar(max), @str_line as nvarchar(max)
 set  @str_line = replicate('#*',55) 
	set @Error_Text = @str_line + char(09) +  char(13)+ char(09) +  char(13)
	set @Error_Text = @Error_Text + ' Mail erzeugt:    ' + CONVERT(varchar(25),getdate())+ char(09) +  char(13)
	if ERROR_NUMBER() is not null 
		begin 
			set @Error_Text =  @Error_Text + 'ERROR_SEVERITY:  '  + CONVERT(varchar(max),ERROR_NUMBER())+ char(09) +  char(13)
		end
	if ERROR_SEVERITY() is not null 
		begin
			set @Error_Text = @Error_Text + 'ERROR_SEVERITY:  '  + CONVERT(varchar(max),ERROR_SEVERITY())+ char(09) +  char(13)
		end
	if ERROR_STATE() is not null 
	begin
		set @Error_Text = @Error_Text + 'ERROR_STATE:     '  + CONVERT(varchar(max),ERROR_STATE())+ char(09) +  char(13)
	end
	if ERROR_PROCEDURE() is not null 
	begin
		set @Error_Text = @Error_Text + 'ERROR_PROCEDURE:   '  + CONVERT(varchar(max),ERROR_PROCEDURE())+ char(09) +  char(13)
	end
	if ERROR_LINE() is not null 
	begin
		set @Error_Text = @Error_Text + 'ERROR_LINE:      '  + CONVERT(varchar(max),ERROR_LINE())+ char(09) +  char(13)
	end
	if ERROR_MESSAGE() is not null 
	begin
		set @Error_Text = @Error_Text + 'ERROR_MESSAGE:   '  + CONVERT(varchar(max),ERROR_MESSAGE())+ char(09) +  char(13)
	end
		set @Error_Text = @Error_Text + char(09) +  char(13)
		set @Error_Text = @Error_Text + @str_line

	INSERT INTO [dbo].[LogMsg]
           ([LogMsg],[Logdate])
     VALUES
           (@Error_Text, getdate())
END

GO

/* create now Trigger */
/****** Object:  Trigger [dbo].[T_TB_Clients_I]    Script Date: 3/7/2019 8:55:23 PM ******/
/****************************************************************************/
/*** Script Name                  : - [T_TB_Clients_I]                    ***/
/*** Script Version               : - 1.00                                ***/
/*** Script Desciption            : - erstellt Trigger for Insert (Hist)  ***/
/*** Script Audience              : -                                     ***/
/*** Script Owner                 : - C-S-L K.Bilger                      ***/
/*** Scripter/Design              : - C-S-L K.Bilger                      ***/
/***                                                                      ***/
/*** Change History *********************************************************/
/*** Version (Old/New)            : - 1.00.00                             ***/
/*** Modification Date            : - 01/25/2019                          ***/
/*** By                           : - Klaus Bilger                        ***/
/*** Reason                       : -                                     ***/
/*** Comments                     : -                                     ***/
/***                                                                      ***/
/*** Version (Old/New)            : - %Version%                           ***/
/*** Modification Date            : - %DATE%                              ***/
/*** By                           : - %PERSON%                            ***/
/*** Reason                       : - %REASON%                            ***/
/*** Comments                     : - %COMMENTS%                          ***/
/***                                                                      ***/
/****************************************************************************/
--
--

CREATE TRIGGER [dbo].[T_TB_Clients_I]
   ON  [dbo].[Clients]
   AFTER INSERT
AS 
BEGIN
       begin try
             Declare @Hostname as varchar(100)
             DECLARE DS_Update_Cursor CURSOR FOR  
             SELECT Hostname FROM INSERTED
             OPEN DS_Update_Cursor   
             FETCH NEXT FROM DS_Update_Cursor INTO @Hostname   

             WHILE @@FETCH_STATUS = 0   
       BEGIN   
                    INSERT INTO  [dbo].[Clients_Hist]
                    ([Hostname],[OperatingSystem],[Architecture],[Build],[Manufacturer],[Model],[InstallDate],
                           [OSUpdates],[LastLoggedOnUser],[ClientVersion],[PSVersion],[PSBuild],[Sitecode],[Domain],
                           [MaxLogSize],[MaxLogHistory],[CacheSize],[ClientCertificate],[ProvisioningMode],[DNS],
                           [Drivers],[Updates],[PendingReboot],[LastBootTime],[OSDiskFreeSpace],[Services],[AdminShare],
                           [StateMessages],[WUAHandler],[WMI],[RefreshComplianceState],[ClientInstalled],[Version],
                           [Timestamp],[HWInventory],[SWMetering],[BITS],[PatchLevel],[ClientInstalledReason],
                           [LOG_Created_Date],[LOG_Created_by],[LOG_Action])
                           
                    SELECT 
                           [Hostname],[OperatingSystem],[Architecture],[Build],[Manufacturer],[Model],[InstallDate],
                           [OSUpdates],[LastLoggedOnUser],[ClientVersion],[PSVersion],[PSBuild],[Sitecode],[Domain],
                           [MaxLogSize],[MaxLogHistory],[CacheSize],[ClientCertificate],[ProvisioningMode],[DNS],
                           [Drivers],[Updates],[PendingReboot],[LastBootTime],[OSDiskFreeSpace],[Services],[AdminShare],
                           [StateMessages],[WUAHandler],[WMI],[RefreshComplianceState],[ClientInstalled],[Version],
                           [Timestamp],[HWInventory],[SWMetering],[BITS],[PatchLevel],[ClientInstalledReason]
                           ,Getdate() as 'Created_Date'
                           ,USER as 'Created_by'
                           ,'INSERT' as 'Action'
                           FROM INSERTED 
        where ([Hostname] = @Hostname) 

       FETCH NEXT FROM DS_Update_Cursor INTO @Hostname   
       END   
       end try
       begin catch
             print 'error'
       end catch 
CLOSE DS_Update_Cursor   
DEALLOCATE DS_Update_Cursor
end
GO
ALTER TABLE [dbo].[Clients] ENABLE TRIGGER [T_TB_Clients_I]
GO
/****** Object:  Trigger [dbo].[T_TB_Clients_U]    Script Date: 3/7/2019 8:55:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************/
/*** Script Name                  : - [T_TB_Clients_U]                    ***/
/*** Script Version               : - 1.00                                ***/
/*** Script Desciption            : - erstellt Trigger for Update (Hist)  ***/
/*** Script Audience              : -                                     ***/
/*** Script Owner                 : - C-S-L K.Bilger                      ***/
/*** Scripter/Design              : - C-S-L K.Bilger                      ***/
/***                                                                      ***/
/*** Change History *********************************************************/
/*** Version (Old/New)            : - 1.00.00                             ***/
/*** Modification Date            : - 01/25/2019                          ***/
/*** By                           : - Klaus Bilger                        ***/
/*** Reason                       : -                                     ***/
/*** Comments                     : -                                     ***/
/***                                                                      ***/
/*** Version (Old/New)            : - %Version%                           ***/
/*** Modification Date            : - %DATE%                              ***/
/*** By                           : - %PERSON%                            ***/
/*** Reason                       : - %REASON%                            ***/
/*** Comments                     : - %COMMENTS%                          ***/
/***                                                                      ***/
/****************************************************************************/

CREATE TRIGGER [dbo].[T_TB_Clients_U]
   ON  [dbo].[Clients]
   AFTER Update
AS 
BEGIN
       begin try
             Declare @Hostname as varchar(100)
             DECLARE DS_Update_Cursor CURSOR FOR  
             
             SELECT Hostname FROM INSERTED
             OPEN DS_Update_Cursor   
             FETCH NEXT FROM DS_Update_Cursor INTO @Hostname   

             WHILE @@FETCH_STATUS = 0   
       BEGIN   
                    INSERT INTO [dbo].[Clients_Hist]
                    ([Hostname],[OperatingSystem],[Architecture],[Build],[Manufacturer],[Model],[InstallDate],
                           [OSUpdates],[LastLoggedOnUser],[ClientVersion],[PSVersion],[PSBuild],[Sitecode],[Domain],
                           [MaxLogSize],[MaxLogHistory],[CacheSize],[ClientCertificate],[ProvisioningMode],[DNS],
                           [Drivers],[Updates],[PendingReboot],[LastBootTime],[OSDiskFreeSpace],[Services],[AdminShare],
                           [StateMessages],[WUAHandler],[WMI],[RefreshComplianceState],[ClientInstalled],[Version],
                           [Timestamp],[HWInventory],[SWMetering],[BITS],[PatchLevel],[ClientInstalledReason],
                           [LOG_Created_Date],[LOG_Created_by],[LOG_Action])
                           
                    SELECT 
                           [Hostname],[OperatingSystem],[Architecture],[Build],[Manufacturer],[Model],[InstallDate],
                           [OSUpdates],[LastLoggedOnUser],[ClientVersion],[PSVersion],[PSBuild],[Sitecode],[Domain],
                           [MaxLogSize],[MaxLogHistory],[CacheSize],[ClientCertificate],[ProvisioningMode],[DNS],
                           [Drivers],[Updates],[PendingReboot],[LastBootTime],[OSDiskFreeSpace],[Services],[AdminShare],
                           [StateMessages],[WUAHandler],[WMI],[RefreshComplianceState],[ClientInstalled],[Version],
                           [Timestamp],[HWInventory],[SWMetering],[BITS],[PatchLevel],[ClientInstalledReason]
                           ,Getdate() as 'Created_Date'
                           ,USER as 'Created_by'
                           ,'Update' as 'Action'
                           FROM INSERTED
             where ([Hostname] = @Hostname) 
       FETCH NEXT FROM DS_Update_Cursor INTO @Hostname   
       END   
       end try
       begin catch
             print 'error'
       
       end catch 
CLOSE DS_Update_Cursor   
DEALLOCATE DS_Update_Cursor
end
GO
ALTER TABLE [dbo].[Clients] ENABLE TRIGGER [T_TB_Clients_U]
Print ''
Print '#############################################################################'
Print '## before you run the report you need to import the base configuration !! ###'
Print '#############################################################################'
Print ''