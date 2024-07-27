select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3, 4

--chances of dying if you get covid in your country
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%ndia%'
and continent is not null
ORDER BY 1, 2;


--total cases vs population
--shows what percentage of population got covid
SELECT Location, date, population, total_cases, (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%ndia%'
ORDER BY 1, 2;

--countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT))) * 100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by location, population
ORDER BY PercentOfPopulationInfected desc;

--countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by location
ORDER BY TotalDeathCount desc;

--by continents
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by continent
ORDER BY TotalDeathCount desc;


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by continent
ORDER BY TotalDeathCount desc;

--continents with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by continent
ORDER BY TotalDeathCount desc;

--global number
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE (SUM(new_deaths) / SUM(new_cases)) * 100 
    END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--across the world 
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE (SUM(new_deaths) / SUM(new_cases)) * 100 
    END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;
--------------------------------------------------------------
--total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date 
where dea.continent is not null
order by 2,3
--order by new_vaccinations desc

--using cte
with PopvsVac(continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date 
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/ population)*100
from PopvsVac


--using temp table

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date= vac.date 

select *, (RollingPeopleVaccinated/ population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated


--creating view to store data for tableau
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
       --, (RollingPeopleVaccinated / population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3;

select * 
from PercentPopulationVaccinated

