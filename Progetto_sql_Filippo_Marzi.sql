-- Adesso andrò a creare la mia tabella

CREATE TABLE IF NOT EXISTS WorldData2023 (
	country Varchar ,
	Density int, 
	Abbreviation Varchar,	
	Agricultural_Land decimal,	
	Land_Area int, 
	Armed_Forces_size int,
	birth_rate decimal,
	calling_code int,
	capital_major_city varchar, 
	tons_Co2_Emissions 	int,
	Consumer_Price_Index decimal,	
	CPI_Change decimal,
	Currency_Code varchar,	
	avg_Fertility_Rate	decimal,
	Forested_Area decimal,
	Gasoline_Price decimal,
	GDP	bigint,
	Gross_primary_education_enrollment decimal, 
	Gross_tertiary_education_enrollment decimal, 
	Infant_mortality decimal,
	Largest_city varchar,
	Life_expectancy	decimal,
	Maternal_mortality_ratio int,
	Minimum_wage decimal, 
	Official_language varchar,
	Out_of_pocket_health_expenditure decimal, 	
	Physicians_per_thousand	decimal,
	Population	int, 
	Workforce_Rate decimal,
	Tax_revenue	decimal,
	Total_tax_rate decimal,
	Unemployment_rate decimal,
	Urban_population int,
	Latitude decimal,
	Longitude decimal
);

--COPY WorldData2023 FROM 'C:\Users\admin\Desktop\world_data.csv' WITH CSV HEADER DELIMITER ';';
-- Ho messo la query di importazione come commento perchè nel caso in cui faccia partire il codice per sbaglio, evito di reiimportare nuovamente i dati


-- Adesso controllo se il caricamento dei dati è avvenuto
SELECT *
FROM WorldData2023;

-- Il caricamento sembra essere stato effettuato con successo, adesso procedo, osservando quanti valori ci sono come country

SELECT COUNT (country)
FROM WorldData2023;

-- La query mi ha dato come output 195, Adesso guardo le città uniche.

SELECT COUNT (DISTINCT country)
FROM WorldData2023;

-- La query mi ha dato come output 195, quindi posso affermare che non ci sono città duplicate.
-- Adesso vorrei vedere se ci sono dei valori nulli nelle città.

SELECT COUNT (country)
FROM WorldData2023
WHERE country IS NULL;

-- La query mi da come output 0, pertantanto non sono presenti valori nulli, ne duplicati, potrebbe essere una canditata alla primary key
-- Adesso iniziando a spostarci sugli indicatori economici vorrei vedere quanti valori nulli ci sono nel gdp

SELECT country, gdp
FROM WorldData2023
WHERE gdp IS NULL;

-- il database sembra essere molto attendibile e pulito, l'unici valori in cui abbiamo null sono il Vaticano e la Palestina, 
-- per ovvi motivi.
-- Adesso procedo cercando di capire il dataset osservando il GDP nel  suoi massimi, minimi, medi etc..

SELECT 
  AVG(gdp) AS media,
  MIN(gdp) AS minimo,
  MAX(gdp) AS massimo
FROM WorldData2023;

-- Adesso vorrei vedere i paesi che sono sopra la media del gdp,  etichettandoli in modo diverso a seconda del suo gdp
-- e contarli in modo totale

SELECT country, abbreviation, gdp,
    CASE
        WHEN gdp > (SELECT AVG(gdp) FROM WorldData2023) THEN 'gdp ABOVE average'
        ELSE 'gdp below average'
    END AS gdp_classification,
    COUNT(*) FILTER (WHERE gdp > (SELECT AVG(gdp) FROM WorldData2023)) OVER () AS count_above_average,
    COUNT(*) FILTER (WHERE gdp <= (SELECT AVG(gdp) FROM WorldData2023)) OVER () AS count_below_average
FROM WorldData2023
ORDER BY gdp DESC;


-- qui ho notato che nella riga 7 ho un dato fallato, pertanto controllando l'abbreviation su google ho notato che la città 
-- è "São Tomé and Príncipe", quindi procederò a cambiarla, prima di fare ciò mi assicuro che ST non sia da nessuna altra parte.

SELECT *
FROM WorldData2023
WHERE abbreviation = 'ST'

-- la query mi restituisce solo un valore, ma vedo che anche la colonna capital_major_city e largest_city ha lo stesso problema
-- quindi posso procedere anche con questa nuova modifica

UPDATE WorldData2023
	SET country = 'São Tomé e Príncipe',
		capital_major_city = 'São Tomé',
		largest_city = 'São Tomé'
	WHERE abbreviation = 'ST'
	
-- ora ricontrollo

SELECT *
FROM WorldData2023
WHERE abbreviation = 'ST'

-- la modifica è avvenuta correttamente. Riprendo il comando di prima per fare esattamente la stessa cosa:

SELECT country, abbreviation, gdp,
    CASE
        WHEN gdp > (SELECT AVG(gdp) FROM WorldData2023) THEN 'gdp ABOVE average'
        ELSE 'gdp below average'
    END AS gdp_classification,
    COUNT(*) FILTER (WHERE gdp > (SELECT AVG(gdp) FROM WorldData2023)) OVER () AS count_above_average,
    COUNT(*) FILTER (WHERE gdp <= (SELECT AVG(gdp) FROM WorldData2023)) OVER () AS count_below_average
FROM WorldData2023
ORDER BY gdp;

-- Adesso non abbiamo più quel problema e la query mi restituisce i valori richiesti, ma anche qui vaticano e palestina 
-- non hanno nessun tipo di dati, per questo voglio controllare se sono righe che possono essere tenute o eliminate 

SELECT *
FROM WorldData2023
WHERE country = 'Palestinian National Authority' OR country = 'Vatican City';
-- non hanno nessun tipo di dato, e essendo molto difficile trovare dati affidabili in merito, procederò con l'eleiminazione di queste due righe.

DELETE FROM WorldData2023
WHERE country IN ('Palestinian National Authority', 'Vatican City');

-- controllo l'avvenuta eliminazione

SELECT *
FROM WorldData2023
WHERE country IN ('Palestinian National Authority', 'Vatican City');

-- avvenuta con successo.


-- LA gdp_classification la voglio inserire come vista, quindi riprenderò il solito input aggiungendo 
-- il comando CREATE WIEW all'inizio

CREATE VIEW gdp_classification AS
SELECT country, abbreviation, gdp,
    CASE
        WHEN gdp > (SELECT AVG(gdp) FROM WorldData2023) THEN 'gdp ABOVE average'
        ELSE 'gdp below average'
    END AS gdp_classification,
    COUNT(*) FILTER (WHERE gdp > (SELECT AVG(gdp) FROM WorldData2023)) OVER () AS count_above_average,
    COUNT(*) FILTER (WHERE gdp <= (SELECT AVG(gdp) FROM WorldData2023)) OVER () AS count_below_average
FROM WorldData2023
ORDER BY gdp;

-- controllo adesso la vista 

SELECT *
FROM gdp_classification;

-- Adesso il mio obiettivo sarà quello di mettere in relazione l'emissioni di CO2 con il GDP, per vedere come lo sviluppo 
-- del prodotto interno lordo, incida sull'inquinamento, proverò a farlo sia in termini assoluti, che relativi.
-- Come primo step quindi cercherò di capire come si muovono le emissioni a seconda del paese e del gdp

SELECT country, gdp, tons_co2_emissions
FROM WorldData2023
ORDER BY tons_co2_emissions DESC

-- Da una prima analisi in termini assoluti le nazioni con un PIL più alto sono anche quelle che inquinano di più tra i principali China, USA, e India
-- ma ci sono anche nazioni come Iran che anche con un pil basso tengono testa, a livello di emissioni di CO2, alle nazioni come le sopracitate.
-- Per questo vorrei vedere quali dei paesi che hanno un PIL INFERIORE alla media ma con emissioni di CO2 MAGGIORI della media.

SELECT country, gdp, tons_co2_emissions
FROM WorldData2023
WHERE 
    gdp < (SELECT AVG(gdp) FROM WorldData2023) AND 
    tons_co2_emissions > (SELECT AVG(tons_co2_emissions) FROM WorldData2023)
ORDER BY tons_co2_emissions DESC;

--- questa query ci mostra come tantissimi paesi con pil inferiori alla media, emettano più della media della CO2.
--- Adesso farò l'inverso: Paesi con PIl > della media ed Emissioni < della media

SELECT country, gdp, tons_co2_emissions
FROM WorldData2023
WHERE 
    gdp > (SELECT AVG(gdp) FROM WorldData2023) AND 
    tons_co2_emissions < (SELECT AVG(tons_co2_emissions) FROM WorldData2023)
ORDER BY tons_co2_emissions DESC;

-- Adesso andrò a mettere in relazione le emissioni con il PIL
SELECT country, gdp, tons_co2_emissions,
       (CAST(tons_co2_emissions AS FLOAT) / CAST(gdp AS FLOAT))  AS emissions_per_dollar
FROM WorldData2023	
ORDER BY emissions_per_dollar

-- i numeri non sono facilmente interpretabili, pertanto farò emissioni per milioni di dollari 
SELECT country, gdp, tons_co2_emissions,
       (CAST(tons_co2_emissions AS FLOAT) / CAST(gdp AS FLOAT)) *1000000  AS emissions_per_milion_dollar
FROM WorldData2023	
ORDER BY emissions_per_milion_dollar DESC

--- in questo modo ho ottenuto il numero di tonnellate per milioni di dollari, cioè per ogni milione di dollari le relative nazioni 
--- emettono x tonnellate di CO2, questo essendo un rapporto ci indica quanto in termini relativi una nazione emetta CO2
--- adesso ordianiamoli per emissions_per_milion_dollar decrescente per vedere quelli che emettono più CO2

SELECT country, gdp, tons_co2_emissions,
       (CAST(tons_co2_emissions AS FLOAT) / CAST(gdp AS FLOAT)) *1000000  AS emissions_per_milion_dollar
FROM WorldData2023	
ORDER BY gdp 

-- Creo una view per facilitarmi il lavoro con le emissions_per_milion_dollar

CREATE VIEW emission_co2_classification AS( 
	SELECT country, gdp, tons_co2_emissions,
		   (CAST(tons_co2_emissions AS FLOAT) / CAST(gdp AS FLOAT)) *1000000  AS emissions_per_milion_dollar
	FROM WorldData2023	
) 
-- controllo 
SELECT *
FROM emission_co2_classification
ORDER BY emissions_per_milion_dollar DESC

-- adesso vorrei unire le tabelle per mettere in relazione la wiew delle emissioni per milioni di dollari con il gdp pro capite, unendo per nazione,
-- ovvero l'unica colonna che non ha al suo interno dei duplicati e che non presenta valori nulli.

SELECT e.country, e.gdp, e.tons_co2_emissions, e.emissions_per_milion_dollar, (e.gdp / population) AS gdp_per_capita
FROM emission_co2_classification e
JOIN WorldData2023 w ON e.country = w.country
ORDER BY gdp_per_capita DESC

-- da questa tabella risulta evidente che maggiore è il gdp per capita minore sono anche le nazioni che emettono meno CO2 
-- per milioni di dollari, quindi con uno sviluppo piu sostenibile.
-- per rendere più comprensibile l'output aggiungerò alla query dei filtri che mi permettano di vedere la stessa situazione 
-- solo tra i paesi con pil superiore alla media come sono il gdp pro capite e le emissioni per milioni di dollari.

SELECT e.country, e.gdp, e.tons_co2_emissions, (e.gdp / population) AS gdp_per_capita, e.emissions_per_milion_dollar 
FROM emission_co2_classification e 
JOIN WorldData2023 w ON e.country = w.country 
WHERE w.gdp > (SELECT AVG (gdp)FROM WorldData2023)
ORDER BY emissions_per_milion_dollar DESC

--ora farò lo stesso per vedere i paesi con il gdp inferiore alla media

SELECT e.country, e.gdp,  (e.gdp / w.population) AS gdp_per_capita, e.tons_co2_emissions, e.emissions_per_milion_dollar
FROM emission_co2_classification e 
JOIN WorldData2023 w ON e.country = w.country
WHERE w.gdp < (SELECT AVG(gdp)FROM WorldData2023)
ORDER BY emissions_per_milion_dollar DESC


-- Qui vediamo che nostra ipotesi è confermata:
-- i paesi con un pil pro capite più alto emmettono, in termini relativi, quantità maggiori di CO2.


-- Adesso vorrei analizzare i dati mettendo in relazione i paesi che hanno il gdp_per_capita inferiore e maggiore alla media,
-- e tra questi vedere come varia la media dell'età di vita.
-- Partiamo con i paesi con il gdp_per_capita maggiore della media

WITH AvgGdpPerCapita AS (
    SELECT AVG(gdp / population) AS avg_gdp_per_capita
    FROM WorldData2023
),
SelectedCountries AS (
    SELECT w.country, w.life_expectancy
    FROM WorldData2023 w, AvgGdpPerCapita a
    WHERE (w.gdp / w.population) > a.avg_gdp_per_capita
)
SELECT AVG(life_expectancy) AS avg_life_expectancy_above_avg_gdp
FROM SelectedCountries;

-- abbiamo visto adesso che per i paesi con un gdp sopra la media l'aspettativa di vita media è 79,70
-- Adesso osserviamola tra i paesi con il gdp < della media, copio esattamente la query cambiando il segno da ">" a "<"

WITH AvgGdpPerCapita AS (
    SELECT AVG(gdp / population) AS avg_gdp_per_capita
    FROM WorldData2023
),
SelectedCountries AS (
    SELECT w.country, w.life_expectancy
    FROM WorldData2023 w, AvgGdpPerCapita a
    WHERE (w.gdp / w.population) < a.avg_gdp_per_capita
)
SELECT AVG(life_expectancy) AS avg_life_expectancy_above_avg_gdp
FROM SelectedCountries;

-- qui la media scende tantissimo, addirittura di 10 anni, quindi la mia ipotesi è confermata.







