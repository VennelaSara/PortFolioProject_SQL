--SELECT * FROM PortfolioProject..CovidDeaths$ order by 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations$ 

SELECT Location,date,total_cases,new_cases,total_deaths,population FROM PortfolioProject..CovidDeaths$ order by 1,2

--Looking at Total Cases VS Total Deaths
--Shows the Likelihood of dying if you tracked in your Country.
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage FROM PortfolioProject..CovidDeaths$
 where continent is not null and Location like '%states%' 
 order by 1,2

--Looking at Total_Cases VS Population
--Shows what percentage of population got Covid
SELECT Location,date,total_cases,population,(total_cases/population)*100 as covid_percentage FROM PortfolioProject..CovidDeaths$
 where Location like '%states%' 
 order by 1,2


 --Country's with highest infection rate compared to population

 SELECT Location,population,max(total_cases) as Highest_infection_count,max(total_cases/population)*100 as Percentage_of_infection_count from PortfolioProject..CovidDeaths$
 group by population,Location 
 order by Percentage_of_infection_count desc

 --Showing Countries with Highest Death count per Population

 
 SELECT Location,population,max(cast(total_deaths as int)) as Highest_death_count from PortfolioProject..CovidDeaths$
 group by population,Location 
 order by Highest_death_count desc

 --LET'S BREAK THINGS DOWN BY CONTINENT

 --Showing Continents with the highest death Counts

SELECT Location,max(cast(total_deaths as int)) as Total_death_count from PortfolioProject..CovidDeaths$
where continent is null
group by Location
order by Total_death_count desc

--Global Numbers
SELECT date,sum(new_cases) as new_cases_count,sum(cast(new_deaths as int)) as new_deaths_count,sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 as new_death_percentage--,(total_cases/population)*100 as covid_percentage 
FROM PortfolioProject..CovidDeaths$
 where continent is not null
 group by date
 order by 1,2

 --Looking at Total Population vs Vaccinations

 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as total_new_vaccinations_per_location_of_Country from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location and
 dea.date = vac.date
 where dea.continent is not null and vac.new_vaccinations is not null
 order by 2,3;

 --USE CTE

 With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) 
 as 
 (
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location and
 dea.date = vac.date
 where dea.continent is not null and vac.new_vaccinations is not null
 )
 select *,(RollingPeopleVaccinated/population)*100 from PopvsVac;

 --TEMP_TABLE
 Drop table if exists #percentPopulationVaccinated
 create table #percentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #percentPopulationVaccinated
  SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location and
 dea.date = vac.date
 where dea.continent is not null and vac.new_vaccinations is not null

 select * from #percentPopulationVaccinated;

 --Creating View to Store data for later Visualizations
 GO

 create view percentagePopulationVaccinated as
  SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location and
 dea.date = vac.date
 where dea.continent is not null and vac.new_vaccinations is not null
-- order by 2,3




















