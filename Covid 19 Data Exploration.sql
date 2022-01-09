-- The Covid-19 database is downloaded from https://ourworldindata.org/covid-deaths and covers the period of  February 15, 2020 - April 30, 2021. 
-- The main purpose of this portfolio is to explore the data by asking simple questions that I came up myself
-- Skills used: Joins, Converting Data Types

SELECT *
FROM PortfolioProject..Coviddeaths


SELECT *
FROM PortfolioProject..CovidVaccinations



-- Q: Which country has the highest infection rate globally?
-- A: Andorra recorded the highest infection rate, 17% per its population

SELECT Location, population, MAX(total_cases) as total_cases_count, MAX(total_cases/population) * 100 as infection_rate
FROM PortfolioProject..CovidDeaths
GROUP BY population, Location
ORDER BY infection_rate desc


-- Q: Which country has the highest death count per population?
-- A: United States has the highest death count per its population.

SELECT Location, population, MAX(cast(total_deaths as int)) as total_deaths_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY total_deaths_count desc



-- Q: Which continent has the lowest death count?
-- A: Oceania has the lowest death count

SELECT continent, SUM(cast(total_deaths as int)) as total_deaths_count
FROM PortfolioProject..CovidDeaths
WHERE continent  is not null
GROUP BY continent
ORDER BY total_deaths_count asc



-- Q: When was the highest death rate per total cases recorded in a country - Georgia. 
-- A: Highest death rate was recorded in Georgia on 2020-05-14 as 1.8%  

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_rate
FROM PortfolioProject..CovidDeaths
Where location = 'Georgia' and total_deaths is not NULL
ORDER BY death_rate desc

 
-- Q: When was the highest infection rate per population reported in Georgia?
-- A: Highest infection rate in Georgia was recorded as 7.8% on 2021-04-30.

SELECT Location, date, total_cases, population, (total_cases/population)*100 as infection_rate
FROM PortfolioProject..CovidDeaths
Where location = 'Georgia'
Order BY infection_rate desc


-- Join two tables based on location and date

Select *
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

---- Q: Which country has the highest vaccination count?
---- A: China has the highest vaccination count
Select dea.location, MAX(CONVERT(int,vac.total_vaccinations)) as vaccination_count --, dea.population --*100 as vaccination_rate 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
GROUP BY dea.location 
Order by vaccination_count desc

