
--Select Data that we are going to be using
SELECT Location ,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 3,4

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying  if you contract covid in my country 

SELECT Location ,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
FROM CovidDeaths
where location like 'Turkey'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location ,date,total_cases,population,(total_cases/population)*100 as PercentOfPopulationInfected 
FROM CovidDeaths
--WHERE location like 'Turkey'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to population
SELECT Location,population,MAX(total_cases) as HighestInfectionCount,population,MAX((total_cases/population))*100 as PercentOfPopulationInfected
FROM CovidDeaths
group by  Location,population
ORDER BY PercentOfPopulationInfected desc


--Showing Countries with Highest Death Count per Population


SELECT Location,MAX(cast(total_deaths as int) ) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
group by  Location
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT 

--Showing continents with the highest death count per population 

SELECT continent,MAX(cast(total_deaths as int) ) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
group by  continent 
ORDER BY TotalDeathCount desc


--Global Numbers 

SELECT SUM(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths,Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
FROM CovidDeaths
where continent is not null
ORDER BY 1,2

--Looking at Total Population vs Vaccination 

--USE CTE 

WITH PopvsVac (Continent,location,date,population,New_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)  
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM 
CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

)
SELECT * ,(RollingPeopleVaccinated/population)*100 FROM PopvsVac

--Temp Table
DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)




INSERT INTO  #PercentPopulationVaccinated

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)  
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM 
CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


SELECT * ,(RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)  
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM 
CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

SELECT * FROM PercentPopulationVaccinated













