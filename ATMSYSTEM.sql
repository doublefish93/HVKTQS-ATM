
create database ATMSYSTEM
go 
use ATMSYSTEM
go
create table [Administrator]
(
	Admin_ID int identity primary key,
	Admin_Username varchar(16) not null,
	Admin_Password varchar(40) not null,	
)

insert into [Administrator] values('admin','123456')

create table [User]
(
	[User_ID] int identity primary key,
	[User_IDCard] varchar(9) unique,
	[User_Name] varchar(40) not null,
	[User_Dob] datetime not null,
	[User_Gender] bit ,
	[User_Address] varchar(300) not null,
	[User_Phone] VARCHAR(15),
	[User_Delete] bit DEFAULT(0),
	
)

go
Create table [Bank_Info]
(
	
	[Bank_ID] INT PRIMARY KEY,
	[Bank_Name] VARCHAR(40) NOT NULL,
	[Bank_Address] VARCHAR(300) NOT NULL,
	[Bank_Phone] VARCHAR(15),
	[Bank_Fax] VARCHAR(15),
)
go
create table [Account]
(
	[Acc_ID] INT IDENTITY PRIMARY KEY,
	[Bank_ID] INT FOREIGN KEY REFERENCES[Bank_Info]([Bank_ID]),
	[User_ID] INT FOREIGN KEY REFERENCES [User]([User_ID]),
	[Acc_No] VARCHAR(16) UNIQUE,
	[Acc_PIN] VARCHAR(4) NOT NULL,
	[Acc_Balance] decimal NOT NULL,
	[Acc_Status] bit DEFAULT(1) ,
	[Acc_Delete] bit DEFAULT(0),
	[Acc_Delete_Reason] VARCHAR(MAX),
)
go

create table [Transaction]
(
	[Tran_ID] INT IDENTITY PRIMARY KEY,
	[Tran_Type] Int NOT NULL,
	[Tran_Balance] decimal not null,
	[Acc_From_ID] INT FOREIGN KEY REFERENCES [Account]([Acc_ID]),
	[Acc_To_ID] INT FOREIGN KEY REFERENCES [Account]([Acc_ID]),
	[Tran_Amount] decimal NOT NULL,
	[Tran_Reason] VARCHAR(MAX),
	[Tran_Date] DATETIME DEFAULT(GETDATE())
)


GO


Create table [ATM_Info]
(
	
	[Sys_ID] INT PRIMARY KEY,
	[Bank_ID]INT FOREIGN KEY REFERENCES [Bank_Info]([Bank_ID]),
	[Sys_WA] decimal NOT NULL, -- Maximum amount of withdrawal in a single day
	[Sys_DA] decimal NOT NULL, -- Maximum amount of deposit in a single day 
	[Sys_WT] INT NOT NULL, -- Maximum time of withdrawal in a single day
	[Sys_DT] INT NOT NULL, -- Maximum time of deposit in a single day
	[Sys_MAT] decimal NOT NULL, -- Maximum amount of per transfer
	[Sys_AIM] decimal NOT NULL, -- Amount in multiple of value
	[Sys_FC1] decimal NOT NULL, -- Fast cash value level 1
	[Sys_FC2] decimal NOT NULL, -- Fast cash value level 2
	[Sys_FC3] decimal NOT NULL, -- Fast cash value level 3
	[Sys_FC4] decimal NOT NULL, -- Fast cash value level 4
	[Sys_FC5] decimal NOT NULL, -- Fast cash value level 5
	[Sys_FC6] decimal NOT NULL, -- Fast cash value level 6
)
--- create table - TB_SYSTEM_REPORT ---
GO
CREATE TABLE [SYSTEM_REPORT]
(
	[Rep_ID] INT IDENTITY PRIMARY KEY,
	[Rep_Title] VARCHAR(100),
	[Rep_Description] VARCHAR(MAX),
	[Rep_Time] DATETIME DEFAULT(GETDATE())
)

insert into [Bank_Info] values(1,'Aptech Bank','19 Nguyen Trai','0123456789','0123456789')
insert into [ATM_Info] values(1,1,25000,25000,5,5,100000,20,20,50,100,150,300,500)


GO

CREATE PROC [sp_insert_system_report]
	@sTitle VARCHAR(1000),
	@sDescription VARCHAR(MAX) = ''
AS
BEGIN
	INSERT INTO [SYSTEM_REPORT]([Rep_Title], [Rep_Description])
		VALUES(@sTitle, @sDescription)
END

--- create procedure - sp_create_new_user ---
GO

CREATE PROC [sp_create_new_user]
	@sAccNo VARCHAR(16),
	@sPIN VARCHAR(40),
	@fBalance Decimal,
	@sFullName VARCHAR(40),
	@sIdCardNo VARCHAR(9),
	@bGender bit,
	@dDoB DATETIME,	
	@sPhone VARCHAR(15),
	@sAddress VARCHAR(300)

AS
BEGIN
	INSERT INTO [User]([User_IDCard], [User_Name], [User_DoB],
							[User_Gender], [User_Phone], [User_Address])
		VALUES (@sIdCardNo, @sFullName, @dDoB,
					@bGender, @sPhone, @sAddress)
	
	DECLARE @nUserID INT
	SET @nUserID = (SELECT [User_ID] FROM [User] WHERE [User_IDCard] = @sIdCardNo)
	INSERT INTO [Account]([User_ID], [Acc_No], [Acc_PIN], [Acc_Balance],[Bank_ID])
		VALUES(@nUserID, @sAccNo, @sPIN, @fBalance,1)
	DECLARE @nAccID INT
	SET @nAccID = (SELECT [Acc_ID] FROM [Account] WHERE [User_ID] = @nUserID)
	DECLARE @sDes VARCHAR(100)
	SET @sDes = ('System created successful a new User ID ' 
					+ CONVERT(VARCHAR(10),@nUserID)
					+ ' (Account ID ' 
					+ CONVERT(VARCHAR(10),@nAccID) + ')')
	EXEC [sp_insert_system_report] 'System', @sDes
END

--- create procedure - sp_edit_user_info ---
go
create PROC [sp_edit_user_info]
	@nIDCard Varchar(9),
	@bGender bit,
	@sFullName VARCHAR(40),
	@sPhone VARCHAR(15),
	@sAddress VARCHAR(300)

	
AS
BEGIN
	UPDATE [USER]
		SET [User_Gender] = @bGender,
			[User_Name] = @sFullName,
			[User_Phone] = @sPhone,
			[User_Address] = @sAddress
			
			
		WHERE [User_IDCard] = @nIDCard
	DECLARE @sDes VARCHAR(100)
	SET @sDes = ('Update information successful for User Name: ' 
					+ CONVERT(VARCHAR(40),@sFullName)
					+ ' (User IDCard ' 
					+ CONVERT(VARCHAR(9),@nIDCard) + ')')
	EXEC sp_insert_system_report 'System', @sDes
END


--- create procedure - sp_reset_pin ---
GO
CREATE PROC [sp_reset_pin]	
	@nAccID INT,
	@sAccPIN VARCHAR(40)
AS
BEGIN
	UPDATE [ACCOUNT]
	SET [Acc_PIN] = @sAccPIN
	WHERE [Acc_ID] = @nAccID	
	DECLARE @sDes VARCHAR(100)
	SET @sDes = ('Administrator '+  ' reset PIN of Account ID '
					+ CONVERT(VARCHAR(10),@nAccID))
	EXEC sp_insert_system_report 'Account', @sDes
END
--- create procedure - sp_set_status_acc ---
GO
Create PROC [sp_set_status_acc]
	@bStatus bit,
	@nAccID INT

AS	
BEGIN
	UPDATE [ACCOUNT]
	SET [Acc_Status] = @bStatus
	WHERE [Acc_ID] = @nAccID 
	DECLARE @sDes VARCHAR(100)			
			IF @bStatus = 1
				BEGIN
				SET @sDes = ('Administrator'			
								+ ' set status(Enable) Account ID ' 
								+ CONVERT(VARCHAR(10),@nAccID))
				END
			ELSE
				BEGIN
				SET @sDes = ('Administrator ' 
								+ 'set status(Disable) Account ID ' 
								+ CONVERT(VARCHAR(10),@nAccID))
				END
			EXEC sp_insert_system_report 'System', @sDes
	
END


--- create procedure - sp_change_pin ---
GO
Create PROC sp_change_pin
	@nAccID INT,
	@snewPIN VARCHAR(40)
AS
BEGIN
	UPDATE [Account]
		SET [Acc_PIN] = @snewPIN
		WHERE [Acc_ID] = @nAccID 
	DECLARE @sDes VARCHAR(100)
		SET @sDes = ('Account ID ' 
						+ CONVERT(VARCHAR(10),@nAccID)
						+ ': change PIN')
	EXEC sp_insert_system_report 'Account', @sDes
END

--- create procedure - sp_transaction ---
GO
create PROC [sp_transaction]
	@bType int,
	@nAccID INT,
	@fAmount decimal,
	@sReason VARCHAR(MAX) = ''
AS
BEGIN
	DECLARE @fTranBalance Decimal
	DECLARE @fAccBalance Decimal
	--
	SET @fAccBalance = (SELECT [Acc_Balance]
								 FROM [ACCOUNT]
								 WHERE [Acc_ID] = @nAccID)
	--
	DECLARE @sDes VARCHAR(100)
	
	IF (@bType = 1)
	BEGIN
		SET @fTranBalance = @fAccBalance - @fAmount
				SET @sReason = 'ATM System: Cash Withdraw'
				SET @sDes = ('Account ID ' 
							+ CONVERT(VARCHAR(10),@nAccID )
							+ ': withdraw $' 
							+ CONVERT(VARCHAR(20),@fAmount)
							+ ' .Balance: $' + 
							+ CONVERT(VARCHAR(20),@fTranBalance))
				EXEC sp_insert_system_report 'Transaction', @sDes
			
	END
	IF(@bType = 0)
	BEGIN
		SET @fTranBalance = @fAccBalance + @fAmount	
				SET @sReason = 'ATM System: Cash Deposit'
				SET @sDes = ('Account ID ' 
							+ CONVERT(VARCHAR(10),@nAccID)
							+ ': deposit $' 
							+ CONVERT(VARCHAR(20),@fAmount)
							+ ' .Balance: $' 
							+ CONVERT(VARCHAR(20),@fTranBalance))
				EXEC sp_insert_system_report 'Transaction', @sDes
			
	END
	--
	INSERT INTO [TRANSACTION]([Tran_Type], [Acc_From_ID]
									, [Tran_Reason]
									, [Tran_Amount], [Tran_Balance])
		VALUES(@bType, @nAccID
				, @sReason
				, @fAmount, @fTranBalance)
	--
	UPDATE [ACCOUNT]
		SET [Acc_Balance] = @fTranBalance
		WHERE [Acc_ID] = @nAccID
	
END
--- create procedure - sp_fund_transfer ---
GO
create PROC [sp_fund_transfer]
	@nFromAccID INT,
	@nToAccID INT,
	@fAmount decimal,
	@sReason1 VARCHAR(MAX) = '',
	@sReason2 VARCHAR(MAX) = ''

	
AS
BEGIN
	DECLARE @fFromAccBalance decimal
	DECLARE @fToAccBalance decimal
	--
	SET @fFromAccBalance = (SELECT [Acc_Balance] 
									FROM [ACCOUNT] 
									WHERE [Acc_ID] = @nFromAccID)
	SET @fToAccBalance = (SELECT [Acc_Balance] 
									FROM [ACCOUNT]
									WHERE [Acc_ID] = @nToAccID)
	--
	DECLARE @sDes VARCHAR(1000)		
	SET @sReason1 = ('ATM System : Transfer money to Account ID ' 
						+ CONVERT(VARCHAR(10),@nToAccID))
	SET @sReason2 = ('ATM System : Received money from Account ID ' 
						+ CONVERT(VARCHAR(10),@nFromAccID))							
	SET @sDes = ('Account ID ' 
				+ CONVERT(VARCHAR(10),@nFromAccID)
				+ ': transfer $' 
				+ CONVERT(VARCHAR(20),@fAmount)
				+ ' to Account ID ' 
				+ CONVERT(VARCHAR(10),@nToAccID))
	EXEC sp_insert_system_report 'Transaction', @sDes
	
	--
	INSERT INTO [TRANSACTION]([Tran_Type], [Acc_To_ID]
									, [Acc_From_ID], [Tran_Reason]
									, [Tran_Amount], [Tran_Balance])
		VALUES(2, @nFromAccID
				, @nToAccID, @sReason2
				, @fAmount, @fFromAccBalance - @fAmount)
	--
	INSERT INTO [TRANSACTION]([Tran_Type], [Acc_To_ID]
									, [Acc_from_ID], [Tran_Reason]
									, [Tran_Amount], [Tran_Balance])
		VALUES(2, @nToAccID
				, @nFromAccID, @sReason1
				, @fAmount, @fToAccBalance + @fAmount)
	--
	UPDATE [ACCOUNT]
		SET [Acc_Balance] = @fFromAccBalance - @fAmount
		WHERE [Acc_ID] = @nFromAccID
	UPDATE [ACCOUNT]
		SET [Acc_Balance] = @fToAccBalance + @fAmount
		WHERE [Acc_ID] = @nToAccID
	
END








/*select * from SYSTEM_REPORT
select * from account
select * from [user]
select * from [transaction]

update Account set Acc_PIN =1111 where Acc_ID=1 and Acc_PIN =2071

SELECT COUNT([tran_type]) FROM [transaction]
WHERE [tran_date] >= CONVERT(varchar, GETDATE(),101) 
AND [Acc_From_ID] = 1
and [Tran_Type]=0 */




