CREATE USER Manager WITHOUT LOGIN;
GO
CREATE USER Joe WITHOUT LOGIN;
GO
CREATE USER DataScienceUser WITHOUT LOGIN;
GO
    
GRANT SELECT ON dbo.Transactions TO Manager;
GRANT SELECT ON dbo.Transactions TO Joe;
GO

CREATE SCHEMA Security;  
GO   
  
CREATE FUNCTION Security.fn_securitypredicate(@SALES_PERSON AS sysname)  
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN SELECT 1 AS fn_securitypredicate_result
WHERE @SALES_PERSON = USER_NAME() OR USER_NAME() = 'Manager' OR USER_NAME() = 'DataScienceUser';
GO

CREATE SECURITY POLICY TransactionsFilter  
ADD FILTER PREDICATE Security.fn_securitypredicate(SALES_PERSON)
ON dbo.Transactions  
WITH (STATE = ON);
GO

GRANT SELECT ON security.fn_securitypredicate TO Manager;  
GRANT SELECT ON security.fn_securitypredicate TO Joe;
GO

GRANT SELECT ON Transactions(
    [TRANSACTION_DATE], 
    [QUANTITY], 
    [PRODUCT_CODE], 
    [PRODUCT_CATEGORY], 
    [PRODUCT_NAME], 
    [PRODUCT_PRICE], 
    [LINE_TOTAL], 
    [PAYMENT_TYPE], 
    [USED_COUPON], 
    [USED_GIFT_CARD], 
    [COUPON_CODE], 
    [SALES_PERSON], 
    [STORE_ID]) TO DataScienceUser;
GO