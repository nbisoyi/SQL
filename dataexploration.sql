/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [portfolio].[dbo].[CovidDeaths]
  order by 3,4 

---SELECT *
---  FROM [portfolio].[dbo].[CovidVaccinations]
--- order by 3,4 
 
----Select Data that we are going to be using

 SELECT location,date,total_cases,new_cases,total_deaths,population
  FROM [portfolio].[dbo].[CovidDeaths]
  order by 1,2


  ----Looking at Total cases Vs Total Deaths
  -----Shows likelihood of dying if you contract covid in your country
  SELECT location,date,total_cases,total_deaths,population, (total_deaths/total_cases)*100 as DeathPercentage
  FROM [portfolio].[dbo].[CovidDeaths]
  where location like '%nada%'
  order by 1,2


  -----Looking at Total cases vs Population
 SELECT location,date,total_cases,population, (total_cases/population)*100 as PercentagePopulation
  FROM [portfolio].[dbo].[CovidDeaths]
  ---where location like '%nada%'
  order by 1,2

  --Looking at Countries where Highest Infection Rate compared to Population

   SELECT location,population,MAX(total_cases) As HighestInfectionCount, MAX((total_cases/population))*100 as 
   PercentPopulationInfected
  FROM [portfolio].[dbo].[CovidDeaths]
  ---where location like '%nada%'
  group by location,population
  order by   PercentPopulationInfected desc

  ---Showing Countries with Highest Death count per Population

    SELECT location,MAX(Cast(total_deaths as int))As TotalDeathCount 
    FROM [portfolio].[dbo].[CovidDeaths]
  ---where location like '%nada%'
    group by location
    order by   TotalDeathCount desc

/*Continent is null in some places */

SELECT *
  FROM [portfolio].[dbo].[CovidDeaths]
  Where continent is not null
  order by 3,4 

  
    SELECT location,MAX(Cast(total_deaths as int))As TotalDeathCount 
    FROM [portfolio].[dbo].[CovidDeaths]
  ---where location like '%nada%'
  WHERE continent is not NULL
    group by location
    order by   TotalDeathCount desc


	--------------------------------------------------------------------------------
	------Lets organize by Continent

	----Showing Continents with the highest death count per population

	SELECT continent,MAX(Cast(total_deaths as int))As TotalDeathCount 
    FROM [portfolio].[dbo].[CovidDeaths]
  ---where location like '%nada%'
  WHERE continent is not NULL
    group by continent
    order by   TotalDeathCount desc


	-----Global Numbers

	SELECT SUM(total_cases) AS Total_cases,SUM(cast(new_deaths As int)) AS Total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) *100 As DeathPercentage
  FROM [portfolio].[dbo].[CovidDeaths]
  where continent is not NULL
  --Group by date
  order by 1,2

  ----Joining Covid deaths and Covid vaccinations
  -----Looking at Total Population vs Total Vaccinations

  Select Dea.continent,Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
  ,SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.location,Dea.date) AS RollingPeopleVaccainated
  From [portfolio].[dbo].[CovidDeaths] As Dea
  Join [portfolio].[dbo].[CovidVaccinations] as Vac
  On Dea.location = Vac.location
  and Dea.date = Vac.date
  Where Dea.continent is NOT NULL
  order by  2,3

  -----USE CTE

  With PopvsVac (continent, location, date, popuation ,New_Vaccinations, RollingPeopleVaccinated)
  as 
  (
   Select Dea.continent,Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
  ,SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.location,Dea.date) AS RollingPeopleVaccainated
  From [portfolio].[dbo].[CovidDeaths] As Dea
  Join [portfolio].[dbo].[CovidVaccinations] as Vac
  On Dea.location = Vac.location
  and Dea.date = Vac.date
  Where Dea.continent is NOT NULL
  --order by  2,3
  )
  Select * , (RollingPeopleVaccinated/popuation)*100
  From PopvsVac




  -------TEMPORARY TABLE #PercentPopulationVaccinated

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
  Select Dea.continent,Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
  ,SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.location,Dea.date) AS RollingPeopleVaccainated
  From [portfolio].[dbo].[CovidDeaths] As Dea
  Join [portfolio].[dbo].[CovidVaccinations] as Vac
  On Dea.location = Vac.location
  and Dea.date = Vac.date
  Where Dea.continent is NOT NULL
  --order by  2,3
  

  Select * , (RollingPeopleVaccinated/Population)*100
  From #PercentPopulationVaccinated


  ----Creating View to store data for Visualizations

  Create View PercentPeopleVaccinated as
   Select Dea.continent,Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
  ,SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by Dea.location,Dea.date) AS RollingPeopleVaccainated
  From [portfolio].[dbo].[CovidDeaths] As Dea
  Join [portfolio].[dbo].[CovidVaccinations] as Vac
  On Dea.location = Vac.location
  and Dea.date = Vac.date
  Where Dea.continent is NOT NULL
  --order by  2,3

  Select * 
  From PercentPeopleVaccinated