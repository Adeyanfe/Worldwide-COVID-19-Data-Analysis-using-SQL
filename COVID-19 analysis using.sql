---1. Total covid19 cases and deaths for each location
select location, SUM(total_cases) AS total_cases,
SUM(total_deaths) AS total_deaths
from CovidDeaths
where continent IS NOT NULL
GROUP BY location;

---2. Global cases per day
SELECT date, SUM(new_cases) as total_newcases, sum(new_deaths) as total_newdeaths, 
    case
        WHEN SUM(new_cases) <> 0 THEN SUM(new_deaths)*1.0/SUM(new_cases)*100 
        ELSE NULL
    END AS death_rate
FROM coviddeaths
WHERE Continent is not NULL
GROUP BY DATE

---3.Continent with the highest deathcount
SELECT continent, MAX(total_deaths) as highestDeathCount
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by continent
ORDER BY highestDeathCount Desc;

----4. Continent with the highest cummulative death cases
SELECT continent, SUM(total_deaths) as CummulativeTotalDeaths
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by continent
order by CummulativeTotalDeaths desc;

---5. Country with the highest Cummlative death cases
select location, continent, SUM(total_deaths) AS Cummulative_total_deaths
from CovidDeaths
where continent IS NOT NULL
GROUP BY location, continent
ORDER BY cummulative_total_deaths DESC;


---6. Country with the highest death counts
SELECT location, continent, MAX(total_deaths) as highestDeathCount
FROM coviddeaths
WHERE CONTINENT IS NOT NULL 
Group by location, continent
order by highestDeathCount desc;

---7. What country has the highest death rate per population
SELECT continent, location, population, MAX(total_deaths) as highestDeathCount, MAX((total_deaths * 1.0/population)*100) as PercentPopulationDied
FROM coviddeaths
WHERE Continent is not NULL
Group by continent, location, population
order by highestDeathCount desc;

----8. What country has the highest infection rate compared to population
SELECT continent, location, population, Max(total_cases) as highestInfectionCount, MAX((total_cases * 1.0/population)*100) as PercentPopulationInfected
FROM coviddeaths
WHERE Continent is not NULL
Group by continent, location, population
order by highestInfectionCount desc;

----9. What is the total number of cases and the total percentage of population infected across each country, 
SELECT continent, location, population, SUM(total_cases) as cummulativedeathcases, SUM((total_cases * 1.0/population)*100) as PercentPopulationInfected
FROM coviddeaths
WHERE Continent is not NULL
Group by continent, location, population
order by cummulativedeathcases desc;

----10. What is the Mortality rate - total deaths divided by total cases
SELECT continent, location, date, total_cases, total_deaths, (total_deaths * 1.0 /total_cases) * 100 as mortality_rate
FROM coviddeaths
WHERE Continent is not NULL
order by continent, location;

----11. What percentage of the population got covid
SELECT continent, location, date, total_cases, population, (total_cases * 1.0 /population) * 100 as PercentPopulationInfected
FROM coviddeaths
WHERE Continent is not NULL
order by continent, location;

---12. Is there a correlation between Population density and death rate
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

----13. Is there a correlation between Povery rate and total deaths
SELECT location, continent, AVG(total_deaths) as avgTotalDeaths, extreme_poverty, count (*) As numcountries
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY extreme_poverty;

----14. Creating view

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

