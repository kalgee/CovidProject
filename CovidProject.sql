use covidproject

select * from covid_deaths cd 

select * from covid_vaccinations cv

/*PERCENTAGE of PEOPLE INFECTED PER POPULATION*/

select continent,location,date,population,total_cases,(total_cases/population)*100 as InfectedPopulation
from covid_deaths cd 
where continent!=''
order by 2,3

/*HIGHEST INFECTION RATE IN COUNTRIES*/

select location,population,max(total_cases),max((total_cases/population))*100 as maxinfrate
from covid_deaths
group by location,population
order by maxinfrate desc

/*HIGHEST INFECTION RATE IN INDIA*/

select location,max(population),max(total_cases),max((total_cases/population))*100 as maxinfrate
from covid_deaths cd where location='India'

/*PERCENTAGE of DEATH PER POPULATION*/

select continent,location,date,population,total_deaths,(total_deaths/population)*100 as PerDeathsPerPop
from covid_deaths cd 
where continent!=''
order by 2,3

/*DEATH PERCENTAGE IN DIFFERENT COUNTRIES*/

select location, population, sum(new_deaths) as total_deaths, sum(new_deaths)/population*100 as DeathPercentage
From covid_deaths 
group by location,population
order by DeathPercentage desc

/*DEATH COUNT IN DIFFERENT COUNTRIES*/

select location, max(total_deaths) as maxdeathcount 
from covid_deaths
where continent!=''
group by location
order by maxdeathcount desc

/*DEATH COUNT IN INDIA*/

select location,max(total_deaths) as maxdeathcount
from covid_deaths cd 
where location='India'
group by location

/*DEATH COUNT IN CONTINENTS*/

select location, sum(new_deaths) as totaldeathcount 
from covid_deaths
where continent='' 
and location not in ('World','High income','Upper middle income','Lower middle income','European Union','Low income')
group by location
order by totaldeathcount desc

/*GLOBAL TOTAL CASES AND TOTAL DEATHS AND DEATH BY CASES PERCENTAGE*/

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(New_Cases)*100 as DeathPercentage
From covid_deaths 
where continent!='' 

/*WORLDWIDE COVID CASES PEAK*/

select location, date, new_cases
from covid_deaths  
where new_cases=(select max(new_cases) from covid_deaths) 
and location='World'

/*WORLDWIDE COVID DEATHS PEAK*/

select location, date, new_deaths 
from covid_deaths  
where new_deaths=(select max(new_deaths) from covid_deaths)
and location='World'

/*MAXIMAL NUMBER OF ICU PATIENTS AND WEEKLY ICU ADMISSIONS*/

select continent,location,date, icu_patients 
from covid_deaths  
where icu_patients=(select max(icu_patients) from covid_deaths) 

select continent, location,date, weekly_icu_admissions 
from covid_deaths  
where weekly_icu_admissions=(select max(weekly_icu_admissions) from covid_deaths) 

/*MAXIMAL NUMBER OF HOSPITAL PATIENTS AND WEEKLY HOSPITAL ADMISSIONS*/

select continent, location,date, hosp_patients 
from covid_deaths  
where hosp_patients=(select max(hosp_patients) from covid_deaths)

select continent, location,date, weekly_hosp_admissions 
from covid_deaths  
where weekly_hosp_admissions=(select max(weekly_hosp_admissions) from covid_deaths)

/*TOTAL POPULATION VS VACCINATION*/

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.Location order by dea.location, dea.date) as PeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent!='' 
order by 2,3

/*NUMBER OF PEOPLE VACCINATED PER LOCATION*/

select location, sum(new_vaccinations) as pplvaccinated
from covid_vaccinations
where continent!=''
group by location
order by pplvaccinated desc


/*CALCULATING PERCENTAGE OF PEOPLE VACCINATED PER POPULATION USING CTE*/

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.Location order by dea.location, dea.date) as PeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent!=''
)
select *, (PeopleVaccinated/Population)*100
from PopvsVac

/*CALCULATING PERCENTAGE OF PEOPLE VACCINATED PER POPULATION USING TEMP TABLE*/

drop temporary Table if exists PercentPopulationVaccinated

create temporary Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population bigint,
New_vaccinations bigint,
PeopleVaccinated bigint
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
From covid_deaths dea
Join covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *,(PeopleVaccinated/Population)*100
From PercentPopulationVaccinated

/*CREATING VIEW*/
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.Location order by dea.location, dea.date) as PeopleVaccinated
From covid_deaths dea
Join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent!=''

/*CREATING VIEWS for INDIA'S STATS*/

/*1-Total cases per population percentage in India*/
create view InfectedPopulationInIndia as
select continent,location,date,population,total_cases,(total_cases/population)*100 as InfectedPopulation,
from covid_deaths cd 
where location='India' 
order by 3

select * from infectedpopulationinindia 

/*2-Total deaths per population percentage in India*/
create view DeathsInIndia as
select location,date,population,total_deaths,(total_deaths/population)*100 as TotalDeathsPerPopulation
from covid_deaths cd 
where location='India'

select * from deathsinindia 

/*3-Total deaths per total cases percentage in India*/
create view CasesvsDeathsInIndia as
select location,date,population,new_cases,new_deaths,(new_Deaths/new_cases)*100 as DeathChancesIfPositive
from covid_deaths cd 
where location='India'

select * from casesvsdeathsinindia 

/*4-Total people vaccinated per population in India*/

create view VaccinatedPopulationInIndia as
select dea.location,dea.date,dea.population,vac.people_vaccinated 
, vac.people_vaccinated/dea.population*100 as VaccinatedPeoplePercent
From covid_deaths dea
Join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.location='India'
order by dea.date

select * from vaccinatedpopulationinindia