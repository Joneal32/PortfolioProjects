--Explore the data we just added 
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Select the data that we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Updating the data type of the columns total_cases and total_deaths to perform operations 

USE PortfolioProject; 

-- For total_cases column
ALTER TABLE CovidDeaths
ALTER COLUMN total_cases FLOAT;

-- For total_deaths column
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT;

--looking at total cases vs. total deaths
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Dominican%'
ORDER BY 1,2

--Total cases vs the population
SELECT location, date,population, total_cases, (total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%Dominican%'
ORDER BY 1,2

--Countries with highest infection rate
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location,location
ORDER BY InfectionRate Desc

--Countries with the highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount, MAX((total_deaths/population))*100 as DeathRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY DeathRate Desc

--By Continent
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
AND location NOT IN ('High income','Upper middle income', 'lower middle income','Low income')
GROUP BY location
ORDER BY TotalDeathCount Desc

--Global Numbers
SELECT SUM(new_cases) as TotalNewCases ,SUM(new_deaths) as TotalNewDeaths,
CASE
	WHEN SUM(new_cases) = 0 then NULL 
	ELSE SUM(new_deaths)/SUM(new_cases) *100
END as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Dominican%'
ORDER BY 1,2

--Looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

	--Use CTE
	WITH PopvsVac(continent,location,date,population,new_vaccinations,RollingpeopleVaccinated)
	as
	(
	SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
		)
	SELECT *, (RollingpeopleVaccinated/population)*100 VaccPercentage
	FROM PopvsVac

--Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
SELECT *, (RollingpeopleVaccinated/population)*100 VaccPercentage
	FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

CREATE VIEW PercentpopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	
