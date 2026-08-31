SELECT *
FROM ProjectPortfolio..CovidDeaths
order by 3,4

--SELECT *
--FROM ProjectPortfolio..CovidVaccinations
--order by 3,4

-- Select Data that we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
Where location like '%India%'
order by 1,2

-- Looking at the Total Cases Vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
--Where location like '%India%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
--Where location like '%India%'
GROUP BY location, population
ORDER by PercentPopulationInfected desc

-- Showing Countries with Higest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
--Where location like '%India%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(try_cast(new_deaths as bigint)) as total_deaths,  SUM(try_cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths
--Where location like '%India%'
WHERE continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations	

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

WITH PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
	
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later

DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
FROM ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated
