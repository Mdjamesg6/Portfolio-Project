Select *
From PortifolioProject..CovidDeaths$
order by 3,4

--Select *
--From PortifolioProject..CovidVaccinations$
--order by 3,4

--Select Data That we are going to be using 

Select location, date, total_cases, new_cases,total_deaths,population
From PortifolioProject..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths 
--Shows the likeihood of dying if you contract covid in your counrtry 

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortifolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at the Total cases vs Population 


--What percentage of population got Covid in United States 


Select location, date,population, total_cases,(total_cases/population)*100 as PercentofPopulationInfected 
From PortifolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at Countries with the Highest Infection Rate complared to population

Select location,population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentofPopulationInfected
From PortifolioProject..CovidDeaths$
--where location like '%states%'
group by location, population
order by PercentofPopulationInfected desc

--Showing Countries the Highest Death Count per Population 

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortifolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null	
group by location
order by TotalDeathCount desc


--LETS BREAK DOWN BY CONTINTENT

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortifolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null	
group by continent
order by TotalDeathCount desc

--Change to location to see the world count 

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortifolioProject..CovidDeaths$
--where location like '%states%'
where continent is null	
group by location
order by TotalDeathCount desc

--showing the Continent by death rate 

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortifolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null	
group by continent
order by TotalDeathCount desc


-- Global numbers 

Select Sum(new_cases) as TOTAL_CASES, SUM(cast(new_deaths as int)) as TOTAL_DEATHS,SUM(cast(new_deaths as int))/SUM(NEW_CASES)*100 as Deathpercentage
From PortifolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vacinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
from PortifolioProject..CovidDeaths$ dea
join PortifolioProject..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null	
order by 2,3

--Use CTE

with PopvsVac (Continent, location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
from PortifolioProject..CovidDeaths$ dea
join PortifolioProject..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null	
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac



---Temp Table
Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
from PortifolioProject..CovidDeaths$ dea
join PortifolioProject..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null	
--order by 2,3

select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later Visualizations 

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
from PortifolioProject..CovidDeaths$ dea
join PortifolioProject..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null	