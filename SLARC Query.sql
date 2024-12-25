-- __/\\\\\\\\\\\__/\\\\\_____/\\\__/\\\\\\\\\\\\\\\____/\\\\\_________/\\\\\\\\\_________/\\\\\\\________/\\\\\\\________/\\\\\\\________/\\\\\\\\\\________________/\\\\\\\\\_______/\\\\\\\\\_____        
--  _\/////\\\///__\/\\\\\\___\/\\\_\/\\\///////////___/\\\///\\\_____/\\\///////\\\_____/\\\/////\\\____/\\\/////\\\____/\\\/////\\\____/\\\///////\\\_____________/\\\\\\\\\\\\\___/\\\///////\\\___       
--   _____\/\\\_____\/\\\/\\\__\/\\\_\/\\\____________/\\\/__\///\\\__\///______\//\\\___/\\\____\//\\\__/\\\____\//\\\__/\\\____\//\\\__\///______/\\\_____________/\\\/////////\\\_\///______\//\\\__      
--    _____\/\\\_____\/\\\//\\\_\/\\\_\/\\\\\\\\\\\___/\\\______\//\\\___________/\\\/___\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\_________/\\\//_____________\/\\\_______\/\\\___________/\\\/___     
--     _____\/\\\_____\/\\\\//\\\\/\\\_\/\\\///////___\/\\\_______\/\\\________/\\\//_____\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\________\////\\\____________\/\\\\\\\\\\\\\\\________/\\\//_____    
--      _____\/\\\_____\/\\\_\//\\\/\\\_\/\\\__________\//\\\______/\\\______/\\\//________\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\___________\//\\\___________\/\\\/////////\\\_____/\\\//________   
--       _____\/\\\_____\/\\\__\//\\\\\\_\/\\\___________\///\\\__/\\\______/\\\/___________\//\\\____/\\\__\//\\\____/\\\__\//\\\____/\\\___/\\\______/\\\____________\/\\\_______\/\\\___/\\\/___________  
--        __/\\\\\\\\\\\_\/\\\___\//\\\\\_\/\\\_____________\///\\\\\/______/\\\\\\\\\\\\\\\__\///\\\\\\\/____\///\\\\\\\/____\///\\\\\\\/___\///\\\\\\\\\/_____________\/\\\_______\/\\\__/\\\\\\\\\\\\\\\_ 
--         _\///////////__\///_____\/////__\///________________\/////_______\///////////////_____\///////________\///////________\///////_______\/////////_______________\///________\///__\///////////////__

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1
SELECT postPermanentID, text
FROM post
WHERE postPermanentID NOT IN (
    SELECT postID
    FROM react
);
-- END Q1
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2
SELECT m.modID, u.username, m.dateModStatus
FROM moderator m
JOIN user u
    ON m.linkedUserID = u.userID
ORDER BY m.dateModStatus DESC
LIMIT 1;
-- END Q2
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3
SELECT postPermanentID, viewCount
FROM post
WHERE authorID IN (
    SELECT userID
    FROM user
    WHERE username = 'axe'
) 
AND viewCount >= 9000;
-- END Q3
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q4
SELECT originalPostID as postPermanentID, COUNT(*) AS totalCommentCount
FROM postreply
GROUP BY originalPostID
HAVING COUNT(*) = (
    SELECT MAX(commentCount)
    FROM (
        SELECT COUNT(*) AS commentCount
        FROM postreply
        GROUP BY originalPostID
    ) AS counts
);
-- END Q4
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q5
SELECT a.dataURL, pc.channelID
FROM attachmentobject a
JOIN postchannel pc
    ON a.postPermanentID = pc.postID
WHERE pc.channelID IN (
    SELECT channelID
    FROM channel
    WHERE channelName LIKE '%dota2%'
);
-- END Q5
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q6
SELECT c.channelName, COUNT(r.emoji) AS heartCount
FROM channel c
JOIN postchannel pc ON c.channelID = pc.channelID
JOIN react r ON pc.postID = r.postID
WHERE r.emoji = 'love'
GROUP BY c.channelID
HAVING COUNT(r.emoji) = (
    SELECT MAX(heartCount)
    FROM (
        SELECT COUNT(r2.emoji) AS heartCount
        FROM channel c2
        JOIN postchannel pc2 ON c2.channelID = pc2.channelID
        JOIN react r2 ON pc2.postID = r2.postID
        WHERE r2.emoji = 'love'
        GROUP BY c2.channelID
    ) AS maxHearts
);
-- END Q6
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q7
SELECT u.userID, u.reputation, 
       COUNT(DISTINCT mr.caseID) AS totalModeratorReports,
       COUNT(CASE WHEN r.emoji = 'love' THEN 1 END) AS totalLoveReacts
FROM user u
JOIN post p ON u.userID = p.authorID
LEFT JOIN moderatorreport mr ON p.postPermanentID = mr.postPermanentID
LEFT JOIN react r ON p.postPermanentID = r.postID
where u.reputation < 60
GROUP BY u.userID
HAVING COUNT(DISTINCT mr.caseID) >= 1
   AND COUNT(CASE WHEN r.emoji = 'love' THEN 1 END) >= 3;
-- END Q7
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q8
SELECT c.channelID, c.channelName, 
       COUNT(*) AS totalVirusInfectedAttachments
FROM channel c
JOIN postchannel pc
    ON c.channelID = pc.channelID
JOIN attachmentobject a
    ON pc.postID = a.postPermanentID
WHERE a.virusScanned = TRUE
GROUP BY c.channelID
HAVING COUNT(*) >= (
    SELECT MIN(virusCount)
    FROM (
        SELECT COUNT(*) AS virusCount
        FROM postchannel pc2
        JOIN attachmentobject a2
            ON pc2.postID = a2.postPermanentID
        WHERE a2.virusScanned = TRUE 
        GROUP BY pc2.channelID
        ORDER BY virusCount DESC
        LIMIT 3
    ) AS top3
);
-- END Q8
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q9
SELECT m.modID, COUNT(DISTINCT r.caseID) AS numberOfDisciplinariesToRepeaters
FROM moderator m
LEFT JOIN moderatorreport r ON m.modID = r.modID
AND r.disciplinaryAction = True
AND r.postPermanentID IN (
    SELECT p.postPermanentID
    FROM post p
    WHERE p.authorID IN (
        SELECT p.authorID
        FROM post p
        JOIN moderatorreport mr ON p.postPermanentID = mr.postPermanentID
        JOIN postchannel pc ON p.postPermanentID = pc.postID
        GROUP BY p.authorID
        HAVING COUNT(DISTINCT pc.channelID) >= 2
    )
)
GROUP BY m.modID;
-- END Q9
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q10
SELECT DISTINCT p.authorID as userID
FROM post p
JOIN postreply pr ON p.postPermanentID = pr.replyPostID
JOIN postchannel pc ON p.postPermanentID = pc.postID
JOIN channel c ON pc.channelID = c.channelID
-- find all userID who has post at least one COMMENT in dota2_memes from 01/04/2024
WHERE c.channelName = 'dota2_memes'
AND p.dateCreated >= '2024-04-01'
AND p.authorID NOT IN (
	-- find all userID who has post or comment on ranked_grind before 01/04/2024
    SELECT DISTINCT p2.authorID
    FROM post p2
    JOIN postchannel pc2 ON p2.postPermanentID = pc2.postID
    JOIN channel c2 ON pc2.channelID = c2.channelID
    WHERE c2.channelName = 'ranked_grind'
    AND p2.dateCreated < '2024-04-01'
);
-- END Q10
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- END OF ASSIGNMENT Do not write below this line