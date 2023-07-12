Select *
From ProjectPortfolio1..CovidDeaths
Where continent is NOT Null
Order By 3,4


Select *
From ProjectPortfolio1..CovidVaccinations
Where continent is NOT Null
Order By 3,4

--Select Data that we are going to using

Select location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio1..CovidDeath
Where continent is NOT Null
order by 1,2


--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 As DeathPercentage
From ProjectPortfolio1..CovidDeaths
Where location = 'indonesia'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population get percentage

Select location, date, total_cases, population, (total_cases/population)* 100 As PercentPopulatinInfected
From ProjectPortfolio1..CovidDeaths
Where location = 'indonesia'
order by 1,2


--Looking at Countries with highest Infection Rate Compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 As PercentPopulatinInfected
From ProjectPortfolio1..CovidDeaths
Where continent is NOT Null
Group By location,Population
Order By HighestInfectionCount DESC

--Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) As TotalDeathCount
From ProjectPortfolio1..CovidDeaths
Where continent is NOT Null
Group By location
Order By TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) As TotalDeathCount
From ProjectPortfolio1..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount DESC

--Showing the continent with the highest deat per population

Select continent, MAX(cast(total_deaths as int)) As TotalDeathCount
From ProjectPortfolio1..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount DESC

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
From ProjectPortfolio1..CovidDeaths
Where continent is not null
--group by date
order by 1,2


--LOOking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectPortfolio1..CovidDeaths dea
Join ProjectPortfolio1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopVsVac (Continent,Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectPortfolio1..CovidDeaths dea
Join ProjectPortfolio1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopVsVac


--TEMP TABLE


DROP table if exists #PercentPopulationVaccinated
CReate table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectPortfolio1..CovidDeaths dea
Join ProjectPortfolio1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--CREATING view to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectPortfolio1..CovidDeaths dea
Join ProjectPortfolio1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated