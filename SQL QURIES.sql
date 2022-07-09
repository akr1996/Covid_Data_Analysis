/*
covid 19 data exploraton 
skills used : Joins,CTEs , Temp Tables,windows functions,Aggreagae functions.creating view,Converting data types */
select *
from ['owid-covid-data$']
where continent is not null
order by 3,4

--Select data that we are going to  be starting with 
select Location,date,total_cases,new_cases,total_deaths,population
from ['owid-covid-data$']
where continent is not null
order by 1,2

--Total cases VS total Death
--Shows liklehood of dying if you contract covid in your country

select Location,date,Total_cases,Total_deaths,(total_deaths/total_cases)*100 as [death percentage]
from ['owid-covid-data$']
where continent is not null and Location  like 'India'
order by location,date desc


--SHOWS TOTAL CASE VS POPULATION 
--SHOWS WHAT PERCENTAGE OF POPULATION INFECT WITH COVID

SELECT date,Location,population,total_cases,(total_cases/population)*100 AS Percentageofpopulationinfected
from ['owid-covid-data$']
where continent IS NOT NULL AND location LIKE 'INDIA'


--Countries with higest infection rate as compare to populaton 
Select trim(Location), max(Population), MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ['owid-covid-data$']
--Where location like '%states%'
where continent is not null
Group by Location, Population
order by Population desc, PercentPopulationInfected desc

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION 
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ['owid-covid-data$']
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ['owid-covid-data$']
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ['owid-covid-data$']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--total population vs vaccination
--shows percentage of population thta has recived at least one covid vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['owid-covid-data$'] dea
Join Covid_vaccination$ as  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--using CTE to perferom calculation on partion by in previous query
WIth Popvsvac (Continent,Location,date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['owid-covid-data$'] dea
Join Covid_vaccination$ as  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population) *100
from Popvsvac

--using temptable to perfrom calculation on poration by in previus query
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['owid-covid-data$'] dea
Join Covid_vaccination$ as  vac
	On dea.location = vac.location
	and dea.date = vac.date,
--where dea.continent is not null 
--order by 2,3

--create view to store the date for later visulaization 
Create view Percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations))over (partition by dea.location order by dea.location,dea.date) as RollingVaccinated
from ['owid-covid-data$'] as dea
join Covid_vaccination$ as vac
 on dea.location=vac.location
 and dea.date = vac.date
where dea.continent is not null

select * from Percentpopulationvaccinated

-- FOR TABLUE VISULAIZATION
--1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--2

Select location, SUM(cast(new_deaths as float)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International','High income','Low income','Lower middle income','Upper middle income')
Group by location
order by TotalDeathCount desc


--3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--4

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc