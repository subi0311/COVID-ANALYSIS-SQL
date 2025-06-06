-- COVID-19 DATA EXPLORATION AND ANALYSIS USING SQL

-- 1. View all COVID-19 deaths data (excluding null continents)
SELECT * 
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- 2. View all COVID-19 vaccination data (excluding null continents)
SELECT * 
FROM PortfolioProject..covid_vaccination$
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- 3. Basic data overview
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- 4. Death percentage in Pakistan
SELECT location, date, total_cases, total_deaths,
       (CAST(total_deaths AS DECIMAL) / CAST(total_cases AS DECIMAL)) * 100 AS DeathPercentage
FROM PortfolioProject..covid_deaths$
WHERE location LIKE '%kistan%' AND continent IS NOT NULL
ORDER BY 1, 2;

-- 5. Total cases vs population in Pakistan
SELECT location, date, population, total_cases,
       (CAST(total_cases AS DECIMAL) / CAST(population AS DECIMAL)) * 100 AS PopulationInfected
FROM PortfolioProject..covid_deaths$
WHERE location LIKE '%kistan%' AND continent IS NOT NULL
ORDER BY 1, 2;

-- 6. Countries with highest infection rate
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
       MAX((CAST(total_cases AS DECIMAL) / CAST(population AS DECIMAL)) * 100) AS PopulationInfected
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PopulationInfected DESC;

-- 7. Total death count by country
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- 8. Total death count by continent
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- 9. Death percentage by country
SELECT location,
       SUM(CAST(new_cases AS INT)) AS total_cases,
       SUM(CAST(total_deaths AS INT)) AS total_deaths,
       SUM(CAST(total_deaths AS INT)) * 100.0 / SUM(CAST(new_cases AS INT)) AS death_percentage
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
  AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY 1, 2;

-- 10. Vaccination trend: Total vaccinations vs rolling count
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (
            PARTITION BY dea.location ORDER BY dea.location, dea.date
       ) AS rollingvaccinated
FROM PortfolioProject..covid_deaths$ dea
JOIN PortfolioProject..covid_vaccination$ vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- 11. Vaccination ratio using CTE
WITH popvsvacc (continent, location, date, population, new_vaccinations, rollingvaccinated) AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(INT, vac.new_vaccinations)) OVER (
               PARTITION BY dea.location ORDER BY dea.location, dea.date
           ) AS rollingvaccinated
    FROM PortfolioProject..covid_deaths$ dea
    JOIN PortfolioProject..covid_vaccination$ vac
      ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (rollingvaccinated / population) * 100 AS vaccinationRatio
FROM popvsvacc;

-- 12. Creating a view for people vaccinated
CREATE VIEW PeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (
           PARTITION BY dea.location ORDER BY dea.location, dea.date
       ) AS rollingvaccinated
FROM PortfolioProject..covid_deaths$ dea
JOIN PortfolioProject..covid_vaccination$ vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- (Optional) View data from the PeopleVaccinated view
-- SELECT * FROM PeopleVaccinated;
