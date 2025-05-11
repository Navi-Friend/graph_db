USE master

DROP DATABASE IF EXISTS DeFi;
GO
CREATE DATABASE DeFi;
GO
USE DeFi;

-- 1. Создание таблиц узлов

CREATE TABLE Tokens (
	TokenID INT PRIMARY KEY NOT NULL,
	Name NVARCHAR(32) NOT NULL,
	TotalSupply DECIMAL(18, 2) NOT NULL
) AS NODE;
GO

CREATE TABLE Wallets (
	WalletID INT PRIMARY KEY NOT NULL,
	Address NVARCHAR(100) NOT NULL,
	OwnerName NVARCHAR(100) NOT NULL
) AS NODE;
GO

CREATE TABLE SmartContracts (
	ContractID INT PRIMARY KEY NOT NULL,
	ContractName NVARCHAR(100) NOT NULL,
	ProtocolType NVARCHAR(50) NOT NULL
) AS NODE;
GO

-- 2. Создание таблиц ребер

CREATE TABLE Holds(
	Amount DECIMAL(18, 2) NOT NULL
) AS EDGE;
GO

ALTER TABLE Holds ADD CONSTRAINT EC_Holds CONNECTION (Wallets TO Tokens);
GO

CREATE TABLE Transfers (
	TokenID INT REFERENCES Tokens(TokenID) NOT NULL,
	Amount DECIMAL(18, 2) NOT NULL,
	TransferDate DATETIME NOT NULL
) AS EDGE;
GO

ALTER TABLE Transfers ADD CONSTRAINT EC_Transfers CONNECTION (Wallets TO Wallets);
GO

CREATE TABLE Calls (
	FunctionName NVARCHAR(50) NOT NULL,
	TransactionHash NVARCHAR(66) NOT NULL,
	Amount DECIMAL(18, 2) NOT NULL,
	CallDate DATETIME NOT NULL
) AS EDGE;
GO

ALTER TABLE Calls ADD CONSTRAINT EC_Calls CONNECTION (Wallets TO SmartContracts);
GO

-- 3. Заполнение таблиц узлов

INSERT INTO Wallets (WalletID, Address, OwnerName) VALUES 
(1, '34xp4vRoCGJym3xR7yCVPFHoCNxv4Twseo', 'Иван Сидоров'), 
(2, 'bc1ql49ydapnjafl5t2cp9zqpjwe6pdgmxy98859v2', 'Мария Коваленко'), 
(3, 'bc1qgdjqv0av3q56jvd82tkdjpy7gdp9ut8tlqmgrpmv24sq90ecnvqqjwvw97', 'Алексей Романов'), 
(4, '3M219KR5vEneNb47ewrPfWyb5jQ2DjxRP6', 'Елена Григорьева'), 
(5, 'bc1qazcm763858nkj2dj986etajv6wquslv8uxwczt', 'Дмитрий Волков'), 
(6, 'bc1qjasf9z3h7w3jspkhtgatgpyvvzgpa2wwd2lr0eh5tx44reyn2k7sfc27a4', 'Анна Лебедева'), 
(7, '1FeexV6bAHb8ybZjqQMjJrcCrHGW9sb6uF', 'Сергей Павлов'), 
(8, 'bc1q8yj0herd4r4yxszw3nkfvt53433thk0f5qst4g', 'Ольга Зайцева'), 
(9, 'bc1qa5wkgaew2dkv56kfvj49j0av5nml45x9ek9hz6', 'Павел Морозов'), 
(10, '3LYJfcfHPXYJreMsASk2jkn69LWEYKzexb', 'Наталья Соколова');
GO

INSERT INTO Tokens (TokenID, Name, TotalSupply) VALUES
(1, 'ETH', 120000000.00),
(2, 'USDT', 80000000000.00),
(3, 'UNI', 1000000000.00),
(4, 'DAI', 9000000000.00),
(5, 'LINK', 1000000000.00),
(6, 'AAVE', 16000000.00),
(7, 'WBTC', 200000.00),
(8, 'MATIC', 10000000000.00),
(9, 'CRV', 2000000000.00),
(10, 'COMP', 10000000.00);
GO

INSERT INTO SmartContracts (ContractID, ContractName, ProtocolType) VALUES
(1, 'Uniswap V3', 'DEX'),
(2, 'Aave V3', 'Lending'),
(3, 'Compound', 'Lending'),
(4, 'Curve Finance', 'DEX'),
(5, 'SushiSwap', 'DEX'),
(6, 'MakerDAO', 'Stablecoin'),
(7, 'Yearn Finance', 'Yield Farming'),
(8, 'Balancer', 'DEX'),
(9, 'Synthetix', 'Derivatives'),
(10, 'PancakeSwap', 'DEX');
GO

-- 4. Заполнение таблиц ребер

INSERT INTO Holds ($from_id, $to_id, Amount) VALUES
((SELECT $node_id FROM Wallets WHERE WalletID = 1), (SELECT $node_id FROM Tokens WHERE TokenID = 1), 10.12),
((SELECT $node_id FROM Wallets WHERE WalletID = 1), (SELECT $node_id FROM Tokens WHERE TokenID = 10), 1.12),
((SELECT $node_id FROM Wallets WHERE WalletID = 1), (SELECT $node_id FROM Tokens WHERE TokenID = 3), 321.12),
((SELECT $node_id FROM Wallets WHERE WalletID = 2), (SELECT $node_id FROM Tokens WHERE TokenID = 1), 1123),
((SELECT $node_id FROM Wallets WHERE WalletID = 3), (SELECT $node_id FROM Tokens WHERE TokenID = 5), 12),
((SELECT $node_id FROM Wallets WHERE WalletID = 4), (SELECT $node_id FROM Tokens WHERE TokenID = 7), 1123.12),
((SELECT $node_id FROM Wallets WHERE WalletID = 5), (SELECT $node_id FROM Tokens WHERE TokenID = 2), 140.12),
((SELECT $node_id FROM Wallets WHERE WalletID = 6), (SELECT $node_id FROM Tokens WHERE TokenID = 9), 1058.02),
((SELECT $node_id FROM Wallets WHERE WalletID = 7), (SELECT $node_id FROM Tokens WHERE TokenID = 4), 130.11),
((SELECT $node_id FROM Wallets WHERE WalletID = 8), (SELECT $node_id FROM Tokens WHERE TokenID = 6), 110.2),
((SELECT $node_id FROM Wallets WHERE WalletID = 9), (SELECT $node_id FROM Tokens WHERE TokenID = 8), 111230.21),
((SELECT $node_id FROM Wallets WHERE WalletID = 10), (SELECT $node_id FROM Tokens WHERE TokenID = 2), 1410.23),
((SELECT $node_id FROM Wallets WHERE WalletID = 10), (SELECT $node_id FROM Tokens WHERE TokenID = 3), 11310.42)
GO

INSERT INTO Transfers ($from_id, $to_id, TokenID, Amount, TransferDate) VALUES
((SELECT $node_id FROM Wallets WHERE WalletID = 1), (SELECT $node_id FROM Wallets WHERE WalletID = 2), 1, 1.0, '2025-05-01 12:35:29.123'),
((SELECT $node_id FROM Wallets WHERE WalletID = 2), (SELECT $node_id FROM Wallets WHERE WalletID = 3), 2, 1000.0, '2025-05-02 22:35:29.123'),
((SELECT $node_id FROM Wallets WHERE WalletID = 3), (SELECT $node_id FROM Wallets WHERE WalletID = 4), 3, 50.0, '2025-05-03 12:35:29.131'),
((SELECT $node_id FROM Wallets WHERE WalletID = 4), (SELECT $node_id FROM Wallets WHERE WalletID = 5), 4, 500.0, '2025-05-04 16:15:29.123'),
((SELECT $node_id FROM Wallets WHERE WalletID = 5), (SELECT $node_id FROM Wallets WHERE WalletID = 6), 5, 2.0, '2025-05-05 14:54:21.123'),
((SELECT $node_id FROM Wallets WHERE WalletID = 6), (SELECT $node_id FROM Wallets WHERE WalletID = 7), 3, 121.0, '2025-05-01 14:54:21.331'),
((SELECT $node_id FROM Wallets WHERE WalletID = 7), (SELECT $node_id FROM Wallets WHERE WalletID = 8), 7, 325.31, '2025-05-02 23:54:21.123'),
((SELECT $node_id FROM Wallets WHERE WalletID = 8), (SELECT $node_id FROM Wallets WHERE WalletID = 9), 6, 5021.02, '2025-05-03 20:54:21.123'),
((SELECT $node_id FROM Wallets WHERE WalletID = 9), (SELECT $node_id FROM Wallets WHERE WalletID = 10), 4, 500.0, '2025-05-04 14:01:21.123'),
((SELECT $node_id FROM Wallets WHERE WalletID = 10), (SELECT $node_id FROM Wallets WHERE WalletID = 1), 5, 2.0, '2025-05-05 12:04:11.123');
GO

INSERT INTO Calls ($from_id, $to_id, FunctionName, TransactionHash, Amount, CallDate) VALUES
((SELECT $node_id FROM Wallets WHERE WalletID = 1), (SELECT $node_id FROM SmartContracts WHERE ContractID = 1), N'swap', 'eexV6bAHb8ybZjqQMjJrcCrHGW9sb', 1.23, '2024-05-08 12:35:29.123'),
((SELECT $node_id FROM Wallets WHERE WalletID = 2), (SELECT $node_id FROM SmartContracts WHERE ContractID = 3), N'deposit', 'asdfeexV6bAHb8ybZjqQMjasdfsadfaJrcCrHGW9sb', 112300.23, '2025-05-08 12:35:29.123'),
((SELECT $node_id FROM Wallets WHERE WalletID = 3), (SELECT $node_id FROM SmartContracts WHERE ContractID = 6), N'stake', 'adgkfjnfbsfd.kfAHb8ybZjqQMjasdfsadfaJrcCrHGW9sb', 168600.23, '2025-08-08 12:35:29.523'),
((SELECT $node_id FROM Wallets WHERE WalletID = 4), (SELECT $node_id FROM SmartContracts WHERE ContractID = 8), N'borrow', 'asdf8ybZjqQMjasdfsadfaJrcCrHGW9sb', 522.25, '2025-02-08 13:35:29.123'),
((SELECT $node_id FROM Wallets WHERE WalletID = 8), (SELECT $node_id FROM SmartContracts WHERE ContractID = 2), N'swap', '284yfsadfKJHjhh123KJakfjk', 321.25, '2025-01-08 13:35:29.123')
GO

-- 5. Запросы с использованием MATCH

-- Найти все кошельки, владеющие токеном ETH
SELECT 
    w.WalletID, 
    w.OwnerName, 
    h.Amount
FROM Wallets AS w, Tokens AS t, Holds AS h
WHERE MATCH(w-(h)->t)
    AND t.Name = 'ETH';
GO


-- Найти кошельки, которые взаимодействовали с Uniswap V3
SELECT 
    w.WalletID, 
    w.OwnerName, 
    c.FunctionName, 
    c.Amount
FROM Wallets AS w, SmartContracts AS sc, Calls AS c
WHERE MATCH(w-(c)->sc)
    AND sc.ContractID = 1
    AND sc.ContractName = 'Uniswap V3';
GO


-- Найти все переводы токена USDT между кошельками
SELECT 
    sender.WalletID AS SenderID, 
    sender.OwnerName AS SenderName, 
    receiver.WalletID AS ReceiverID, 
    receiver.OwnerName AS ReceiverName, 
    t.Amount
FROM Wallets AS sender, Wallets AS receiver, Transfers AS t, Tokens AS tok
WHERE MATCH(sender-(t)->receiver)
    AND t.TokenID = tok.TokenID
    AND tok.TokenID = 2
    AND tok.Name = 'USDT';
GO


-- Найти кошельки, владеющие более 1000 единиц любого токена
SELECT w.WalletID,
	   w.OwnerName,
	   t.Name AS TokenName, 
	   h.Amount
FROM Wallets w, Tokens t, Holds h
WHERE MATCH(w-(h)->t)
	AND h.Amount > 1000
GO


-- Найти цепочку переводов, начинающихся с Ивана Сидорова
SELECT 
    sender.WalletID AS SenderID, 
    sender.OwnerName AS SenderName, 
    receiver.WalletID AS ReceiverID, 
    receiver.OwnerName AS ReceiverName, 
    tok.Name AS TokenName, 
    t.Amount
FROM Wallets AS sender, Wallets AS receiver, Transfers AS t, Tokens AS tok
WHERE MATCH(sender-(t)->receiver)
    AND sender.WalletID = 1
    AND sender.OwnerName = 'Иван Сидоров'
    AND t.TokenID = tok.TokenID;
GO

-- 6. Запросы с использованием функции SHORTEST_PATH

-- Найти кратчайший путь переводов от Ивана Сидорова к Наталье Соколовой
WITH T1 AS (
	SELECT 
		sender.WalletID AS StartWalletID, 
		sender.OwnerName AS StartWalletName, 
		LAST_VALUE(receiver.WalletID) WITHIN GROUP (GRAPH PATH) AS EndWalletID, 
		LAST_VALUE(receiver.OwnerName) WITHIN GROUP (GRAPH PATH) AS EndWalletName,
		STRING_AGG(CAST(t.Amount AS NVARCHAR) + ' ' + receiver.OwnerName, ' -> ') WITHIN GROUP (GRAPH PATH) AS PathDetails
	FROM Wallets AS sender, 
		 Wallets FOR PATH AS receiver, 
		 Transfers FOR PATH AS t,
		 Tokens AS tok
	WHERE MATCH(SHORTEST_PATH(sender(-(t)->receiver)+))
		AND sender.WalletID = 1
		AND sender.OwnerName = 'Иван Сидоров'
)
SELECT TOP(1) *
FROM T1
WHERE EndWalletName = 'Наталья Соколова'
      AND EndWalletID = 10
GO


-- Найти кратчайший путь переводов от Марии Коваленко к Дмитрию Волкову с максимум 3 шагами
WITH T1 AS (
	SELECT 
		sender.WalletID AS StartWalletID, 
		sender.OwnerName AS StartWalletName, 
		LAST_VALUE(receiver.WalletID) WITHIN GROUP (GRAPH PATH) AS EndWalletID, 
		LAST_VALUE(receiver.OwnerName) WITHIN GROUP (GRAPH PATH) AS EndWalletName, 
		STRING_AGG(CAST(t.Amount AS NVARCHAR) + ' ' + receiver.OwnerName, ' -> ') WITHIN GROUP (GRAPH PATH) AS PathDetails
	FROM Wallets AS sender,
		 Wallets FOR PATH AS receiver, 
		 Transfers FOR PATH AS t,
		 Tokens AS tok
	WHERE MATCH(SHORTEST_PATH(sender(-(t)->receiver){1,4}))
		AND sender.WalletID = 2
		AND sender.OwnerName = 'Мария Коваленко'
)
SELECT TOP(1) *
FROM T1
WHERE EndWalletName = 'Анна Лебедева'
GO