Select*
From PortfolioProject..Covid_Deaths
Where continent is not null
Order by 3,4

--Select*
--From PortfolioProject..Covid_Vaccinations
--order by 3,4

Select location,date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid_Deaths
Order by 1,2

--Total cases vs Total deaths
Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..Covid_Deaths
Where location like '%viet%'
and total_cases is not null
Order by 1,2

--Total cases vs Population
Select location,date, total_cases, new_cases, population, (total_cases/population)*100 as infected_percentage
From PortfolioProject..Covid_Deaths
where location like '%viet%'
and total_cases is not null
Order by 1,2

--Countries with the highest infection rate compare to population
Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as Infected_Percentage
From PortfolioProject..Covid_Deaths
Group by location, population
Order by Infected_Percentage desc

Select location, population, date, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as Infected_Percentage
From PortfolioProject..Covid_Deaths
Group by location, population, date
Order by Infected_Percentage desc

--Countries with the highest deaths count per population
Select location, population, MAX(total_deaths) as total_deaths_count
From PortfolioProject..Covid_Deaths
Where continent is not null
Group by location, population
Order by total_deaths_count desc

-- Conut by continent

-- Continent with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as total_deaths_count
From PortfolioProject..Covid_Deaths
Where continent is not null
Group by continent
Order by total_deaths_count desc

-- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From PortfolioProject..Covid_Deaths
Where continent is not null
--Group by continent
Order by 1,2 


--Total population and vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac
On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--and dea.location like '%viet%'
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #percent_population_vaccinated


-- Creating View to store data for later visualizations

Create View percent_population_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths dea
join PortfolioProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 