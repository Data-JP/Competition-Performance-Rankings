SELECT *
FROM track_and_field_competition_rankings
ORDER BY  Ranking

-- Rename columns ---
EXEC sp_rename 'track_and_field_competition_rankings.[0]', 'Ranking','COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[1]', 'MeetingName', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[2]', 'StadiumName', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[3]', 'City', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[4]', 'CountryCode', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[5]', 'StartDate', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[6]', 'EndDate', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[7]', 'ParticipationScore', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[8]', 'ParticipationScorePlace', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[9]', 'ResultScore', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[10]', 'ResultScorePlace', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[11]', 'WorldRecordScore', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[12]', 'CompetitionScore', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[13]', 'Column13', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[14]', 'Column14', 'COLUMN'
EXEC sp_rename 'track_and_field_competition_rankings.[15]', 'Column15', 'COLUMN'

-- Alter RAKING column data type ---
ALTER TABLE track_and_field_competition_rankings
ALTER COLUMN Ranking INT


--- Remove empty rows ---
DELETE
FROM track_and_field_competition_rankings
WHERE Ranking =''

--- Checking duplicate data ---
WITH Duplicate_Rows
AS(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY Ranking, MeetingName ORDER BY Ranking) AS ranking_row_number
	FROM track_and_field_competition_rankings
)


--- Remove duplicate data ---
DELETE
FROM Duplicate_Rows
WHERE ranking_row_number >1 

--- Correction for USA and IRL rows: shift columns ----
UPDATE track_and_field_competition_rankings
SET 
	CountryCode = StartDate,
	StartDate=EndDate,
	EndDate=[ParticipationScore],
	ParticipationScore=ParticipationScorePlace,
	ParticipationScorePlace=ResultScore,
	ResultScore=ResultScorePlace,
	ResultScorePlace=WorldRecordScore,
	WorldRecordScore=CompetitionScore,
	CompetitionScore=Column13
WHERE StartDate IN ('USA', 'IRL') AND Ranking <= 100

--- Correction for other USA rows: shift columns ----
UPDATE track_and_field_competition_rankings
SET 
	CountryCode = StartDate,
	StartDate=EndDate,
	EndDate=[ParticipationScore],
	ParticipationScore=ParticipationScorePlace,
	ParticipationScorePlace=ResultScore,
	ResultScore=ResultScorePlace,
	ResultScorePlace=WorldRecordScore,
	WorldRecordScore=0
WHERE StartDate = 'USA' AND Ranking > 100


--- Correction shifting column ---

UPDATE track_and_field_competition_rankings
SET 
    City = CASE 
        -- Fix USA cities
        WHEN Ranking = 235 THEN 'St. Paul'
        WHEN Ranking = 489 THEN 'Claremont'
        -- Fix misaligned cities
        WHEN Ranking = 452 THEN 'Birmingham'
        WHEN Ranking = 660 THEN 'Praha'
        WHEN Ranking = 714 THEN 'Stará Boleslav'
        WHEN Ranking = 826 THEN 'Craiova'
        WHEN Ranking = 830 THEN 'Birstonas'
        WHEN Ranking = 840 THEN 'Brisbane'
        WHEN Ranking = 850 THEN 'Quito'
        WHEN Ranking = 1016 THEN 'Kladno'
        WHEN Ranking = 1029 THEN 'Kolin'
        ELSE City 
    END,
	MeetingName = CASE 
        -- Fix concatenated meeting names
        WHEN Ranking = 452 THEN 'England Athletics U15/U17 Open Championships - Senior & U20 Combined Events Championships & UK CE Championships'
        WHEN Ranking = 489 THEN 'Pomona-Pitzer Track & Field Invitational'
        WHEN Ranking = 660 THEN 'Přebor Prahy mužů, žen, juniorů a juniorek'
        WHEN Ranking = 714 THEN '1. liga mužů a žen, skupina B, 1. kolo'
        WHEN Ranking = 826 THEN 'Campionatul National Seniori U23, U20 - Etapa 2'
        WHEN Ranking = 830 THEN '39th SELL (Suomija, Estija, Latvija, Lietuva) Students Games'
        WHEN Ranking = 840 THEN 'Dane Bird-Smith Shield & QLD 10000m Race Walk Championships'
        WHEN Ranking = 850 THEN 'National Championships in Sprint, Hurdles, Relays, Middle-distance and Long-distance'
        WHEN Ranking = 1016 THEN 'II. liga mužů a žen, skupina A, 3. kolo'
        WHEN Ranking = 1029 THEN 'KP Středočeského kraje mužů, žen, juniorů, juniorek, dorostenců a dorostenek'
        ELSE MeetingName
    END,
	StadiumName = CASE 
        WHEN Ranking = 235 THEN 'St. Thomas O''Shaughnessy Stadium'
        WHEN Ranking = 452 THEN 'Alexander Stadium'
        WHEN Ranking = 489 THEN 'Strehle Track, Pomona College'
        WHEN Ranking = 660 THEN 'Stadion Juliska'
        WHEN Ranking = 714 THEN 'Atletické středisko Emila Zátopka'
        WHEN Ranking = 826 THEN 'Stadionul de atletism Nicolae Mărășescu'
        WHEN Ranking = 830 THEN 'Sport Center Stadium'
        WHEN Ranking = 840 THEN 'Queensland Sport and Athletics Centre'
        WHEN Ranking = 850 THEN 'La Vicentina'
        WHEN Ranking = 1016 THEN 'Městský Stadion Sletiště'
        WHEN Ranking = 1029 THEN 'Atletický stadion Mirka Tučka'
        ELSE StadiumName
    END,
	CountryCode = 
    CASE 
        WHEN Ranking = 235 THEN 'USA'
        WHEN Ranking = 452 THEN 'GBR'
        WHEN Ranking = 489 THEN 'USA'
        WHEN Ranking = 660 THEN 'CZE'
        WHEN Ranking = 714 THEN 'CZE'
        WHEN Ranking = 826 THEN 'ROU'
        WHEN Ranking = 830 THEN 'LTU'
        WHEN Ranking = 840 THEN 'AUS'
        WHEN Ranking = 850 THEN 'ECU'
        WHEN Ranking = 1016 THEN 'CZE'
        WHEN Ranking = 1029 THEN 'CZE'
        ELSE CountryCode -- Keep existing value if no match
    END,
	StartDate = 
    CASE 
        WHEN Ranking = 235 THEN '2024-05-09'
        WHEN Ranking = 452 THEN '2024-07-26'
        WHEN Ranking = 489 THEN '2024-04-06'
        WHEN Ranking = 660 THEN '2024-05-18'
        WHEN Ranking = 714 THEN '2024-05-11'
        WHEN Ranking = 826 THEN '2024-06-15'
        WHEN Ranking = 830 THEN '2024-05-17'
        WHEN Ranking = 840 THEN '2024-02-17'
        WHEN Ranking = 850 THEN '2024-03-16'
        WHEN Ranking = 1016 THEN '2024-06-08'
        WHEN Ranking = 1029 THEN '2024-05-18'
        ELSE StartDate -- Keep existing value if no match
    END,
	EndDate = 
    CASE 
        WHEN Ranking = 235 THEN '2024-05-11'
        WHEN Ranking = 452 THEN '2024-07-28'
        WHEN Ranking = 489 THEN '2024-04-06'
        WHEN Ranking = 660 THEN '2024-05-19'
        WHEN Ranking = 714 THEN '2024-05-11'
        WHEN Ranking = 826 THEN '2024-06-16'
        WHEN Ranking = 830 THEN '2024-05-18'
        WHEN Ranking = 840 THEN '2024-02-17'
        WHEN Ranking = 850 THEN '2024-03-17'
        WHEN Ranking = 1016 THEN '2024-06-08'
        WHEN Ranking = 1029 THEN '2024-05-18'
        ELSE EndDate -- Keep existing value if no match
    END, 
    ParticipationScore = CASE 
        WHEN Ranking = 235 THEN 10
        WHEN Ranking = 452 THEN 185
        WHEN Ranking = 489 THEN 40
        WHEN Ranking = 660 THEN 25
        WHEN Ranking = 714 THEN 0
        WHEN Ranking = 826 THEN 0
        WHEN Ranking = 830 THEN 0
        WHEN Ranking = 840 THEN 15
        WHEN Ranking = 850 THEN 15
        WHEN Ranking = 1016 THEN 0
        WHEN Ranking = 1029 THEN 0
        ELSE ParticipationScore
    END,
    ParticipationScorePlace = CASE 
        WHEN Ranking = 235 THEN 686
        WHEN Ranking = 452 THEN 236
        WHEN Ranking = 489 THEN 482
        WHEN Ranking = 660 THEN 555
        WHEN Ranking = 714 THEN NULL
        WHEN Ranking = 826 THEN NULL
        WHEN Ranking = 830 THEN NULL
        WHEN Ranking = 840 THEN 627
        WHEN Ranking = 850 THEN 627
        WHEN Ranking = 1016 THEN NULL
        WHEN Ranking = 1029 THEN NULL
        ELSE ParticipationScorePlace
    END,
    ResultScore = CASE 
        WHEN Ranking = 235 THEN 75586
        WHEN Ranking = 452 THEN 70760
        WHEN Ranking = 489 THEN 70352
        WHEN Ranking = 660 THEN 67515
        WHEN Ranking = 714 THEN 66802
        WHEN Ranking = 826 THEN 65017
        WHEN Ranking = 830 THEN 64925
        WHEN Ranking = 840 THEN 64757
        WHEN Ranking = 850 THEN 64603
        WHEN Ranking = 1016 THEN 61054
        WHEN Ranking = 1029 THEN 60808
        ELSE ResultScore
    END,
    ResultScorePlace = CASE 
        WHEN Ranking = 235 THEN 230
        WHEN Ranking = 452 THEN 462
        WHEN Ranking = 489 THEN 491
        WHEN Ranking = 660 THEN 659
        WHEN Ranking = 714 THEN 712
        WHEN Ranking = 826 THEN 825
        WHEN Ranking = 830 THEN 829
        WHEN Ranking = 840 THEN 841
        WHEN Ranking = 850 THEN 850
        WHEN Ranking = 1016 THEN 1016
        WHEN Ranking = 1029 THEN 1028
        ELSE ResultScorePlace
    END,
    WorldRecordScore = CASE 
        WHEN Ranking = 235 THEN 0
        WHEN Ranking = 452 THEN 0
        WHEN Ranking = 489 THEN 0
        WHEN Ranking = 660 THEN 0
        WHEN Ranking = 714 THEN 0
        WHEN Ranking = 826 THEN 0
        WHEN Ranking = 830 THEN 0
        WHEN Ranking = 840 THEN 0
        WHEN Ranking = 850 THEN 0
        WHEN Ranking = 1016 THEN 0
        WHEN Ranking = 1029 THEN 0
        ELSE WorldRecordScore
    END,
    CompetitionScore = CASE 
        WHEN Ranking = 235 THEN 75596
        WHEN Ranking = 452 THEN 70945
        WHEN Ranking = 489 THEN 70392
        WHEN Ranking = 660 THEN 67540
        WHEN Ranking = 714 THEN 66802
        WHEN Ranking = 826 THEN 65017
        WHEN Ranking = 830 THEN 64925
        WHEN Ranking = 840 THEN 64772
        WHEN Ranking = 850 THEN 64618
        WHEN Ranking = 1016 THEN 61054
        WHEN Ranking = 1029 THEN 60808
        ELSE CompetitionScore
    END
WHERE Ranking IN (235, 452, 489, 660, 714, 826, 830, 840, 850, 1016, 1029)

--- Shift other columns ---
UPDATE track_and_field_competition_rankings
SET 
	MeetingName =CASE
		WHEN Ranking = 509 THEN 'Loughborough Open inc. BUCS 10,000m'
        WHEN Ranking = 717 THEN 'MMaS muži, ženy, junioři, juniorky, dorostenci, dorostenky'
        WHEN Ranking = 782 THEN 'Day one: The 34th Nara City Athletics Circuit'
        WHEN Ranking = 798 THEN '2. kolo Mistrovství Moravy a Slezska družstev mládeže'
        WHEN Ranking = 840 THEN 'Dane Bird-Smith Shield & QLD 10,000m Race Walk Championships'
        WHEN Ranking = 968 THEN 'Spanish Clubs Championships Primera Division Liga Iberdrola - Leg 2 - Match A'
        WHEN Ranking = 1029 THEN 'KP Středočeského kraje mužů, žen, juniorů, juniorek, dorostenců a dorostenek'
        WHEN Ranking = 1080 THEN 'Velká cena Olomouce'
        ELSE MeetingName
	END,
	StadiumName=CASE
		WHEN Ranking = 509 THEN 'Loughborough University Track'
        WHEN Ranking = 717 THEN 'Městský Stadion'
        WHEN Ranking = 782 THEN 'Konoike Athletics Stadium'
        WHEN Ranking = 798 THEN 'Stadion TJ Lokomotiva Olomouc'
        WHEN Ranking = 840 THEN 'Queensland Sport and Athletics Centre'
        WHEN Ranking = 968 THEN 'Pista de Atletismo Río Esgueva'
        WHEN Ranking = 1029 THEN 'Atletický stadion Mirka Tucka'
        WHEN Ranking = 1080 THEN 'Stadion TJ Lokomotiva Olomouc'
        ELSE StadiumName
	END,
	City=CASE
		WHEN Ranking = 509 THEN 'Loughborough'
        WHEN Ranking = 717 THEN 'Ostrava'
        WHEN Ranking = 782 THEN 'Nara'
        WHEN Ranking = 798 THEN 'Olomouc'
        WHEN Ranking = 840 THEN 'Brisbane'
        WHEN Ranking = 968 THEN 'Valladolid'
        WHEN Ranking = 1029 THEN 'Kolin'
        WHEN Ranking = 1080 THEN 'Olomouc'
        ELSE City
	END,
	CountryCode=CASE
		WHEN Ranking = 509 THEN 'GBR'
        WHEN Ranking = 717 THEN 'CZE'
        WHEN Ranking = 782 THEN 'JPN'
        WHEN Ranking = 798 THEN 'CZE'
        WHEN Ranking = 840 THEN 'AUS'
        WHEN Ranking = 968 THEN 'ESP'
        WHEN Ranking = 1029 THEN 'CZE'
        WHEN Ranking = 1080 THEN 'CZE'
        ELSE CountryCode
	END,
	StartDate=CASE
		WHEN Ranking = 509 THEN '2024-04-20'
        WHEN Ranking = 717 THEN '2024-05-08'
        WHEN Ranking = 782 THEN '2024-04-21'
        WHEN Ranking = 798 THEN '2024-06-01'
        WHEN Ranking = 840 THEN '2024-02-17'
        WHEN Ranking = 968 THEN '2024-05-04'
        WHEN Ranking = 1029 THEN '2024-05-18'
        WHEN Ranking = 1080 THEN '2024-05-18'
        ELSE StartDate
	END,
	EndDate=CASE
		WHEN Ranking = 509 THEN '2024-04-20'
        WHEN Ranking = 717 THEN '2024-05-08'
        WHEN Ranking = 782 THEN '2024-04-21'
        WHEN Ranking = 798 THEN '2024-06-01'
        WHEN Ranking = 840 THEN '2024-02-17'
        WHEN Ranking = 968 THEN '2024-05-04'
        WHEN Ranking = 1029 THEN '2024-05-18'
        WHEN Ranking = 1080 THEN '2024-05-18'
        ELSE EndDate
	END,
	ParticipationScore=CASE
		WHEN Ranking = 509 THEN 40
        WHEN Ranking = 717 THEN 0
        WHEN Ranking = 782 THEN 15
        WHEN Ranking = 798 THEN 0
        WHEN Ranking = 840 THEN 15
        WHEN Ranking = 968 THEN 0
        WHEN Ranking = 1029 THEN 0
        WHEN Ranking = 1080 THEN 0
        ELSE ParticipationScore
	END,
	ParticipationScorePlace=CASE
		WHEN Ranking = 509 THEN 482
        WHEN Ranking = 717 THEN NULL
        WHEN Ranking = 782 THEN 627
        WHEN Ranking = 798 THEN NULL
        WHEN Ranking = 840 THEN 627
        WHEN Ranking = 968 THEN NULL
        WHEN Ranking = 1029 THEN 0
        WHEN Ranking = 1080 THEN NULL
        ELSE ParticipationScorePlace
	END,
	ResultScore=CASE
		WHEN Ranking = 509 THEN 70080
        WHEN Ranking = 717 THEN 66769
        WHEN Ranking = 782 THEN 65729
        WHEN Ranking = 798 THEN 65559
        WHEN Ranking = 840 THEN 64757
        WHEN Ranking = 968 THEN 61939
        WHEN Ranking = 1029 THEN 60808
        WHEN Ranking = 1080 THEN 59649
        ELSE ResultScore
	END,
	ResultScorePlace=CASE
		WHEN Ranking = 509 THEN 505
        WHEN Ranking = 717 THEN 716
        WHEN Ranking = 782 THEN 782
        WHEN Ranking = 798 THEN 798
        WHEN Ranking = 840 THEN 841
        WHEN Ranking = 968 THEN 968
        WHEN Ranking = 1029 THEN 1028
        WHEN Ranking = 1080 THEN 1079
        ELSE ResultScorePlace
	END,
	WorldRecordScore=CASE
		WHEN Ranking = 509 THEN 0
        WHEN Ranking = 717 THEN 0
        WHEN Ranking = 782 THEN 0
        WHEN Ranking = 798 THEN 0
        WHEN Ranking = 840 THEN 0
        WHEN Ranking = 968 THEN 0
        WHEN Ranking = 1029 THEN 0
        WHEN Ranking = 1080 THEN 0
        ELSE WorldRecordScore
	END,
	CompetitionScore=CASE
		WHEN Ranking = 509 THEN 70120
        WHEN Ranking = 717 THEN 66769
        WHEN Ranking = 782 THEN 65744
        WHEN Ranking = 798 THEN 65559
        WHEN Ranking = 840 THEN 64772
        WHEN Ranking = 968 THEN 61939
        WHEN Ranking = 1029 THEN 60808
        WHEN Ranking = 1080 THEN 59649
        ELSE CompetitionScore
	END
WHERE Ranking IN (509, 717, 782, 798, 840, 968, 1029, 1080)

--- Shift for the rest of the columns ---
UPDATE track_and_field_competition_rankings
SET 
	CompetitionScore = WorldRecordScore,
	WorldRecordScore=0
WHERE CountryCode NOT IN ('USA', 'IRL') AND Ranking NOT IN (235, 452, 489, 660, 714, 826, 830, 840, 850, 1016, 1029) AND Ranking > 100
UPDATE track_and_field_competition_rankings
SET
MeetingName = CASE 
   WHEN Ranking = 194 THEN 'England Athletics U20 & Senior track & field champs (inc U23)'
   WHEN Ranking = 214 THEN '2nd AK Track & Field Weekend Meeting/AK Relay Series'
   WHEN Ranking = 378 THEN '4° Meeting della Leonessa'
   WHEN Ranking = 379 THEN 'Copa Nuevo León Luciano Ramírez Gallardo'
   WHEN Ranking = 393 THEN '41th Tokai University-Nihon University Game'
   WHEN Ranking = 476 THEN '3rd Nihon University Competition'
   WHEN Ranking = 491 THEN 'Cathy Freeman Shield'
   WHEN Ranking = 539 THEN 'National AAI Outdoor Games'
   WHEN Ranking = 550 THEN 'Surrey County Track and Field Championships'
   WHEN Ranking = 579 THEN '1. kolo I. ligy mužů a žen'
   WHEN Ranking = 610 THEN 'Oliympic Trial'
   WHEN Ranking = 621 THEN '2. kolo I. ligy mužů a žen'
   WHEN Ranking = 638 THEN '3. kolo I. ligy'
   WHEN Ranking = 652 THEN '4. kolo I. ligy mužů a žen'
   WHEN Ranking = 668 THEN '2. kolo I. ligy mužů a žen'
   WHEN Ranking = 711 THEN 'Norma Croker Shield'
   WHEN Ranking = 716 THEN 'AAI May Open'
   WHEN Ranking = 718 THEN 'Day seven'
   WHEN Ranking = 733 THEN 'Garry Brown Shield'
   WHEN Ranking = 775 THEN '1. kolo I. ligy mužů a žen'
   WHEN Ranking = 791 THEN 'Denise Boyd Shield'
   WHEN Ranking = 809 THEN 'Joanna Stone Shield'
   WHEN Ranking = 849 THEN 'High Velocity'
   WHEN Ranking = 853 THEN 'Leinster Schools'''
   WHEN Ranking = 856 THEN 'Sally Pearson Shield'
   WHEN Ranking = 897 THEN 'Irish Milers Club-Crusaders'
   WHEN Ranking = 934 THEN 'Combined Events and Track and Field League 4'
   WHEN Ranking = 941 THEN 'Albie Thomas Mile'
   WHEN Ranking = 980 THEN 'Darren Thrupp Shield'
   WHEN Ranking = 1014 THEN 'Grand Prix Sudamericano - Paraguay'
   WHEN Ranking = 1053 THEN '4. kolo II. ligy mužů a žen'
   WHEN Ranking = 1066 THEN '2. kolo II. ligy mužů a žen'
   WHEN Ranking = 1125 THEN 'Tailteann Interprovincial Games'
   WHEN Ranking = 1130 THEN '2nd Nihon University Competition'
   WHEN Ranking = 753 THEN '3. kolo I. ligy mužů a žen'
   WHEN Ranking = 790 THEN 'Aluemestaruuskilpailut'
   WHEN Ranking = 792 THEN '4. kolo I. ligy mužů a žen'
   WHEN Ranking = 808 THEN 'National Athletics League - Regional East'
   WHEN Ranking = 818 THEN '4. kolo I. ligy mužů a žen'
   WHEN Ranking = 835 THEN 'Day four - the 34th Nara City Athletics Circuit'
   WHEN Ranking = 859 THEN 'Championnats BFC Sprint'
   WHEN Ranking = 922 THEN 'HVC'
   WHEN Ranking = 947 AND City = 'Roanne' THEN '1er Tour Elite Interclubs AURA'
   WHEN Ranking = 947 AND CountryCode = 'Carlow' THEN 'Leinster Senior U20 & Master Championships'
   WHEN Ranking = 965 THEN '1. kolo II. ligy mužů a žen'
   WHEN Ranking = 1021 THEN 'HVC'
   WHEN Ranking = 1153 THEN 'Day five - Nara City Athletics Circuit'
   ELSE MeetingName
END,
StadiumName = CASE 
   WHEN Ranking = 194 THEN 'Alexander Stadium'
   WHEN Ranking = 214 THEN 'Ulinzi Sports Complex'
   WHEN Ranking = 378 THEN 'Centro Gabre Gabric'
   WHEN Ranking = 379 THEN 'Estadio Azul ITESM'
   WHEN Ranking IN (393, 476, 1130) THEN 'Nihon University Athletics Stadium'
   WHEN Ranking IN (491, 711, 733, 791, 809, 856, 980) THEN 'Queensland Sport and Athletics Centre'
   WHEN Ranking IN (539, 716, 853, 897, 1125) THEN 'Morton Stadium'
   WHEN Ranking = 610 THEN 'Atatürk Stadyumu'
   WHEN Ranking = 718 THEN 'Konoike Athletics Stadium'
   WHEN Ranking = 849 THEN 'Lakeside Stadium'
   WHEN Ranking = 550 THEN 'Weir Archer Athletics and Fitness Centre'
   WHEN Ranking = 621 THEN 'Atletický stadion Slavia Praha'
   WHEN Ranking = 638 THEN 'Atletický stadion U sv. Anny'
   WHEN Ranking = 652 THEN 'Stadion TJ Lokomotiva'
   WHEN Ranking = 668 THEN 'Stadion Mládeže'
   WHEN Ranking = 579 THEN 'Městský atletický stadion Dany Zátopkové'
   WHEN Ranking = 775 THEN 'Městský stadion Střelnice'
   WHEN Ranking = 934 THEN 'Athletics Track'
   WHEN Ranking = 941 THEN 'The Crest Athletics Centre'
   WHEN Ranking = 1014 THEN 'Parque Olímpico Pista De Atletismo'
   WHEN Ranking = 1053 THEN 'Městský atletický stadion'
   WHEN Ranking = 1066 THEN 'Stadion Emila Zátopka'
   WHEN Ranking = 753 THEN 'General Klapálek''s stadium'
   WHEN Ranking = 790 THEN 'Klaukkalan urheilukenttä'
   WHEN Ranking = 792 THEN 'Atletický stadion Děkanka'
   WHEN Ranking = 808 THEN 'StoneX Stadium'
   WHEN Ranking = 818 THEN 'Atletický stadion Střelnice'
   WHEN Ranking = 835 THEN 'Konoike Athletics Stadium'
   WHEN Ranking = 859 THEN 'Stade Marie José Pérec'
   WHEN Ranking = 922 THEN 'AV Throwers & Rare Air'
   WHEN Ranking = 947 AND City = 'Roanne' THEN 'Stade H. Malleval'
   WHEN Ranking = 947 AND CountryCode = 'Carlow' THEN 'South Sports Campus'
   WHEN Ranking = 965 THEN 'Atletický stadion'
   WHEN Ranking = 1021 THEN 'AV Throwers & Rare Air'
   WHEN Ranking = 1153 THEN 'Konoike Athletics Stadium'
   ELSE StadiumName
END,
City = CASE 
  WHEN Ranking = 194 THEN 'Birmingham'
  WHEN Ranking = 214 THEN 'Nairobi'
  WHEN Ranking = 378 THEN 'Brescia'
  WHEN Ranking = 379 THEN 'Monterrey'
  WHEN Ranking = 393 THEN 'Tokyo'
  WHEN Ranking = 476 THEN 'Tokyo' 
  WHEN Ranking = 491 THEN 'Brisbane'
  WHEN Ranking = 539 THEN 'Dublin'
  WHEN Ranking = 550 THEN 'London'
  WHEN Ranking = 579 THEN 'Uherské Hradiste'
  WHEN Ranking = 610 THEN 'Izmir'
  WHEN Ranking = 621 THEN 'Praha'
  WHEN Ranking = 638 THEN 'Pacov'
  WHEN Ranking = 652 THEN 'Breclav'
  WHEN Ranking = 668 THEN 'Zlín'
  WHEN Ranking = 711 THEN 'Brisbane'
  WHEN Ranking = 716 THEN 'Dublin'
  WHEN Ranking = 718 THEN 'Nara'
  WHEN Ranking = 733 THEN 'Brisbane'
  WHEN Ranking = 775 THEN 'Domažlice'
  WHEN Ranking = 791 THEN 'Brisbane'
  WHEN Ranking = 809 THEN 'Brisbane'
  WHEN Ranking = 849 THEN 'Melbourne'
  WHEN Ranking = 853 THEN 'Dublin'
  WHEN Ranking = 856 THEN 'Brisbane'
  WHEN Ranking = 897 THEN 'Dublin'
  WHEN Ranking = 934 THEN 'Cape Town'
  WHEN Ranking = 941 THEN 'Sydney'
  WHEN Ranking = 980 THEN 'Brisbane'
  WHEN Ranking = 1014 THEN 'Asunción'
  WHEN Ranking = 1053 THEN 'Pardubice'
  WHEN Ranking = 1066 THEN 'Chrudium'
  WHEN Ranking = 1125 THEN 'Dublin'
  WHEN Ranking = 1130 THEN 'Tokyo'
  WHEN Ranking = 753 THEN 'Nové Město nad Metují'
  WHEN Ranking = 790 THEN 'Nurmijärvi'
  WHEN Ranking = 792 THEN 'Praha'
  WHEN Ranking = 808 THEN 'London'
  WHEN Ranking = 818 THEN 'Jablonec nad Nisou'
  WHEN Ranking = 835 THEN 'Nara'
  WHEN Ranking = 859 THEN 'Macon'
  WHEN Ranking = 922 THEN 'Melbourne'
  WHEN Ranking = 947 AND StartDate = '2024-04-28' THEN 'Roanne'
  WHEN Ranking = 947 AND StartDate = 'IRL' THEN 'Carlow'
  WHEN Ranking = 965 THEN 'Ústí Nad Orlicí'
  WHEN Ranking = 1021 THEN 'Melbourne'
  WHEN Ranking = 1153 THEN 'Nara'
  ELSE City
END,
CountryCode = CASE 
   WHEN Ranking = 194 THEN 'GBR'
   WHEN Ranking = 214 THEN 'KEN'
   WHEN Ranking = 378 THEN 'ITA'
   WHEN Ranking = 379 THEN 'MEX'
   WHEN Ranking = 393 THEN 'JPN'
   WHEN Ranking = 476 THEN 'JPN'
   WHEN Ranking = 491 THEN 'AUS'
   WHEN Ranking = 539 THEN 'IRL'
   WHEN Ranking = 550 THEN 'GBR'
   WHEN Ranking = 579 THEN 'CZE'
   WHEN Ranking = 610 THEN 'TUR'
   WHEN Ranking = 621 THEN 'CZE'
   WHEN Ranking = 638 THEN 'CZE'
   WHEN Ranking = 652 THEN 'CZE'
   WHEN Ranking = 668 THEN 'CZE'
   WHEN Ranking = 711 THEN 'AUS'
   WHEN Ranking = 716 THEN 'IRL'
   WHEN Ranking = 718 THEN 'JPN'
   WHEN Ranking = 733 THEN 'AUS'
   WHEN Ranking = 775 THEN 'CZE'
   WHEN Ranking = 791 THEN 'AUS'
   WHEN Ranking = 809 THEN 'AUS'
   WHEN Ranking = 849 THEN 'AUS'
   WHEN Ranking = 853 THEN 'IRL'
   WHEN Ranking = 856 THEN 'AUS'
   WHEN Ranking = 897 THEN 'IRL'
   WHEN Ranking = 934 THEN 'RSA'
   WHEN Ranking = 941 THEN 'AUS'
   WHEN Ranking = 980 THEN 'AUS'
   WHEN Ranking = 1014 THEN 'PAR'
   WHEN Ranking = 1053 THEN 'CZE'
   WHEN Ranking = 1066 THEN 'CZE'
   WHEN Ranking = 1125 THEN 'IRL'
   WHEN Ranking = 1130 THEN 'JPN'
   WHEN Ranking = 753 THEN 'CZE'
   WHEN Ranking = 790 THEN 'FIN'
   WHEN Ranking = 792 THEN 'CZE'
   WHEN Ranking = 808 THEN 'GBR'
   WHEN Ranking = 818 THEN 'CZE'
   WHEN Ranking = 835 THEN 'JPN'
   WHEN Ranking = 859 THEN 'FRA'
   WHEN Ranking = 922 THEN 'AUS'
   WHEN Ranking = 947 AND StartDate = '2024-04-28' THEN 'FRA'
   WHEN Ranking = 947 AND StartDate = 'IRL' THEN 'IRL'
   WHEN Ranking = 965 THEN 'CZE'
   WHEN Ranking = 1021 THEN 'AUS'
   WHEN Ranking = 1153 THEN 'JPN'
   ELSE CountryCode
END,
StartDate = CASE 
   WHEN Ranking = 194 THEN '2024-07-19'
   WHEN Ranking = 214 THEN '2024-01-05'
   WHEN Ranking = 378 THEN '2024-07-06'
   WHEN Ranking = 379 THEN '2024-02-24'
   WHEN Ranking = 393 THEN '2024-04-07'
   WHEN Ranking = 476 THEN '2024-06-01'
   WHEN Ranking = 491 THEN '2024-02-24'
   WHEN Ranking = 539 THEN '2024-07-13'
   WHEN Ranking = 550 THEN '2024-05-11'
   WHEN Ranking = 579 THEN '2024-05-11'
   WHEN Ranking = 610 THEN '2024-06-01'
   WHEN Ranking = 621 THEN '2024-05-25'
   WHEN Ranking = 638 THEN '2024-06-08'
   WHEN Ranking = 652 THEN '2024-08-17'
   WHEN Ranking = 668 THEN '2024-05-25'
   WHEN Ranking = 711 THEN '2024-02-10'
   WHEN Ranking = 716 THEN '2024-05-19'
   WHEN Ranking = 718 THEN '2024-11-03'
   WHEN Ranking = 733 THEN '2024-01-13'
   WHEN Ranking = 775 THEN '2024-05-11'
   WHEN Ranking = 791 THEN '2024-01-27'
   WHEN Ranking = 809 THEN '2024-02-03'
   WHEN Ranking = 849 THEN '2024-01-06'
   WHEN Ranking = 853 THEN '2024-05-15'
   WHEN Ranking = 856 THEN '2024-03-09'
   WHEN Ranking = 897 THEN '2024-05-04'
   WHEN Ranking = 934 THEN '2024-02-23'
   WHEN Ranking = 941 THEN '2024-03-28'
   WHEN Ranking = 980 THEN '2024-01-20'
   WHEN Ranking = 1014 THEN '2024-11-01'
   WHEN Ranking = 1053 THEN '2024-08-17'
   WHEN Ranking = 1066 THEN '2024-05-25'
   WHEN Ranking = 1125 THEN '2024-06-22'
   WHEN Ranking = 1130 THEN '2024-04-27'
   WHEN Ranking = 753 THEN '2024-06-08'
   WHEN Ranking = 790 THEN '2024-06-11'
   WHEN Ranking = 792 THEN '2024-08-18'
   WHEN Ranking = 808 THEN '2024-06-22'
   WHEN Ranking = 818 THEN '2024-08-18'
   WHEN Ranking = 835 THEN '2024-09-23'
   WHEN Ranking = 859 THEN '2024-06-23'
   WHEN Ranking = 922 THEN '2024-03-09'
   WHEN Ranking = 947 AND City = 'Roanne' THEN '2024-04-28'
   WHEN Ranking = 947 AND CountryCode = 'Carlow' THEN '2024-05-25'
   WHEN Ranking = 965 THEN '2024-05-11'
   WHEN Ranking = 1021 THEN '2024-04-06'
   WHEN Ranking = 1153 THEN '2024-10-14'
   ELSE StartDate
END,
EndDate = CASE 
   WHEN Ranking = 194 THEN '2024-07-21'
   WHEN Ranking = 214 THEN '2024-01-06'
   WHEN Ranking = 378 THEN '2024-07-06'
   WHEN Ranking = 379 THEN '2024-02-25'
   WHEN Ranking = 393 THEN '2024-04-07'
   WHEN Ranking = 476 THEN '2024-06-02'
   WHEN Ranking = 491 THEN '2024-02-24'
   WHEN Ranking = 539 THEN '2024-07-14'
   WHEN Ranking = 550 THEN '2024-05-12'
   WHEN Ranking = 579 THEN '2024-05-11'
   WHEN Ranking = 610 THEN '2024-06-02'
   WHEN Ranking = 621 THEN '2024-05-25'
   WHEN Ranking = 638 THEN '2024-06-08'
   WHEN Ranking = 652 THEN '2024-08-17'
   WHEN Ranking = 668 THEN '2024-05-25'
   WHEN Ranking = 711 THEN '2024-02-10'
   WHEN Ranking = 716 THEN '2024-05-19'
   WHEN Ranking = 718 THEN '2024-11-03'
   WHEN Ranking = 733 THEN '2024-01-13'
   WHEN Ranking = 775 THEN '2024-05-11'
   WHEN Ranking = 791 THEN '2024-01-27'
   WHEN Ranking = 809 THEN '2024-02-03'
   WHEN Ranking = 849 THEN '2024-01-06'
   WHEN Ranking = 853 THEN '2024-05-18'
   WHEN Ranking = 856 THEN '2024-03-09'
   WHEN Ranking = 897 THEN '2024-05-04'
   WHEN Ranking = 934 THEN '2024-02-24'
   WHEN Ranking = 941 THEN '2024-03-28'
   WHEN Ranking = 980 THEN '2024-01-20'
   WHEN Ranking = 1014 THEN '2024-11-01'
   WHEN Ranking = 1053 THEN '2024-08-17'
   WHEN Ranking = 1066 THEN '2024-05-25'
   WHEN Ranking = 1125 THEN '2024-06-22'
   WHEN Ranking = 1130 THEN '2024-04-28'
   WHEN Ranking = 753 THEN '2024-06-08'
   WHEN Ranking = 790 THEN '2024-06-12'
   WHEN Ranking = 792 THEN '2024-08-18'
   WHEN Ranking = 808 THEN '2024-06-22'
   WHEN Ranking = 818 THEN '2024-08-18'
   WHEN Ranking = 835 THEN '2024-09-23'
   WHEN Ranking = 859 THEN '2024-06-23'
   WHEN Ranking = 922 THEN '2024-03-09'
   WHEN Ranking = 947 AND City = 'Roanne' THEN '2024-04-28'
   WHEN Ranking = 947 AND CountryCode = 'Carlow' THEN '2024-05-26'
   WHEN Ranking = 965 THEN '2024-05-11'
   WHEN Ranking = 1021 THEN '2024-04-06'
   WHEN Ranking = 1153 THEN '2024-10-14'
   ELSE EndDate
END,
ParticipationScore = CASE 
  WHEN Ranking = 194 THEN 75
  WHEN Ranking = 214 THEN 105
  WHEN Ranking = 378 THEN 155
  WHEN Ranking = 379 THEN 90
  WHEN Ranking = 393 THEN 0
  WHEN Ranking = 476 THEN 20
  WHEN Ranking = 491 THEN 35
  WHEN Ranking = 539 THEN 5
  WHEN Ranking = 550 THEN 5
  WHEN Ranking = 579 THEN 10
  WHEN Ranking = 610 THEN 15
  WHEN Ranking = 621 THEN 120
  WHEN Ranking = 638 THEN 120
  WHEN Ranking = 652 THEN 15
  WHEN Ranking = 668 THEN 0
  WHEN Ranking = 711 THEN 0
  WHEN Ranking = 716 THEN 15
  WHEN Ranking = 718 THEN 0
  WHEN Ranking = 733 THEN 50
  WHEN Ranking = 775 THEN 120
  WHEN Ranking = 791 THEN 25
  WHEN Ranking = 809 THEN 80
  WHEN Ranking = 849 THEN 40
  WHEN Ranking = 853 THEN 0
  WHEN Ranking = 856 THEN 30
  WHEN Ranking = 897 THEN 35
  WHEN Ranking = 934 THEN 10
  WHEN Ranking = 941 THEN 130
  WHEN Ranking = 980 THEN 25
  WHEN Ranking = 1014 THEN 0
  WHEN Ranking = 1053 THEN 0
  WHEN Ranking = 1066 THEN 0
  WHEN Ranking = 1125 THEN 0
  WHEN Ranking = 1130 THEN 60
  WHEN Ranking = 753 THEN 0
  WHEN Ranking = 790 THEN 20
  WHEN Ranking = 792 THEN 15
  WHEN Ranking = 808 THEN 5
  WHEN Ranking = 818 THEN 0
  WHEN Ranking = 835 THEN 0
  WHEN Ranking = 859 THEN 10
  WHEN Ranking = 922 THEN 15
  WHEN Ranking = 947 AND City = 'Roanne' THEN 0
  WHEN Ranking = 947 AND CountryCode = 'Carlow' THEN 10
  WHEN Ranking = 965 THEN 0
  WHEN Ranking = 1021 THEN 25
  WHEN Ranking = 1153 THEN 0
  ELSE ParticipationScore
END,
ParticipationScorePlace = CASE 
  WHEN Ranking = 194 THEN 387
  WHEN Ranking = 214 THEN 335
  WHEN Ranking = 378 THEN 262
  WHEN Ranking = 379 THEN 356
  WHEN Ranking = 393 THEN NULL
  WHEN Ranking = 476 THEN 588
  WHEN Ranking = 491 THEN 501
  WHEN Ranking = 539 THEN 751
  WHEN Ranking = 550 THEN 751
  WHEN Ranking = 579 THEN 686
  WHEN Ranking = 610 THEN 627
  WHEN Ranking = 621 THEN 312
  WHEN Ranking = 638 THEN 312
  WHEN Ranking = 652 THEN 627
  WHEN Ranking = 668 THEN NULL
  WHEN Ranking = 711 THEN NULL
  WHEN Ranking = 716 THEN 627
  WHEN Ranking = 718 THEN NULL
  WHEN Ranking = 733 THEN 440
  WHEN Ranking = 775 THEN 312
  WHEN Ranking = 791 THEN 555
  WHEN Ranking = 809 THEN 377
  WHEN Ranking = 849 THEN 482
  WHEN Ranking = 853 THEN NULL
  WHEN Ranking = 856 THEN 525
  WHEN Ranking = 897 THEN 501
  WHEN Ranking = 934 THEN 686
  WHEN Ranking = 941 THEN 294
  WHEN Ranking = 980 THEN 555
  WHEN Ranking = 1014 THEN NULL
  WHEN Ranking = 1053 THEN NULL
  WHEN Ranking = 1066 THEN NULL
  WHEN Ranking = 1125 THEN NULL
  WHEN Ranking = 1130 THEN 415
  WHEN Ranking = 753 THEN NULL
  WHEN Ranking = 790 THEN 588
  WHEN Ranking = 792 THEN 627
  WHEN Ranking = 808 THEN 751
  WHEN Ranking = 818 THEN NULL
  WHEN Ranking = 835 THEN NULL
  WHEN Ranking = 859 THEN 686
  WHEN Ranking = 922 THEN 627
  WHEN Ranking = 947 AND City = 'Roanne' THEN NULL
  WHEN Ranking = 947 AND City = 'Carlow' THEN 686
  WHEN Ranking = 965 THEN NULL
  WHEN Ranking = 1021 THEN 555
  WHEN Ranking = 1153 THEN NULL
  ELSE ParticipationScorePlace
END,
ResultScore = CASE 
  WHEN Ranking = 194 THEN 77028
  WHEN Ranking = 214 THEN 76347
  WHEN Ranking = 378 THEN 72080
  WHEN Ranking = 379 THEN 72069
  WHEN Ranking = 393 THEN 71891
  WHEN Ranking = 476 THEN 70583
  WHEN Ranking = 491 THEN 70345
  WHEN Ranking = 539 THEN 69396
  WHEN Ranking = 550 THEN 69204
  WHEN Ranking = 579 THEN 68786
  WHEN Ranking = 610 THEN 68262
  WHEN Ranking = 621 THEN 68021
  WHEN Ranking = 638 THEN 67696
  WHEN Ranking = 652 THEN 67599
  WHEN Ranking = 668 THEN 67444
  WHEN Ranking = 711 THEN 66830
  WHEN Ranking = 716 THEN 66767
  WHEN Ranking = 718 THEN 66768
  WHEN Ranking = 733 THEN 66480
  WHEN Ranking = 775 THEN 65807
  WHEN Ranking = 791 THEN 65588
  WHEN Ranking = 809 THEN 65256
  WHEN Ranking = 849 THEN 64617
  WHEN Ranking = 853 THEN 64535
  WHEN Ranking = 856 THEN 64461
  WHEN Ranking = 897 THEN 63609
  WHEN Ranking = 934 THEN 62712
  WHEN Ranking = 941 THEN 62471
  WHEN Ranking = 980 THEN 61771
  WHEN Ranking = 1014 THEN 61109
  WHEN Ranking = 1053 THEN 60335
  WHEN Ranking = 1066 THEN 59958
  WHEN Ranking = 1125 THEN 58503
  WHEN Ranking = 1130 THEN 58297
  WHEN Ranking = 753 THEN 66242
  WHEN Ranking = 790 THEN 65617
  WHEN Ranking = 792 THEN 65569
  WHEN Ranking = 808 THEN 65338
  WHEN Ranking = 818 THEN 65088
  WHEN Ranking = 835 THEN 64848
  WHEN Ranking = 859 THEN 64457
  WHEN Ranking = 922 THEN 62961
  WHEN Ranking = 947 AND City = 'Roanne' THEN 62454
  WHEN Ranking = 947 AND City = 'Carlow' THEN 62444
  WHEN Ranking = 965 THEN 62022
  WHEN Ranking = 1021 THEN 60929
  WHEN Ranking = 1153 THEN 57827
  ELSE ResultScore
END,
ResultScorePlace = CASE 
  WHEN Ranking = 194 THEN 189
  WHEN Ranking = 214 THEN 212
  WHEN Ranking = 378 THEN 378
  WHEN Ranking = 379 THEN 379
  WHEN Ranking = 393 THEN 388
  WHEN Ranking = 476 THEN 474
  WHEN Ranking = 491 THEN 492
  WHEN Ranking = 539 THEN 538
  WHEN Ranking = 550 THEN 549
  WHEN Ranking = 579 THEN 578
  WHEN Ranking = 610 THEN 609
  WHEN Ranking = 621 THEN 625
  WHEN Ranking = 638 THEN 645
  WHEN Ranking = 652 THEN 650
  WHEN Ranking = 668 THEN 664
  WHEN Ranking = 711 THEN 710
  WHEN Ranking = 716 THEN 718
  WHEN Ranking = 718 THEN 717
  WHEN Ranking = 733 THEN 735
  WHEN Ranking = 775 THEN 779
  WHEN Ranking = 791 THEN 791
  WHEN Ranking = 809 THEN 813
  WHEN Ranking = 849 THEN 849
  WHEN Ranking = 853 THEN 853
  WHEN Ranking = 856 THEN 857
  WHEN Ranking = 897 THEN 896
  WHEN Ranking = 934 THEN 935
  WHEN Ranking = 941 THEN 945
  WHEN Ranking = 980 THEN 979
  WHEN Ranking = 1014 THEN 1014
  WHEN Ranking = 1053 THEN 1049
  WHEN Ranking = 1066 THEN 1064
  WHEN Ranking = 1125 THEN 1125
  WHEN Ranking = 1130 THEN 1130
  WHEN Ranking = 753 THEN 751
  WHEN Ranking = 790 THEN 790
  WHEN Ranking = 792 THEN 793
  WHEN Ranking = 808 THEN 807
  WHEN Ranking = 818 THEN 816
  WHEN Ranking = 835 THEN 835
  WHEN Ranking = 859 THEN 858
  WHEN Ranking = 922 THEN 921
  WHEN Ranking = 947 AND City = 'Roanne' THEN 947
  WHEN Ranking = 947 AND City = 'Carlow' THEN 948
  WHEN Ranking = 965 THEN 963
  WHEN Ranking = 1021 THEN 1021
  WHEN Ranking = 1153 THEN 1152
  ELSE ResultScorePlace
END,
WorldRecordScore = 0,
CompetitionScore = CASE 
  WHEN Ranking = 194 THEN 77103
  WHEN Ranking = 214 THEN 76452
  WHEN Ranking = 378 THEN 72235
  WHEN Ranking = 379 THEN 72159
  WHEN Ranking = 393 THEN 71891
  WHEN Ranking = 476 THEN 70603
  WHEN Ranking = 491 THEN 70380
  WHEN Ranking = 539 THEN 69401
  WHEN Ranking = 550 THEN 69209
  WHEN Ranking = 579 THEN 68796
  WHEN Ranking = 610 THEN 68277
  WHEN Ranking = 621 THEN 68141
  WHEN Ranking = 638 THEN 67816
  WHEN Ranking = 652 THEN 67614
  WHEN Ranking = 668 THEN 67444
  WHEN Ranking = 711 THEN 66830
  WHEN Ranking = 716 THEN 66782
  WHEN Ranking = 718 THEN 66768
  WHEN Ranking = 733 THEN 66530
  WHEN Ranking = 775 THEN 65927
  WHEN Ranking = 791 THEN 65613
  WHEN Ranking = 809 THEN 65336
  WHEN Ranking = 849 THEN 64657
  WHEN Ranking = 853 THEN 64535
  WHEN Ranking = 856 THEN 64491
  WHEN Ranking = 897 THEN 63644
  WHEN Ranking = 934 THEN 62722
  WHEN Ranking = 941 THEN 62601
  WHEN Ranking = 980 THEN 61796
  WHEN Ranking = 1014 THEN 61109
  WHEN Ranking = 1053 THEN 60335
  WHEN Ranking = 1066 THEN 59958
  WHEN Ranking = 1125 THEN 58503
  WHEN Ranking = 1130 THEN 58357
  WHEN Ranking = 753 THEN 66242
  WHEN Ranking = 790 THEN 65637
  WHEN Ranking = 792 THEN 65584
  WHEN Ranking = 808 THEN 65343
  WHEN Ranking = 818 THEN 65088
  WHEN Ranking = 835 THEN 64848
  WHEN Ranking = 859 THEN 64467
  WHEN Ranking = 922 THEN 62976
  WHEN Ranking = 947 AND City = 'Roanne' THEN 62454
  WHEN Ranking = 947 AND CountryCode = 'Carlow' THEN 62454
  WHEN Ranking = 965 THEN 62022
  WHEN Ranking = 1021 THEN 60954
  WHEN Ranking = 1153 THEN 57827
  ELSE CompetitionScore
END
FROM track_and_field_competition_rankings
WHERE Ranking IN (194, 214, 378, 379, 393, 476, 491, 539, 550, 579, 610, 621, 638, 652, 668, 711, 716, 718, 733, 775, 791, 809, 849, 853, 856, 897, 934, 941, 980, 1014, 1053, 1066, 1125, 1130, 753, 790, 792, 808, 818, 835, 859, 922, 947, 965, 1021, 1153)


--- Update 3 rows: ranking 326, 458, 721 and 1039 ---
UPDATE track_and_field_competition_rankings
SET 
   MeetingName = CASE 
       WHEN Ranking = 326 THEN '2024 Iksan National Athletics Meeting'
       WHEN Ranking = 458 THEN 'Regional (Yangtze River Delta) Invitation Meeting'
       WHEN Ranking = 721 THEN 'Xrhstos Boudouris Memorial'
       ELSE MeetingName
   END,
   StadiumName = CASE 
       WHEN Ranking = 326 THEN 'Iksan Stadium'
       WHEN Ranking = 458 THEN 'Cixi City Stadium'
       WHEN Ranking = 721 THEN 'Thiva Stadium'
	   WHEN Ranking =1039 THEN NULL
       ELSE StadiumName
   END,
   City = CASE 
       WHEN Ranking = 326 THEN 'Iksan'
       WHEN Ranking = 458 THEN 'Cixi City'
       WHEN Ranking = 721 THEN 'Thiva'
	   WHEN Ranking =1039 THEN 'Priboj'
       ELSE City
   END,
   CountryCode = CASE 
       WHEN Ranking = 326 THEN 'KOR'
       WHEN Ranking = 458 THEN 'CHN'
       WHEN Ranking = 721 THEN 'GRE'
	   WHEN Ranking = 1039 THEN 'SRB'
       ELSE CountryCode
   END,
   StartDate = CASE 
       WHEN Ranking = 326 THEN '2024-07-06'
       WHEN Ranking = 458 THEN '2024-04-23'
       WHEN Ranking = 721 THEN '2024-06-22'
	   WHEN Ranking = 1039 THEN '2024-09-04'
       ELSE StartDate
   END,
   EndDate = CASE 
       WHEN Ranking = 326 THEN '2024-07-09'
       WHEN Ranking = 458 THEN '2024-04-24'
       WHEN Ranking = 721 THEN '2024-06-22'
	   WHEN Ranking = 1039 THEN '2024-09-04'
       ELSE EndDate
   END,
   ParticipationScore = CASE 
       WHEN Ranking = 326 THEN 30
       WHEN Ranking = 458 THEN 10
       WHEN Ranking = 721 THEN 0
	   WHEN Ranking = 1039 THEN 180
       ELSE ParticipationScore
   END,
   ParticipationScorePlace = CASE 
       WHEN Ranking = 326 THEN 525
       WHEN Ranking = 458 THEN 686
       WHEN Ranking = 721 THEN NULL
	   WHEN Ranking = 1039 THEN 240
       ELSE ParticipationScorePlace
   END,
   ResultScore = CASE 
       WHEN Ranking = 326 THEN 73437
       WHEN Ranking = 458 THEN 70858
       WHEN Ranking = 721 THEN 66728
	   WHEN Ranking = 1039 THEN 60339
       ELSE ResultScore
   END,
   ResultScorePlace = CASE 
       WHEN Ranking = 326 THEN 325
       WHEN Ranking = 458 THEN 452
       WHEN Ranking = 721 THEN 721
	   WHEN Ranking = 1039 THEN 1047
       ELSE ResultScorePlace
   END,
   WorldRecordScore = CASE 
       WHEN Ranking IN (326, 458, 721, 1039) THEN 0
       ELSE WorldRecordScore
   END,
   CompetitionScore = CASE 
       WHEN Ranking = 326 THEN 73467
       WHEN Ranking = 458 THEN 70868
       WHEN Ranking = 721 THEN 66728
	   WHEN Ranking = 1039 THEN 60519
       ELSE CompetitionScore
   END
WHERE Ranking IN (326, 458, 721, 1039)

--- Update row Meeting name:Flag of MCST 45th National Athletics Meeting---
UPDATE track_and_field_competition_rankings
SET
	StadiumName=NULL,
	City='Gimhae',
	CountryCode='KOR',
	StartDate='2024-08-17',
	EndDate='2024-08-19',
	ParticipationScore=0,
	ParticipationScorePlace=NULL,
	ResultScore=66423,
	ResultScorePlace=736,
	CompetitionScore=66423
WHERE MeetingName='Flag of MCST 45th National Athletics Meeting'

--- Convert to appropiete type ---
UPDATE track_and_field_competition_rankings
SET
	WorldRecordScore=CAST(REPLACE(REPLACE(REPLACE(WorldRecordScore, '"', ''), ' ', ''), CHAR(10), '') AS INT),
	CompetitionScore=CAST(REPLACE(REPLACE(REPLACE(CompetitionScore, '"', ''), ' ', ''), CHAR(10), '') AS INT),
	StartDate= TRY_CONVERT(DATE, StartDate, 103),
	EndDate=TRY_CONVERT(DATE, EndDate, 103), 
	ParticipationScore= CAST(ParticipationScore AS INT),
	ParticipationScorePlace= CAST(ParticipationScorePlace AS INT),
	ResultScore= CAST(ResultScore AS INT),
	ResultScorePlace= CAST(ResultScorePlace AS INT)

--- Switch column for some rows ---
UPDATE track_and_field_competition_rankings
SET
	CompetitionScore=WorldRecordScore,
	WorldRecordScore=0
WHERE Ranking > 100 AND WorldRecordScore <> 0

