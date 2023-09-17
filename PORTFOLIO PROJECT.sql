--Covid 19 Data Exploration 

--Skills used:JOIN function, CTE's, Temp tables, Aggregate functions, Creating views

--Showing covid deaths
SELECT *
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--Showing covid vaccinations
SELECT *
FROM [PORTFOLIO PROJECT]..CovidVaccinations
ORDER BY 3,4

--Selecting data that we need to work with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total cases vs Total deaths
--Showing covid death percentage in India
SELECT location, date, total_cases, total_deaths, 
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS Death_Percentage
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2


--Death rate in India rised rapidly in 2020


--Total cases vs Population
--Shows what percent of population is infected with covid
SELECT location, date, CAST(total_cases AS decimal) as total_cases, population, (CAST(total_cases AS decimal)/population)*100 AS Percent_Population_Infected
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent is not null
AND location = 'India'
ORDER BY 1,2


--India's population is around 1.4 billion, total cases is around 44 million

--Countries with Highest Infection Rate compared to population

SELECT location, population, MAX( total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 AS Highest_Infection_Rate
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Highest_Infection_Rate DESC

--Countries with Highest Infection Rate compared to population (add in date)

SELECT location, population,date ,MAX( total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 AS Highest_Infection_Rate
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent is not null
GROUP BY location, population, date
ORDER BY Highest_Infection_Rate DESC

--Highest death count per population

SELECT location, MAX(CONVERT(int,total_deaths)) as total_death_count
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC

--Highest death count per population(by continent)

SELECT continent, MAX(CONVERT(int,total_deaths)) as total_death_count
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC

--Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as  death_percentage
FROM [PORTFOLIO PROJECT]..CovidDeaths
WHERE continent is not null
--GROUP BY date 
ORDER BY 1,2

--Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,dea.date) as Rolling_people_vaccinated
FROM [PORTFOLIO PROJECT]..CovidDeaths dea 
JOIN [PORTFOLIO PROJECT]..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH Popvsvac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,dea.date) as Rolling_people_vaccinated
FROM [PORTFOLIO PROJECT]..CovidDeaths dea 
JOIN [PORTFOLIO PROJECT]..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT*, (Rolling_people_vaccinated/population)*100
FROM Popvsvac

--Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,dea.date) as Rolling_people_vaccinated
FROM [PORTFOLIO PROJECT]..CovidDeaths dea 
JOIN [PORTFOLIO PROJECT]..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3
SELECT*, (Rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

USE [PORTFOLIO PROJECT] 
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,dea.date) as Rolling_people_vaccinated
FROM [PORTFOLIO PROJECT]..CovidDeaths dea 
JOIN [PORTFOLIO PROJECT]..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

--Check the view

SELECT *
FROM PercentPopulationVaccinated 
