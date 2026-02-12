-- ============================================
-- SQL MURDER MYSTERY - COMPLETE SOLUTION
-- Author: Ashlesha Sirsikar
-- Objective: Identify the murderer using SQL
-- ============================================

SELECT name FROM sqlite_master
where type = 'table';

-- STEP 1: Check crime scene report
SELECT *
FROM crime_scene_report
WHERE date = 20180115
  AND city = 'SQL City'
  AND type = 'murder';

-- STEP 2: Identify witnesses from description

-- Witness 1: Lives at last house on Northwestern Dr
SELECT *
FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1;


-- Witness 2: Lives on Franklin Ave, name starts with Ann
SELECT *
FROM person
WHERE address_street_name = 'Franklin Ave'
  AND name LIKE 'Ann%';


-- STEP 3: Get witness interview statements

SELECT *
FROM interview
WHERE person_id IN (14887, 16371);


-- STEP 4: Analyze interview clues

-- Clue 1: Killer has "Get Fit Now Gym" membership starting with '48Z'
-- Clue 2: Membership type = gold
-- Clue 3: Car plate contains 'H42W'


-- STEP 5: Find matching gym members

SELECT *
FROM get_fit_now_member
WHERE membership_status = 'gold'
  AND id LIKE '48Z%';


-- STEP 6: Check gym check-ins on murder date

SELECT *
FROM get_fit_now_check_in
WHERE check_in_date = 20180109
  AND membership_id IN (
      SELECT id
      FROM get_fit_now_member
      WHERE membership_status = 'gold'
        AND id LIKE '48Z%'
  );


-- STEP 7: Get suspect details

SELECT p.*, d.plate_number
FROM person p
JOIN drivers_license d
  ON p.license_id = d.id
WHERE p.id IN (
    SELECT person_id
    FROM get_fit_now_member
    WHERE id IN ('48Z7A','48Z55')
);


-- STEP 8: Filter by car plate clue

SELECT p.*, d.plate_number
FROM person p
JOIN drivers_license d
  ON p.license_id = d.id
WHERE d.plate_number LIKE '%H42W%';


-- RESULT: Jeremy Bowers (Main Suspect)


-- STEP 9: Check suspect interview

SELECT *
FROM interview
WHERE person_id = 67318;


-- STEP 10: Analyze Jeremy's confession
-- He says he was hired by a wealthy woman:
-- - Red hair
-- - Tesla Model S
-- - Attended SQL Symphony Concert 3 times in December 2017


-- STEP 11: Find woman matching description

SELECT p.*, d.*
FROM person p
JOIN drivers_license d
  ON p.license_id = d.id
WHERE d.gender = 'female'
  AND d.hair_color = 'red'
  AND d.car_make = 'Tesla'
  AND d.car_model = 'Model S';


-- STEP 12: Check concert attendance

SELECT person_id, COUNT(*) AS visits
FROM facebook_event_checkin
WHERE event_name = 'SQL Symphony Concert'
  AND date LIKE '201712%'
GROUP BY person_id
HAVING visits = 3;


-- STEP 13: Match final suspect

SELECT p.name
FROM person p
WHERE p.id IN (
    SELECT person_id
    FROM facebook_event_checkin
    WHERE event_name = 'SQL Symphony Concert'
      AND date LIKE '201712%'
    GROUP BY person_id
    HAVING COUNT(*) = 3
)
AND p.license_id IN (
    SELECT id
    FROM drivers_license
    WHERE gender = 'female'
      AND hair_color = 'red'
      AND car_make = 'Tesla'
      AND car_model = 'Model S'
);


-- FINAL RESULT:
-- Miranda Priestly is the mastermind behind the murder