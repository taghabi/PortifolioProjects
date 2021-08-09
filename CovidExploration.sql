-- COVID 19 DATA EXPLORATION.
-- Data source:https://ourworldindata.org/covid-deaths
-- Data analysis on covid using data up until August 8th 2021.
-- Skills used: 

SELECT * FROM PortifolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Select the data to we are working with 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortifolioProject..CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total_cases vs total_deaths.
-- DeathPercentage shows likelihood of dying if you contract covid in Jordan. 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortifolioProject..CovidDeaths 
WHERE location LIKE '%jordan%' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at total_cases vs total_population.
-- PercentPopulationAffected shows what percentage of the population has covid in Jordan.
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationAffected
FROM PortifolioProject..CovidDeaths 
WHERE location LIKE '%jordan%' AND continent IS NOT NULL
ORDER BY 1,2


-- Countries with highest infection rate compared to population.
SELECT location, population, MAX(total_cases) AS MaxCases, Max((total_cases/population)*100) AS PercentPopulationAffected
FROM PortifolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC


-- Countries with highest death count per population.
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS MaxDeaths, Max((total_deaths/population)*100) AS PercentPopulationAffected
FROM PortifolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MaxDeaths DESC

-- Continents with highest death count per population.
SELECT continent, MAX(CAST(total_deaths AS INT)) AS MaxDeaths, Max((total_deaths/population)*100) AS PercentPopulationAffected
FROM PortifolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MaxDeaths DESC


-- Global numbers.
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortifolioProject..CovidDeaths 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- SumNewVaccinations shows a rolling sum of new vaccinations for each country. Using window functions.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumNewVaccinations
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform a calculation on the previous partion by query to show the percentage PopulationVaccinated.
WITH PopvsVac (continent, location, date, population, new_vacinations, SumNewVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumNewVaccinations
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL -- AND dea.location LIKE '%jordan%
)
SELECT *, (SumNewVaccinations/population)*100 AS PopulationVaccinated
FROM PopvsVac

-- Using Temp Tables to perform a calculation on the previous partion by query to show the percentage PopulationVaccinated in Jordan.
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
SumNewVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumNewVaccinations
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL -- AND dea.location LIKE '%jordan%

SELECT *, (SumNewVaccinations/population)*100 AS PopulationVaccinated
FROM #PercentPopulationVaccinated 
WHERE location LIKE '%jordan%'


-- Creating Views for visualization in Tableau BI tool.

-- Continent death count:
CREATE VIEW ContinentDeathCount AS
-- Showing continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS MaxDeaths, Max((total_deaths/population)*100) AS PercentPopulationAffected
FROM PortifolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY MaxDeaths DESC

-- Percent population vaccinated:
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumNewVaccinations
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

-- Percent Jordanians vaccinated:
CREATE VIEW PercentJordanVaccinated AS
WITH PopvsVac (continent, location, date, population, new_vacinations, SumNewVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumNewVaccinations
FROM PortifolioProject..CovidDeaths dea
JOIN PortifolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL -- AND dea.location LIKE '%jordan%
)
SELECT *, (SumNewVaccinations/population)*100 AS PopulationVaccinated
FROM PopvsVac 
WHERE location LIKE '%jordan%'


-- Country death count:
CREATE VIEW CountryDeathCount AS
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS MaxDeaths, Max((total_deaths/population)*100) AS PercentPopulationAffected
FROM PortifolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location, population

-- Country infection count:
CREATE VIEW CountryInfectionCount AS
SELECT location, population, MAX(total_cases) AS MaxCases, Max((total_cases/population)*100) AS PercentPopulationAffected
FROM PortifolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location, population
