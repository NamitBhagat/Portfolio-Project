--select*
--from PortfolioProject..['covid vaccinations']
--order by 3,4

select*
from PortfolioProject..['covid-deaths']
where continent is not null
order by 3,4

----select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['covid-deaths'] 
order by 1,2

--Comparision between Total cases v/s Total Deaths
-- You can check your survival percentange based on your location if you get infected

select location, date, population, total_cases, total_deaths,(100-(total_deaths/total_cases)*100) as SurvivalPercentage
from PortfolioProject..['covid-deaths']
--you can type in whichever county you want
where location like 'france'
order by 1,2

--Total cases v/s Population 
--this will show what percentage of population gets affected per day
select location, date, total_cases, population ,(total_cases/population)*100 as InfectedPopulationPercentage
from PortfolioProject..['covid-deaths']
--you can type in whichever county you want
where location like 'australia'
order by 1,2

--Countries with highest rate of infection per population
select location, MAX(total_cases) as max_infection_count, population ,MAX((total_cases/population))*100 as InfectedPopulationPercentage
from PortfolioProject..['covid-deaths']
group by Location,Population
order by InfectedPopulationPercentage desc


--Countries with highest death count per population
select location,  max(cast(total_deaths as int)) as Max_death_count
from PortfolioProject..['covid-deaths']
where continent is not null
group by location
order by Max_death_count desc




--Countries with highest death count percentage per population
select location,population,max(cast(total_deaths as int)) as Max_death_count, max((total_deaths/population))*100 as Death_count_percentage
from PortfolioProject..['covid-deaths']
where continent is not null
group by location,population
order by Death_count_percentage desc

-- Continents with highest death count 
select continent, max(cast(total_deaths as int)) as Max_death_count 
from PortfolioProject..['covid-deaths']
where continent is not null
group by continent
order by Max_death_count  desc


--Global Numbers
-- Death percentage by date worldwide
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PortfolioProject..['covid-deaths']
where continent is not null
group by date
order by Death_percentage


--Total population v/s vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..['covid-deaths'] dea
join PortfolioProject..['covid vaccinations'] vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--total population vs vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..['covid-deaths'] dea
join PortfolioProject..['covid vaccinations'] vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




--total population vs Rolling vaccination count
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as  bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_vaccination_count
from PortfolioProject..['covid-deaths'] dea
join PortfolioProject..['covid vaccinations'] vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
-- Percentage of rolling people vaccinated per population

with PopsvsVac ( continent,location , date, population, new_vaccinations,Rolling_vaccination_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as  bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_vaccination_count
from PortfolioProject..['covid-deaths'] dea
join PortfolioProject..['covid vaccinations'] vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,(Rolling_vaccination_count/population)*100 as Percent_rolling_people_vaccinated
from PopsvsVac



--Temp Table

drop table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_vaccination_count numeric
)
Insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as  bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_vaccination_count
from PortfolioProject..['covid-deaths'] dea
join PortfolioProject..['covid vaccinations'] vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*,(Rolling_vaccination_count/population)*100 as Percent_rolling_people_vaccinated
from #PercentPeopleVaccinated 


--Creating view to store data later for visualization

Create view PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as  bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_vaccination_count
from PortfolioProject..['covid-deaths'] dea
join PortfolioProject..['covid vaccinations'] vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPeopleVaccinated





