/*Covid-19 Data Exploration
Date Range: From January 1st, 2020 to November 5th, 2022
Skills used: CTE's Joins, Temp Tables, Aggregate Functions, Windows Functions, Creating views, Coverting data types
*/
---1. Viewing Data Sets
SELECT *
FROM covidDeaths
Where continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM covidVaccinations
ORDER BY 3,4;

---2. Select Data we are going to start with
SELECT location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

---3. Total covid19 cases and deaths for each location
select location, SUM(total_cases) AS total_cases,
SUM(total_deaths) AS total_deaths
from CovidDeaths
where continent IS NOT NULL
GROUP BY location;

---4. Global cases per day
SELECT date, SUM(new_cases) as total_newcases, sum(new_deaths) as total_newdeaths, 
    case
        WHEN SUM(new_cases) <> 0 THEN SUM(new_deaths)*1.0/SUM(new_cases)*100 
        ELSE NULL
    END AS death_rate
FROM coviddeaths
WHERE Continent is not NULL
GROUP BY DATE

---5. Continent with the highest deathcount
SELECT continent, MAX(total_deaths) as highestDeathCount
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by continent
ORDER BY highestDeathCount Desc;

----6. Continent with the highest cummulative death cases
SELECT continent, SUM(total_deaths) as CummulativeTotalDeaths
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by continent
order by CummulativeTotalDeaths desc;

---7. Country with the highest Cummlative death cases
select location, continent, SUM(total_deaths) AS Cummulative_total_deaths
from CovidDeaths
where continent IS NOT NULL
GROUP BY location, continent
ORDER BY cummulative_total_deaths DESC;

---8. Country with the highest death counts
SELECT location, continent, MAX(total_deaths) as highestDeathCount
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by location, continent
order by highestDeathCount desc;

---9. What country has the highest death rate per population
SELECT continent, location, population, MAX(total_deaths) as highestDeathCount, MAX((total_deaths * 1.0/population)*100) as PercentPopulationDied
FROM coviddeaths
WHERE Continent is not NULL
Group by continent, location, population
order by highestDeathCount desc;

----10. What country has the highest infection rate compared to population
SELECT continent, location, population, Max(total_cases) as highestInfectionCount, MAX((total_cases * 1.0/population)*100) as PercentPopulationInfected
FROM coviddeaths
WHERE Continent is not NULL
Group by continent, location, population
order by highestInfectionCount desc;

----11. What is the total number of cases and the total percentage of population infected across each country, 
SELECT continent, location, population, SUM(total_cases) as cummulativedeathcases, SUM((total_cases * 1.0/population)*100) as PercentPopulationInfected
FROM coviddeaths
WHERE Continent is not NULL
Group by continent, location, population
order by cummulativedeathcases desc;

----12. What is the Mortality rate - total deaths divided by total cases
SELECT continent, location, date, total_cases, total_deaths, (total_deaths * 1.0 /total_cases) * 100 as mortality_rate
FROM coviddeaths
WHERE Continent is not NULL
order by continent, location;

----13. What percentage of the population got covid
SELECT continent, location, date, total_cases, population, (total_cases * 1.0 /population) * 100 as PercentPopulationInfected
FROM coviddeaths
WHERE Continent is not NULL
order by continent, location;

---14. Is there a correlation between Population density and death rate
SELECT
    continent,
    AVG(population_density) AS avg_population_density,
    SUM(total_deaths) AS total_deaths,
    SUM(total_cases) AS total_cases,
    SUM(total_deaths) / SUM(total_cases) AS death_rate
FROM
    CovidDeaths
    WHERE continent IS NOT NULL
GROUP BY continent; 

----15. Is there a correlation between Povery rate and total deaths
SELECT location, continent, AVG(total_deaths) as avgTotalDeaths, extreme_poverty, count (*) As numcountries
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY extreme_poverty;

---16. Accessing Vaccination Data
SELECT * 
FROM CovidVaccinations;

----Joining the two tables together for viewing

SELECT *
FROM CovidDeaths
JOIN CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location
AND CovidDeaths.date = CovidVaccinations.date;

----17. What percentage of Population that has received at least one Covid Vaccine
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER 
(PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM  CovidDeaths death
JOIN CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3;

----18. Getting the percentage of RollingPeopleVaccinated for each location

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM  CovidDeaths death
JOIN CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 AS RollingPeopleVaccinatedPercentage
FROM PopvsVac;

----19. Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM  CovidDeaths death
JOIN CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
--WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population) * 100 AS PercentRollingPeopleVaccinated
FROM #PercentPopulationVaccinated;



----19. Creating view

CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER 
(PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM  CovidDeaths death
JOIN CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated;

Create View GlobalCasesPerDay AS 
SELECT date, SUM(new_cases) as total_newcases, sum(new_deaths) as total_newdeaths, 
    case
        WHEN SUM(new_cases) <> 0 THEN SUM(new_deaths)*1.0/SUM(new_cases)*100 
        ELSE NULL
    END AS death_rate
FROM coviddeaths
WHERE Continent is not NULL
GROUP BY DATE

Create View HighestDeathCountContinent AS 
SELECT continent, MAX(total_deaths) as hightestDeathCount
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by continent

CREATE VIEW TotalCovidCasesAndDeathLocation AS 
select location, SUM(total_cases) AS total_cases,
SUM(total_deaths) AS total_deaths
from CovidDeaths
where continent IS NOT NULL
GROUP BY location;

CREATE VIEW cummulativeDeathCasesLocation AS
select location, continent, SUM(total_deaths) AS total_deaths
from CovidDeaths
where continent IS NOT NULL
GROUP BY location, continent
ORDER BY total_deaths DESC;

Create View hightestDeathCountLocation AS 
SELECT continent, location, MAX(total_deaths) as hightestDeathCount
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by continent, location

CREATE VIEW highestcummulativeDeathLocation AS
select location, continent, SUM(total_deaths) AS total_deaths
from CovidDeaths
where continent IS NOT NULL
GROUP BY location, continent
ORDER BY total_deaths DESC;

Create View HighestDeathCountContinent AS 
SELECT continent, MAX(total_deaths) as hightestDeathCount
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by continent;

Create View HighestDeathperPopulation AS 
SELECT continent, location, population, MAX(total_deaths) as hightestDeathCount, MAX((total_deaths * 1.0/population)*100) as PercentPopulationDied
FROM coviddeaths
WHERE Continent is not NULL
Group by continent, location, population;

Create View HighestInfectedCountry AS 
SELECT continent, location, population, Max(total_cases) as highestInfectionCount, MAX((total_cases * 1.0/population)*100) as PercentPopulationInfected
FROM coviddeaths
WHERE Continent is not NULL
Group by continent, location, population

Create View mortalityrate AS 
SELECT continent, location, date, total_cases, total_deaths, (total_deaths * 1.0 /total_cases) * 100 as mortality_rate
FROM coviddeaths
WHERE Continent is not NULL

Create View PercentagePopulationInfected AS 
SELECT continent, location, date, total_cases, population, (total_cases * 1.0 /population) * 100 as PercentPopulationInfected
FROM coviddeaths
WHERE Continent is not NULL

 CREATE VIEW relationship_between_population_densityAndDeath_rate AS
SELECT
    continent,
    AVG(population_density) AS avg_population_density,
    SUM(total_deaths) AS total_deaths,
    SUM(total_cases) AS total_cases,
    SUM(total_deaths) / SUM(total_cases) AS death_rate
FROM
    CovidDeaths
    WHERE continent IS NOT NULL
GROUP BY continent;  

CREATE VIEW PovertyRateAndTotalDeathsCorrelation AS
SELECT location, continent, AVG(total_deaths) as avgTotalDeaths, extreme_poverty, count (*) As numcountries
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY extreme_poverty;

