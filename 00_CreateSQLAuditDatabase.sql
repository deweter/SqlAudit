/*
** Deployment script for SQLAudit Database
**    Authors: Andy Roberts, Ayad Shammout, Denny Lee
**    Date: 09/16/2008
**
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DataDirectory "I:\UserDB\"
:setvar LogDirectory "I:\TRANSLOG\DATA\"
:setvar DatabaseName "SQLAudit"
:setvar DefaultDataPath ""

GO
USE [master]

GO
IF (DB_ID(N'$(DatabaseName)') IS NOT NULL
    AND DATABASEPROPERTYEX(N'$(DatabaseName)','Status') <> N'ONLINE')
BEGIN
    RAISERROR(N'The state of the target database, %s, is not set to ONLINE. To deploy to this database, its state must be set to ONLINE.', 16, 127,N'$(DatabaseName)') WITH NOWAIT
    RETURN
END

GO
IF (DB_ID('$(DatabaseName)') IS NOT NULL) 
BEGIN
    ALTER DATABASE [$(DatabaseName)]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$(DatabaseName)];
END

GO
PRINT N'Creating $(DatabaseName)'
GO
CREATE DATABASE [$(DatabaseName)]
    ON 
    PRIMARY(NAME = [SQL_AuditLog], FILENAME = '$(DataDirectory)$(DatabaseName)_data.mdf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB), 
    FILEGROUP [fgAuditMonth01](NAME = [fAuditMonth01], FILENAME = '$(DataDirectory)$(DatabaseName)_fAuditMonth01.ndf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB), 
    FILEGROUP [fgAuditMonth02](NAME = [fAuditMonth02], FILENAME = '$(DataDirectory)$(DatabaseName)_fAuditMonth02.ndf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB), 
    FILEGROUP [fgAuditMonth03](NAME = [fAuditMonth03], FILENAME = '$(DataDirectory)$(DatabaseName)_fAuditMonth03.ndf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB), 
    FILEGROUP [fgAuditMonth04](NAME = [fAuditMonth04], FILENAME = '$(DataDirectory)$(DatabaseName)_fAuditMonth04.ndf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB), 
    FILEGROUP [fgAuditMonth05](NAME = [fAuditMonth05], FILENAME = '$(DataDirectory)$(DatabaseName)_fAuditMonth05.ndf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB),
    FILEGROUP [fgAuditMonth06](NAME = [fAuditMonth06], FILENAME = '$(DataDirectory)$(DatabaseName)_fAuditMonth06.ndf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB),
    FILEGROUP [fgAuditMonth07](NAME = [fAuditMonth07], FILENAME = '$(DataDirectory)$(DatabaseName)_fAuditMonth07.ndf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB),
    FILEGROUP [fgAuditMonth08](NAME = [fAuditMonth08], FILENAME = '$(DataDirectory)$(DatabaseName)_fAuditMonth08.ndf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB),
    FILEGROUP [fgAuditMonth09](NAME = [fAuditMonth09], FILENAME = '$(DataDirectory)$(DatabaseName)_fAuditMonth09.ndf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB),
    FILEGROUP [fgAuditMonth10](NAME = [fAuditMonth10], FILENAME = '$(DataDirectory)$(DatabaseName)_fAuditMonth10.ndf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB),
    FILEGROUP [fgAuditMonth11](NAME = [fAuditMonth11], FILENAME = '$(DataDirectory)$(DatabaseName)_fAuditMonth11.ndf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB),
    FILEGROUP [fgAuditMonth12](NAME = [fAuditMonth12], FILENAME = '$(DataDirectory)$(DatabaseName)_fAuditMonth12.ndf', SIZE = 1 GB, MAXSIZE = UNLIMITED, FILEGROWTH = 1048576 KB)
    LOG ON (NAME = [SQL_AuditLog_log], FILENAME = '$(LogDirectory)$(DatabaseName)_log.ldf', SIZE = 1049600 KB, MAXSIZE = 2097152 MB, FILEGROWTH = 1048576 KB) COLLATE SQL_Latin1_General_CP1_CI_AS
GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                NUMERIC_ROUNDABORT OFF,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT OFF,
                CURSOR_DEFAULT GLOBAL,
                RECOVERY BULK_LOGGED,
                CURSOR_CLOSE_ON_COMMIT OFF,
                AUTO_CLOSE OFF,
                AUTO_CREATE_STATISTICS ON,
                AUTO_SHRINK OFF,
                AUTO_UPDATE_STATISTICS ON,
                RECURSIVE_TRIGGERS OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ALLOW_SNAPSHOT_ISOLATION OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET READ_COMMITTED_SNAPSHOT OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_UPDATE_STATISTICS_ASYNC OFF,
                PAGE_VERIFY CHECKSUM,
                DISABLE_BROKER,
                PARAMETERIZATION SIMPLE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET TRUSTWORTHY OFF,
        DB_CHAINING OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'Unable to modify the database settings for DB_CHAINING or TRUSTWORTHY. You must be a SysAdmin in order to apply these settings.';
    END


GO
USE [$(DatabaseName)]

GO
IF fulltextserviceproperty(N'IsFulltextInstalled') = 1
    EXECUTE sp_fulltext_database 'enable';


GO

GO
/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script	
 Use SQLCMD syntax to include a file into the pre-deployment script			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/


if (DB_NAME() != '$(DatabaseName)')
begin
	--
	-- raising a sev 20 error to terminate this connection so that the script does not continue past this batch. 
	-- if the script is executed by a non-sysadmin then sql will not allow the sev 20 to be raised so instead we will
	-- put context to tempdb. 
	--
	-- the issue we are trying to solve here is that if the script is not executed in sqlcmd mode then 
	-- the create database and use statements fail because it does not recognize $(DatabaseName) as a script variable
	-- and context is left in master when the database objects are created. 
	--
	
	raiserror('context is not set to the correct database. please make sure that you are executing this script in SQLCMD mode.', 20, 0) with log
	use tempdb
end
GO

GO
PRINT N'Creating monthly_partition_function';


GO
declare @PartitionStartDate smalldatetime
set @PartitionStartDate = cast(cast(dateadd(dd, 1-datepart(dd, GetDate()), GETDATE()) as varchar(11)) as smalldatetime)
CREATE PARTITION FUNCTION [monthly_partition_function](DATETIME2 (7))
    AS RANGE RIGHT
    FOR VALUES (
		@PartitionStartDate, 
		dateadd(mm, 1, @PartitionStartDate), 
		dateadd(mm, 2, @PartitionStartDate),
		dateadd(mm, 3, @PartitionStartDate),
		dateadd(mm, 4, @PartitionStartDate),
		dateadd(mm, 5, @PartitionStartDate),
		dateadd(mm, 6, @PartitionStartDate),
		dateadd(mm, 7, @PartitionStartDate),
		dateadd(mm, 8, @PartitionStartDate),
		dateadd(mm, 9, @PartitionStartDate),
		dateadd(mm, 10, @PartitionStartDate),
		dateadd(mm, 11, @PartitionStartDate)
	);


GO
PRINT N'Creating monthly_partition_scheme';


GO
CREATE PARTITION SCHEME [monthly_partition_scheme]
    AS PARTITION [monthly_partition_function]
    TO (
		[fgAuditMonth01], 
		[fgAuditMonth02], 
		[fgAuditMonth03], 
		[fgAuditMonth04], 
		[fgAuditMonth05], 
		[fgAuditMonth06], 
		[fgAuditMonth07], 
		[fgAuditMonth08], 
		[fgAuditMonth09], 
		[fgAuditMonth10], 
		[fgAuditMonth11], 
		[fgAuditMonth12], 
		[PRIMARY]
	);


GO
PRINT N'Creating aud';


GO
CREATE SCHEMA [aud]
    AUTHORIZATION [dbo];


GO
PRINT N'Creating stage';


GO
CREATE SCHEMA [stage]
    AUTHORIZATION [dbo];


GO
PRINT N'Creating aud.AuditedClassType';

GO
CREATE TABLE [aud].[AuditFile_ErrorLog](
	[event_time] [datetime2](7) NULL,
	[sequence_number] [int] NULL,
	[action_id] [varchar](4) NULL,
	[succeeded] [bit] NULL,
	[permission_bitmask] [bigint] NULL,
	[is_column_permission] [bit] NULL,
	[session_id] [smallint] NULL,
	[class_type] [varchar](2) NULL,
	[session_server_principal_name] [nvarchar](128) NULL,
	[server_principal_name] [nvarchar](128) NULL,
	[database_principal_name] [nvarchar](128) NULL,
	[target_server_principal_name] [nvarchar](128) NULL,
	[target_database_principal_name] [nvarchar](128) NULL,
	[server_instance_name] [nvarchar](110) NULL,
	[database_name] [nvarchar](110) NULL,
	[schema_name] [nvarchar](110) NULL,
	[object_name] [nvarchar](110) NULL,
	[statement] [nvarchar](4000) NULL,
	[additional_information] [nvarchar](4000) NULL,
	[file_name] [nvarchar](260) NULL,
	[audit_file_offset] [bigint] NULL,
	[pooled_connection] [bit] NULL,
	[packet_data_size] [int] NULL,
	[address] [nvarchar](50) NULL,
	[is_dac] [bit] NULL,
	[total_cpu] [int] NULL,
	[reads] [int] NULL,
	[writes] [int] NULL,
	[event_count] [int] NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [aud].[AuditFile]    Script Date: 09/29/2011 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[AuditFile](
	[audit_file_id] [int] IDENTITY(1,1) NOT NULL,
	[audit_file_name] [nvarchar](512) NOT NULL,
	[audit_file_name_trimmed] [nvarchar](260) NULL,
	[audit_file_path] [nvarchar](260) NULL,
	[audit_file_extension] [nvarchar](260) NULL,
	[audit_name] [nvarchar](128) NULL,
	[audit_guid] [nvarchar](50) NULL,
	[audit_file_partition] [nvarchar](10) NULL,
	[audit_file_timestamp] [nvarchar](50) NULL,
	[audit_file_source_server] [nvarchar](110) NULL,
 CONSTRAINT [pk_audit_file] PRIMARY KEY NONCLUSTERED 
(
	[audit_file_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [aud].[AuditedObject]    Script Date: 09/29/2011 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[AuditedObject](
	[audited_object_id] [int] IDENTITY(1,1) NOT NULL,
	[server_instance_name] [nvarchar](110) NULL,
	[database_name] [nvarchar](110) NULL,
	[schema_name] [nvarchar](110) NULL,
	[object_name] [nvarchar](110) NULL,
 CONSTRAINT [pk_auditedObject] PRIMARY KEY NONCLUSTERED 
(
	[audited_object_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [uxc_AuditedObject] ON [aud].[AuditedObject] 
(
	[server_instance_name] ASC,
	[database_name] ASC,
	[schema_name] ASC,
	[object_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[AuditedClassType]    Script Date: 09/29/2011 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [aud].[AuditedClassType](
	[audited_class_type_id] [int] IDENTITY(1,1) NOT NULL,
	[class_type] [varchar](2) NOT NULL,
	[class_type_desc] [nvarchar](35) NULL,
	[securable_class_desc] [nvarchar](25) NULL,
 CONSTRAINT [pk_AuditedClassType] PRIMARY KEY NONCLUSTERED 
(
	[audited_class_type_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE CLUSTERED INDEX [uxc_AuditedClassType] ON [aud].[AuditedClassType] 
(
	[class_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_AuditedClassType] ON [aud].[AuditedClassType] 
(
	[class_type_desc] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[AuditedAction]    Script Date: 09/29/2011 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [aud].[AuditedAction](
	[audited_action_id] [int] IDENTITY(1,1) NOT NULL,
	[action_id] [char](4) NOT NULL,
	[action_name] [nvarchar](128) NULL,
 CONSTRAINT [pk_AuditedAction] PRIMARY KEY NONCLUSTERED 
(
	[audited_action_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE CLUSTERED INDEX [uxc_AuditedAction] ON [aud].[AuditedAction] 
(
	[action_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ux_AuditedAction] ON [aud].[AuditedAction] 
(
	[action_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[ActionGroup_Ref]    Script Date: 09/29/2011 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [aud].[ActionGroup_Ref](
	[ActionGroup] [varchar](50) NULL,
	[ActionName] [varchar](250) NULL,
	[ActionDescription] [varchar](4000) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  UserDefinedFunction [aud].[fn_GetServerInstanceName]    Script Date: 09/29/2011 16:13:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [aud].[fn_GetServerInstanceName] (
	@Audit_File_Name nvarchar(128)
) returns nvarchar(128)
as
begin
	declare @i int, @j int, @InstanceName nvarchar(128)
	set @i = CHARINDEX('SQLAudit$', @Audit_File_Name)
	set @InstanceName = SUBSTRING(@Audit_File_Name, @i + 9, 128)
	set @j = CHARINDEX('_', @InstanceName)
	set @InstanceName = replace(SUBSTRING(@InstanceName, 1, @j - 1), '$', '\')
	return (@InstanceName)


end
GO
/****** Object:  UserDefinedFunction [aud].[fn_GetAuditFileInfo_OLD]    Script Date: 09/29/2011 16:13:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [aud].[fn_GetAuditFileInfo_OLD]
(@audit_file_name NVARCHAR (512))
RETURNS TABLE 
AS
RETURN 
    (
	select audit_name = LEFT(audit_file_name_trimmed, us1 - 1)
			, audit_guid = SUBSTRING(audit_file_name_trimmed, us1 + 1, us2 - us1 - 1)
			, audit_file_partition = SUBSTRING(audit_file_name_trimmed, us2 + 1, us3 - us2 - 1)
			, audit_file_timestamp = RIGHT(audit_file_name_trimmed, len(audit_file_name_trimmed) - us3)
			, audit_file_name
			, audit_file_name_trimmed
			, audit_file_path
			, audit_file_extension
	  from (
		select audit_file_name
				, audit_file_name_trimmed
				, audit_file_path
				, audit_file_extension
				, us1 = CHARINDEX('_', audit_file_name_trimmed)
				, us2 = CHARINDEX('_', audit_file_name_trimmed, CHARINDEX('_', audit_file_name_trimmed) + 1)
				, us3 = CHARINDEX('_', audit_file_name_trimmed, CHARINDEX('_', audit_file_name_trimmed, CHARINDEX('_', audit_file_name_trimmed) + 1) + 1)
		  from (
			select audit_file_name = @audit_file_name
					, audit_file_name_trimmed = LEFT(RIGHT(@audit_file_name, CHARINDEX('\', reverse(@audit_file_name))-1), CHARINDEX('.', RIGHT(@audit_file_name, CHARINDEX('\', reverse(@audit_file_name))-1), 1) - 1)
					, audit_file_path = LEFT(@audit_file_name, len(@audit_file_name) - CHARINDEX('\', reverse(@audit_file_name)))
					, audit_file_extension = RIGHT(@audit_file_name, CHARINDEX('.', reverse(@audit_file_name))-1)
		  ) a
		) b
)
GO
/****** Object:  UserDefinedFunction [aud].[fn_GetAuditFileInfo]    Script Date: 09/29/2011 16:13:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [aud].[fn_GetAuditFileInfo]
(@audit_file_name NVARCHAR (512))
RETURNS TABLE 
AS
RETURN 

-- Look for last 3 occurance of '_' to identify TimeStamp, PartitionID, Guid and File name then reverse them again
    (
	select audit_name = Reverse(RIGHT(audit_file_name_trimmed, len(audit_file_name_trimmed) - us3))
			, audit_guid = Reverse(SUBSTRING(audit_file_name_trimmed, us2 + 1, us3 - us2 - 1))
			, audit_file_partition = Reverse(SUBSTRING(audit_file_name_trimmed, us1 + 1, us2 - us1 - 1))
			, audit_file_timestamp = Reverse(LEFT(audit_file_name_trimmed, us1 - 1))
			, audit_file_name
			, Reverse(audit_file_name_trimmed) AS audit_file_name_trimmed
			, audit_file_path
			, audit_file_extension
	  from (
		select audit_file_name
				, audit_file_name_trimmed
				, audit_file_path
				, audit_file_extension
				, us1 = CHARINDEX('_', audit_file_name_trimmed)
				, us2 = CHARINDEX('_', audit_file_name_trimmed, CHARINDEX('_', audit_file_name_trimmed) + 1)
				, us3 = CHARINDEX('_', audit_file_name_trimmed, CHARINDEX('_', audit_file_name_trimmed, CHARINDEX('_', audit_file_name_trimmed) + 1) + 1)
		  from (
			select audit_file_name = @audit_file_name
					, audit_file_name_trimmed = reverse(LEFT(RIGHT(@audit_file_name, CHARINDEX('\', reverse(@audit_file_name))-1), CHARINDEX('.', RIGHT(@audit_file_name, CHARINDEX('\', reverse(@audit_file_name))-1), 1) - 1))
					, audit_file_path = LEFT(@audit_file_name, len(@audit_file_name) - CHARINDEX('\', reverse(@audit_file_name)))
					, audit_file_extension = RIGHT(@audit_file_name, CHARINDEX('.', reverse(@audit_file_name))-1)
		  ) a
		) b
)
GO
/****** Object:  UserDefinedFunction [aud].[fn_AuditFileGet2]    Script Date: 09/29/2011 16:13:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [aud].[fn_AuditFileGet2]
(@filename NVARCHAR (512), @fileoffset BIGINT)
RETURNS TABLE 
AS
RETURN 
    (
    with log_file_cte as (
		select event_time							= aud.event_time
				, sequence_number					= aud.sequence_number
				, succeeded							= aud.succeeded
				, permission_bitmask				= aud.permission_bitmask
				, is_column_permission				= aud.is_column_permission
				, session_id						= aud.session_id
				, statement							= cast(aud.statement as nvarchar(4000))
				, additional_information			= cast(aud.additional_information as nvarchar(4000))
				, file_name							= aud.file_name
				, audit_file_offset					= aud.audit_file_offset
				, action_id							= upper(aud.action_id)
				, class_type						= upper(aud.class_type)
				, session_server_principal_name		= upper(aud.session_server_principal_name)
				, server_principal_name				= upper(aud.server_principal_name)
				, target_server_principal_name		= upper(aud.target_server_principal_name)
				, database_principal_name			= upper(aud.database_principal_name)
				, target_database_principal_name	= upper(aud.target_database_principal_name)
				, server_instance_name				= upper(left(aud.server_instance_name, 110))
				, database_name						= upper(left(aud.database_name, 110))
				, schema_name						= upper(left(aud.schema_name, 110))
				, object_name						= upper(left(aud.object_name, 110))

				, pooled_connection					= CASE WHEN action_id IN ('LGIF', 'LGIS')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:pooled_connection[1]/text())[1]', 'bit')
														ELSE NULL
													  END
				, packet_data_size					= CASE WHEN action_id IN ('LGIF', 'LGIS')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:packet_data_size[1]/text())[1]', 'int')
														ELSE NULL
													  END
				, address							= ISNULL(CASE WHEN action_id IN ('LGIF', 'LGIS')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:address[1]/text())[1]', 'nvarchar(50)')
														ELSE NULL
													  END, '')
				, is_dac							= CASE WHEN action_id IN ('LGIF', 'LGIS')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:is_dac[1]/text())[1]', 'bit')
														ELSE NULL
													  END

				, total_cpu							= CASE WHEN action_id IN ('LGO')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:total_cpu[1]/text())[1]', 'int')
														ELSE NULL
													  END
				, reads								= CASE WHEN action_id IN ('LGO')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:reads[1]/text())[1]', 'int')
														ELSE NULL
													  END
				, writes							= CASE WHEN action_id IN ('LGO')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:writes[1]/text())[1]', 'int')
														ELSE NULL
													  END
		  from sys.fn_get_audit_file(@filename, @filename, @fileoffset) aud
		  )
		select event_time							
				, sequence_number					
				, succeeded							
				, permission_bitmask				
				, is_column_permission				
				, session_id						
				, statement							
				, additional_information			
				, file_name							
				, audit_file_offset					
				, action_id							
				, class_type						
				, session_server_principal_name		
				, server_principal_name				
				, target_server_principal_name		
				, database_principal_name			
				, target_database_principal_name	
				, server_instance_name				
				, database_name						
				, schema_name						
				, object_name						
				, pooled_connection					
				, packet_data_size					
				, address							
				, is_dac							
				, total_cpu							
				, reads								
				, writes							
				, event_count = count(*) 
		  from log_file_cte
		 group by event_time							
				, sequence_number					
				, succeeded							
				, permission_bitmask				
				, is_column_permission				
				, session_id						
				, statement							
				, additional_information			
				, file_name							
				, audit_file_offset					
				, action_id							
				, class_type						
				, session_server_principal_name		
				, server_principal_name				
				, target_server_principal_name		
				, database_principal_name			
				, target_database_principal_name	
				, server_instance_name				
				, database_name						
				, schema_name						
				, object_name						
				, pooled_connection					
				, packet_data_size					
				, address							
				, is_dac							
				, total_cpu							
				, reads								
				, writes							


	)
GO
/****** Object:  UserDefinedFunction [aud].[fn_AuditFileGet]    Script Date: 09/29/2011 16:13:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [aud].[fn_AuditFileGet]
(@filename NVARCHAR (512), @fileoffset BIGINT)
RETURNS TABLE 
AS
RETURN 
    (
    with log_file_cte as (
		select event_time							= aud.event_time
				, sequence_number					= aud.sequence_number
				, succeeded							= aud.succeeded
				, permission_bitmask				= aud.permission_bitmask
				, is_column_permission				= aud.is_column_permission
				, session_id						= aud.session_id
				, statement							= cast(aud.statement as nvarchar(4000))
				, additional_information			= cast(aud.additional_information as nvarchar(4000))
				, file_name							= aud.file_name
				, audit_file_offset					= aud.audit_file_offset
				, action_id							= upper(aud.action_id)
				, class_type						= upper(aud.class_type)
				, session_server_principal_name		= upper(aud.session_server_principal_name)
				, server_principal_name				= upper(aud.server_principal_name)
				, target_server_principal_name		= upper(aud.target_server_principal_name)
				, database_principal_name			= upper(aud.database_principal_name)
				, target_database_principal_name	= upper(aud.target_database_principal_name)
				, server_instance_name				= upper(left(aud.server_instance_name, 110))
				, database_name						= upper(left(aud.database_name, 110))
				, schema_name						= upper(left(aud.schema_name, 110))
				, object_name						= upper(left(aud.object_name, 110))

				, pooled_connection					= CASE WHEN action_id IN ('LGIF', 'LGIS')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:pooled_connection[1]/text())[1]', 'bit')
														ELSE NULL
													  END
				, packet_data_size					= CASE WHEN action_id IN ('LGIF', 'LGIS')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:packet_data_size[1]/text())[1]', 'int')
														ELSE NULL
													  END
				, address							= ISNULL(CASE WHEN action_id IN ('LGIF', 'LGIS')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:address[1]/text())[1]', 'nvarchar(50)')
														ELSE NULL
													  END, '')
				, is_dac							= CASE WHEN action_id IN ('LGIF', 'LGIS')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:is_dac[1]/text())[1]', 'bit')
														ELSE NULL
													  END

				, total_cpu							= CASE WHEN action_id IN ('LGO')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:total_cpu[1]/text())[1]', 'int')
														ELSE NULL
													  END
				, reads								= CASE WHEN action_id IN ('LGO')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:reads[1]/text())[1]', 'int')
														ELSE NULL
													  END
				, writes							= CASE WHEN action_id IN ('LGO')
														THEN CAST(additional_information as xml).value(N'declare namespace sqlaudit="http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data";(/sqlaudit:action_info/sqlaudit:writes[1]/text())[1]', 'int')
														ELSE NULL
													  END
		  from sys.fn_get_audit_file(@filename, case when @fileoffset = 0 then null else @filename end, case when @fileoffset = 0 then null else @fileoffset end) aud
		  )
		select event_time							
				, sequence_number					
				, succeeded							
				, permission_bitmask				
				, is_column_permission				
				, session_id						
				, statement							
				, additional_information			
				, file_name							
				, audit_file_offset					
				, action_id							
				, class_type						
				, session_server_principal_name		
				, server_principal_name				
				, target_server_principal_name		
				, database_principal_name			
				, target_database_principal_name	
				, server_instance_name				
				, database_name						
				, schema_name						
				, object_name						
				, pooled_connection					
				, packet_data_size					
				, address							
				, is_dac							
				, total_cpu							
				, reads								
				, writes							
				, event_count = count(*) 
		  from log_file_cte
		 group by event_time							
				, sequence_number					
				, succeeded							
				, permission_bitmask				
				, is_column_permission				
				, session_id						
				, statement							
				, additional_information			
				, file_name							
				, audit_file_offset					
				, action_id							
				, class_type						
				, session_server_principal_name		
				, server_principal_name				
				, target_server_principal_name		
				, database_principal_name			
				, target_database_principal_name	
				, server_instance_name				
				, database_name						
				, schema_name						
				, object_name						
				, pooled_connection					
				, packet_data_size					
				, address							
				, is_dac							
				, total_cpu							
				, reads								
				, writes							


	)
GO
/****** Object:  Table [aud].[DatabasePrincipalName]    Script Date: 09/29/2011 16:13:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[DatabasePrincipalName](
	[database_principal_name_id] [int] IDENTITY(1,1) NOT NULL,
	[database_principal_name] [nvarchar](128) NOT NULL,
 CONSTRAINT [pk_DatabasePrincipalName] PRIMARY KEY NONCLUSTERED 
(
	[database_principal_name_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [uxc_DatabasePrincipalName] ON [aud].[DatabasePrincipalName] 
(
	[database_principal_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[ClientAddress]    Script Date: 09/29/2011 16:13:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[ClientAddress](
	[client_address_id] [int] IDENTITY(1,1) NOT NULL,
	[client_address] [nvarchar](50) NULL,
 CONSTRAINT [PK_ClientAddress] PRIMARY KEY CLUSTERED 
(
	[client_address_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [aud].[AuditLog_UnknownActions]    Script Date: 09/29/2011 16:13:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[AuditLog_UnknownActions](
	[event_time] [datetime2](7) NULL,
	[sequence_number] [int] NULL,
	[audited_action_id] [int] NULL,
	[audited_class_type_id] [int] NULL,
	[server_principal_name_id] [int] NULL,
	[session_server_principal_name_id] [int] NULL,
	[target_server_principal_name_id] [int] NULL,
	[database_principal_name_id] [int] NULL,
	[target_database_principal_name_id] [int] NULL,
	[audited_object_id] [int] NULL,
	[succeeded] [bit] NULL,
	[permission_bitmask] [bigint] NULL,
	[is_column_permission] [bit] NULL,
	[session_id] [smallint] NULL,
	[statement_id] [int] NULL,
	[additional_information] [nvarchar](4000) NULL,
	[audit_file_offset] [bigint] NULL,
	[import_id] [int] NULL,
	[audit_file_id] [int] NULL,
	[client_address_id] [int] NULL,
	[pooled_connection] [bit] NULL,
	[packet_data_size] [int] NULL,
	[is_dac] [bit] NULL,
	[total_cpu] [int] NULL,
	[reads] [int] NULL,
	[writes] [int] NULL,
	[event_count] [int] NULL
) ON [PRIMARY]
GO

/****** Object:  UserDefinedFunction [dbo].[index_name]    Script Date: 09/29/2011 16:13:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[index_name] (@object_id int, @index_id tinyint)
RETURNS sysname
AS
BEGIN
  DECLARE @index_name sysname
  SELECT @index_name = name FROM sys.indexes
     WHERE object_id = @object_id and index_id = @index_id
  RETURN(@index_name)
END;
GO
/****** Object:  Table [aud].[ImportExecution]    Script Date: 09/29/2011 16:13:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[ImportExecution](
	[import_id] [int] IDENTITY(1,1) NOT NULL,
	[started_time] [datetime] NOT NULL,
	[stopped_time] [datetime] NULL,
	[disposition] [nvarchar](128) NULL,
 CONSTRAINT [pk_importexecution] PRIMARY KEY CLUSTERED 
(
	[import_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[spPartitionsList]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spPartitionsList]
AS
With R (boundary_id, value) AS
(select boundary_id, value from sys.partition_range_values
 where function_id in (select function_id 
      from sys.partition_functions
       where name in ('monthly_partition_function'))
)

--View the distribution of data in the partitions
SELECT R.value, ps.partition_number ,ps.row_count , ps.used_page_count
      
FROM sys.dm_db_partition_stats ps
INNER JOIN sys.partitions p
ON ps.partition_id = p.partition_id
AND p.[object_id] = OBJECT_ID('aud.AuditLog_ServerActions')
INNER JOIN R on ps.partition_number = R.boundary_id+1

Where p.index_id = 1
Order by R.value
GO
/****** Object:  StoredProcedure [dbo].[spADD_PARTITION_RIGHT_ON_AuditLog]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spADD_PARTITION_RIGHT_ON_AuditLog]
AS

DECLARE @month datetime, @fg char(14),@mm char(2), @str varchar(1000)

SET @month = cast((select top 1 [value] from sys.partition_range_values
       where function_id = (select function_id 
               from sys.partition_functions
               where name = 'monthly_partition_function')
      order by boundary_id DESC) as datetime)

SET @month = DATEADD(month, 1, @month)

Print @month

If datepart(mm,@month) < 10
  Set @mm = '0'+Cast(datepart(mm,@month) as CHAR(2))
Else
  Set @mm = Cast(datepart(mm,@month) as CHAR(2))

Set @fg = 'fgAuditMonth'+@mm

Print @fg

Set @str = 'ALTER PARTITION SCHEME monthly_partition_scheme NEXT USED ['+@fg+']';

Print @str

Execute (@str)

ALTER PARTITION FUNCTION monthly_partition_function() 
SPLIT RANGE (@month);
GO
/****** Object:  Table [aud].[ServerPrincipalName]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[ServerPrincipalName](
	[server_principal_name_id] [int] IDENTITY(1,1) NOT NULL,
	[server_principal_name] [nvarchar](128) NOT NULL,
	[domain_name] [nvarchar](128) NULL,
	[principal_name] [nvarchar](128) NULL,
	[is_windows_principal] [bit] NULL,
 CONSTRAINT [pk_ServerPrincipalName] PRIMARY KEY NONCLUSTERED 
(
	[server_principal_name_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [uxc_ServerPrincipalName] ON [aud].[ServerPrincipalName] 
(
	[server_principal_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[rptAggServerActionsByObject]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[rptAggServerActionsByObject](
	[EventDate] [smalldatetime] NOT NULL,
	[server_instance_name] [nvarchar](128) NULL,
	[database_principal_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[schema_name] [nvarchar](128) NULL,
	[object_name] [nvarchar](128) NULL,
	[ServerActionCount] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_rptAggServerActionsByObject] ON [aud].[rptAggServerActionsByObject] 
(
	[EventDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[rptAggServerActionsByClass]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[rptAggServerActionsByClass](
	[EventDate] [smalldatetime] NOT NULL,
	[server_instance_name] [nvarchar](128) NULL,
	[database_principal_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[action_name] [nvarchar](128) NULL,
	[class_type_desc] [nvarchar](128) NULL,
	[securable_class_desc] [nvarchar](128) NULL,
	[ServerActionCount] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_rptAggServerActionsByClass] ON [aud].[rptAggServerActionsByClass] 
(
	[EventDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ActionName] ON [aud].[rptAggServerActionsByClass] 
(
	[action_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_class_type_desc] ON [aud].[rptAggServerActionsByClass] 
(
	[class_type_desc] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Database_name] ON [aud].[rptAggServerActionsByClass] 
(
	[database_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_instance_class_action] ON [aud].[rptAggServerActionsByClass] 
(
	[server_instance_name] ASC,
	[class_type_desc] ASC,
	[action_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Instance_Name] ON [aud].[rptAggServerActionsByClass] 
(
	[server_instance_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[rptAggGeneralActionsByObject]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[rptAggGeneralActionsByObject](
	[EventDate] [smalldatetime] NOT NULL,
	[server_instance_name] [nvarchar](128) NULL,
	[database_principal_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[schema_name] [nvarchar](128) NULL,
	[object_name] [nvarchar](128) NULL,
	[ServerActionCount] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_rptAggGeneralActionsByObject] ON [aud].[rptAggGeneralActionsByObject] 
(
	[EventDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[rptAggGeneralActionsByClass]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[rptAggGeneralActionsByClass](
	[EventDate] [smalldatetime] NOT NULL,
	[server_instance_name] [nvarchar](128) NULL,
	[database_principal_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[action_name] [nvarchar](128) NULL,
	[class_type_desc] [nvarchar](128) NULL,
	[securable_class_desc] [nvarchar](128) NULL,
	[ServerActionCount] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_rptAggGeneralActionsByClass] ON [aud].[rptAggGeneralActionsByClass] 
(
	[EventDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_instance_class_action] ON [aud].[rptAggGeneralActionsByClass] 
(
	[server_instance_name] ASC,
	[class_type_desc] ASC,
	[action_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[rptAggDMLActionsByObject]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[rptAggDMLActionsByObject](
	[EventDate] [smalldatetime] NOT NULL,
	[server_instance_name] [nvarchar](128) NULL,
	[database_principal_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[schema_name] [nvarchar](128) NULL,
	[object_name] [nvarchar](128) NULL,
	[DMLActionCount] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_rptAggDMLActionsByObject] ON [aud].[rptAggDMLActionsByObject] 
(
	[EventDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[rptAggDMLActionsByClass]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[rptAggDMLActionsByClass](
	[EventDate] [smalldatetime] NOT NULL,
	[server_instance_name] [nvarchar](128) NULL,
	[database_principal_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[action_name] [nvarchar](128) NULL,
	[class_type_desc] [nvarchar](128) NULL,
	[securable_class_desc] [nvarchar](128) NULL,
	[DMLActionCount] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_rptAggDMLActionsByClass] ON [aud].[rptAggDMLActionsByClass] 
(
	[EventDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ActionName] ON [aud].[rptAggDMLActionsByClass] 
(
	[action_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_class_type_desc] ON [aud].[rptAggDMLActionsByClass] 
(
	[class_type_desc] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Database_name] ON [aud].[rptAggDMLActionsByClass] 
(
	[database_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Instance_Name] ON [aud].[rptAggDMLActionsByClass] 
(
	[server_instance_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[rptAggDDLActionsByObject]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[rptAggDDLActionsByObject](
	[EventDate] [smalldatetime] NOT NULL,
	[server_instance_name] [nvarchar](128) NULL,
	[database_principal_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[schema_name] [nvarchar](128) NULL,
	[object_name] [nvarchar](128) NULL,
	[DDLActionCount] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_rptAggDDLActionsByObject] ON [aud].[rptAggDDLActionsByObject] 
(
	[EventDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[rptAggDDLActionsByClass]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[rptAggDDLActionsByClass](
	[EventDate] [smalldatetime] NOT NULL,
	[server_instance_name] [nvarchar](128) NULL,
	[database_principal_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[action_name] [nvarchar](128) NULL,
	[class_type_desc] [nvarchar](128) NULL,
	[securable_class_desc] [nvarchar](128) NULL,
	[DDLActionCount] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_rptAggDDLActionsByClass] ON [aud].[rptAggDDLActionsByClass] 
(
	[EventDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ActionName] ON [aud].[rptAggDDLActionsByClass] 
(
	[action_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_class_type_desc] ON [aud].[rptAggDDLActionsByClass] 
(
	[class_type_desc] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Database_name] ON [aud].[rptAggDDLActionsByClass] 
(
	[database_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Instance_Name] ON [aud].[rptAggDDLActionsByClass] 
(
	[server_instance_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[rptAggDatabaseActionsByObject]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[rptAggDatabaseActionsByObject](
	[EventDate] [smalldatetime] NOT NULL,
	[server_instance_name] [nvarchar](128) NULL,
	[database_principal_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[schema_name] [nvarchar](128) NULL,
	[object_name] [nvarchar](128) NULL,
	[DatabaseActionCount] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_rptAggDatabaseActionsByObject] ON [aud].[rptAggDatabaseActionsByObject] 
(
	[EventDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [aud].[rptAggDatabaseActionsByClass]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[rptAggDatabaseActionsByClass](
	[EventDate] [smalldatetime] NOT NULL,
	[server_instance_name] [nvarchar](128) NULL,
	[database_principal_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[action_name] [nvarchar](128) NULL,
	[class_type_desc] [nvarchar](128) NULL,
	[securable_class_desc] [nvarchar](128) NULL,
	[DatabaseActionCount] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_rptAggDatabaseActionsByClass] ON [aud].[rptAggDatabaseActionsByClass] 
(
	[EventDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ActionName] ON [aud].[rptAggDatabaseActionsByClass] 
(
	[action_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_class_type_desc] ON [aud].[rptAggDatabaseActionsByClass] 
(
	[class_type_desc] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Database_name] ON [aud].[rptAggDatabaseActionsByClass] 
(
	[database_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Instance_Name] ON [aud].[rptAggDatabaseActionsByClass] 
(
	[server_instance_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [aud].[uspTop10Stats]    Script Date: 09/29/2011 16:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [aud].[uspTop10Stats]
AS
Select Server_instance_name AS InstanceName, SUM(ActionCount) AS ActionCount, MIN(eventdate) AS StartDate, MAX(eventdate) AS EndDate
from aud.vAggALLActionsByClass
Where EVENTDATE > GETDATE()-8 AND server_instance_name <> ''
Group by server_instance_name
Order by ActionCount desc


Select Top 10 Database_name AS DBName, SUM(ActionCount) AS ActionCount, MIN(eventdate) AS StartDate, MAX(eventdate) AS EndDate 
from aud.vAggALLActionsByClass
Where EVENTDATE > GETDATE()-8 AND database_name <> ''
Group by database_name
Order by ActionCount desc


Select Top 10 Action_name AS ActionName, SUM(ActionCount) AS ActionCount, MIN(eventdate) AS StartDate, MAX(eventdate) AS EndDate 
from aud.vAggALLActionsByClass
Where EVENTDATE > GETDATE()-8 AND Action_Name <> ''
Group by Action_name
Order by ActionCount desc

Select Top 10 database_principal_name AS UserName, SUM(ActionCount) AS ActionCount, MIN(eventdate) AS StartDate, MAX(eventdate) AS EndDate
from aud.vAggALLActionsByClass
Where EVENTDATE > GETDATE()-8 AND database_principal_name <> ''
Group by database_principal_name
Order by ActionCount desc


Select Top 10 class_type_desc AS ActionClass, SUM(ActionCount) AS ActionCount, MIN(eventdate) AS StartDate, MAX(eventdate) AS EndDate
from aud.vAggALLActionsByClass
Where EVENTDATE > GETDATE()-8 AND class_type_desc <> ''
Group by class_type_desc
Order by ActionCount desc
GO
/****** Object:  View [dbo].[vw_Partition_Info]    Script Date: 09/29/2011 16:13:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create a view to return details about a partitioned table or index
--  First run the script to create the function index_name()

CREATE VIEW [dbo].[vw_Partition_Info] AS
SELECT s.name+'.'+OBJECT_NAME(i.object_id) as Object_Name, dbo.INDEX_NAME(i.object_id,i.index_id) AS Index_Name, 
    p.partition_number, fg.name AS Filegroup_Name, rows, 
    au.total_pages,
    CASE boundary_value_on_right 
        WHEN 1 THEN 'less than' 
        ELSE 'less than or equal to' 
    END as 'comparison'
    , rv.value,
    CASE WHEN ISNULL(rv.value, rv2.value) IS NULL THEN 'N/A'
    ELSE 
      CASE 
        WHEN boundary_value_on_right = 0 AND rv2.value IS NULL  
           THEN 'Greater than or equal to'
        WHEN boundary_value_on_right = 0 
           THEN 'Greater than' 
        ELSE 'Greater than or equal to' END + ' ' +
           ISNULL(CONVERT(varchar(15), rv2.value), 'Min Value') 
                + ' ' +
                + 
           CASE boundary_value_on_right 
             WHEN 1 THEN 'and less than' 
               ELSE 'and less than or equal to' 
               END + ' ' +
                + ISNULL(CONVERT(varchar(15), rv.value), 
                           'Max Value')
        END as 'TextComparison'
  FROM sys.partitions p 
    JOIN sys.indexes i 
      ON p.object_id = i.object_id and p.index_id = i.index_id
    LEFT JOIN sys.partition_schemes ps 
      ON ps.data_space_id = i.data_space_id
    LEFT JOIN sys.partition_functions f 
      ON f.function_id = ps.function_id
    LEFT JOIN sys.partition_range_values rv 
      ON f.function_id = rv.function_id 
          AND p.partition_number = rv.boundary_id     
    LEFT JOIN sys.partition_range_values rv2 
      ON f.function_id = rv2.function_id 
          AND p.partition_number - 1= rv2.boundary_id
    LEFT JOIN sys.destination_data_spaces dds
      ON dds.partition_scheme_id = ps.data_space_id 
          AND dds.destination_id = p.partition_number 
    LEFT JOIN sys.filegroups fg 
      ON dds.data_space_id = fg.data_space_id
    JOIN sys.allocation_units au
      ON au.container_id = p.partition_id 
    JOIN sys.objects o  
      ON i.object_id = o.object_id
    JOIN sys.schemas s
      ON o.schema_id = s.schema_id  
WHERE i.index_id <2 AND au.type =1
GO
/****** Object:  View [aud].[vw_AggALLActionsByClass]    Script Date: 09/29/2011 16:13:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [aud].[vw_AggALLActionsByClass]
AS
Select z.EventDate, z.server_instance_name, z.database_principal_name, z.database_name, z.action_name,
        z.class_type_desc, z.securable_class_desc, z.ActionCount, z.ActionSource
From 
(Select EventDate, server_instance_name, database_principal_name, database_name, action_name,
        class_type_desc, securable_class_desc, ServerActionCount AS ActionCount,'SRV' AS ActionSource
 From aud.rptAggServerActionsByClass
 UNION ALL
 Select EventDate, server_instance_name, database_principal_name, database_name, action_name,
        class_type_desc, securable_class_desc, DatabaseActionCount AS ActionCount,'DB' AS ActionSource
 From aud.rptAggDatabaseActionsByClass
 UNION ALL
 Select EventDate, server_instance_name, database_principal_name, database_name, action_name,
        class_type_desc, securable_class_desc, DDLActionCount AS ActionCount,'DDL' AS ActionSource
 From aud.rptAggDDLActionsByClass
 UNION ALL
 Select EventDate, server_instance_name, database_principal_name, database_name, action_name,
        class_type_desc, securable_class_desc, DMLActionCount AS ActionCount, 'DML' AS ActionSource
 From aud.rptAggDMLActionsByClass
  
 ) z
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[ImportedFile](
	[imported_file_id] [int] IDENTITY(1,1) NOT NULL,
	[import_id] [int] NOT NULL,
	[file_name] [nvarchar](512) NOT NULL,
	[audit_file_offset_min] [bigint] NOT NULL,
	[audit_file_offset_max] [bigint] NOT NULL,
	[event_time_min] [datetime2](7) NOT NULL,
	[event_time_max] [datetime2](7) NOT NULL,
	[rows_processed] [int] NOT NULL,
 CONSTRAINT [pk_ImportedFile] PRIMARY KEY CLUSTERED 
(
	[imported_file_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [aud].[uspInsServerPrincipalName]    Script Date: 09/29/2011 16:13:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[uspInsServerPrincipalName]
@server_principal_name NVARCHAR (128)
AS
SET NOCOUNT ON;

WITH namecte AS (
	SELECT server_principal_name = RTRIM(LTRIM(@server_principal_name))
	)
MERGE aud.ServerPrincipalName AS target
USING namecte AS source 
   ON (target.server_principal_name = source.server_principal_name)
 WHEN NOT MATCHED THEN 
	INSERT (server_principal_name)
	VALUES (server_principal_name)
	;
 
SELECT * 
  FROM aud.ServerPrincipalName 
 WHERE server_principal_name = RTRIM(LTRIM(@server_principal_name))
GO
/****** Object:  StoredProcedure [aud].[uspInsDatabasePrincipalName]    Script Date: 09/29/2011 16:13:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[uspInsDatabasePrincipalName]
@database_principal_name NVARCHAR (128)
AS
SET NOCOUNT ON ;
WITH namecte AS (
	SELECT database_principal_name = RTRIM(LTRIM(@database_principal_name))
	)
MERGE aud.DatabasePrincipalName AS target
USING namecte AS source 
   ON (target.database_principal_name = source.database_principal_name)
 WHEN NOT MATCHED THEN 
	INSERT (database_principal_name)
	VALUES (database_principal_name)
	;

SELECT * 
  FROM aud.DatabasePrincipalName 
   WHERE database_principal_name = RTRIM(LTRIM(@database_principal_name))
GO
/****** Object:  StoredProcedure [aud].[uspInsClientAddress]    Script Date: 09/29/2011 16:13:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[uspInsClientAddress]
@client_address NVARCHAR (50)
AS
SET NOCOUNT ON 

if @client_address is null
begin
	select @client_address = ''
end

;
WITH addresscte AS (
	SELECT client_address = RTRIM(LTRIM(@client_address))
	)
MERGE aud.ClientAddress AS target
USING addresscte AS source 
   ON (target.client_address = source.client_address)
 WHEN NOT MATCHED THEN 
	INSERT (client_address)
	VALUES (client_address)
	;

SELECT * 
  FROM aud.ClientAddress 
   WHERE client_address = RTRIM(LTRIM(@client_address))
GO
/****** Object:  StoredProcedure [aud].[uspInsAuditFile]    Script Date: 09/29/2011 16:13:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[uspInsAuditFile]
@audit_file_name NVARCHAR (512)
AS
SET NOCOUNT ON ;

select @audit_file_name = RTRIM(ltrim(@audit_file_name))

declare @audit_file_info table (
			audit_name nvarchar(128)
			, audit_guid nvarchar(50)
			, audit_file_partition nvarchar(10)
			, audit_file_timestamp nvarchar(50)
			, audit_file_name nvarchar(260)
			, audit_file_name_trimmed nvarchar(260)
			, audit_file_path nvarchar(260)
			, audit_file_extension nvarchar(260)
			);
insert into @audit_file_info (
	audit_name 
	, audit_guid 
	, audit_file_partition 
	, audit_file_timestamp 
	, audit_file_name
	, audit_file_name_trimmed 
	, audit_file_path 
	, audit_file_extension 
	)
	select audit_name 
			, audit_guid 
			, audit_file_partition 
			, audit_file_timestamp 
			, audit_file_name
			, audit_file_name_trimmed
			, audit_file_path
			, audit_file_extension
	  from aud.fn_GetAuditFileInfo(@audit_file_name)

declare @server_instance_name nvarchar(110)

if exists(
		select top 1 1 
		  from aud.AuditFile f
		  join @audit_file_info i
		    on f.audit_guid = i.audit_guid
		    )
begin
	select top 1 @server_instance_name = f.audit_file_source_server
	  from aud.AuditFile f
	  cross join @audit_file_info i
	 where f.audit_guid = i.audit_guid
end
else
begin

	begin try
		declare @audit_file_namepat nvarchar(260)
		select @audit_file_namepat = i.audit_file_path + '\' + i.audit_name + '_' + i.audit_guid + '*.' + i.audit_file_extension
		  from @audit_file_info i
		
		select top 1 @server_instance_name = server_instance_name
		  from fn_get_audit_file(@audit_file_namepat, default, default)
		 where  action_id = 'AUSC'
	 end try
	 begin catch
		select top 1 @server_instance_name = ''
	 end catch
	 
	 /* Additional Logic for the server_instance_name */
	 if ISNULL(@server_instance_name, '') = '' set @server_instance_name = [aud].[fn_GetServerInstanceName](@audit_file_namepat);
end;
WITH filecte AS (
	SELECT *
	  from @audit_file_info	
	)
MERGE aud.AuditFile AS target
USING filecte AS source 
   ON (target.audit_file_name = source.audit_file_name)
 WHEN NOT MATCHED THEN 
insert (
	audit_name 
	, audit_guid 
	, audit_file_partition 
	, audit_file_timestamp 
	, audit_file_name
	, audit_file_name_trimmed 
	, audit_file_path 
	, audit_file_extension 
	, audit_file_source_server
	)
	values (
	audit_name 
	, audit_guid 
	, audit_file_partition 
	, audit_file_timestamp 
	, audit_file_name
	, audit_file_name_trimmed 
	, audit_file_path 
	, audit_file_extension 
	, @server_instance_name
	)
	;

SELECT * 
  FROM aud.AuditFile 
 WHERE audit_file_name = RTRIM(LTRIM(@audit_file_name))


PRINT N'Creating uspInsAuditedObject';
GO
/****** Object:  StoredProcedure [aud].[uspInsAuditedObject]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[uspInsAuditedObject]
@server_instance_name NVARCHAR (110), @database_name NVARCHAR (110), @schema_name NVARCHAR (110), @object_name NVARCHAR (110)
AS
SET NOCOUNT ON;
WITH objectcte AS (
	SELECT server_instance_name = RTRIM(LTRIM(@server_instance_name))
	, database_name = RTRIM(LTRIM(@database_name))
	, schema_name = RTRIM(LTRIM(@schema_name))
	, object_name = RTRIM(LTRIM(@object_name))
	)
MERGE aud.AuditedObject AS target
USING objectcte AS source 
   ON (
		    target.server_instance_name = source.server_instance_name
		AND target.database_name = source.database_name
		AND target.schema_name = source.schema_name
		AND target.object_name = source.object_name
	)
 WHEN NOT MATCHED THEN 
	INSERT (server_instance_name, database_name, schema_name, object_name)
	VALUES (server_instance_name, database_name, schema_name, object_name)
;

SELECT *
  FROM aud.AuditedObject
 WHERE server_instance_name = RTRIM(LTRIM(@server_instance_name))
   AND database_name = RTRIM(LTRIM(@database_name))
   AND schema_name = RTRIM(LTRIM(@schema_name))
   AND object_name = RTRIM(LTRIM(@object_name))
GO
/****** Object:  StoredProcedure [aud].[uspInsAuditedClassType]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[uspInsAuditedClassType]
@class_type VARCHAR (2)
AS
SET NOCOUNT ON;

WITH classcte AS (
	SELECT class_type
			, class_type_desc 
			, securable_class_desc
	  FROM sys.dm_audit_class_type_map 
	 WHERE class_type = RTRIM(LTRIM(IsNull(@class_type, 'ZZ')))
	)
MERGE aud.AuditedClassType AS target
USING classcte AS source 
   ON (target.class_type = source.class_type)
 WHEN NOT MATCHED THEN 
	INSERT (class_type, class_type_desc, securable_class_desc)
	VALUES (class_type, class_type_desc, securable_class_desc)
	;

SELECT *
  FROM aud.AuditedClassType 
 WHERE class_type = IsNull(@class_type, 'ZZ')
GO
/****** Object:  StoredProcedure [aud].[uspInsAuditedAction]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[uspInsAuditedAction]
@action_id VARCHAR (4)
AS
SET NOCOUNT ON;

WITH actioncte AS (
	SELECT DISTINCT action_id
			, name as action_name 
	  FROM sys.dm_audit_actions 
	 WHERE action_id = RTRIM(LTRIM(@action_id))
	)
MERGE aud.auditedAction AS target
USING actioncte AS source 
   ON (target.action_id = source.action_id)
 WHEN NOT MATCHED THEN 
	INSERT (action_id, action_name)
	VALUES (action_id, action_name)
	;

SELECT * 
  FROM aud.AuditedAction 
 WHERE action_id = @action_id
GO
/****** Object:  StoredProcedure [aud].[uspImportExecutionStop]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[uspImportExecutionStop]
@import_id INT
AS
UPDATE aud.ImportExecution
   SET stopped_time = getdate()
 WHERE import_id = @import_id
GO
/****** Object:  StoredProcedure [aud].[uspImportExecutionStart]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[uspImportExecutionStart]
@import_id INT OUTPUT
AS
SET NOCOUNT ON;

INSERT INTO aud.ImportExecution (
	started_time
	) 
	VALUES (
		getdate()
		);

SET @import_id = SCOPE_IDENTITY();
GO
/****** Object:  StoredProcedure [aud].[uspAggServerActionsByObject]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [aud].[uspAggServerActionsByObject] (
	@StartTime smalldatetime, 
	@EndTime smalldatetime,
	@Instance_name nvarchar(128) = null, 
	@DB_Name nvarchar(128) = null, 
	@Schema_Name nvarchar(128) = null,
	@Object_Name nvarchar(128) = null	
)
as
begin
	-- query optimization
	set nocount on

	-- Query
	select 
		EventDate, 
		server_instance_name, 
		database_principal_name, 
		database_name, 
		[schema_name], 
		[object_name], 
		ServerActionCount
	from aud.rptAggServerActionsByObject (NoLock)
	where
		EventDate >= @StartTime and EventDate <= @EndTime	-- time
		and (server_instance_name = @Instance_name or @Instance_name is null)
		and (database_name = @DB_Name or @DB_Name is null)
		and ([schema_name] = @Schema_Name or @Schema_Name is null)
		and ([object_name] = @Object_Name or @Object_Name is null)
		
end
GO
/****** Object:  StoredProcedure [aud].[uspAggServerActionsByClass]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [aud].[uspAggServerActionsByClass] (
	@StartTime smalldatetime, 
	@EndTime smalldatetime,
	@Instance_name nvarchar(128) = null, 
	@DB_Name nvarchar(128) = null, 
	@Class_Type nvarchar(128) = null,
	@Action_Name nvarchar(128) = null
)
as
begin
	-- query optimization
	set nocount on

	-- Query
	select 
		EventDate, 
		server_instance_name, 
		database_principal_name, 
		database_name, 
		action_name, 
		class_type_desc, 
		securable_class_desc,  
		ServerActionCount
	from aud.rptAggServerActionsByClass (NoLock)
	where
		EventDate >= @StartTime and EventDate <= @EndTime	-- time
		and (server_instance_name = @Instance_name or @Instance_name is null)
		and (database_name = @DB_Name or @DB_Name is null)
		and (class_type_desc = @Class_Type or @Class_Type is null)
		and (action_name = @Action_Name or @Action_Name is null)
end
GO
/****** Object:  StoredProcedure [aud].[uspAggGeneralActionsByObject]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [aud].[uspAggGeneralActionsByObject] (
	@StartTime smalldatetime, 
	@EndTime smalldatetime,
	@Instance_name nvarchar(128) = null, 
	@DB_Name nvarchar(128) = null, 
	@Schema_Name nvarchar(128) = null,
	@Object_Name nvarchar(128) = null	
)
as
begin
	-- query optimization
	set nocount on

	-- Query
	select 
		EventDate, 
		server_instance_name, 
		database_principal_name, 
		database_name, 
		[schema_name], 
		[object_name], 
		ServerActionCount
	from aud.rptAggGeneralActionsByObject (NoLock)
	where
		EventDate >= @StartTime and EventDate <= @EndTime	-- time
		and (server_instance_name = @Instance_name or @Instance_name is null)
		and (database_name = @DB_Name or @DB_Name is null)
		and ([schema_name] = @Schema_Name or @Schema_Name is null)
		and ([object_name] = @Object_Name or @Object_Name is null)
		
end
GO
/****** Object:  StoredProcedure [aud].[uspAggGeneralActionsByClass]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [aud].[uspAggGeneralActionsByClass] (
	@StartTime smalldatetime, 
	@EndTime smalldatetime,
	@Instance_name nvarchar(128) = null, 
	@DB_Name nvarchar(128) = null, 
	@Class_Type nvarchar(128) = null,
	@Action_Name nvarchar(128) = null
)
as
begin
	-- query optimization
	set nocount on

	-- Query
	select 
		EventDate, 
		server_instance_name, 
		database_principal_name, 
		database_name, 
		action_name, 
		class_type_desc, 
		securable_class_desc,  
		ServerActionCount
	from aud.rptAggGeneralActionsByClass (NoLock)
	where
		EventDate >= @StartTime and EventDate <= @EndTime	-- time
		and (server_instance_name = @Instance_name or @Instance_name is null)
		and (database_name = @DB_Name or @DB_Name is null)
		and (class_type_desc = @Class_Type or @Class_Type is null)
		and (action_name = @Action_Name or @Action_Name is null)
end
GO
/****** Object:  StoredProcedure [aud].[uspAggDMLActionsByObject]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [aud].[uspAggDMLActionsByObject] (
	@StartTime smalldatetime, 
	@EndTime smalldatetime,
	@Instance_name nvarchar(128) = null, 
	@DB_Name nvarchar(128) = null, 
	@Schema_Name nvarchar(128) = null,
	@Object_Name nvarchar(128) = null	
)
as
begin
	-- query optimization
	set nocount on

	-- Query
	select 
		EventDate, 
		server_instance_name, 
		database_principal_name, 
		database_name, 
		[schema_name], 
		[object_name], 
		DMLActionCount
	from aud.rptAggDMLActionsByObject (NoLock)
	where
		EventDate >= @StartTime and EventDate <= @EndTime	-- time
		and (server_instance_name = @Instance_name or @Instance_name is null)
		and (database_name = @DB_Name or @DB_Name is null)
		and ([schema_name] = @Schema_Name or @Schema_Name is null)
		and ([object_name] = @Object_Name or @Object_Name is null)
		
end
GO
/****** Object:  StoredProcedure [aud].[uspAggDMLActionsByClass]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [aud].[uspAggDMLActionsByClass] (
	@StartTime smalldatetime, 
	@EndTime smalldatetime,
	@Instance_name nvarchar(128) = null, 
	@DB_Name nvarchar(128) = null, 
	@Class_Type nvarchar(128) = null,
	@Action_Name nvarchar(128) = null
)
as
begin
	-- query optimization
	set nocount on

	-- Query
	select 
		EventDate, 
		server_instance_name, 
		database_principal_name, 
		database_name, 
		action_name, 
		class_type_desc, 
		securable_class_desc,  
		DMLActionCount
	from aud.rptAggDMLActionsByClass (NoLock)
	where
		EventDate >= @StartTime and EventDate <= @EndTime	-- time
		and (server_instance_name = @Instance_name or @Instance_name is null)
		and (database_name = @DB_Name or @DB_Name is null)
		and (class_type_desc = @Class_Type or @Class_Type is null)
		and (action_name = @Action_Name or @Action_Name is null)
end
GO
/****** Object:  StoredProcedure [aud].[uspAggDDLActionsByObject]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [aud].[uspAggDDLActionsByObject] (
	@StartTime smalldatetime, 
	@EndTime smalldatetime,
	@Instance_name nvarchar(128) = null, 
	@DB_Name nvarchar(128) = null, 
	@Schema_Name nvarchar(128) = null,
	@Object_Name nvarchar(128) = null	
)
as
begin
	-- query optimization
	set nocount on

	-- Query
	select 
		EventDate, 
		server_instance_name, 
		database_principal_name, 
		database_name, 
		[schema_name], 
		[object_name], 
		DDLActionCount
	from aud.rptAggDDLActionsByObject (NoLock)
	where
		EventDate >= @StartTime and EventDate <= @EndTime	-- time
		and (server_instance_name = @Instance_name or @Instance_name is null)
		and (database_name = @DB_Name or @DB_Name is null)
		and ([schema_name] = @Schema_Name or @Schema_Name is null)
		and ([object_name] = @Object_Name or @Object_Name is null)
		
end
GO
/****** Object:  StoredProcedure [aud].[uspAggDDLActionsByClass]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [aud].[uspAggDDLActionsByClass] (
	@StartTime smalldatetime, 
	@EndTime smalldatetime,
	@Instance_name nvarchar(128) = null, 
	@DB_Name nvarchar(128) = null, 
	@Class_Type nvarchar(128) = null,
	@Action_Name nvarchar(128) = null
)
as
begin
	-- query optimization
	set nocount on

	-- Query
	select 
		EventDate, 
		server_instance_name, 
		database_principal_name, 
		database_name, 
		action_name, 
		class_type_desc, 
		securable_class_desc,  
		DDLActionCount
	from aud.rptAggDDLActionsByClass (NoLock)
	where
		EventDate >= @StartTime and EventDate <= @EndTime	-- time
		and (server_instance_name = @Instance_name or @Instance_name is null)
		and (database_name = @DB_Name or @DB_Name is null)
		and (class_type_desc = @Class_Type or @Class_Type is null)
		and (action_name = @Action_Name or @Action_Name is null)
end
GO
/****** Object:  StoredProcedure [aud].[uspAggDatabaseActionsByObject]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [aud].[uspAggDatabaseActionsByObject] (
	@StartTime smalldatetime, 
	@EndTime smalldatetime,
	@Instance_name nvarchar(128) = null, 
	@DB_Name nvarchar(128) = null, 
	@Schema_Name nvarchar(128) = null,
	@Object_Name nvarchar(128) = null	
)
as
begin
	-- query optimization
	set nocount on

	-- Query
	select 
		EventDate, 
		server_instance_name, 
		database_principal_name, 
		database_name, 
		[schema_name], 
		[object_name], 
		DatabaseActionCount
	from aud.rptAggDatabaseActionsByObject (NoLock)
	where
		EventDate >= @StartTime and EventDate <= @EndTime	-- time
		and (server_instance_name = @Instance_name or @Instance_name is null)
		and (database_name = @DB_Name or @DB_Name is null)
		and ([schema_name] = @Schema_Name or @Schema_Name is null)
		and ([object_name] = @Object_Name or @Object_Name is null)
		
end
GO
/****** Object:  StoredProcedure [aud].[uspAggDatabaseActionsByClass]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [aud].[uspAggDatabaseActionsByClass] (
	@StartTime smalldatetime, 
	@EndTime smalldatetime,
	@Instance_name nvarchar(128) = null, 
	@DB_Name nvarchar(128) = null, 
	@Class_Type nvarchar(128) = null,
	@Action_Name nvarchar(128) = null
)
as
begin
	-- query optimization
	set nocount on

	-- Query
	select 
		EventDate, 
		server_instance_name, 
		database_principal_name, 
		database_name, 
		action_name, 
		class_type_desc, 
		securable_class_desc,  
		DatabaseActionCount
	from aud.rptAggDatabaseActionsByClass (NoLock)
	where
		EventDate >= @StartTime and EventDate <= @EndTime	-- time
		and (server_instance_name = @Instance_name or @Instance_name is null)
		and (database_name = @DB_Name or @DB_Name is null)
		and (class_type_desc = @Class_Type or @Class_Type is null)
		and (action_name = @Action_Name or @Action_Name is null)
end
GO
/****** Object:  Table [aud].[AuditLog_ServerActions]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[AuditLog_ServerActions](
	[event_time] [datetime2](7) NOT NULL,
	[sequence_number] [int] NOT NULL,
	[audited_action_id] [int] NOT NULL,
	[audited_class_type_id] [int] NULL,
	[server_principal_name_id] [int] NULL,
	[session_server_principal_name_id] [int] NULL,
	[target_server_principal_name_id] [int] NULL,
	[database_principal_name_id] [int] NULL,
	[target_database_principal_name_id] [int] NULL,
	[audited_object_id] [int] NULL,
	[succeeded] [bit] NULL,
	[permission_bitmask] [bigint] NULL,
	[is_column_permission] [bit] NULL,
	[session_id] [smallint] NULL,
	[statement_id] [int] NULL,
	[additional_information] [nvarchar](4000) NULL,
	[audit_file_offset] [bigint] NULL,
	[import_id] [int] NULL,
	[audit_file_id] [int] NOT NULL,
	[client_address_id] [int] NULL,
	[pooled_connection] [bit] NULL,
	[packet_data_size] [int] NULL,
	[is_dac] [bit] NULL,
	[total_cpu] [int] NULL,
	[reads] [int] NULL,
	[writes] [int] NULL,
	[event_count] [int] NULL
) ON [monthly_partition_scheme]([event_time])
GO
CREATE CLUSTERED INDEX [cidx_auditlog_ServerActions] ON [aud].[AuditLog_ServerActions] 
(
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_aucited_action_id] ON [aud].[AuditLog_ServerActions] 
(
	[audited_action_id] ASC
)
INCLUDE ( [event_time],
[audited_class_type_id],
[server_principal_name_id],
[database_principal_name_id],
[audited_object_id],
[statement_id],
[client_address_id],
[event_count]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_ServerActions_2] ON [aud].[AuditLog_ServerActions] 
(
	[audited_action_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_ServerActions_3] ON [aud].[AuditLog_ServerActions] 
(
	[audited_class_type_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_ServerActions_4] ON [aud].[AuditLog_ServerActions] 
(
	[server_principal_name_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_serveractions_5] ON [aud].[AuditLog_ServerActions] 
(
	[session_server_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([session_server_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_serveractions_6] ON [aud].[AuditLog_ServerActions] 
(
	[target_server_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([target_server_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_ServerActions_7] ON [aud].[AuditLog_ServerActions] 
(
	[database_principal_name_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_serveractions_8] ON [aud].[AuditLog_ServerActions] 
(
	[target_database_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([target_database_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_serveractions_9] ON [aud].[AuditLog_ServerActions] 
(
	[statement_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
/****** Object:  Table [aud].[AuditLog_GeneralActions]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[AuditLog_GeneralActions](
	[event_time] [datetime2](7) NOT NULL,
	[sequence_number] [int] NOT NULL,
	[audited_action_id] [int] NOT NULL,
	[audited_class_type_id] [int] NULL,
	[server_principal_name_id] [int] NULL,
	[session_server_principal_name_id] [int] NULL,
	[target_server_principal_name_id] [int] NULL,
	[database_principal_name_id] [int] NULL,
	[target_database_principal_name_id] [int] NULL,
	[audited_object_id] [int] NULL,
	[succeeded] [bit] NULL,
	[permission_bitmask] [bigint] NULL,
	[is_column_permission] [bit] NULL,
	[session_id] [smallint] NULL,
	[statement_id] [int] NULL,
	[additional_information] [nvarchar](4000) NULL,
	[audit_file_offset] [bigint] NULL,
	[import_id] [int] NULL,
	[audit_file_id] [int] NOT NULL,
	[client_address_id] [int] NULL,
	[pooled_connection] [bit] NULL,
	[packet_data_size] [int] NULL,
	[is_dac] [bit] NULL,
	[total_cpu] [int] NULL,
	[reads] [int] NULL,
	[writes] [int] NULL,
	[event_count] [int] NULL
) ON [monthly_partition_scheme]([event_time])
GO
CREATE CLUSTERED INDEX [cidx_auditlog_GeneralActions] ON [aud].[AuditLog_GeneralActions] 
(
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_aucited_action_id] ON [aud].[AuditLog_GeneralActions] 
(
	[audited_action_id] ASC
)
INCLUDE ( [event_time],
[audited_class_type_id],
[server_principal_name_id],
[database_principal_name_id],
[audited_object_id],
[statement_id],
[client_address_id],
[event_count]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_GeneralActions_2] ON [aud].[AuditLog_GeneralActions] 
(
	[audited_action_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_GeneralActions_3] ON [aud].[AuditLog_GeneralActions] 
(
	[audited_class_type_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_GeneralActions_4] ON [aud].[AuditLog_GeneralActions] 
(
	[server_principal_name_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_GeneralActions_5] ON [aud].[AuditLog_GeneralActions] 
(
	[session_server_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([session_server_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_GeneralActions_6] ON [aud].[AuditLog_GeneralActions] 
(
	[target_server_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([target_server_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_GeneralActions_7] ON [aud].[AuditLog_GeneralActions] 
(
	[database_principal_name_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_GeneralActions_8] ON [aud].[AuditLog_GeneralActions] 
(
	[target_database_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([target_database_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_GeneralActions_9] ON [aud].[AuditLog_GeneralActions] 
(
	[statement_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
/****** Object:  Table [aud].[AuditLog_DMLActions]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[AuditLog_DMLActions](
	[event_time] [datetime2](7) NOT NULL,
	[sequence_number] [int] NOT NULL,
	[audited_action_id] [int] NOT NULL,
	[audited_class_type_id] [int] NULL,
	[server_principal_name_id] [int] NULL,
	[session_server_principal_name_id] [int] NULL,
	[target_server_principal_name_id] [int] NULL,
	[database_principal_name_id] [int] NULL,
	[target_database_principal_name_id] [int] NULL,
	[audited_object_id] [int] NULL,
	[succeeded] [bit] NULL,
	[permission_bitmask] [bigint] NULL,
	[is_column_permission] [bit] NULL,
	[session_id] [smallint] NULL,
	[statement_id] [int] NULL,
	[additional_information] [nvarchar](4000) NULL,
	[audit_file_offset] [bigint] NULL,
	[import_id] [int] NULL,
	[audit_file_id] [int] NOT NULL,
	[client_address_id] [int] NULL,
	[pooled_connection] [bit] NULL,
	[packet_data_size] [int] NULL,
	[is_dac] [bit] NULL,
	[total_cpu] [int] NULL,
	[reads] [int] NULL,
	[writes] [int] NULL,
	[event_count] [int] NULL
) ON [monthly_partition_scheme]([event_time])
GO
CREATE CLUSTERED INDEX [cidx_auditlog_DMLActions] ON [aud].[AuditLog_DMLActions] 
(
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_aucited_action_id] ON [aud].[AuditLog_DMLActions] 
(
	[audited_action_id] ASC
)
INCLUDE ( [event_time],
[audited_class_type_id],
[server_principal_name_id],
[database_principal_name_id],
[audited_object_id],
[statement_id],
[client_address_id],
[event_count]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_DMLActions_2] ON [aud].[AuditLog_DMLActions] 
(
	[audited_action_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_DMLActions_3] ON [aud].[AuditLog_DMLActions] 
(
	[audited_class_type_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_DMLActions_4] ON [aud].[AuditLog_DMLActions] 
(
	[server_principal_name_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_dmlactions_5] ON [aud].[AuditLog_DMLActions] 
(
	[session_server_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([session_server_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_dmlactions_6] ON [aud].[AuditLog_DMLActions] 
(
	[target_server_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([target_server_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_DMLActions_7] ON [aud].[AuditLog_DMLActions] 
(
	[database_principal_name_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_dmlactions_8] ON [aud].[AuditLog_DMLActions] 
(
	[target_database_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([target_database_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_dmlactions_9] ON [aud].[AuditLog_DMLActions] 
(
	[statement_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
/****** Object:  Table [aud].[AuditLog_DDLActions]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[AuditLog_DDLActions](
	[event_time] [datetime2](7) NOT NULL,
	[sequence_number] [int] NOT NULL,
	[audited_action_id] [int] NOT NULL,
	[audited_class_type_id] [int] NULL,
	[server_principal_name_id] [int] NULL,
	[session_server_principal_name_id] [int] NULL,
	[target_server_principal_name_id] [int] NULL,
	[database_principal_name_id] [int] NULL,
	[target_database_principal_name_id] [int] NULL,
	[audited_object_id] [int] NULL,
	[succeeded] [bit] NULL,
	[permission_bitmask] [bigint] NULL,
	[is_column_permission] [bit] NULL,
	[session_id] [smallint] NULL,
	[statement_id] [int] NULL,
	[additional_information] [nvarchar](4000) NULL,
	[audit_file_offset] [bigint] NULL,
	[import_id] [int] NULL,
	[audit_file_id] [int] NOT NULL,
	[client_address_id] [int] NULL,
	[pooled_connection] [bit] NULL,
	[packet_data_size] [int] NULL,
	[is_dac] [bit] NULL,
	[total_cpu] [int] NULL,
	[reads] [int] NULL,
	[writes] [int] NULL,
	[event_count] [int] NULL
) ON [monthly_partition_scheme]([event_time])
GO
CREATE CLUSTERED INDEX [cidx_auditlog_DDLActions] ON [aud].[AuditLog_DDLActions] 
(
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_aucited_action_id] ON [aud].[AuditLog_DDLActions] 
(
	[audited_action_id] ASC
)
INCLUDE ( [event_time],
[audited_class_type_id],
[server_principal_name_id],
[database_principal_name_id],
[audited_object_id],
[statement_id],
[client_address_id],
[event_count]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_DDLActions_2] ON [aud].[AuditLog_DDLActions] 
(
	[audited_action_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_DDLActions_3] ON [aud].[AuditLog_DDLActions] 
(
	[audited_class_type_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_DDLActions_4] ON [aud].[AuditLog_DDLActions] 
(
	[server_principal_name_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_ddlactions_5] ON [aud].[AuditLog_DDLActions] 
(
	[session_server_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([session_server_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_ddlactions_6] ON [aud].[AuditLog_DDLActions] 
(
	[target_server_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([target_server_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_DDLActions_7] ON [aud].[AuditLog_DDLActions] 
(
	[database_principal_name_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_ddlactions_8] ON [aud].[AuditLog_DDLActions] 
(
	[target_database_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([target_database_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_ddlactions_9] ON [aud].[AuditLog_DDLActions] 
(
	[statement_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
/****** Object:  Table [aud].[AuditLog_DatabaseActions]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[AuditLog_DatabaseActions](
	[event_time] [datetime2](7) NOT NULL,
	[sequence_number] [int] NOT NULL,
	[audited_action_id] [int] NOT NULL,
	[audited_class_type_id] [int] NULL,
	[server_principal_name_id] [int] NULL,
	[session_server_principal_name_id] [int] NULL,
	[target_server_principal_name_id] [int] NULL,
	[database_principal_name_id] [int] NULL,
	[target_database_principal_name_id] [int] NULL,
	[audited_object_id] [int] NULL,
	[succeeded] [bit] NULL,
	[permission_bitmask] [bigint] NULL,
	[is_column_permission] [bit] NULL,
	[session_id] [smallint] NULL,
	[statement_id] [int] NULL,
	[additional_information] [nvarchar](4000) NULL,
	[audit_file_offset] [bigint] NULL,
	[import_id] [int] NULL,
	[audit_file_id] [int] NOT NULL,
	[client_address_id] [int] NULL,
	[pooled_connection] [bit] NULL,
	[packet_data_size] [int] NULL,
	[is_dac] [bit] NULL,
	[total_cpu] [int] NULL,
	[reads] [int] NULL,
	[writes] [int] NULL,
	[event_count] [int] NULL
) ON [monthly_partition_scheme]([event_time])
GO
CREATE CLUSTERED INDEX [cidx_auditlog_databaseactions] ON [aud].[AuditLog_DatabaseActions] 
(
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_databaseactions_2] ON [aud].[AuditLog_DatabaseActions] 
(
	[audited_action_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_databaseactions_3] ON [aud].[AuditLog_DatabaseActions] 
(
	[audited_class_type_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_databaseactions_4] ON [aud].[AuditLog_DatabaseActions] 
(
	[server_principal_name_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_databaseactions_5] ON [aud].[AuditLog_DatabaseActions] 
(
	[session_server_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([session_server_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_databaseactions_6] ON [aud].[AuditLog_DatabaseActions] 
(
	[target_server_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([target_server_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_databaseactions_7] ON [aud].[AuditLog_DatabaseActions] 
(
	[database_principal_name_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_databaseactions_8] ON [aud].[AuditLog_DatabaseActions] 
(
	[target_database_principal_name_id] ASC,
	[event_time] ASC
)
WHERE ([target_database_principal_name_id]<>(1))
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
CREATE NONCLUSTERED INDEX [idx_auditlog_databaseactions_9] ON [aud].[AuditLog_DatabaseActions] 
(
	[statement_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
/****** Object:  Table [aud].[StatementWorkTable]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [aud].[StatementWorkTable](
	[statement_id] [int] NOT NULL,
	[event_time] [datetime2](7) NOT NULL,
	[statement] [nvarchar](4000) NULL,
 CONSTRAINT [pk_StatementWorkTable] PRIMARY KEY CLUSTERED 
(
	[statement_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
) ON [monthly_partition_scheme]([event_time])
GO
/****** Object:  Table [aud].[Statement]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [aud].[Statement](
	[statement_id] [int] IDENTITY(1,1) NOT NULL,
	[event_time] [datetime2](7) NOT NULL,
	[statement_hash] [binary](64) NULL,
	[statement_tail] [nvarchar](400) NULL,
	[statement] [nvarchar](4000) NULL,
 CONSTRAINT [statement_pk] PRIMARY KEY NONCLUSTERED 
(
	[statement_id] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
) ON [monthly_partition_scheme]([event_time])
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE CLUSTERED INDEX [cuidx_statement_1] ON [aud].[Statement] 
(
	[statement_hash] ASC,
	[statement_tail] ASC,
	[event_time] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [monthly_partition_scheme]([event_time])
GO
/****** Object:  StoredProcedure [aud].[uspImportedFileGetLastImportedOffset]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[uspImportedFileGetLastImportedOffset]
@file_name NVARCHAR (260), @file_offset BIGINT OUTPUT
AS
select @file_name = RTRIM(ltrim(@file_name))

declare @audit_guid uniqueidentifier
		, @audit_file_timestamp bigint
		, @audit_file_name_trimmed nvarchar(260)

select @audit_guid  = audit_guid
		, @audit_file_timestamp = audit_file_timestamp
		, @audit_file_name_trimmed = audit_file_name_trimmed
	  from aud.fn_GetAuditFileInfo(@file_name)


if exists(
	select top 1 1 
	  from aud.AuditFile
	 where audit_guid = @audit_guid
	   and audit_file_timestamp > @audit_file_timestamp
	   )
	   and exists (
	   select top 1 1 
	     from aud.AuditFile
	    where audit_file_name_trimmed = @audit_file_name_trimmed
	    )
begin
	SELECT @file_offset = -1
end
else
begin
	SELECT @file_offset = isnull(max(audit_file_offset_max), 0)
	  FROM aud.ImportedFile
	 WHERE file_name = @file_name
end
GO
/****** Object:  StoredProcedure [aud].[uspUpdateStatementEventTimes]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[uspUpdateStatementEventTimes]

AS
declare @min_event_time datetime2(7)
		, @max_event_time datetime2(7);

with first_range_cte as (
select top 2 prv.value
  from sys.partition_range_values prv
  join sys.partition_functions pf
    on prv.function_id = pf.function_id
 where name = 'monthly_partition_function'
 order by value
)
select @min_event_time = MIN(cast(value as datetime2(7))), @max_event_time = MAX(cast(value as datetime2(7))) from first_range_cte;
 


with statements_cte as (
select statement_id, event_time
  from aud.Statement
 where event_time between @min_event_time and @max_event_time
 )
update s
   set event_time = act.event_time
  from statements_cte s
  join (
	select statement_id, event_time = MAX(event_time)
	  from (
		select act.statement_id, event_time = MAX(act.event_time)
		  from aud.AuditLog_ServerActions act
		  join statements_cte 
			on act.statement_id = statements_cte.statement_id
		  group by act.statement_id
		UNION  
		select act.statement_id, event_time = MAX(act.event_time)
		  from aud.AuditLog_DatabaseActions act
		  join statements_cte 
			on act.statement_id = statements_cte.statement_id
		  group by act.statement_id
		UNION  
		select act.statement_id, event_time = MAX(act.event_time)
		  from aud.AuditLog_DDLActions act
		  join statements_cte 
			on act.statement_id = statements_cte.statement_id
		  group by act.statement_id
		UNION  
		select act.statement_id, event_time = MAX(act.event_time)
		  from aud.AuditLog_DMLActions act
		  join statements_cte 
			on act.statement_id = statements_cte.statement_id
		  group by act.statement_id
	  ) act
	  group by act.statement_id
	 ) act
	on s.statement_id = act.statement_id
GO
/****** Object:  View [aud].[vw_AuditLog_ServerActions]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [aud].[vw_AuditLog_ServerActions]
as
select 
	f.event_time,
	f.sequence_number,
	--f.audited_action_id,
	a.action_id,
	a.action_name,
	--f.audited_class_type_id,
	b.class_type_desc, 
	b.securable_class_desc,
	--f.server_principal_name_id,
	c.server_principal_name,
	--f.session_server_principal_name_id,
	d.server_principal_name as session_server_principal_name,
	--f.target_server_principal_name_id,
	e.server_principal_name as target_server_principal_name,
	--f.database_principal_name_id,
	g.database_principal_name,
	--f.target_database_principal_name_id,
	h.database_principal_name as target_database_principal_name,
	--f.audited_object_id,
	i.server_instance_name, 
	i.database_name, 
	i.[schema_name], 
	i.[object_name],
	f.succeeded,
	f.permission_bitmask,
	f.is_column_permission,
	f.session_id,
	s.[statement],
	f.additional_information,
	f.audit_file_offset,
	f.import_id,
	f.audit_file_id,
	--f.client_address_id,
	j.client_address,
	f.pooled_connection,
	f.packet_data_size,
	f.is_dac,
	f.total_cpu,
	f.reads,
	f.writes
from [aud].[AuditLog_ServerActions] f
	left outer join aud.auditedAction a
		on a.audited_action_id = f.audited_action_id
	left outer join aud.AuditedClassType b
		on b.audited_class_type_id = f.audited_class_type_id
	left outer join aud.ServerPrincipalName c
		on c.server_principal_name_id = f.server_principal_name_id
	left outer join aud.ServerPrincipalName d
		on d.server_principal_name_id = f.session_server_principal_name_id
	left outer join aud.ServerPrincipalName e
		on e.server_principal_name_id = f.target_server_principal_name_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = f.database_principal_name_id 
	left outer join aud.DatabasePrincipalName h
		on g.database_principal_name_id = f.target_database_principal_name_id 
	left outer join aud.AuditedObject i
		on i.audited_object_id = f.audited_object_id
	left outer join aud.ClientAddress j
		on j.client_address_id = f.client_address_id
	left outer join aud.[Statement] s
		on s.statement_id = f.statement_id
GO
/****** Object:  View [aud].[vw_AuditLog_GeneralActions]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [aud].[vw_AuditLog_GeneralActions]
as
select 
	f.event_time,
	f.sequence_number,
	--f.audited_action_id,
	a.action_id,
	a.action_name,
	--f.audited_class_type_id,
	b.class_type_desc, 
	b.securable_class_desc,
	--f.server_principal_name_id,
	c.server_principal_name,
	--f.session_server_principal_name_id,
	d.server_principal_name as session_server_principal_name,
	--f.target_server_principal_name_id,
	e.server_principal_name as target_server_principal_name,
	--f.database_principal_name_id,
	g.database_principal_name,
	--f.target_database_principal_name_id,
	h.database_principal_name as target_database_principal_name,
	--f.audited_object_id,
	i.server_instance_name, 
	i.database_name, 
	i.[schema_name], 
	i.[object_name],
	f.succeeded,
	f.permission_bitmask,
	f.is_column_permission,
	f.session_id,
	s.[statement],
	f.additional_information,
	f.audit_file_offset,
	f.import_id,
	f.audit_file_id,
	--f.client_address_id,
	j.client_address,
	f.pooled_connection,
	f.packet_data_size,
	f.is_dac,
	f.total_cpu,
	f.reads,
	f.writes
from [aud].[AuditLog_GeneralActions] f
	left outer join aud.auditedAction a
		on a.audited_action_id = f.audited_action_id
	left outer join aud.AuditedClassType b
		on b.audited_class_type_id = f.audited_class_type_id
	left outer join aud.ServerPrincipalName c
		on c.server_principal_name_id = f.server_principal_name_id
	left outer join aud.ServerPrincipalName d
		on d.server_principal_name_id = f.session_server_principal_name_id
	left outer join aud.ServerPrincipalName e
		on e.server_principal_name_id = f.target_server_principal_name_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = f.database_principal_name_id 
	left outer join aud.DatabasePrincipalName h
		on g.database_principal_name_id = f.target_database_principal_name_id 
	left outer join aud.AuditedObject i
		on i.audited_object_id = f.audited_object_id
	left outer join aud.ClientAddress j
		on j.client_address_id = f.client_address_id
	left outer join aud.[Statement] s
		on s.statement_id = f.statement_id
GO
/****** Object:  View [aud].[vw_AuditLog_DMLActions]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [aud].[vw_AuditLog_DMLActions]
as
select 
	f.event_time,
	f.sequence_number,
	--f.audited_action_id,
	a.action_id,
	a.action_name,
	--f.audited_class_type_id,
	b.class_type_desc, 
	b.securable_class_desc,
	--f.server_principal_name_id,
	c.server_principal_name,
	--f.session_server_principal_name_id,
	d.server_principal_name as session_server_principal_name,
	--f.target_server_principal_name_id,
	e.server_principal_name as target_server_principal_name,
	--f.database_principal_name_id,
	g.database_principal_name,
	--f.target_database_principal_name_id,
	h.database_principal_name as target_database_principal_name,
	--f.audited_object_id,
	i.server_instance_name, 
	i.database_name, 
	i.[schema_name], 
	i.[object_name],
	f.succeeded,
	f.permission_bitmask,
	f.is_column_permission,
	f.session_id,
	s.[statement],
	f.additional_information,
	f.audit_file_offset,
	f.import_id,
	f.audit_file_id,
	--f.client_address_id,
	j.client_address,
	f.pooled_connection,
	f.packet_data_size,
	f.is_dac,
	f.total_cpu,
	f.reads,
	f.writes
from [aud].[AuditLog_DMLActions] f
	left outer join aud.auditedAction a
		on a.audited_action_id = f.audited_action_id
	left outer join aud.AuditedClassType b
		on b.audited_class_type_id = f.audited_class_type_id
	left outer join aud.ServerPrincipalName c
		on c.server_principal_name_id = f.server_principal_name_id
	left outer join aud.ServerPrincipalName d
		on d.server_principal_name_id = f.session_server_principal_name_id
	left outer join aud.ServerPrincipalName e
		on e.server_principal_name_id = f.target_server_principal_name_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = f.database_principal_name_id 
	left outer join aud.DatabasePrincipalName h
		on g.database_principal_name_id = f.target_database_principal_name_id 
	left outer join aud.AuditedObject i
		on i.audited_object_id = f.audited_object_id
	left outer join aud.ClientAddress j
		on j.client_address_id = f.client_address_id
	left outer join aud.[Statement] s
		on s.statement_id = f.statement_id
GO
/****** Object:  View [aud].[vw_AuditLog_DDLActions]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [aud].[vw_AuditLog_DDLActions]
as
select 
	f.event_time,
	f.sequence_number,
	--f.audited_action_id,
	a.action_id,
	a.action_name,
	--f.audited_class_type_id,
	b.class_type_desc, 
	b.securable_class_desc,
	--f.server_principal_name_id,
	c.server_principal_name,
	--f.session_server_principal_name_id,
	d.server_principal_name as session_server_principal_name,
	--f.target_server_principal_name_id,
	e.server_principal_name as target_server_principal_name,
	--f.database_principal_name_id,
	g.database_principal_name,
	--f.target_database_principal_name_id,
	h.database_principal_name as target_database_principal_name,
	--f.audited_object_id,
	i.server_instance_name, 
	i.database_name, 
	i.[schema_name], 
	i.[object_name],
	f.succeeded,
	f.permission_bitmask,
	f.is_column_permission,
	f.session_id,
	s.[statement],
	f.additional_information,
	f.audit_file_offset,
	f.import_id,
	f.audit_file_id,
	--f.client_address_id,
	j.client_address,
	f.pooled_connection,
	f.packet_data_size,
	f.is_dac,
	f.total_cpu,
	f.reads,
	f.writes
from [aud].[AuditLog_DDLActions] f
	left outer join aud.auditedAction a
		on a.audited_action_id = f.audited_action_id
	left outer join aud.AuditedClassType b
		on b.audited_class_type_id = f.audited_class_type_id
	left outer join aud.ServerPrincipalName c
		on c.server_principal_name_id = f.server_principal_name_id
	left outer join aud.ServerPrincipalName d
		on d.server_principal_name_id = f.session_server_principal_name_id
	left outer join aud.ServerPrincipalName e
		on e.server_principal_name_id = f.target_server_principal_name_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = f.database_principal_name_id 
	left outer join aud.DatabasePrincipalName h
		on g.database_principal_name_id = f.target_database_principal_name_id 
	left outer join aud.AuditedObject i
		on i.audited_object_id = f.audited_object_id
	left outer join aud.ClientAddress j
		on j.client_address_id = f.client_address_id
	left outer join aud.[Statement] s
		on s.statement_id = f.statement_id
GO
/****** Object:  View [aud].[vw_AuditLog_DatabaseActions]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [aud].[vw_AuditLog_DatabaseActions]
as
select 
	f.event_time,
	f.sequence_number,
	--f.audited_action_id,
	a.action_id,
	a.action_name,
	--f.audited_class_type_id,
	b.class_type_desc, 
	b.securable_class_desc,
	--f.server_principal_name_id,
	c.server_principal_name,
	--f.session_server_principal_name_id,
	d.server_principal_name as session_server_principal_name,
	--f.target_server_principal_name_id,
	e.server_principal_name as target_server_principal_name,
	--f.database_principal_name_id,
	g.database_principal_name,
	--f.target_database_principal_name_id,
	h.database_principal_name as target_database_principal_name,
	--f.audited_object_id,
	i.server_instance_name, 
	i.database_name, 
	i.[schema_name], 
	i.[object_name],
	f.succeeded,
	f.permission_bitmask,
	f.is_column_permission,
	f.session_id,
	s.[statement],
	f.additional_information,
	f.audit_file_offset,
	f.import_id,
	f.audit_file_id,
	--f.client_address_id,
	j.client_address,
	f.pooled_connection,
	f.packet_data_size,
	f.is_dac,
	f.total_cpu,
	f.reads,
	f.writes
from [aud].[AuditLog_DatabaseActions] f
	left outer join aud.auditedAction a
		on a.audited_action_id = f.audited_action_id
	left outer join aud.AuditedClassType b
		on b.audited_class_type_id = f.audited_class_type_id
	left outer join aud.ServerPrincipalName c
		on c.server_principal_name_id = f.server_principal_name_id
	left outer join aud.ServerPrincipalName d
		on d.server_principal_name_id = f.session_server_principal_name_id
	left outer join aud.ServerPrincipalName e
		on e.server_principal_name_id = f.target_server_principal_name_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = f.database_principal_name_id 
	left outer join aud.DatabasePrincipalName h
		on g.database_principal_name_id = f.target_database_principal_name_id 
	left outer join aud.AuditedObject i
		on i.audited_object_id = f.audited_object_id
	left outer join aud.ClientAddress j
		on j.client_address_id = f.client_address_id
	left outer join aud.[Statement] s
		on s.statement_id = f.statement_id
GO
/****** Object:  StoredProcedure [aud].[uspListServerActionsByPrincipal]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListServerActionsByPrincipal]  
@Instance_name nvarchar(128), @Principal_name nvarchar(128), @StartTime smalldatetime, @EndTime smalldatetime
AS

/*
List Server Actions by Instance and Principal name

*/
     
Declare @pString nvarchar(128)
Declare @TimeDiff int

Set @pString = '%'+@Principal_name+'%'

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())
     
SELECT S1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,S1.event_time) AS event_time, 
A.action_name, C1.class_type_desc, O.database_name, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, S3.statement
FROM aud.auditlog_Serveractions S1 
join aud.auditedAction A on S1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on S1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on S1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on S1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on S1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on S1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S3 on S1.statement_id = S3.statement_id
Where O.server_instance_name = @Instance_name AND S2.Server_principal_name LIKE @pString
AND DATEADD(hh,@TimeDiff,S1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,S1.event_time) <= @EndTime
order by S1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListServerActionsByInstance]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListServerActionsByInstance]  
@Instance_name nvarchar(128), @StartTime smalldatetime, @EndTime smalldatetime
AS

/*
List Server Actions by Instance 

*/
     
Declare @TimeDiff int

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())
     
SELECT S1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,S1.event_time) AS event_time, 
A.action_name, C1.class_type_desc, O.database_name, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S3.statement
FROM aud.auditlog_Serveractions S1 
join aud.auditedAction A on S1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on S1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on S1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on S1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on S1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on S1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S3 on S1.statement_id = S3.statement_id
Where O.server_instance_name = @Instance_name 
AND DATEADD(hh,@TimeDiff,S1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,S1.event_time) <= @EndTime
order by S1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListServerActionsByDatabase]    Script Date: 09/29/2011 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListServerActionsByDatabase]  
@Instance_name nvarchar(128), @DB_Name nvarchar(128), @StartTime smalldatetime, @EndTime smalldatetime
AS

/*

List Server Actions by Instance and Database name

*/
     
Declare @TimeDiff int

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())
     
SELECT S1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,S1.event_time) AS event_time, 
A.action_name, C1.class_type_desc, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S3.statement
FROM aud.auditlog_Serveractions S1 
join aud.auditedAction A on S1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on S1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on S1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on S1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on S1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on S1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S3 on S1.statement_id = S3.statement_id
Where O.server_instance_name = @Instance_name AND o.database_name = @DB_Name
AND DATEADD(hh,@TimeDiff,S1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,S1.event_time) <= @EndTime
order by S1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListServerActionsByActions]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListServerActionsByActions]
     @Instance_name nvarchar(128), @DB_Name nvarchar(128) = NULL, @EventDate smalldatetime,
     @Action_name nvarchar(128) = NULL, @Class_type nvarchar(128)= NULL
AS

/*

List Server Actions

*/
     
Declare @TimeDiff int

--Get the local time difference from UTC
Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())


IF @Class_type IS NULL AND @Action_name is NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_ServerActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate

	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_ServerActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name 
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND C1.class_type_desc = @Class_type
	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NOT NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_ServerActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND A.action_name = @Action_name AND C1.class_type_desc = @Class_type
	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NOT NULL AND @DB_Name IS NOT NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_ServerActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name 
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND A.action_name = @Action_name AND C1.class_type_desc = @Class_type AND O.database_name = @DB_Name
	Order by D1.event_time
End
GO
/****** Object:  StoredProcedure [aud].[uspListGeneralActionsByPrincipal]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListGeneralActionsByPrincipal]  
@Instance_name nvarchar(128), @Principal_name nvarchar(128), @StartTime smalldatetime, @EndTime smalldatetime
AS

/*
List Server Actions by Instance and Principal name

*/
     
Declare @pString nvarchar(128)
Declare @TimeDiff int

Set @pString = '%'+@Principal_name+'%'

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())
     
SELECT S1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,S1.event_time) AS event_time, 
A.action_name, C1.class_type_desc, O.database_name, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, S3.statement
FROM aud.auditlog_GeneralActions S1 
join aud.auditedAction A on S1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on S1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on S1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on S1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on S1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on S1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S3 on S1.statement_id = S3.statement_id
Where O.server_instance_name = @Instance_name AND S2.Server_principal_name LIKE @pString
AND DATEADD(hh,@TimeDiff,S1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,S1.event_time) <= @EndTime
order by S1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListGeneralActionsByInstance]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListGeneralActionsByInstance]  
@Instance_name nvarchar(128), @StartTime smalldatetime, @EndTime smalldatetime
AS

/*
List Server Actions by Instance 

*/
     
Declare @TimeDiff int

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())
     
SELECT S1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,S1.event_time) AS event_time, 
A.action_name, C1.class_type_desc, O.database_name, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S3.statement
FROM aud.auditlog_GeneralActions S1 
join aud.auditedAction A on S1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on S1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on S1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on S1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on S1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on S1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S3 on S1.statement_id = S3.statement_id
Where O.server_instance_name = @Instance_name 
AND DATEADD(hh,@TimeDiff,S1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,S1.event_time) <= @EndTime
order by S1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListGeneralActionsByDatabase]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListGeneralActionsByDatabase]  
@Instance_name nvarchar(128), @DB_Name nvarchar(128), @StartTime smalldatetime, @EndTime smalldatetime
AS

/*

List Server Actions by Instance and Database name

*/
     
Declare @TimeDiff int

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())
     
SELECT S1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,S1.event_time) AS event_time, 
A.action_name, C1.class_type_desc, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S3.statement
FROM aud.auditlog_GeneralActions S1 
join aud.auditedAction A on S1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on S1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on S1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on S1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on S1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on S1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S3 on S1.statement_id = S3.statement_id
Where O.server_instance_name = @Instance_name AND o.database_name = @DB_Name
AND DATEADD(hh,@TimeDiff,S1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,S1.event_time) <= @EndTime
order by S1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListGeneralActionsByActions]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListGeneralActionsByActions]
     @Instance_name nvarchar(128), @DB_Name nvarchar(128) = NULL, @EventDate smalldatetime,
     @Action_name nvarchar(128) = NULL, @Class_type nvarchar(128)= NULL
AS

/*

List Server Actions

*/
     
Declare @TimeDiff int

--Get the local time difference from UTC
Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())


IF @Class_type IS NULL AND @Action_name is NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_GeneralActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate

	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_GeneralActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name 
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND C1.class_type_desc = @Class_type
	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NOT NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_GeneralActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND A.action_name = @Action_name AND C1.class_type_desc = @Class_type
	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NOT NULL AND @DB_Name IS NOT NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_GeneralActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name 
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND A.action_name = @Action_name AND C1.class_type_desc = @Class_type AND O.database_name = @DB_Name
	Order by D1.event_time
End
GO
/****** Object:  StoredProcedure [aud].[uspListDMLActionsByPrincipal]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [aud].[uspListDMLActionsByPrincipal]
     @Instance_name nvarchar(128), @Principal_name nvarchar(128) , @StartTime smalldatetime, @EndTime smalldatetime
AS

/*

List DML Actions by Instance by Principal

*/

Declare @pString nvarchar(130)
     
Declare @TimeDiff int

Set @pString = '%'+@Principal_name+'%'

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())

SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc,  O.database_name, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S1.statement
FROM aud.AuditLog_DMLActions D1 
join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S1 on D1.statement_id = S1.statement_id
Where O.server_instance_name = @Instance_name AND S2.server_principal_name LIKE @pString
    AND DATEADD(hh,@TimeDiff,D1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,D1.event_time) <= @EndTime
Order by D1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListDMLActionsByInstance]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [aud].[uspListDMLActionsByInstance]
     @Instance_name nvarchar(128), @StartTime smalldatetime, @EndTime smalldatetime
AS

/*

List DML Actions by Instance

*/
     
Declare @iString nvarchar(128)
Declare @TimeDiff int

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())

SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.database_name, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S1.statement
FROM aud.AuditLog_DMLActions D1 
join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S1 on D1.statement_id = S1.statement_id
Where O.server_instance_name = @Instance_name 
    AND DATEADD(hh,@TimeDiff,D1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,D1.event_time) <= @EndTime
Order by D1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListDMLActionsByDatabase]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [aud].[uspListDMLActionsByDatabase]
     @Instance_name nvarchar(128), @DB_Name nvarchar(128) , @StartTime smalldatetime, @EndTime smalldatetime
AS

/*

List DML Actions by Instance by Database

*/
     
Declare @TimeDiff int

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())

SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S1.statement
FROM aud.AuditLog_DMLActions D1 
join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S1 on D1.statement_id = S1.statement_id
Where O.server_instance_name = @Instance_name AND O.database_name = @DB_Name
    AND DATEADD(hh,@TimeDiff,D1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,D1.event_time) <= @EndTime
Order by D1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListDMLActionsByActions]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListDMLActionsByActions]
     @Instance_name nvarchar(128), @DB_Name nvarchar(128) = NULL, @EventDate smalldatetime,
     @Action_name nvarchar(128) = NULL, @Class_type nvarchar(128)= NULL
AS

/*

List DML Actions

*/
     
Declare @TimeDiff int

--Get the local time difference from UTC
Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())


IF @Class_type IS NULL AND @Action_name is NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DMLActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate

	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DMLActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name 
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND C1.class_type_desc = @Class_type
	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NOT NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DMLActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND A.action_name = @Action_name AND C1.class_type_desc = @Class_type
	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NOT NULL AND @DB_Name IS NOT NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DMLActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name 
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND A.action_name = @Action_name AND C1.class_type_desc = @Class_type AND O.database_name = @DB_Name
	Order by D1.event_time
End
GO
/****** Object:  StoredProcedure [aud].[uspListDDLActionsByPrincipal]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [aud].[uspListDDLActionsByPrincipal]
     @Instance_name nvarchar(128), @Principal_name nvarchar(128) , @StartTime smalldatetime, @EndTime smalldatetime
AS

/*

List DDl Actions by Instance by Principal

*/

Declare @pString nvarchar(130)
     
Declare @TimeDiff int

Set @pString = '%'+@Principal_name+'%'

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())

SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc,  O.database_name, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S1.statement
FROM aud.AuditLog_DDLActions D1 
join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S1 on D1.statement_id = S1.statement_id
Where O.server_instance_name = @Instance_name AND S2.server_principal_name LIKE @pString
    AND DATEADD(hh,@TimeDiff,D1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,D1.event_time) <= @EndTime
Order by D1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListDDLActionsByInstance]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [aud].[uspListDDLActionsByInstance]
     @Instance_name nvarchar(128), @StartTime smalldatetime, @EndTime smalldatetime
AS

/*

List DDL Actions by Instance

*/
     
Declare @iString nvarchar(128)
Declare @TimeDiff int

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())

SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.database_name, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S1.statement
FROM aud.AuditLog_DDLActions D1 
join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S1 on D1.statement_id = S1.statement_id
Where O.server_instance_name = @Instance_name 
    AND DATEADD(hh,@TimeDiff,D1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,D1.event_time) <= @EndTime
Order by D1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListDDLActionsByDatabase]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListDDLActionsByDatabase]
     @Instance_name nvarchar(128), @DB_Name nvarchar(128) , @StartTime smalldatetime, @EndTime smalldatetime
AS

/*

List DDL Actions by Instance by Database

*/
     
Declare @TimeDiff int

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())

SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S1.statement
FROM aud.AuditLog_DDLActions D1 
join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S1 on D1.statement_id = S1.statement_id
Where O.server_instance_name = @Instance_name AND O.database_name = @DB_Name
    AND DATEADD(hh,@TimeDiff,D1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,D1.event_time) <= @EndTime
Order by D1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListDDLActionsByActions2]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [aud].[uspListDDLActionsByActions2]
     @Instance_name nvarchar(128), @DB_Name nvarchar(128) = NULL, @EventDate smalldatetime,
     @Action_name nvarchar(128) = NULL, @Class_type nvarchar(128)= NULL
AS

/*

List DDL Actions by Instance by Action Name

*/
     
Declare @TimeDiff int

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())


IF @Class_type IS NULL AND @Action_name is NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DDLActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate

	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DDLActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name 
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND C1.class_type_desc = @Class_type
	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NOT NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DDLActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND A.action_name = @Action_name AND C1.class_type_desc = @Class_type
	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NOT NULL AND @DB_Name IS NOT NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DDLActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name 
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND A.action_name = @Action_name AND C1.class_type_desc = @Class_type AND O.database_name = @DB_Name
	Order by D1.event_time
End
GO
/****** Object:  StoredProcedure [aud].[uspListDDLActionsByActions]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListDDLActionsByActions]
     @Instance_name nvarchar(128), @DB_Name nvarchar(128) = NULL, @EventDate smalldatetime,
     @Action_name nvarchar(128) = NULL, @Class_type nvarchar(128)= NULL
AS

/*

List DDL Actions

*/
     
Declare @TimeDiff int

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())


IF @Class_type IS NULL AND @Action_name is NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DDLActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate

	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DDLActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name 
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND C1.class_type_desc = @Class_type
	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NOT NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DDLActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND A.action_name = @Action_name AND C1.class_type_desc = @Class_type
	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NOT NULL AND @DB_Name IS NOT NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DDLActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name 
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND A.action_name = @Action_name AND C1.class_type_desc = @Class_type AND O.database_name = @DB_Name
	Order by D1.event_time
End
GO
/****** Object:  StoredProcedure [aud].[uspListDatabaseActionsByActions]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListDatabaseActionsByActions]
     @Instance_name nvarchar(128), @DB_Name nvarchar(128) = NULL, @EventDate smalldatetime,
     @Action_name nvarchar(128) = NULL, @Class_type nvarchar(128)= NULL
AS

/*

List Database Actions

*/
     
Declare @TimeDiff int

--Get the local time difference from UTC
Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())


IF @Class_type IS NULL AND @Action_name is NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DatabaseActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate

	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DatabaseActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name 
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND C1.class_type_desc = @Class_type
	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NOT NULL AND @DB_Name IS NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DatabaseActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND A.action_name = @Action_name AND C1.class_type_desc = @Class_type
	Order by D1.event_time
End


IF @Class_type IS NOT NULL AND @Action_name is NOT NULL AND @DB_Name IS NOT NULL
Begin
	SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
	O.schema_name, C2.client_address, D2.database_principal_name, 
	S2.server_principal_name, S1.statement, D1.event_count
	FROM aud.AuditLog_DatabaseActions D1 
	join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
	join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
	join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
	join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
	join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
	join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
	join aud.Statement S1 on D1.statement_id = S1.statement_id
	Where O.server_instance_name = @Instance_name 
		AND Cast(DATEADD(hh,@TimeDiff,D1.event_time) AS DATE) = @EventDate
		AND A.action_name = @Action_name AND C1.class_type_desc = @Class_type AND O.database_name = @DB_Name
	Order by D1.event_time
End
GO
/****** Object:  StoredProcedure [aud].[uspListDatabasActionsByPrincipal]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListDatabasActionsByPrincipal]
     @Instance_name nvarchar(128), @Principal_name nvarchar(128) , @StartTime smalldatetime, @EndTime smalldatetime
AS

/*

List Database Actions by Instance by Principal

*/

Declare @pString nvarchar(130)     
Declare @TimeDiff int

Set @pString = '%'+@Principal_name+'%'
Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())

SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc,  O.database_name, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S1.statement
FROM aud.AuditLog_DatabaseActions D1 
join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S1 on D1.statement_id = S1.statement_id
Where O.server_instance_name = @Instance_name AND S2.server_principal_name LIKE @pString
    AND DATEADD(hh,@TimeDiff,D1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,D1.event_time) <= @EndTime
Order by D1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListDatabasActionsByInstance]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListDatabasActionsByInstance]
     @Instance_name nvarchar(128), @StartTime smalldatetime, @EndTime smalldatetime
AS

/*

List Database Actions by Instance

*/
     
Declare @iString nvarchar(128)
Declare @TimeDiff int

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())

SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.database_name, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S1.statement
FROM aud.AuditLog_DatabaseActions D1 
join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S1 on D1.statement_id = S1.statement_id
Where O.server_instance_name = @Instance_name 
    AND DATEADD(hh,@TimeDiff,D1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,D1.event_time) <= @EndTime
Order by D1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspListDatabasActionsByDatabase]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [aud].[uspListDatabasActionsByDatabase]
     @Instance_name nvarchar(128), @DB_Name nvarchar(128) , @StartTime smalldatetime, @EndTime smalldatetime
AS

/*

List Database Actions by Instance by Database

*/
     
Declare @TimeDiff int

Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())

SELECT D1.event_time AS UTC_Time, DATEADD(hh,@TimeDiff,D1.event_time) AS event_time, A.action_name, C1.class_type_desc, O.object_name, 
O.schema_name, C2.client_address, D2.database_principal_name, 
S2.server_principal_name, S1.statement
FROM aud.AuditLog_DatabaseActions D1 
join aud.auditedAction A on D1.audited_action_id = A.audited_action_id
join aud.AuditedClassType C1 on D1.audited_class_type_id = C1.audited_class_type_id
join aud.AuditedObject O on D1.audited_object_id = O.audited_object_id
join aud.ClientAddress C2 on D1.client_address_id = C2.client_address_id
join aud.DatabasePrincipalName D2 on D1.database_principal_name_id = D2.database_principal_name_id
join aud.ServerPrincipalName S2 on D1.server_principal_name_id = S2.server_principal_name_id
join aud.Statement S1 on D1.statement_id = S1.statement_id
Where O.server_instance_name = @Instance_name AND O.database_name = @DB_Name
    AND DATEADD(hh,@TimeDiff,D1.event_time) >= @StartTime AND DATEADD(hh,@TimeDiff,D1.event_time) <= @EndTime
Order by D1.event_time
GO
/****** Object:  StoredProcedure [aud].[uspInsStatement]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [aud].[uspInsStatement]
@statement_hash BINARY (64), @statement_tail NVARCHAR (400)
AS
SET NOCOUNT ON ;

DECLARE @new_statement_ids TABLE (statement_id int) ;

WITH statementcte AS (
	SELECT statement_hash = @statement_hash
			, statement_tail = @statement_tail
	)
MERGE aud.Statement AS target
USING statementcte AS source 
   ON (     target.statement_hash = source.statement_hash
		AND target.statement_tail = source.statement_tail
		)
 WHEN NOT MATCHED THEN 
	INSERT (statement_hash, statement_tail, event_time)
	VALUES (statement_hash, statement_tail, '1/1/2000')
output inserted.statement_id into @new_statement_ids
	;

SELECT statement_id
		, statement_hash
		, statement_tail
		, is_new_statement = CAST(
				case 
					when exists(select top 1 1 from @new_statement_ids) then 1 
					else 0 
				end
				as bit)
				
  FROM aud.Statement
 WHERE statement_hash = @statement_hash
   AND statement_tail = @statement_tail
GO
/****** Object:  StoredProcedure [aud].[uspDeleteChunckData]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [aud].[uspDeleteChunckData]
AS

Declare @chunkDeleted  int
Declare @TotalDeleted int
Declare @ROWCNT int


SET ROWCOUNT 100000

SET @chunkDeleted = 1
SET @TotalDeleted = 0

WHILE ( @chunkDeleted > 0 )
Begin
	Delete From aud.AuditLog_ServerActions  where audited_action_id = '?'
    SET @RowCNT = @@ROWCOUNT
	SET @chunkDeleted = @ROWCNT
	SET @TotalDeleted = @RowCNT + @TotalDeleted
	Select @TotalDeleted
End

Print '** Delete from Audit Server Actions completed **'
GO
/****** Object:  StoredProcedure [aud].[uspDataGromming]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [aud].[uspDataGromming]
AS
Declare @chunkDeleted  int
Declare @TotalDeleted int
Declare @ROWCNT int


SET ROWCOUNT 100000

SET @chunkDeleted = 1
SET @TotalDeleted = 0

WHILE ( @chunkDeleted > 0 )
Begin
	Delete From aud.AuditLog_ServerActions  where audited_action_id = 3
    SET @RowCNT = @@ROWCOUNT
	SET @chunkDeleted = @ROWCNT
	SET @TotalDeleted = @RowCNT + @TotalDeleted
	Select @TotalDeleted
End

Print '** Delete from Audit Server Actions completed **'
GO
/****** Object:  StoredProcedure [aud].[rspAggServerActions]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [aud].[rspAggServerActions](
	@EventDate smalldatetime = null
)
as
begin
	/* Dev Notes: 
		- probably should go into partitioned tables so can drop partition instead of deleting data
		- probably should put transactions around this to protect data */

	-- optimization
	set nocount on
	
	-- set date
	-- assumes you want to process the previous days' data
	Declare @TimeDiff int


    -- Get the difference between Local Time and UTC time
    Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())
    
	if @EventDate is null set @EventDate = cast(cast(dateadd(dd, -1, GETDATE()) as varchar(11)) as smalldatetime)

	Select @EventDate

	/* Server Actions by Date, Instance, Principal, Object */
	-- delete data with this date
	delete from [aud].[rptAggServerActionsByObject] where EventDate = @EventDate
	
	-- populate date with this date
	insert into [aud].[rptAggServerActionsByObject]
	select
		z.EventDate,
		i.server_instance_name, 
		g.database_principal_name,
		i.database_name, 
		i.[schema_name], 
		i.[object_name],
		z.ServerActionCount
	from (
			select 
				cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) as EventDate, 
				audited_object_id,
				database_principal_name_id,
				sum(event_count) as ServerActionCount
			from aud.AuditLog_ServerActions
			where cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) = @EventDate
			group by 
				cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime), 
				audited_object_id,
				database_principal_name_id
	) z
	left outer join aud.AuditedObject i
		on i.audited_object_id = z.audited_object_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = z.database_principal_name_id 
		
 
	/* Server Actions by Class */
	-- delete data with this date
	delete from aud.rptAggServerActionsByClass where EventDate = @EventDate
	
	-- populate date with this date
	insert into [aud].[rptAggServerActionsByClass]
	select 
		z.EventDate,
		i.server_instance_name, 	
		g.database_principal_name,
		i.database_name,
		a.action_name,
		b.class_type_desc,
		b.securable_class_desc,
		z.ServerActionCount
	from (	
		select 
			cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) as EventDate, 
			audited_object_id,		
			database_principal_name_id,		
			audited_action_id,
			audited_class_type_id,
			sum(event_count) as ServerActionCount
		from aud.AuditLog_ServerActions
		where cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) = @EventDate
		group by 
			cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime), 
			audited_object_id,		
			database_principal_name_id,		
			audited_action_id,
			audited_class_type_id
	) z
	left outer join aud.AuditedObject i
		on i.audited_object_id = z.audited_object_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = z.database_principal_name_id 
	left outer join aud.auditedAction a
		on a.audited_action_id = z.audited_action_id
	left outer join aud.AuditedClassType b
		on b.audited_class_type_id = z.audited_class_type_id

end
GO
/****** Object:  StoredProcedure [aud].[rspAggGeneralActions]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [aud].[rspAggGeneralActions](
	@EventDate smalldatetime = null
)
as
begin
	/* Dev Notes: 
		- probably should go into partitioned tables so can drop partition instead of deleting data
		- probably should put transactions around this to protect data */

	-- optimization
	set nocount on
	
	-- set date
	-- assumes you want to process the previous days' data
	Declare @TimeDiff int


    -- Get the difference between Local Time and UTC time
    Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())
    
	if @EventDate is null set @EventDate = cast(cast(dateadd(dd, -1, GETDATE()) as varchar(11)) as smalldatetime)

	Select @EventDate

	/* Server Actions by Date, Instance, Principal, Object */
	-- delete data with this date
	delete from [aud].[rptAggGeneralActionsByObject] where EventDate = @EventDate
	
	-- populate date with this date
	insert into [aud].[rptAggGeneralActionsByObject]
	select
		z.EventDate,
		i.server_instance_name, 
		g.database_principal_name,
		i.database_name, 
		i.[schema_name], 
		i.[object_name],
		z.ServerActionCount
	from (
			select 
				cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) as EventDate, 
				audited_object_id,
				database_principal_name_id,
				sum(event_count) as ServerActionCount
			from aud.AuditLog_GeneralActions
			where cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) = @EventDate
			group by 
				cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime), 
				audited_object_id,
				database_principal_name_id
	) z
	left outer join aud.AuditedObject i
		on i.audited_object_id = z.audited_object_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = z.database_principal_name_id 
		
 
	/* Server Actions by Class */
	-- delete data with this date
	delete from aud.rptAggGeneralActionsByClass where EventDate = @EventDate
	
	-- populate date with this date
	insert into [aud].[rptAggGeneralActionsByClass]
	select 
		z.EventDate,
		i.server_instance_name, 	
		g.database_principal_name,
		i.database_name,
		a.action_name,
		b.class_type_desc,
		b.securable_class_desc,
		z.ServerActionCount
	from (	
		select 
			cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) as EventDate, 
			audited_object_id,		
			database_principal_name_id,		
			audited_action_id,
			audited_class_type_id,
			sum(event_count) as ServerActionCount
		from aud.AuditLog_GeneralActions
		where cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) = @EventDate
		group by 
			cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime), 
			audited_object_id,		
			database_principal_name_id,		
			audited_action_id,
			audited_class_type_id
	) z
	left outer join aud.AuditedObject i
		on i.audited_object_id = z.audited_object_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = z.database_principal_name_id 
	left outer join aud.auditedAction a
		on a.audited_action_id = z.audited_action_id
	left outer join aud.AuditedClassType b
		on b.audited_class_type_id = z.audited_class_type_id

end
GO
/****** Object:  StoredProcedure [aud].[rspAggDMLActions]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [aud].[rspAggDMLActions](
	@EventDate smalldatetime = null
)
as
begin
	/* Dev Notes: 
		- probably should go into partitioned tables so can drop partition instead of deleting data
		- probably should put transactions around this to protect data */

	-- optimization
	set nocount on
	
	-- set date
	-- assumes you want to process the previous days' data
	Declare @TimeDiff int


    -- Get the difference between Local Time and UTC time
    Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())
    
	if @EventDate is null set @EventDate = cast(cast(dateadd(dd, -1, GETDATE()) as varchar(11)) as smalldatetime)

	Select @EventDate

	/* DML Actions by Date, Instance, Principal, Object */
	-- delete data with this date
	delete from [aud].[rptAggDMLActionsByObject] where EventDate = @EventDate
	
	-- populate date with this date
	insert into [aud].[rptAggDMLActionsByObject]
	select
		z.EventDate,
		i.server_instance_name, 
		g.database_principal_name,
		i.database_name, 
		i.[schema_name], 
		i.[object_name],
		z.DMLActionCount
	from (
			select 
				cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) as EventDate, 
				audited_object_id,
				database_principal_name_id,
				sum(event_count) as DMLActionCount
			from aud.AuditLog_DMLActions
			where cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) = @EventDate
			group by 
				cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime), 
				audited_object_id,
				database_principal_name_id
	) z
	left outer join aud.AuditedObject i
		on i.audited_object_id = z.audited_object_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = z.database_principal_name_id 
		
 
	/* DML Actions by Class */
	-- delete data with this date
	delete from aud.rptAggDMLActionsByClass where EventDate = @EventDate
	
	-- populate date with this date
	insert into [aud].[rptAggDMLActionsByClass]
	select 
		z.EventDate,
		i.server_instance_name, 	
		g.database_principal_name,
		i.database_name,
		a.action_name,
		b.class_type_desc,
		b.securable_class_desc,
		z.DMLActionCount
	from (	
		select 
			cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) as EventDate, 
			audited_object_id,		
			database_principal_name_id,		
			audited_action_id,
			audited_class_type_id,
			sum(event_count) as DMLActionCount
		from aud.AuditLog_DMLActions
		where cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) = @EventDate
		group by 
			cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime), 
			audited_object_id,		
			database_principal_name_id,		
			audited_action_id,
			audited_class_type_id
	) z
	left outer join aud.AuditedObject i
		on i.audited_object_id = z.audited_object_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = z.database_principal_name_id 
	left outer join aud.auditedAction a
		on a.audited_action_id = z.audited_action_id
	left outer join aud.AuditedClassType b
		on b.audited_class_type_id = z.audited_class_type_id

end
GO
/****** Object:  StoredProcedure [aud].[rspAggDDLActions]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [aud].[rspAggDDLActions](
	@EventDate smalldatetime = null
)
as
begin
	/* Dev Notes: 
		- probably should go into partitioned tables so can drop partition instead of deleting data
		- probably should put transactions around this to protect data */

	-- optimization
	set nocount on
	
	-- set date
	-- assumes you want to process the previous days' data
	Declare @TimeDiff int


    -- Get the difference between Local Time and UTC time
    Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())
    
	if @EventDate is null set @EventDate = cast(cast(dateadd(dd, -1, GETDATE()) as varchar(11)) as smalldatetime)

	Select @EventDate

	/* DDL Actions by Date, Instance, Principal, Object */
	-- delete data with this date
	delete from [aud].[rptAggDDLActionsByObject] where EventDate = @EventDate
	
	-- populate date with this date
	insert into [aud].[rptAggDDLActionsByObject]
	select
		z.EventDate,
		i.server_instance_name, 
		g.database_principal_name,
		i.database_name, 
		i.[schema_name], 
		i.[object_name],
		z.DDLActionCount
	from (
			select 
				cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) as EventDate, 
				audited_object_id,
				database_principal_name_id,
				sum(event_count) as DDLActionCount
			from aud.AuditLog_DDLActions
			where cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) = @EventDate
			group by 
				cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime), 
				audited_object_id,
				database_principal_name_id
	) z
	left outer join aud.AuditedObject i
		on i.audited_object_id = z.audited_object_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = z.database_principal_name_id 
		
 
	/* DDL Actions by Class */
	-- delete data with this date
	delete from aud.rptAggDDLActionsByClass where EventDate = @EventDate
	
	-- populate date with this date
	insert into [aud].[rptAggDDLActionsByClass]
	select 
		z.EventDate,
		i.server_instance_name, 	
		g.database_principal_name,
		i.database_name,
		a.action_name,
		b.class_type_desc,
		b.securable_class_desc,
		z.DDLActionCount
	from (	
		select 
			cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) as EventDate, 
			audited_object_id,		
			database_principal_name_id,		
			audited_action_id,
			audited_class_type_id,
			sum(event_count) as DDLActionCount
		from aud.AuditLog_DDLActions
		where cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) = @EventDate
		group by 
			cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime), 
			audited_object_id,		
			database_principal_name_id,		
			audited_action_id,
			audited_class_type_id
	) z
	left outer join aud.AuditedObject i
		on i.audited_object_id = z.audited_object_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = z.database_principal_name_id 
	left outer join aud.auditedAction a
		on a.audited_action_id = z.audited_action_id
	left outer join aud.AuditedClassType b
		on b.audited_class_type_id = z.audited_class_type_id

end
GO
/****** Object:  StoredProcedure [aud].[rspAggDatabaseActions]    Script Date: 09/29/2011 16:13:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [aud].[rspAggDatabaseActions](
	@EventDate smalldatetime = null
)
as
begin
	/* Dev Notes: 
		- probably should go into partitioned tables so can drop partition instead of deleting data
		- probably should put transactions around this to protect data */

	-- optimization
	set nocount on
	
	-- set date
	-- assumes you want to process the previous days' data
	Declare @TimeDiff int


    -- Get the difference between Local Time and UTC time
    Select @TimeDiff = DATEDIFF(hh,GETUTCDATE(),GETDATE())
    
	if @EventDate is null set @EventDate = cast(cast(dateadd(dd, -1, GETDATE()) as varchar(11)) as smalldatetime)

	Select @EventDate

	/* Database Actions by Date, Instance, Principal, Object */
	-- delete data with this date
	delete from [aud].[rptAggDatabaseActionsByObject] where EventDate = @EventDate
	
	-- populate date with this date
	insert into [aud].[rptAggDatabaseActionsByObject]
	select
		z.EventDate,
		i.server_instance_name, 
		g.database_principal_name,
		i.database_name, 
		i.[schema_name], 
		i.[object_name],
		z.DatabaseActionCount
	from (
			select 
				cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) as EventDate, 
				audited_object_id,
				database_principal_name_id,
				sum(event_count) as DatabaseActionCount
			from aud.AuditLog_DatabaseActions
			where cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) = @EventDate
			group by 
				cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime), 
				audited_object_id,
				database_principal_name_id
	) z
	left outer join aud.AuditedObject i
		on i.audited_object_id = z.audited_object_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = z.database_principal_name_id 
		
 
	/* Database Actions by Class */
	-- delete data with this date
	delete from aud.rptAggDatabaseActionsByClass where EventDate = @EventDate
	
	-- populate date with this date
	insert into [aud].[rptAggDatabaseActionsByClass]
	select 
		z.EventDate,
		i.server_instance_name, 	
		g.database_principal_name,
		i.database_name,
		a.action_name,
		b.class_type_desc,
		b.securable_class_desc,
		z.DatabaseActionCount
	from (	
		select 
			cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) as EventDate, 
			audited_object_id,		
			database_principal_name_id,		
			audited_action_id,
			audited_class_type_id,
			sum(event_count) as DatabaseActionCount
		from aud.AuditLog_DatabaseActions
		where cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime) = @EventDate
		group by 
			cast(CAST(DATEADD(hh,@TimeDiff,event_time) as varchar(11)) as smalldatetime), 
			audited_object_id,		
			database_principal_name_id,		
			audited_action_id,
			audited_class_type_id
	) z
	left outer join aud.AuditedObject i
		on i.audited_object_id = z.audited_object_id
	left outer join aud.DatabasePrincipalName g
		on g.database_principal_name_id = z.database_principal_name_id 
	left outer join aud.auditedAction a
		on a.audited_action_id = z.audited_action_id
	left outer join aud.AuditedClassType b
		on b.audited_class_type_id = z.audited_class_type_id

end
GO
/****** Object:  ForeignKey [FK_ImportedFile_ImportExecution]    Script Date: 09/29/2011 16:13:39 ******/
ALTER TABLE [aud].[ImportedFile]  WITH NOCHECK ADD  CONSTRAINT [FK_ImportedFile_ImportExecution] FOREIGN KEY([import_id])
REFERENCES [aud].[ImportExecution] ([import_id])
GO
ALTER TABLE [aud].[ImportedFile] CHECK CONSTRAINT [FK_ImportedFile_ImportExecution]
GO
/****** Object:  ForeignKey [FK_AuditLog_ServerActions_auditedAction]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_ServerActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_ServerActions_auditedAction] FOREIGN KEY([audited_action_id])
REFERENCES [aud].[AuditedAction] ([audited_action_id])
GO
ALTER TABLE [aud].[AuditLog_ServerActions] CHECK CONSTRAINT [FK_AuditLog_ServerActions_auditedAction]
GO
/****** Object:  ForeignKey [FK_AuditLog_ServerActions_AuditedClassType]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_ServerActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_ServerActions_AuditedClassType] FOREIGN KEY([audited_class_type_id])
REFERENCES [aud].[AuditedClassType] ([audited_class_type_id])
GO
ALTER TABLE [aud].[AuditLog_ServerActions] CHECK CONSTRAINT [FK_AuditLog_ServerActions_AuditedClassType]
GO
/****** Object:  ForeignKey [FK_AuditLog_ServerActions_AuditedObject]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_ServerActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_ServerActions_AuditedObject] FOREIGN KEY([audited_object_id])
REFERENCES [aud].[AuditedObject] ([audited_object_id])
GO
ALTER TABLE [aud].[AuditLog_ServerActions] CHECK CONSTRAINT [FK_AuditLog_ServerActions_AuditedObject]
GO
/****** Object:  ForeignKey [FK_AuditLog_ServerActions_AuditFile]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_ServerActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_ServerActions_AuditFile] FOREIGN KEY([audit_file_id])
REFERENCES [aud].[AuditFile] ([audit_file_id])
GO
ALTER TABLE [aud].[AuditLog_ServerActions] CHECK CONSTRAINT [FK_AuditLog_ServerActions_AuditFile]
GO
/****** Object:  ForeignKey [FK_AuditLog_ServerActions_ClientAddress]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_ServerActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_ServerActions_ClientAddress] FOREIGN KEY([client_address_id])
REFERENCES [aud].[ClientAddress] ([client_address_id])
GO
ALTER TABLE [aud].[AuditLog_ServerActions] CHECK CONSTRAINT [FK_AuditLog_ServerActions_ClientAddress]
GO
/****** Object:  ForeignKey [FK_AuditLog_ServerActions_DatabasePrincipalName]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_ServerActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_ServerActions_DatabasePrincipalName] FOREIGN KEY([database_principal_name_id])
REFERENCES [aud].[DatabasePrincipalName] ([database_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_ServerActions] CHECK CONSTRAINT [FK_AuditLog_ServerActions_DatabasePrincipalName]
GO
/****** Object:  ForeignKey [FK_AuditLog_ServerActions_DatabasePrincipalName1]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_ServerActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_ServerActions_DatabasePrincipalName1] FOREIGN KEY([target_database_principal_name_id])
REFERENCES [aud].[DatabasePrincipalName] ([database_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_ServerActions] CHECK CONSTRAINT [FK_AuditLog_ServerActions_DatabasePrincipalName1]
GO
/****** Object:  ForeignKey [FK_AuditLog_ServerActions_ImportExecution]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_ServerActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_ServerActions_ImportExecution] FOREIGN KEY([import_id])
REFERENCES [aud].[ImportExecution] ([import_id])
GO
ALTER TABLE [aud].[AuditLog_ServerActions] CHECK CONSTRAINT [FK_AuditLog_ServerActions_ImportExecution]
GO
/****** Object:  ForeignKey [FK_AuditLog_ServerActions_ServerPrincipalName]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_ServerActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_ServerActions_ServerPrincipalName] FOREIGN KEY([server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_ServerActions] CHECK CONSTRAINT [FK_AuditLog_ServerActions_ServerPrincipalName]
GO
/****** Object:  ForeignKey [FK_AuditLog_ServerActions_ServerPrincipalName1]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_ServerActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_ServerActions_ServerPrincipalName1] FOREIGN KEY([session_server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_ServerActions] CHECK CONSTRAINT [FK_AuditLog_ServerActions_ServerPrincipalName1]
GO
/****** Object:  ForeignKey [FK_AuditLog_ServerActions_ServerPrincipalName2]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_ServerActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_ServerActions_ServerPrincipalName2] FOREIGN KEY([target_server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_ServerActions] CHECK CONSTRAINT [FK_AuditLog_ServerActions_ServerPrincipalName2]
GO
/****** Object:  ForeignKey [FK_AuditLog_GeneralActions_auditedAction]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_GeneralActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_GeneralActions_auditedAction] FOREIGN KEY([audited_action_id])
REFERENCES [aud].[AuditedAction] ([audited_action_id])
GO
ALTER TABLE [aud].[AuditLog_GeneralActions] CHECK CONSTRAINT [FK_AuditLog_GeneralActions_auditedAction]
GO
/****** Object:  ForeignKey [FK_AuditLog_GeneralActions_AuditedClassType]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_GeneralActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_GeneralActions_AuditedClassType] FOREIGN KEY([audited_class_type_id])
REFERENCES [aud].[AuditedClassType] ([audited_class_type_id])
GO
ALTER TABLE [aud].[AuditLog_GeneralActions] CHECK CONSTRAINT [FK_AuditLog_GeneralActions_AuditedClassType]
GO
/****** Object:  ForeignKey [FK_AuditLog_GeneralActions_AuditedObject]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_GeneralActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_GeneralActions_AuditedObject] FOREIGN KEY([audited_object_id])
REFERENCES [aud].[AuditedObject] ([audited_object_id])
GO
ALTER TABLE [aud].[AuditLog_GeneralActions] CHECK CONSTRAINT [FK_AuditLog_GeneralActions_AuditedObject]
GO
/****** Object:  ForeignKey [FK_AuditLog_GeneralActions_AuditFile]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_GeneralActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_GeneralActions_AuditFile] FOREIGN KEY([audit_file_id])
REFERENCES [aud].[AuditFile] ([audit_file_id])
GO
ALTER TABLE [aud].[AuditLog_GeneralActions] CHECK CONSTRAINT [FK_AuditLog_GeneralActions_AuditFile]
GO
/****** Object:  ForeignKey [FK_AuditLog_GeneralActions_ClientAddress]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_GeneralActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_GeneralActions_ClientAddress] FOREIGN KEY([client_address_id])
REFERENCES [aud].[ClientAddress] ([client_address_id])
GO
ALTER TABLE [aud].[AuditLog_GeneralActions] CHECK CONSTRAINT [FK_AuditLog_GeneralActions_ClientAddress]
GO
/****** Object:  ForeignKey [FK_AuditLog_GeneralActions_DatabasePrincipalName]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_GeneralActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_GeneralActions_DatabasePrincipalName] FOREIGN KEY([database_principal_name_id])
REFERENCES [aud].[DatabasePrincipalName] ([database_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_GeneralActions] CHECK CONSTRAINT [FK_AuditLog_GeneralActions_DatabasePrincipalName]
GO
/****** Object:  ForeignKey [FK_AuditLog_GeneralActions_DatabasePrincipalName1]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_GeneralActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_GeneralActions_DatabasePrincipalName1] FOREIGN KEY([target_database_principal_name_id])
REFERENCES [aud].[DatabasePrincipalName] ([database_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_GeneralActions] CHECK CONSTRAINT [FK_AuditLog_GeneralActions_DatabasePrincipalName1]
GO
/****** Object:  ForeignKey [FK_AuditLog_GeneralActions_ImportExecution]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_GeneralActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_GeneralActions_ImportExecution] FOREIGN KEY([import_id])
REFERENCES [aud].[ImportExecution] ([import_id])
GO
ALTER TABLE [aud].[AuditLog_GeneralActions] CHECK CONSTRAINT [FK_AuditLog_GeneralActions_ImportExecution]
GO
/****** Object:  ForeignKey [FK_AuditLog_GeneralActions_ServerPrincipalName]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_GeneralActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_GeneralActions_ServerPrincipalName] FOREIGN KEY([server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_GeneralActions] CHECK CONSTRAINT [FK_AuditLog_GeneralActions_ServerPrincipalName]
GO
/****** Object:  ForeignKey [FK_AuditLog_GeneralActions_ServerPrincipalName1]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_GeneralActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_GeneralActions_ServerPrincipalName1] FOREIGN KEY([session_server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_GeneralActions] CHECK CONSTRAINT [FK_AuditLog_GeneralActions_ServerPrincipalName1]
GO
/****** Object:  ForeignKey [FK_AuditLog_GeneralActions_ServerPrincipalName2]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_GeneralActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_GeneralActions_ServerPrincipalName2] FOREIGN KEY([target_server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_GeneralActions] CHECK CONSTRAINT [FK_AuditLog_GeneralActions_ServerPrincipalName2]
GO
/****** Object:  ForeignKey [FK_AuditLog_DMLActions_auditedAction]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DMLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DMLActions_auditedAction] FOREIGN KEY([audited_action_id])
REFERENCES [aud].[AuditedAction] ([audited_action_id])
GO
ALTER TABLE [aud].[AuditLog_DMLActions] CHECK CONSTRAINT [FK_AuditLog_DMLActions_auditedAction]
GO
/****** Object:  ForeignKey [FK_AuditLog_DMLActions_AuditedClassType]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DMLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DMLActions_AuditedClassType] FOREIGN KEY([audited_class_type_id])
REFERENCES [aud].[AuditedClassType] ([audited_class_type_id])
GO
ALTER TABLE [aud].[AuditLog_DMLActions] CHECK CONSTRAINT [FK_AuditLog_DMLActions_AuditedClassType]
GO
/****** Object:  ForeignKey [FK_AuditLog_DMLActions_AuditedObject]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DMLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DMLActions_AuditedObject] FOREIGN KEY([audited_object_id])
REFERENCES [aud].[AuditedObject] ([audited_object_id])
GO
ALTER TABLE [aud].[AuditLog_DMLActions] CHECK CONSTRAINT [FK_AuditLog_DMLActions_AuditedObject]
GO
/****** Object:  ForeignKey [FK_AuditLog_DMLActions_AuditFile]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DMLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DMLActions_AuditFile] FOREIGN KEY([audit_file_id])
REFERENCES [aud].[AuditFile] ([audit_file_id])
GO
ALTER TABLE [aud].[AuditLog_DMLActions] CHECK CONSTRAINT [FK_AuditLog_DMLActions_AuditFile]
GO
/****** Object:  ForeignKey [FK_AuditLog_DMLActions_ClientAddress]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DMLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DMLActions_ClientAddress] FOREIGN KEY([client_address_id])
REFERENCES [aud].[ClientAddress] ([client_address_id])
GO
ALTER TABLE [aud].[AuditLog_DMLActions] CHECK CONSTRAINT [FK_AuditLog_DMLActions_ClientAddress]
GO
/****** Object:  ForeignKey [FK_AuditLog_DMLActions_DatabasePrincipalName]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DMLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DMLActions_DatabasePrincipalName] FOREIGN KEY([database_principal_name_id])
REFERENCES [aud].[DatabasePrincipalName] ([database_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DMLActions] CHECK CONSTRAINT [FK_AuditLog_DMLActions_DatabasePrincipalName]
GO
/****** Object:  ForeignKey [FK_AuditLog_DMLActions_DatabasePrincipalName1]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DMLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DMLActions_DatabasePrincipalName1] FOREIGN KEY([target_database_principal_name_id])
REFERENCES [aud].[DatabasePrincipalName] ([database_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DMLActions] CHECK CONSTRAINT [FK_AuditLog_DMLActions_DatabasePrincipalName1]
GO
/****** Object:  ForeignKey [FK_AuditLog_DMLActions_ImportExecution]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DMLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DMLActions_ImportExecution] FOREIGN KEY([import_id])
REFERENCES [aud].[ImportExecution] ([import_id])
GO
ALTER TABLE [aud].[AuditLog_DMLActions] CHECK CONSTRAINT [FK_AuditLog_DMLActions_ImportExecution]
GO
/****** Object:  ForeignKey [FK_AuditLog_DMLActions_ServerPrincipalName]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DMLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DMLActions_ServerPrincipalName] FOREIGN KEY([server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DMLActions] CHECK CONSTRAINT [FK_AuditLog_DMLActions_ServerPrincipalName]
GO
/****** Object:  ForeignKey [FK_AuditLog_DMLActions_ServerPrincipalName1]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DMLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DMLActions_ServerPrincipalName1] FOREIGN KEY([session_server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DMLActions] CHECK CONSTRAINT [FK_AuditLog_DMLActions_ServerPrincipalName1]
GO
/****** Object:  ForeignKey [FK_AuditLog_DMLActions_ServerPrincipalName2]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DMLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DMLActions_ServerPrincipalName2] FOREIGN KEY([target_server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DMLActions] CHECK CONSTRAINT [FK_AuditLog_DMLActions_ServerPrincipalName2]
GO
/****** Object:  ForeignKey [FK_AuditLog_DDLActions_auditedAction]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DDLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DDLActions_auditedAction] FOREIGN KEY([audited_action_id])
REFERENCES [aud].[AuditedAction] ([audited_action_id])
GO
ALTER TABLE [aud].[AuditLog_DDLActions] CHECK CONSTRAINT [FK_AuditLog_DDLActions_auditedAction]
GO
/****** Object:  ForeignKey [FK_AuditLog_DDLActions_AuditedClassType]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DDLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DDLActions_AuditedClassType] FOREIGN KEY([audited_class_type_id])
REFERENCES [aud].[AuditedClassType] ([audited_class_type_id])
GO
ALTER TABLE [aud].[AuditLog_DDLActions] CHECK CONSTRAINT [FK_AuditLog_DDLActions_AuditedClassType]
GO
/****** Object:  ForeignKey [FK_AuditLog_DDLActions_AuditedObject]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DDLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DDLActions_AuditedObject] FOREIGN KEY([audited_object_id])
REFERENCES [aud].[AuditedObject] ([audited_object_id])
GO
ALTER TABLE [aud].[AuditLog_DDLActions] CHECK CONSTRAINT [FK_AuditLog_DDLActions_AuditedObject]
GO
/****** Object:  ForeignKey [FK_AuditLog_DDLActions_AuditFile]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DDLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DDLActions_AuditFile] FOREIGN KEY([audit_file_id])
REFERENCES [aud].[AuditFile] ([audit_file_id])
GO
ALTER TABLE [aud].[AuditLog_DDLActions] CHECK CONSTRAINT [FK_AuditLog_DDLActions_AuditFile]
GO
/****** Object:  ForeignKey [FK_AuditLog_DDLActions_ClientAddress]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DDLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DDLActions_ClientAddress] FOREIGN KEY([client_address_id])
REFERENCES [aud].[ClientAddress] ([client_address_id])
GO
ALTER TABLE [aud].[AuditLog_DDLActions] CHECK CONSTRAINT [FK_AuditLog_DDLActions_ClientAddress]
GO
/****** Object:  ForeignKey [FK_AuditLog_DDLActions_DatabasePrincipalName]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DDLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DDLActions_DatabasePrincipalName] FOREIGN KEY([database_principal_name_id])
REFERENCES [aud].[DatabasePrincipalName] ([database_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DDLActions] CHECK CONSTRAINT [FK_AuditLog_DDLActions_DatabasePrincipalName]
GO
/****** Object:  ForeignKey [FK_AuditLog_DDLActions_DatabasePrincipalName1]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DDLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DDLActions_DatabasePrincipalName1] FOREIGN KEY([target_database_principal_name_id])
REFERENCES [aud].[DatabasePrincipalName] ([database_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DDLActions] CHECK CONSTRAINT [FK_AuditLog_DDLActions_DatabasePrincipalName1]
GO
/****** Object:  ForeignKey [FK_AuditLog_DDLActions_ImportExecution]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DDLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DDLActions_ImportExecution] FOREIGN KEY([import_id])
REFERENCES [aud].[ImportExecution] ([import_id])
GO
ALTER TABLE [aud].[AuditLog_DDLActions] CHECK CONSTRAINT [FK_AuditLog_DDLActions_ImportExecution]
GO
/****** Object:  ForeignKey [FK_AuditLog_DDLActions_ServerPrincipalName]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DDLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DDLActions_ServerPrincipalName] FOREIGN KEY([server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DDLActions] CHECK CONSTRAINT [FK_AuditLog_DDLActions_ServerPrincipalName]
GO
/****** Object:  ForeignKey [FK_AuditLog_DDLActions_ServerPrincipalName1]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DDLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DDLActions_ServerPrincipalName1] FOREIGN KEY([session_server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DDLActions] CHECK CONSTRAINT [FK_AuditLog_DDLActions_ServerPrincipalName1]
GO
/****** Object:  ForeignKey [FK_AuditLog_DDLActions_ServerPrincipalName2]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DDLActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DDLActions_ServerPrincipalName2] FOREIGN KEY([target_server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DDLActions] CHECK CONSTRAINT [FK_AuditLog_DDLActions_ServerPrincipalName2]
GO
/****** Object:  ForeignKey [FK_AuditLog_DatabaseActions_auditedAction]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DatabaseActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DatabaseActions_auditedAction] FOREIGN KEY([audited_action_id])
REFERENCES [aud].[AuditedAction] ([audited_action_id])
GO
ALTER TABLE [aud].[AuditLog_DatabaseActions] CHECK CONSTRAINT [FK_AuditLog_DatabaseActions_auditedAction]
GO
/****** Object:  ForeignKey [FK_AuditLog_DatabaseActions_AuditedClassType]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DatabaseActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DatabaseActions_AuditedClassType] FOREIGN KEY([audited_class_type_id])
REFERENCES [aud].[AuditedClassType] ([audited_class_type_id])
GO
ALTER TABLE [aud].[AuditLog_DatabaseActions] CHECK CONSTRAINT [FK_AuditLog_DatabaseActions_AuditedClassType]
GO
/****** Object:  ForeignKey [FK_AuditLog_DatabaseActions_AuditedObject]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DatabaseActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DatabaseActions_AuditedObject] FOREIGN KEY([audited_object_id])
REFERENCES [aud].[AuditedObject] ([audited_object_id])
GO
ALTER TABLE [aud].[AuditLog_DatabaseActions] CHECK CONSTRAINT [FK_AuditLog_DatabaseActions_AuditedObject]
GO
/****** Object:  ForeignKey [FK_AuditLog_DatabaseActions_AuditFile]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DatabaseActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DatabaseActions_AuditFile] FOREIGN KEY([audit_file_id])
REFERENCES [aud].[AuditFile] ([audit_file_id])
GO
ALTER TABLE [aud].[AuditLog_DatabaseActions] CHECK CONSTRAINT [FK_AuditLog_DatabaseActions_AuditFile]
GO
/****** Object:  ForeignKey [FK_AuditLog_DatabaseActions_ClientAddress]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DatabaseActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DatabaseActions_ClientAddress] FOREIGN KEY([client_address_id])
REFERENCES [aud].[ClientAddress] ([client_address_id])
GO
ALTER TABLE [aud].[AuditLog_DatabaseActions] CHECK CONSTRAINT [FK_AuditLog_DatabaseActions_ClientAddress]
GO
/****** Object:  ForeignKey [FK_AuditLog_DatabaseActions_DatabasePrincipalName]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DatabaseActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DatabaseActions_DatabasePrincipalName] FOREIGN KEY([database_principal_name_id])
REFERENCES [aud].[DatabasePrincipalName] ([database_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DatabaseActions] CHECK CONSTRAINT [FK_AuditLog_DatabaseActions_DatabasePrincipalName]
GO
/****** Object:  ForeignKey [FK_AuditLog_DatabaseActions_DatabasePrincipalName1]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DatabaseActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DatabaseActions_DatabasePrincipalName1] FOREIGN KEY([target_database_principal_name_id])
REFERENCES [aud].[DatabasePrincipalName] ([database_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DatabaseActions] CHECK CONSTRAINT [FK_AuditLog_DatabaseActions_DatabasePrincipalName1]
GO
/****** Object:  ForeignKey [FK_AuditLog_DatabaseActions_ImportExecution]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DatabaseActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DatabaseActions_ImportExecution] FOREIGN KEY([import_id])
REFERENCES [aud].[ImportExecution] ([import_id])
GO
ALTER TABLE [aud].[AuditLog_DatabaseActions] CHECK CONSTRAINT [FK_AuditLog_DatabaseActions_ImportExecution]
GO
/****** Object:  ForeignKey [FK_AuditLog_DatabaseActions_ServerPrincipalName]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DatabaseActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DatabaseActions_ServerPrincipalName] FOREIGN KEY([server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DatabaseActions] CHECK CONSTRAINT [FK_AuditLog_DatabaseActions_ServerPrincipalName]
GO
/****** Object:  ForeignKey [FK_AuditLog_DatabaseActions_ServerPrincipalName1]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DatabaseActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DatabaseActions_ServerPrincipalName1] FOREIGN KEY([target_server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DatabaseActions] CHECK CONSTRAINT [FK_AuditLog_DatabaseActions_ServerPrincipalName1]
GO
/****** Object:  ForeignKey [FK_AuditLog_DatabaseActions_ServerPrincipalName2]    Script Date: 09/29/2011 16:13:40 ******/
ALTER TABLE [aud].[AuditLog_DatabaseActions]  WITH NOCHECK ADD  CONSTRAINT [FK_AuditLog_DatabaseActions_ServerPrincipalName2] FOREIGN KEY([session_server_principal_name_id])
REFERENCES [aud].[ServerPrincipalName] ([server_principal_name_id])
GO
ALTER TABLE [aud].[AuditLog_DatabaseActions] CHECK CONSTRAINT [FK_AuditLog_DatabaseActions_ServerPrincipalName2]
GO


ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 1 WITH(DATA_COMPRESSION = PAGE )
ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 2 WITH(DATA_COMPRESSION = PAGE )
ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 3 WITH(DATA_COMPRESSION = PAGE )
ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 4 WITH(DATA_COMPRESSION = PAGE )
ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 5 WITH(DATA_COMPRESSION = PAGE )
ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 6 WITH(DATA_COMPRESSION = PAGE )
ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 7 WITH(DATA_COMPRESSION = PAGE )
ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 8 WITH(DATA_COMPRESSION = PAGE )
ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 9 WITH(DATA_COMPRESSION = PAGE )
ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 10 WITH(DATA_COMPRESSION = PAGE )
ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 11 WITH(DATA_COMPRESSION = PAGE )
ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 12 WITH(DATA_COMPRESSION = PAGE )
ALTER TABLE [aud].[AuditLog_DMLActions] REBUILD PARTITION = 13 WITH(DATA_COMPRESSION = PAGE )
