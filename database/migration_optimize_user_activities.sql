-- Storage optimization for user activity logs (backward compatible)
-- - Deduplicate user agents into a separate table
-- - Store IP in binary form (IPv4/IPv6) for compact storage + indexing
-- - Add helpful indexes for faster filtering

-- 1) User agents table (dedupe)
CREATE TABLE IF NOT EXISTS `user_agents` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_agent_hash` CHAR(64) NOT NULL,
  `user_agent` TEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_agents_hash` (`user_agent_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 2) Add optimized columns to user_activities (keep legacy columns for compatibility)
ALTER TABLE `user_activities`
  ADD COLUMN IF NOT EXISTS `user_agent_id` INT(11) NULL AFTER `user_agent`,
  ADD COLUMN IF NOT EXISTS `ip_address_bin` VARBINARY(16) NULL AFTER `ip_address`,
  ADD KEY `idx_user_activities_user_created` (`user_id`, `created_at`),
  ADD KEY `idx_user_activities_action_created` (`action`, `created_at`),
  ADD KEY `idx_user_activities_created` (`created_at`),
  ADD KEY `idx_user_activities_user_agent_id` (`user_agent_id`);

-- 3) Backfill ip_address_bin from ip_address (best-effort)
UPDATE `user_activities`
SET `ip_address_bin` = INET6_ATON(`ip_address`)
WHERE `ip_address_bin` IS NULL
  AND `ip_address` IS NOT NULL
  AND `ip_address` <> '';

-- 4) Backfill user_agent_id by inserting distinct user agents (best-effort)
INSERT IGNORE INTO `user_agents` (`user_agent_hash`, `user_agent`)
SELECT SHA2(`user_agent`, 256) AS `user_agent_hash`, `user_agent`
FROM `user_activities`
WHERE `user_agent` IS NOT NULL AND `user_agent` <> ''
GROUP BY SHA2(`user_agent`, 256), `user_agent`;

UPDATE `user_activities` ua
JOIN `user_agents` uag
  ON uag.user_agent_hash = SHA2(ua.user_agent, 256)
SET ua.user_agent_id = uag.id
WHERE ua.user_agent_id IS NULL
  AND ua.user_agent IS NOT NULL
  AND ua.user_agent <> '';

-- OPTIONAL: once you've verified everything, you can reduce storage further by nulling legacy user_agent
-- UPDATE user_activities SET user_agent = NULL WHERE user_agent_id IS NOT NULL;


