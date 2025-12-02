BEGIN TRY

BEGIN TRAN;

-- CreateTable
CREATE TABLE [dbo].[user] (
    [user_id] VARCHAR(16) NOT NULL,
    [name] NVARCHAR(128) NOT NULL,
    [email] VARCHAR(64),
    [password_hash] VARCHAR(64) NOT NULL,
    [phone] VARCHAR(16),
    [role] VARCHAR(32) NOT NULL,
    [registration_date] DATE NOT NULL,
    CONSTRAINT [user_pkey] PRIMARY KEY CLUSTERED ([user_id]),
    CONSTRAINT [user_email_key] UNIQUE NONCLUSTERED ([email])
);

COMMIT TRAN;

END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
BEGIN
    ROLLBACK TRAN;
END;
THROW

END CATCH
