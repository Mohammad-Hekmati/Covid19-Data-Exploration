-- In this file we are going to explore covid19 impact on populations based on geography.

---------
-- Simple test

SELECT * FROM covid_data 
WHERE continent is not null
order by 3,4;

-- Taking a glance at the data that we are going to work with

Select Location, date, total_cases, new_cases, total_deaths, population
From covid_data
Where continent is not null 
order by 1,2;

-- Infections vs deaths among infected people
-- Illustrating the mortality rate among infected people in each country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From covid_data
Where total_deaths is not null
and continent is not null 
order by 1,2;

-- Comparing the total number of cases with the population of each country
-- Illustrating the infection rate across different countries

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From covid_data
Where total_cases is not null
order by 1,2;

-- Highest Infection Rate among countries
SELECT Location,population, MAX(total_cases) as HighestInfectionRate, Max(total_cases/population) * 100 as PopulationInfectedPercentage
From covid_data
Group by 1,2
Order by PopulationInfectedPercentage desc;

-- Countries with Higest mortality

Select Location, Max(Total_deaths) as TotalDeathsCount
from covid_data
Where continent is not null
Group by location
Order by TotalDeathsCount desc NULLS LAST;

-- Countries with Highest Mortality rate

SELECT location,
       MAX(total_cases)  AS total_cases_count,
       MAX(total_deaths) AS total_deaths_count,
       MAX(total_deaths) / NULLIF(MAX(total_cases), 0) * 100 AS death_percentage
FROM covid_data
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_percentage DESC NULLS LAST;

-- Continents with highest mortality rates

SELECT continent,
       SUM(total_deaths_count) AS total_death_count,
       SUM(total_cases_count)  AS total_cases_count,
       SUM(total_deaths_count) / NULLIF(SUM(total_cases_count), 0) * 100 AS death_percentage,
       SUM(total_cases_count)  / NULLIF(SUM(population), 0) * 100        AS infection_rate,
	   SUM(total_deaths_count) / NULLIF(SUM(population),0) * 100 AS mortality_rate
FROM (
    SELECT continent,
           location,
           MAX(total_deaths) AS total_deaths_count,
           MAX(total_cases)  AS total_cases_count,
           MAX(population)   AS population
    FROM covid_data
    WHERE continent IS NOT NULL
    GROUP BY continent, location
) AS by_country
GROUP BY continent
ORDER BY death_percentage DESC NULLS LAST;

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid_data
where continent is not null 
order by 1,2;

-- Population and Vaccination
WITH vaccinated AS (
    SELECT dea.continent, dea.location, dea.date, dea.population,
           vac.new_vaccinations,
           SUM(vac.new_vaccinations) OVER (
               PARTITION BY dea.location
               ORDER BY dea.date
           ) AS rolling_people_vaccinated
    FROM covid_data dea
    JOIN covid_vaccinations vac
      ON dea.location = vac.location
     AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *
FROM vaccinated
WHERE rolling_people_vaccinated IS NOT NULL
ORDER BY location, date;

