SELECT *
FROM [Portfolio Project]..CovidDeaths_v1
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT *
FROM [Portfolio Project]..CovidVaccinations
ORDER BY 3,4

--SELECT Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths_v1
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shoes likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases,total_deaths, Cast(total_deaths as float) / (total_cases)*100 AS death_percentage
FROM [Portfolio Project]..CovidDeaths_v1
WHERE Location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, Cast(total_cases as float) / (population)*100 AS Percent of Population Infected
FROM [Portfolio Project]..CovidDeaths_v1
--WHERE Location like '%states%'
ORDER BY 1,2

-- Looking at countires with the Highest Infection Rate compared to Population

SELECT Location, population, max(total_cases)AS HighestInfectionCount, MAX(Cast(total_cases as float) / (population))*100 AS PopulationInfected
FROM [Portfolio Project]..CovidDeaths_v1
--WHERE Location like '%states%'
GROUP BY location, population
ORDER BY PopulationInfected DESC

-- This is showing the Countries with the Highest Death Count per Population

SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths_v1
--WHERE Location like '%states%'
WHERE Continent IS NOT NULL
GROUP BY Location 
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- This is showing the Continents with the Highest Death Count per Population


SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths_v1
--WHERE Location like '%states%'
WHERE Continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths_v1
--WHERE Location like '%states%'
WHERE Continent IS NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT date, SUM(new_cases)as TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/ SUM(CAST(New_cases AS Float))*100 AS DeathPercentage--, Cast(total_deaths as float) / (total_cases)*100 AS death_percentage
FROM [Portfolio Project]..CovidDeaths_v1
--WHERE Location like '%states%'
WHERE Continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases)as TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/ SUM(CAST(New_cases AS Float))*100 AS DeathPercentage--, Cast(total_deaths as float) / (total_cases)*100 AS death_percentage
FROM [Portfolio Project]..CovidDeaths_v1
--WHERE Location like '%states%'
WHERE Continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--  Looking at Total Population vs [Portfolio Project].CovidVaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST (new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths_v1 dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
ORDER BY 2,3

--USE CTE


WITH PopvsVac (continent, locaiton, date, population, new_vaccinations, RolllingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths_v1 dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, CAST(RolllingPeopleVaccinated as FLOAT)/(population)*100 
FROM PopvsVac


__ TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths_v1 dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
--ORDER BY 2,3

SELECT *, CAST(RollingPeopleVaccinated as FLOAT)/(population)*100 
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS



CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths_v1 dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
--ORDER BY 2,3
