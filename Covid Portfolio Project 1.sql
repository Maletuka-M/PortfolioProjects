SELECT* 
FROM PorfolioProject1..CovidDeaths
Order by location

SELECT *
FROM PorfolioProject1..CovidVaccinations
Order by 3,4

--Select Data that we are going to be using

--SELECT 
--location,
--date,
--total_cases,
--new_cases,
--total_deaths,
--new_deaths,
--population
--FROM PorfolioProject1..CovidDeaths
--Order by 1,2


--Looking at the Total Cases vs Total Deaths (The likelihood of death when Covid is contracted)

--Creating a temp table (Reason: Had issues with nvarchar datatypes when doing claculations so instead of changing the datatype in the database I created a temp table with the float datatypes)
Drop table if exists #Temp_CovidDeaths
Create table #Temp_CovidDeaths (
Location varchar(50),
Continent varchar (50),
Date datetime,
TotalCases float,
NewCases float,
TotalDeaths float,
NewDeaths float,
Population float)

Insert into #Temp_CovidDeaths
Select
location,
continent,
date,
total_cases,
new_cases,
total_deaths,
new_deaths,
population
From PorfolioProject1..CovidDeaths


Select *
From #Temp_CovidDeaths
Order by 1,2

SELECT 
Location,
Date,
TotalCases,
TotalDeaths,
(TotalDeaths/TotalCases)*100 as DeathPercentage
FROM #Temp_CovidDeaths
Where Location = 'Lesotho'
Order by 1,2


--Looking at the Total Cases vs Population (Percentage of population that has contracted Covid)

SELECT 
Location,
Date,
Population,
TotalCases,
(TotalCases/Population)*100 TotCasesVsPop
FROM #Temp_CovidDeaths
Where Location = 'Lesotho'
Order by 1,2


--Looking at Countries with highest infection rates compared to Population (Highest infection count per country)

SELECT 
Location,
Population,
Max(TotalCases) as HighestInfectionCount,
Max((TotalCases/Population))*100 MaxCasesVsPop
FROM #Temp_CovidDeaths
Group by Location, Population
Order by 4 DESC


--Showing the countries with the highest death counts per population

SELECT 
Location,
Population,
Max(TotalDeaths) as HighestDeathCount,
Max((TotalDeaths/Population))*100 MaxDeathVsPop
FROM #Temp_CovidDeaths
Group by Location, Population
Order by 3 DESC

--Showing continent stats and checking data, the continent values are different because of how the data has been set up
--Continent is null..Should include just the continents
SELECT 
Location,
Population,
Max(TotalDeaths) as HighestDeathCount
FROM #Temp_CovidDeaths
Where Continent is null
Group by Location, Population
Order by 3 DESC

--Continent data not filtered (Includes all the countries and continent data, basically duplicates)
SELECT
Location,
Population,
Max(TotalDeaths) as HighestDeathCount
FROM #Temp_CovidDeaths
--Where Continent is null
Group by Location, Population
Order by 3 DESC

--Continent is not null...Should include just the countries
SELECT 
Location,
Max(TotalDeaths) as HighestDeathCount
FROM #Temp_CovidDeaths
Where Continent is not null
Group by Location
Order by 2 DESC


--GLOBAL NUMBERS
--Death percentage across the world
SELECT 
--Date,
Sum(TotalCases) as GlobalTotalCases,
Sum(TotalDeaths) as GlobalTotalDeaths,
(Sum(TotalDeaths)/Sum(TotalCases))*100 as GlobalDeathPercentage
FROM #Temp_CovidDeaths
Where Continent is not null
--Group by Date
Order by 1

--SELECT 
--Date,
--Sum(NewCases) as GlobalNewCases,
--Sum(NewDeaths) as GlobalNewDeaths,
--(Sum(NewDeaths)/Sum(NewCases))*100 as GlobalNewDeathPercentage
--FROM #Temp_CovidDeaths
--Group by Date
--Order by 1

--The above code does not work because there are dates when there are reported deaths but no new cases reported which leads to a divion by 0

--SELECT 
--location,
--date,
--new_deaths,
--new_cases
----(new_deaths/new_cases) as deathpercentage
--FROM PorfolioProject1..CovidDeaths
--Where new_cases = '0'
--Order by location


--Looking at Total Population vs Vacccinations

SELECT TOP 100 *
FROM PorfolioProject1..CovidDeaths as Deaths
Join PorfolioProject1..CovidVaccinations as Vaccines
	ON Deaths.location = Vaccines.location
	and Deaths.date = Vaccines.date
Order by 3,4


SELECT
Deaths.continent,
Deaths.location,
Deaths.date,
Population,
new_vaccinations,
--people_vaccinated,
--total_vaccinations,
Sum(cast(new_vaccinations as float)) over 
(Partition by Deaths.location 
Order by Deaths.location, deaths.date) as CummulativeVacsPerCountry
--(CummulativeVacsPerCountry/Deaths.population)
FROM PorfolioProject1..CovidDeaths as Deaths
Join PorfolioProject1..CovidVaccinations as Vaccines
	ON Deaths.location = Vaccines.location
	and Deaths.date = Vaccines.date
Where deaths.continent is not null
Order by 2,3


--USE A CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CummulativeVacsPerCountry)
as
(
SELECT
Deaths.continent,
Deaths.location,
Deaths.date,
Population,
new_vaccinations,
--people_vaccinated,
--total_vaccinations,
Sum(cast(new_vaccinations as float)) over 
(Partition by Deaths.location 
Order by Deaths.location, deaths.date) as CummulativeVacsPerCountry
--,(CummulativeVacsPerCountry/Deaths.population)*100
FROM PorfolioProject1..CovidDeaths as Deaths
Join PorfolioProject1..CovidVaccinations as Vaccines
	ON Deaths.location = Vaccines.location
	and Deaths.date = Vaccines.date
Where deaths.continent is not null
--Order by 2,3
)
Select *, (CummulativeVacsPerCountry/Population)*100
From PopvsVac

--Creating a view to store data for later visualisations

Create View PercentPopVaccinated as
SELECT
Deaths.continent,
Deaths.location,
Deaths.date,
Population,
new_vaccinations,
--people_vaccinated,
--total_vaccinations,
Sum(cast(new_vaccinations as float)) over 
(Partition by Deaths.location 
Order by Deaths.location, deaths.date) as CummulativeVacsPerCountry
--(CummulativeVacsPerCountry/Deaths.population)
FROM PorfolioProject1..CovidDeaths as Deaths
Join PorfolioProject1..CovidVaccinations as Vaccines
	ON Deaths.location = Vaccines.location
	and Deaths.date = Vaccines.date
Where deaths.continent is not null
--Order by 2,3
