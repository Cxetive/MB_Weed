CREATE TABLE IF NOT EXISTS `dopeplants` (
  `owner` varchar(50) NOT NULL,
  `plant` longtext NOT NULL,
  `plantid` bigint(20) NOT NULL
);


INSERT INTO `items` (`name`,`label`,`weight`) VALUES
	('highgradeogkushseedmale', 'Goeie OG Kush zaadje Man', -1),
	('lowgradeogkushseedmale', 'Slechte OG Kush zaadje Man', -1),
	('highgradefert', 'Goeie Voeding', -1),
	('lowgradefert', 'Slechte Voeding', -1),
	('purifiedwater', 'gezuiverd water', -1),
	('wateringcan', 'gieter', -1),
	('plantpot', 'plantenpot', -1),
	('trimmedweed', 'Geknipte wiet', -1),
	('dopebag', 'Leeg zakje', -1),
	('bagofdope', 'Zakje Wiet', -1),
	('drugscales', 'Wiet Weegschaal', -1);


--Rodguefer#6826 para mais informações