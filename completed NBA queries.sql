Select *
From NBAProject..All_Seasons

--First we will check our dataset for duplicates

Select F1, COUNT(*)
From NBAProject..All_Seasons
Group by F1
Having count(*) > 1

--There are no duplicates in our data
--Now we want to find and address any NULL values

Select *
From NBAProject..All_Seasons
Where f1 is null

Select *
From NBAProject..All_Seasons
Where player_name is null

Select *
From NBAProject..All_Seasons
Where team_abbreviation is null

Select *
From NBAProject..All_Seasons
Where age is null

Select *
From NBAProject..All_Seasons
Where player_height is null

Select *
From NBAProject..All_Seasons
Where player_weight is null

Select *
From NBAProject..All_Seasons
Where college is null

Select *
From NBAProject..All_Seasons
Where country is null

Select *
From NBAProject..All_Seasons
Where draft_year is null

Select *
From NBAProject..All_Seasons
Where draft_round is null

Select *
From NBAProject..All_Seasons
Where draft_number is null

Select *
From NBAProject..All_Seasons
Where gp is null

Select *
From NBAProject..All_Seasons
Where pts is null

Select *
From NBAProject..All_Seasons
Where reb is null

Select *
From NBAProject..All_Seasons
Where ast is null

Select *
From NBAProject..All_Seasons
Where net_rating is null

Select *
From NBAProject..All_Seasons
Where oreb_pct is null

Select *
From NBAProject..All_Seasons
Where dreb_pct is null

Select *
From NBAProject..All_Seasons
Where usg_pct is null

Select *
From NBAProject..All_Seasons
Where ts_pct is null

Select *
From NBAProject..All_Seasons
Where ast_pct is null

--NULL values appear in draft year, draft round, and draft number
--We will update this data for undrafted players
--First we will have to change the data types of these columns so that they can be changed

Alter Table NBAProject..All_Seasons
Alter Column draft_year nvarchar(255)

Alter Table NBAProject..All_Seasons
Alter Column draft_round nvarchar(255)

Alter Table NBAProject..All_Seasons
Alter Column draft_number nvarchar(255)

--We will now create a temp table to look at the null values in draft year

Drop Table if Exists #undrafted_players
Select f1, draft_year
Into #undrafted_players
From NBAProject..All_Seasons

--We know that NULL values in draft year mean that the player went undrafted so we will mark these values as 'Undrafted'

Update #undrafted_players
Set draft_year = 'Undrafted'
Where draft_year is null

Update NBAProject..All_Seasons
Set draft_year = 'Undrafted'
From NBAProject..All_Seasons
Join NBAProject..All_Seasons as all2
	On All_Seasons.f1 = all2.f1
Where All_Seasons.draft_year is null 

--Now we must address players that have NULL values for draft round and draft number
--Since we do not have more information, we will mark these values as 'N/A' for now

Update NBAProject..All_Seasons
Set draft_round = 'N/A'
Where draft_round is null

Update NBAProject..All_Seasons
Set draft_number = 'N/A'
Where draft_number is null

--Now lets make sure that there are no other errors in these 3 columns

Select draft_year, draft_round, draft_number
From NBAProject..All_Seasons
Where draft_year = 'Undrafted' and draft_round != 'N/A' and draft_number != 'N/A'

--Now let's make a temp table to show players' height in ft and inches instead of centimeters

Drop Table if Exists #player_height
Select *
Into #player_height
From NBAProject..All_Seasons

select player_name, floor(player_height / (2.54 * 12)) as feet,
       (player_height - floor(player_height / (2.54 * 12)) * 12 * 2.54) / 2.54 as inches
from #player_height

--Getting data ready for visualization 

--Let's get rid of the repeating decimals for player weight and round them to a more usable number

Update NBAProject..All_Seasons
Set player_weight = Round(player_weight, 2)

--Looking at players with the most points

Select top 10 player_name, MAX(Cast(pts as int)) as pts_by_player
From NBAProject..All_Seasons
Where player_name is not null
Group by player_name
Order by pts_by_player desc


--Looking at height vs reb

Select player_name, player_height, reb
From #player_height
Where player_name is not null
Order by reb desc, player_height desc

--Looking at total avg pts by team 

SELECT team_abbreviation, SUM(pts/gp) as pts_per_team
FROM NBAProject..All_Seasons
WHERE pts != '0'
GROUP BY team_abbreviation
ORDER BY pts_per_team DESC

--Looking at Players' BMI

Select player_name, player_height, player_weight, (player_weight/(player_height*0.01*player_height*0.01)) as BMI
From NBAProject..All_Seasons
Order by 1,2

--Looking at pts vs true shooting pct

Select player_name, pts, ts_pct
From NBAProject..All_Seasons
Where player_name is not null
Order by pts desc, ts_pct desc

--Looking at the tallest players and their country

Select distinct country, player_name, MAX(player_height) as max_height
From NBAProject..All_Seasons
Where player_name is not null
Group by player_name, country
Order by max_height desc








