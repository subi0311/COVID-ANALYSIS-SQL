select * from PortfolioProject..covid_deaths$
where continent is not null
order by 3,4

select * from PortfolioProject..covid_vaccination$
where continent is not null
order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..covid_deaths$
where continent is not null
order by 1,2


--Deathpercentage in Pakistan 
select Location,date,total_cases,total_deaths,
(cast(total_deaths as decimal)/cast(total_cases as decimal))*100 as Deathpercentage
from PortfolioProject..covid_deaths$
where location like '%kistan%'
and 
where continent is not null
order by 1,2


--Total cases vs Popultion
select Location,date,population,total_cases,
(cast(total_cases as decimal)/cast(population as decimal))*100 as PopulationInfected
from PortfolioProject..covid_deaths$
where location like '%kistan%'and
where continent is not null
order by 1,2

--Highest InfectionRate Countries
select Location,population,max(total_cases) as HighestInfectionCount,
max((cast(total_cases as decimal)/cast(population as decimal))*100) as PopulationInfected
from PortfolioProject..covid_deaths$
--where location like '%kistan%'
where continent is not null
group by location , population
order by PopulationInfected desc



--total death counts of countries
select location, max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..covid_deaths$
where continent is not null
group by location
order by Totaldeathcount desc

--total death counts per continents
select continent, max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..covid_deaths$
where continent is not null
group by continent
order by Totaldeathcount desc

-- DeathPercentage for each countries
select location,sum(cast(new_cases as int)) as total_cases,sum(cast(total_deaths as int ))
as total_deaths, sum(cast(total_deaths as int ))/sum(cast(new_cases as int))*100 as death_percentage
from PortfolioProject..covid_deaths$
where continent is not null
and location not in ('world','European Union','International')
Group by location
order by 1,2


--looking total vaccination vs rolling
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,
dea.date) as rollingvaccinated
from PortfolioProject..covid_deaths$ dea
join PortfolioProject..covid_vaccination$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE 
with popvsvacc (continent,location,date,population,new_vaccinations,rollingvaccinated)
as
(
--looking total vaccination vs rolling
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,
dea.date) as rollingvaccinated
from PortfolioProject..covid_deaths$ dea
join PortfolioProject..covid_vaccination$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,rollingvaccinated/population*100 as vaccinationRatio
from popvsvacc


-- BY using temp table
--drop table if exists #Peoplevaccinated
--create Table #Peoplevaccinated
--(
--continent varchar(255),
--location varchar(255),
--date datetime,
--population numeric,
--new_vaccination numeric,
--rollingvaccinated numeric
--)
--INSERT INTO #Peoplevaccinated
--select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
--sum(cast(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,
--dea.date) as rollingvaccinated
--from PortfolioProject..covid_deaths$ dea
--join PortfolioProject..covid_vaccination$ vac
--on dea.location=vac.location
--and dea.date=vac.date
--where dea.continent is not null

--select *,rollingvaccinated/population*100 
--from #Peoplevaccinated




create view PeopleVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,
dea.date) as rollingvaccinated
from PortfolioProject..covid_deaths$ dea
join PortfolioProject..covid_vaccination$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3