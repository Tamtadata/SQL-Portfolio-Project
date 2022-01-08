SELECT *
FROM PortfolioProject..Coviddeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations

--select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths in a specific country - US. 
-- DeathPercentage shows the likelihood of dying. In US by the end of 2020 there is around 1.8 percentage chance that a person who has a covid dies.

SELECT Location, date, total_cases, total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population in Georgia. 
-- Shows what percentage of population got covid
-- By the end of 2020, around 5.6% of population has reported covid cases. 

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like 'Georgia'
Order BY 1,2

-- Looking at countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population) *100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY population, Location
ORDER BY PercentPopulationInfected desc

--Looking at countries with Highest Death Rate compared to their Population.
-- Peru has the highest percentage of death compared to its population

SELECT Location, population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX(total_deaths/population) * 100 as PercentPopulationDeath
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationDeath desc



-- Looking at countries with Highest Death count. US has highest death count

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Looking at Total Death by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent  is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Looking at continents with highest death rate per population.
-- South America has the highest death rate per population compared to other continents.

SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX(total_deaths/population) * 100 as PercentPopulationDeath
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY PercentPopulationDeath desc


-- Looking at total global cases each day. 
-- new_death is nvarchar and have to change into int

SELECT  date, SUM(total_cases) as total_cases_global, SUM(new_cases) as new_cases_global, SUM(cast(new_deaths as int)) as new_deaths_global
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY date
ORDER BY 1,2 

-- Looking at new death percentage per new cases.
-- First new death globally was recorded on January 23, 2020 out of 98 total new cases. New death percentage was 1 %. 

SELECT  date, SUM(new_cases) as new_cases_global, SUM(cast(new_deaths as int)) as new_deaths_global, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as NewDeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY date
ORDER BY 1,2 

-- Total global cases

SELECT SUM(new_cases) as new_cases_global, SUM(cast(new_deaths as int)) as new_deaths_global, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as NewDeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 1,2


-- Use CovidVaccination Table
-- Join two tables based on location and date

Select *
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

-- Add a column that sums up the new vaccinations by country 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3 


-- USE CTE (option 1) in order to do manipulations on a newly created column RollingPeopleVaccinated

With PopvsVac (Continent, location,date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
-- order by 2,3 
)
Select * , (RollingPeopleVaccinated/population) *100 
From PopvsVac

-- TEMP Table (option 2)

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Select * , (RollingPeopleVaccinated/population) *100
From #PercentPopulationVaccinated


-- create view to store data

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date