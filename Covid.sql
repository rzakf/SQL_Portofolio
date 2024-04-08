-- Selecting location, date, total cases, total deaths, and calculating death rate as a percentage in Indonesia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Rate
FROM PortfolioProject..CovidDeath
WHERE location = 'Indonesia'
ORDER BY Date ASC

--Cases vs Population Ratio in Indonesia
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Infection_Rate
FROM PortfolioProject..CovidDeath
WHERE location = 'Indonesia'
ORDER BY Date ASC

--Country with Highest Cases
SELECT location, population, MAX(total_cases) AS total_Cases
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY location, population
ORDER BY total_cases DESC

--Country with Highest Death
SELECT location, MAX(total_deaths) AS Total_Deaths
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Deaths DESC

--Country with Highest Infection Rate
SELECT location, population, MAX(total_cases) AS total_Cases, MAX((total_cases/population)*100) AS Infection_Rate
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY location, population
ORDER BY Infection_Rate DESC

--Continent with Highest Death
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--World COVID-19 Daily Death Rate
SELECT date, SUM(total_cases) as total_cases, SUM(total_deaths) as total_deaths, (SUM(total_deaths)/SUM(total_cases))*100 AS Death_Rate
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY date
ORDER BY Date ASC

--World COVID-19 Total Cases, Deaths & Death Rate
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS Death_Rate
FROM PortfolioProject..CovidDeath
WHERE continent is not null


-- Vaccination Rate by Country
WITH PopvsVac (continent, location, date, population, people_vaccinated)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated
    FROM PortfolioProject..CovidDeath dea
    JOIN PortfolioProject..CovidVaccine vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL AND people_vaccinated is NOT NULL
)
SELECT *, (people_vaccinated / population) * 100 AS vaccination_rate
FROM PopvsVac
where continent is not null
order by location, date


-- Total Vacination Rate by Country
WITH PopvsVac (continent, location, date, population, people_vaccinated)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated
    FROM PortfolioProject..CovidDeath dea
    JOIN PortfolioProject..CovidVaccine vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL AND people_vaccinated is NOT NULL
)
SELECT location, MAX((people_vaccinated / population) * 100) AS vaccination_rate
FROM PopvsVac
GROUP BY location
Order by vaccination_rate desc



-- Temp Table

CREATE TABLE #PopulationVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    people_vaccinated NUMERIC,
    vaccination_rate FLOAT
)

INSERT INTO #PopulationVaccinated (continent, location, date, population, people_vaccinated)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccine vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.people_vaccinated IS NOT NULL

UPDATE #PopulationVaccinated
SET vaccination_rate = (people_vaccinated / population) * 100

SELECT *
FROM #PopulationVaccinated
WHERE continent IS NOT NULL
ORDER BY location, date

--DELETE TEMP TABLE
--DROP TABLE #PopulationVaccinated;