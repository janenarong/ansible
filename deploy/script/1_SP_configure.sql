SP_CONFIGURE 'show advanced option',1

RECONFIGURE

GO

SP_CONFIGURE 'backup compression default',1

RECONFIGURE

GO

SP_CONFIGURE 'xp_cmdshell',1

RECONFIGURE

GO

DECLARE @maxmem nvarchar(255)
DECLARE @sql1 nvarchar(255)
SET @maxmem = (select (physical_memory_kb/1024 - 2000)*0.75 FROM sys.dm_os_sys_info)
SET @sql1='sp_configure ''max server memory (MB)'','+ @maxmem +' reconfigure'
--print @sql1
EXEC (@sql1)


DECLARE @maxparallelism nvarchar(255) 
DECLARE @sql2 nvarchar(255)
SET @maxparallelism = (SELECT cpu_count FROM sys.dm_os_sys_info) 
IF (@maxparallelism >= 8)
BEGIN
 SET @maxparallelism = 8
END
SET @sql2='sp_configure ''max degree of parallelism'','+ @maxparallelism +' reconfigure'
--print @sql2
EXEC (@sql2)