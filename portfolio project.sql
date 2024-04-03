
SELECT *
FROM [portfolio project]..[covid deathscsv]
WHERE continent is not null
order by 3,4


SELECT *
FROM [portfolio project]..[covid vaccinationscsv]
order by 3,4

-- Shows data i will be working with
SELECT location, date, population, total_cases, total_deaths
FROM [portfolio project]..[covid deathscsv]
ORDER BY 1,2

-- CHANGING Data types for total cases & total deaths
-- showing percentage of deaths in AFRICA 
SELECT location, date, total_cases,total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100  as deathpercentage
FROM [portfolio project]..[covid deathscsv]
WHERE location Like '%Africa%'
ORDER BY 1,2
--Showing the percentage of population with covid
SELECT location, date, total_cases, population, (CONVERT(float,total_cases)/population)*100 as populationpercentageinfected
FROM [portfolio project]..[covid deathscsv]
WHERE location Like '%Africa%'
-- max cases
SELECT location, population, MAX(CONVERT(float,total_cases)) as Highestinfectedcases, MAX((CONVERT(float,total_cases)/population))*100 as populationpercentageinfected
FROM [portfolio project]..[covid deathscsv]
--WHERE location Like '%Africa%'
GROUP BY population,location
ORDER BY populationpercentageinfected desc

-- SHOWING continent with highest deaths
SELECT continent,  MAX(CONVERT(float,total_deaths)) as Highestdeathcases
FROM [portfolio project]..[covid deathscsv]
--WHERE location Like '%Africa%'
where continent is not null
GROUP BY continent
ORDER BY Highestdeathcases desc

--GLOBAL NUMBERS
SELECT  SUM(CONVERT(float,new_cases))as total_cases, SUM(CONVERT(float,new_deaths)) as total_deaths, SUM(CONVERT(float,new_deaths))/SUM(NULLIF(CONVERT(float,new_cases),0))*100  AS deathpercentage
FROM [portfolio project]..[covid deathscsv]
--WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.location)
FROM [portfolio project]..[covid deathscsv] as dea
join [portfolio project]..[covid vaccinationscsv] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as 
rollingpeoplevaccinated
FROM [portfolio project]..[covid deathscsv] as dea
join [portfolio project]..[covid vaccinationscsv] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--usig CTE

With PopvsVac  (continent, location, date, population, New_vaccinations, rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as 
rollingpeoplevaccinated
FROM [portfolio project]..[covid deathscsv] as dea
join [portfolio project]..[covid vaccinationscsv] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from PopvsVac

-- Creating views to store data for later
Create view percentpopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as
rollingpeoplevaccinated
FROM [portfolio project]..[covid deathscsv] as dea
join [portfolio project]..[covid vaccinationscsv] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select*
from percentpopulationvaccinated








