Select * 
from PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4



--Select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4



select Location, Date, total_cases, new_cases, total_deaths, Population
from PortfolioProject..CovidDeaths
order by 1,2


--I will be looking at Total Cases vs. Total Deaths
-- Shows likelihood of death when contracting covid in US
select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
--shows what percentage of population got covid
select Location, Date, Population, total_cases, (total_cases/Population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
select Location, Population, MAX(total_cases) as HighestInfectionCount,MAX( (total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc



--Showing continents with the Highest Death Count per Population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- Using CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as Bigint)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as TotalPeopleVaccinated
--(TotalPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (TotalPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as Bigint)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as TotalPeopleVaccinated
--(TotalPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
Select *, (TotalPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated





--Creating Views to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as Bigint)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as TotalPeopleVaccinated
--(TotalPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated


Create View US_death_percentage as
select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
--order by 1,2

select * from US_death_percentage


Create View Highest_deathtoll_Countries as
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location
--order by TotalDeathCount desc

select * from Highest_deathtoll_Countries

