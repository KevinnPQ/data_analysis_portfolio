SELECT * FROM covid_deaths cd ORDER BY 3,4;

SELECT * FROM covid_vaccinations cv ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths cd 
ORDER BY 1,2;

# Total cases vs Total deaths

SELECT DISTINCT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths cd 
WHERE location LIKE "%Costa%"
ORDER BY 1,2 DESC;

# Percentage of population with Covid
SELECT DISTINCT location, date, total_cases, population, (total_cases/population)*100 AS sickness_percentage
FROM covid_deaths cd 
WHERE location LIKE "%Costa%"
ORDER BY 1,2;

#Countries with largest population rate
SELECT location, population, MAX(total_cases) AS total_infection_count, MAX((total_cases/population))*100 AS population_infected_percentage
FROM covid_deaths cd 
#WHERE location LIKE "%Costa%"
GROUP BY location, population
ORDER BY population_infected_percentage DESC;


#Countries with highest death count per population
SELECT location, population, MAX(total_deaths) AS total_death_count
FROM covid_deaths cd 
WHERE continent is not null
GROUP BY location, population
ORDER BY total_death_count DESC;

#Total population vs vaccination


SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_people_vaccinated
FROM covid_deaths cd 
JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent != ""
ORDER BY 2,3;

#CTE
WITH population_vs_vaccination (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_people_vaccinated
FROM covid_deaths cd 
JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent != ""
ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100 AS percentage_people_vaccinated FROM population_vs_vaccination;

#Temp Table

DROP TABLE IF EXISTS population_vs_vaccination;
CREATE TEMPORARY TABLE population_vs_vaccination(
continent VARCHAR (255), 
location VARCHAR (255), 
date datetime, 
population numeric,
new_vaccinations numeric, 
rolling_people_vaccinated numeric
);

INSERT INTO population_vs_vaccination
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_people_vaccinated
FROM covid_deaths cd 
JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent != ""
ORDER BY 2,3;

SELECT *, (rolling_people_vaccinated/population)*100 AS percentage_people_vaccinated FROM population_vs_vaccination;	

CREATE VIEW population_vs_vaccination AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_people_vaccinated
FROM covid_deaths cd 
JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent != ""
ORDER BY 2,3;

SELECT * FROM population_vs_vaccination pvv;


