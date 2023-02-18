/*
Covid19 Data Exploration

Skills used : Joins, CTE's, Temp Table, Windows Funtions, Aggreagate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--Select Data that we are going to be starting with

Select location, date, total_cases,new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at the Total Cases vs Total Deaths
--Shows liklihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%States%'
and continent is not null
order by 1,2


--Total Cases Vs Population
--Shows what percentage of the Population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulation_Infected
From PortfolioProject..CovidDeaths
Where location like '%States%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Group By location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%States%'
Where continent is not null
Group By location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT

--Showing continent with Highest Death Count per population


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%States%'
Where continent is  not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases)as total_cases, SUM(cast(total_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE location like '%States%'
Where continent is not null
Group By date
order by 1,2



--Total Population Vs Vaccinations
--Shows Percentage of population that has received atleast one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths  dea
JOIN PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null 
 ORDER BY 2,3

 
 --Using CTE to perform Calculation on Partition By in previous query
 
 With PopVsVac (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated) 
 as 
 (
   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null 
 --Order By 2,3
 )
 Select *, (RollingPeopleVaccinated/Population)*100
 From PopVsVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
 (
  Continent nvarchar(255),
  Location nvarchar(255) ,
  Date datetime,
  Population numeric,
  New_vaccination numeric,
  RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
 and dea.date = vac.date
 --WHERE dea.continent is not null 
 --ORDER BY 2,3
 
 Select *, (RollingPeopleVaccinated/population)*100
 From #PercentPopulationVaccinated




---Creating View to store data later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null 
 
 
