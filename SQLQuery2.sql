Select * 
from PortfolioDatabase..CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--from PortfolioDatabase..CovidVaccinations
--order by 3,4


-- Select Data that we are using

Select location, date, total_cases as 'total cases', total_deaths as 'total deaths'
from PortfolioDatabase..CovidDeaths
Where continent is not null
order by 3,4

--Looking at total cases vs total deaths 
--Shows mortality rate of covid per country

Select location, date, total_cases as 'total cases', total_deaths as 'total deaths', (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioDatabase..CovidDeaths
Where continent is not null
order by 1,2

--Look at the total cases vs population 
--shows total infection rate per country
Select location, date, total_cases as 'total cases', population, (total_cases/population)*100 as 'Infection rate'
from PortfolioDatabase..CovidDeaths
Where continent is not null
order by 1,2

--shows total infection rate for UK
Select location, date, total_cases as 'total cases', population, (total_cases/population)*100 as 'Infection rate'
from PortfolioDatabase..CovidDeaths
where location like 'United Kingdom'
order by 1,2

--Countries with highest infection rates comparative to population
Select location, population, MAX(total_cases) as highesttotalcases, MAX((total_cases/population))*100 as Infectionrate
from PortfolioDatabase..CovidDeaths
Where continent is not null
Group by location, population
order by Infectionrate desc

-- Countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as totalDeathCount
from PortfolioDatabase..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc



-- Let's break things down by continent
-- showing continents with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as totalDeathCount
from PortfolioDatabase..CovidDeaths
where not location in ('world', 'european union') and continent is null
Group by location
order by TotalDeathCount desc

-- this gets the real numbers
-- or 

Select continent, MAX(cast(total_deaths as int)) as totalDeathCount
from PortfolioDatabase..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- global death percentage by day

Select date, SUM(new_cases) as 'total cases', SUM(cast(new_deaths as int)) as 'total deaths', (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioDatabase..CovidDeaths
Where continent is not null
group by date
order by DeathPercentage desc

-- total global death percentage

Select SUM(new_cases) as 'total cases', SUM(cast(new_deaths as int)) as 'total deaths', (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioDatabase..CovidDeaths
Where continent is not null
order by DeathPercentage desc


-- looking at total population vs vaccinations 
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioDatabase..CovidDeaths dea
join PortfolioDatabase..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/population)*100 as RollingPercentageVaccinated
from PopVsVac

--temp table method
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vacccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioDatabase..CovidDeaths dea
join PortfolioDatabase..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as RollingPercentageVaccinated
from #PercentPopulationVaccinated
order by 1,2


--Creating view to store visualisations 
Drop view if exists PercentPopulationVaccinated
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioDatabase..CovidDeaths dea
join PortfolioDatabase..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null