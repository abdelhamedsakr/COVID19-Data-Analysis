select *
from[dbo].[covidDeaths]
where continent is not null
order by 3,4




--Select Data That we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from [dbo].[covidDeaths]
where continent is not null
order by 1,2


 

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying  if you contract covid in your country
SELECT location,
       date,
       total_cases,
       total_deaths,
       (total_deaths / NULLIF(total_cases, 0)) * 100 AS DeapthPrecentage
FROM [dbo].[covidDeaths]
where location like 'Africa'
and  continent is not null
ORDER BY  location,date; 

--Looking at Total Cases vs Population 
-- Show what precentage of population got covid

SELECT location,
       date,
       population,
       total_cases,
       (total_cases / population) * 100 AS precentPopulationInfected
FROM [dbo].[covidDeaths]
--where location like 'Africa'
ORDER BY  1,2;



-- Looking at Countries with Highest infection Rate compared to population 

SELECT location,
       population,
       max(total_cases) as HightesrtInfectionCount ,
       max((total_cases / population)) * 100 AS precentPopulationInfected
FROM [dbo].[covidDeaths]
--where location like 'Africa'
group by location, population
ORDER BY  precentPopulationInfected desc



--Showing Countries with Highest Death Count per Population

SELECT location,
       max(cast(total_deaths as int)) as TotalDeathCount
FROM [dbo].[covidDeaths]
--where location like 'Africa'
where continent is not null
group by location
ORDER BY  TotalDeathCount desc


--Break Things down by Continent

-- Showing contintents with the highest death count per population

SELECT continent,
       max(cast(total_deaths as int)) as TotalDeathCount
FROM [dbo].[covidDeaths]
--where location like 'Africa'
where continent is not null
group by continent
ORDER BY  TotalDeathCount desc


-- Global Numbers
SELECT
       SUM(new_cases) AS Total_Cases,
       SUM(new_deaths) AS Total_Deaths,
       (SUM(new_deaths) / NULLIF(SUM(CAST(new_cases AS INT)), 0)) * 100 AS DeathPrecentage
FROM [dbo].[covidDeaths]
WHERE continent IS NOT NULL
ORDER BY 1, 2;  



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From [dbo].[covidDeaths] dea
Join [dbo].[covidVAccinatio] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From [dbo].[covidDeaths] dea
Join [dbo].[covidVAccinatio] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].[covidDeaths] dea
Join [dbo].[covidVAccinatio] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].[covidDeaths] dea
Join [dbo].[covidVAccinatio] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 