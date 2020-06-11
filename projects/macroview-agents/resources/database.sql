
-- 导出  表 macroview_doc_agent.agent_info 结构
CREATE TABLE IF NOT EXISTS `agent_info` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `status` varchar(30) DEFAULT NULL,
  `uploadTotal` bigint(20) DEFAULT NULL,
  `lastHeartbeatTime` bigint(20) DEFAULT NULL,
  `retryCount` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `agentId` varchar(255) DEFAULT NULL,
  `agentIp` varchar(255) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `lastStartup` bigint(20) DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  `createTime` datetime DEFAULT NULL,
  `baseUrl` varchar(255) DEFAULT NULL,
  `position` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- 导出  表 macroview_doc_agent.agent_update_info 结构
CREATE TABLE IF NOT EXISTS `agent_update_info` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `docAgentId` varchar(255) DEFAULT NULL,
  `status` varchar(30) DEFAULT NULL,
  `lastHeartbeatTime` bigint(20) DEFAULT NULL,
  `retryCount` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `agentId` varchar(255) DEFAULT NULL,
  `agentIp` varchar(255) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `lastStartup` bigint(20) DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  `baseUrl` varchar(255) DEFAULT NULL,
  `createTime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- 导出  表 macroview_doc_agent.agent_update_schedule 结构
CREATE TABLE IF NOT EXISTS `agent_update_schedule` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `versionId` varchar(255) DEFAULT NULL,
  `scheduleId` varchar(255) DEFAULT NULL,
  `date` bigint(20) DEFAULT NULL,
  `force` tinyint(1) DEFAULT NULL,
  `status` varchar(30) DEFAULT NULL,
  `agents` json DEFAULT NULL,
  `createTime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;

-- 导出  表 macroview_doc_agent.agent_versions 结构
CREATE TABLE IF NOT EXISTS `agent_versions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `versionId` varchar(255) DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  `status` varchar(30) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `files` json DEFAULT NULL,
  `createTime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

-- 导出  表 macroview_doc_agent.sysconfig 结构
CREATE TABLE IF NOT EXISTS `sysconfig` (
  `Id` bigint(11) unsigned NOT NULL AUTO_INCREMENT,
  `dataType` varchar(30) NOT NULL DEFAULT '',
  `name` varchar(250) NOT NULL DEFAULT '',
  `value` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

-- 正在导出表  macroview_doc_agent.sysconfig 的数据：~11 rows (大约)
DELETE FROM `sysconfig`;
/*!40000 ALTER TABLE `sysconfig` DISABLE KEYS */;
INSERT INTO `sysconfig` (`dataType`, `name`, `value`) VALUES
	('LoginConfig', 'PassRequest', '/v1/**');
/*!40000 ALTER TABLE `sysconfig` ENABLE KEYS */;

-- 导出  表 macroview_doc_agent.uiproperties 结构
CREATE TABLE IF NOT EXISTS `uiproperties` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `category` varchar(50) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `group` varchar(30) DEFAULT NULL,
  `title` varchar(250) DEFAULT NULL,
  `content` text,
  `sequence` int(11) DEFAULT NULL,
  `images` varchar(255) DEFAULT '',
  `classes` varchar(250) DEFAULT '',
  `url` varchar(250) DEFAULT '',
  `active` tinyint(4) DEFAULT NULL,
  `tagId` varchar(50) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL,
  `helper` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- 正在导出表  macroview_doc_agent.uiproperties 的数据：~6 rows (大约)
DELETE FROM `uiproperties`;
/*!40000 ALTER TABLE `uiproperties` DISABLE KEYS */;
INSERT INTO `uiproperties` (`category`, `name`, `group`, `title`, `content`, `sequence`, `images`, `classes`, `url`, `active`, `tagId`, `role`, `helper`) VALUES
	('MainMenu', 'Agent Manager', '1', 'Agent Manager', '1', 1, 'glyphicon glyphicon-modal-window', '', '/agent/index', 0, 'AgentManager', 'Admin', NULL),
	('MainMenu', 'Agent Versions', '1', 'Agent Versions', '1', 2, 'glyphicon glyphicon-duplicate', '', '/agent-version/index', 0, 'AgentVersionManager', 'Admin', NULL);
/*!40000 ALTER TABLE `uiproperties` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
