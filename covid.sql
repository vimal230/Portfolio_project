

-- Pulling all the data from from both the tables, i.e. CovidDeaths and CovidVaccination

select * from ..CovidDeaths
where continent is not null;


--Selecting specific data for analysis purposes

select Location,Date, Total_cases,new_cases, total_deaths, population
from ..CovidDeaths
order by 1,2;

-- Total cases vs Total deaths
-- Likelyhood of geeting covid in your country.

select location,Date, Total_cases,new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_pecentage
from ..coviddeaths
where location= 'India' order by 1,2; 

-- Looking at death percentage per population

select location,Date, Total_cases,new_cases, total_deaths, (total_deaths/population)*100 as Death_pecentage_by_population
from ..coviddeaths
where location= 'United States' order by 1,2; 

--Countries with highest infection rate

select location, MAX(Total_cases) Highest_cases, MAX((total_deaths/population))*100 as Death_pecentage
from ..coviddeaths
group by location order by 3 desc;

-- Showing countries with highest death count

select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from ..CovidDeaths
where continent is not null
group by location 
order by 2 desc;

--BASED ON CONTINENT
-- Continents with highest Death count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from ..CovidDeaths
where continent is not null
group by continent 
order by 2 desc;

--GLOBAL NUMBERS

select SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeath,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as NewDeathPercentage
from ..CovidDeaths
where continent is not null 
--group by date
order by 1,2;

--COVID VACCINAIONS
select * from ..CovidVaccinations

-- Joining both tables

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int)) over(partition by dea.location order by dea.location, dea.date) as CumelativeVaccination
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null 
--and vac.new_vaccinations is not null
order by 2,3;

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, CumelativeVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int)) over(partition by dea.location order by dea.location, dea.date) as CumelativeVaccination
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null 
--and vac.new_vaccinations is not null
--order by 2,3;
)
Select *, (CumelativeVaccination/population)*100 as Percentage_Vaccinated from popvsvac



--USING TEMP TABLE

drop table if exists #PercentagePopulationVaccianted
Create table #PercentagePopulationVaccianted
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccination numeric,
CumelativeVaccination numeric
)
insert into #PercentagePopulationVaccianted
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int)) over(partition by dea.location order by dea.location, dea.date) as CumelativeVaccination
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null 

select *, (CumelativeVaccination/population)*100 as Percentage_Vaccinated from #PercentagePopulationVaccianted;

--CREATING VIEW
create view PercentagePopulationVaccianted as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int)) over(partition by dea.location order by dea.location, dea.date) as CumelativeVaccination
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null;


select * from PercentagePopulationVaccianted






