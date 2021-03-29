USE [master]
GO

IF NOT EXISTS (
select sp.name as login     
from sys.server_principals sp
left join sys.sql_logins sl on sp.principal_id = sl.principal_id
where sp.type not in ('G', 'R') and sp.name = 'patrol'
)
Begin
    CREATE LOGIN [patrol] WITH PASSWORD=N'Uranus', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
	ALTER LOGIN [patrol] WITH CHECK_POLICY=ON
	ALTER SERVER ROLE [sysadmin] ADD MEMBER [patrol]
end

GO
DECLARE @LoginName  varchar(20)
DECLARE @Sql        NVARCHAR(MAX)
DECLARE Cur CURSOR FOR
SELECT name
FROM sys.sql_logins
WHERE is_policy_checked = 0
  

OPEN Cur 
FETCH NEXT FROM  Cur INTO @LoginName

WHILE (@@FETCH_STATUS = 0)
BEGIN
  SET @Sql = N'ALTER LOGIN ' + QUOTENAME(@LoginName) 
           + N' WITH CHECK_POLICY = ON;'

  --PRINT @SQL  --<-- test before you actually execute it             
  EXEC (@SQL)

  FETCH NEXT FROM  Cur INTO @LoginName  
END 

CLOSE Cur;
DEALLOCATE Cur;