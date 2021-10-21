SELECT 
TOP 10
	* 
FROM
	PortfolioProject1.dbo.CovidDeaths
ORDER BY 3,4

;


--SELECT 
--	* 
--FROM
--	PortfolioProject1.dbo.CovidVaccinations
--ORDER BY 3,4 ;

--SELECT data that we're going to be using

SELECT 
	location,date,total_cases,new_cases, total_deaths,new_deaths,population
FROM
	PortfolioProject1.dbo.CovidDeaths 
ORDER By 
		1,2 ;

--Looking at Total Cases Vs Total Deaths
--Shows the likelihood of dying if you contract the covid-19 virus in the country mentioned in location.

      --Comparing figures mentioned above Belgium Vs Netherlands


SELECT 
	location,date,total_cases, total_deaths,new_deaths,(total_deaths/total_cases)*100 As DeathPercentage
FROM
	PortfolioProject1.dbo.CovidDeaths
WHERE 
	location = 'Belgium'	
ORDER BY
		1,2 ;

SELECT 
	location,date,total_cases, total_deaths,new_deaths,(total_deaths/total_cases)*100 As DeathPercentage
FROM
	PortfolioProject1.dbo.CovidDeaths
WHERE 
	location = 'Netherlands'	
ORDER BY
		1,2 ;

--Looking at Total Cases Vs Population
--Shows What percentage of population is infected with Covid-19


SELECT 
	location,date,total_cases, population,new_deaths,(total_cases/population)*100 As InfectedPopulationPercentage
FROM
	PortfolioProject1.dbo.CovidDeaths
WHERE 
	location = 'Belgium'	
ORDER BY
		1,2 ;

--Looking at countries with highest infection rate compared to population


SELECT 
	location,population,MAX(total_cases) As HighestInfectionCount ,(MAX(total_cases)/population)*100 As InfectedPopulationPercentage
FROM
	PortfolioProject1.dbo.CovidDeaths
WHERE continent is Not Null
Group BY 
	location, population	
ORDER BY
		InfectedPopulationPercentage DESC ;

--Showing the countires with highest DeathCount per Population

SELECT 
	location,MAX(Cast(total_deaths As INT)) As TotalDeathCount 
FROM
	PortfolioProject1.dbo.CovidDeaths
WHERE continent is Not Null
Group BY 
	location	
ORDER BY
		TotalDeathCount DESC;

--Breaking down by continents

--Shwoing continents with highest death counts per population

SELECT 
	continent,MAX(Cast(total_deaths As INT)) As TotalDeathCount 
FROM
	PortfolioProject1.dbo.CovidDeaths
WHERE continent is not Null
Group BY 
	continent	
ORDER BY
		TotalDeathCount DESC;

--Global Figures

SELECT 
	date,SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) As TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 As DeathPercentage
FROM
	PortfolioProject1.dbo.CovidDeaths
WHERE 
	--location = 'Belgium'	
  continent is not null
Group by
		date
ORDER BY
		1,2 ;

--Looking at Total Population Vs Vaccination
--Using CTE

With PopvsVac (date , continent, location , population ,new_vaccinations ,RollingCountPeopleVaccinated)
as
(
SELECT 
		dea.date,dea.continent, dea.location, dea.population, vac.new_vaccinations, 
   sum(Cast(vac.new_vaccinations AS int)) OVER (Partition BY dea.location ORDER BY dea.location , dea.date) As RollingCountPeopleVaccinated
FROM 
	PortfolioProject1.dbo.CovidDeaths dea
JOIN 
	PortfolioProject1.dbo.CovidVaccinations vac
ON 
	dea.location = vac.location
AND 
	dea.date = vac.date
WHERE 
		dea.continent is not null
--ORDER by 2,3
		) 

SELECT
	* , RollingCountPeopleVaccinated/population*100
FROM
	PopvsVac ;

--Using Temp Tables 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingCountPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingCountPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


	
--Creating view to store data for visualization
SELECT 
		dea.date,dea.continent, dea.location, dea.population, vac.new_vaccinations, 
   sum(Cast(vac.new_vaccinations AS int)) OVER (Partition BY dea.location ORDER BY dea.location , dea.date) As RollingCountPeopleVaccinated
FROM 
	PortfolioProject1.dbo.CovidDeaths dea
JOIN 
	PortfolioProject1.dbo.CovidVaccinations vac
ON 
	dea.location = vac.location
AND 
	dea.date = vac.date
WHERE 
		dea.continent is not null
--ORDER by 2,3









