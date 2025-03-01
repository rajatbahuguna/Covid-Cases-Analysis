

select * 
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from [Portfolio Project]..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

select location, date , total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as [DeathPercentage]
from CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

select location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as [DeathPercentage]
from CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2


-- Looking at the Total Cases Vs Population
-- Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as [Percentage Population Infected]
from CovidDeaths
--where location like '%states%'
order by 1,2


--Looking at Countries with highest Infection Rate compared to Population

select location, population, Max(total_cases) as [Highest Infection Count], Max((total_cases/population))*100 
as [Percentage Population Infected]
from CovidDeaths
--where location like '%states%'
group by Location, population
order by [Percentage Population Infected] desc


-- Showing Countries with Highest Death Count Per Population

select location, max(cast(total_deaths as int)) as [Total Death Count]
from CovidDeaths
--where location like '%states%'
where continent is not null
group by Location
order by [Total Death Count] desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population

select continent, max(CAST(total_deaths as int)) as [Total Death Count]
from CovidDeaths
where continent is not null
group by continent
order by [Total Death Count] desc



-- Global Numbers

select sum(new_cases) as [Total Cases], sum(cast (new_deaths as int)) as [Total Deaths],
sum(cast (new_deaths as int))/sum(new_cases) * 100 as [Death Percentage]
from CovidDeaths
--where location like '%states%'
Where continent is not null
--group by date
order by 1,2


-- Looking a Total Population vs Vaccination

-- USE CTE 

With PopvsVac (Continent, Location, Date , Population, new_vaccinations, [Rolling People Vaccinated]) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
  as [Rolling People Vaccinated]
--, ([Rolling People Vaccinated] / population)
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, ([Rolling People Vaccinated] / population) *100
from PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
[Rolling People Vaccinated] numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
  as [Rolling People Vaccinated]
--, ([Rolling People Vaccinated] / population)
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, ([Rolling People Vaccinated] / population) *100
from #PercentPopulationVaccinated




-- Creating View to store the data to later visualization

create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
  as [Rolling People Vaccinated]
--, ([Rolling People Vaccinated] / population)
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated