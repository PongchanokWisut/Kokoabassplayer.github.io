
-- View CovidDeaths Table
SELECT * 
FROM Covid_19..CovidDeaths
where continent is not null
Order by 3,4;

-- View CovidVaccinations Table
SELECT * 
FROM Covid_19..CovidVaccinations
Order by 3,4

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid_19..CovidDeaths
where continent is not null
order by 1,2; 

-- Look at Total Cases vs Total Deaths
-- Show what percentage of population got Covid
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM Covid_19..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2; 

--Looking at Total Cases vs Population
-- Show what percentage of population got Covid
SELECT Location, date, Population, total_cases , (total_cases/population)*100 as per_pop_inf
FROM Covid_19..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2; 

-- Looking at Contries with Highest Infection Rate compared to population
SELECT Location, Population, MAX(total_cases) as highest_infaction_count, MAX((total_cases/population))*100 as per_pop_inf
FROM Covid_19..CovidDeaths
--where location like '%states%'
group by Location,Population
order by per_pop_inf desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continent with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM Covid_19..CovidDeaths
--where location like '%states%'
Where continent is not null
group by continent
order by total_death_count desc;

-- GROBAL NUMBERS
SELECT  SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM Covid_19..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2; 

-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.Location Order by dea.location, dea.date) as rolling_people_vac	 
FROM Covid_19..CovidDeaths dea
JOIN Covid_19..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2, 3

-- Use CTE

WITH pop_vs_vac (Conitnent, Location, Date, Population, new_vaccinations, rolling_people_vac)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.Location Order by dea.location, dea.date) as rolling_people_vac	 
FROM Covid_19..CovidDeaths dea
JOIN Covid_19..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2, 3
)

SELECT * , (rolling_people_vac/Population)*100
FROM pop_vs_vac


Drop table if EXISTs #per_pop_vac;

-- Temp Table
Create table #per_pop_vac
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	new_vaccinations numeric,
	rolling_people_vac numeric
)

Insert into #per_pop_vac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.Location Order by dea.location, dea.date) 
as rolling_people_vac	 
FROM Covid_19..CovidDeaths dea
JOIN Covid_19..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
--Where dea.continent is not null;
--ORDER BY 2, 3

SELECT * , (rolling_people_vac/Population)*100
FROM #per_pop_vac


--Create view to store data for later data visualizations

CREATE VIEW per_pop_vac as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.Location Order by dea.location, dea.date) 
as rolling_people_vac	 
FROM Covid_19..CovidDeaths dea
JOIN Covid_19..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null;
--ORDER BY 2, 3

SELECT *
FROM per_pop_vac;
---------------------------------------END-------------------------------------------------------
