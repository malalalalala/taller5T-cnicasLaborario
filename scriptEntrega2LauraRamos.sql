-- Crear la tabla "moneda" si no existe
CREATE TABLE IF NOT EXISTS moneda (
    id serial PRIMARY KEY,
    moneda VARCHAR(30),
    sigla VARCHAR(3),
    imagen BYTEA
);

-- Agregar una clave foránea en la tabla "pais" si no existe
ALTER TABLE IF EXISTS pais
ADD COLUMN IF NOT EXISTS idmoneda INT;


-- Crear la función PL/pgSQL
CREATE OR REPLACE FUNCTION actualizarMoneda() RETURNS VOID AS $$
BEGIN
  PERFORM column_name FROM information_schema.columns WHERE table_name = 'pais' AND column_name = 'moneda';
  IF FOUND THEN
    -- Copiar valores únicos de la columna "moneda" de la tabla "pais" a la tabla "moneda"
	INSERT INTO moneda (moneda)
	SELECT DISTINCT "moneda"
	FROM pais;

    UPDATE pais SET idmoneda = m.id
    FROM moneda m
    WHERE m.moneda = pais.moneda AND pais.moneda IS NOT NULL;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Llamar a la función para realizar la actualización condicional
SELECT actualizarMoneda();

-- Eliminar la función PL/pgSQL
DROP FUNCTION actualizarMoneda();

-- Eliminar la columna "moneda" de la tabla "pais" si existe
ALTER TABLE IF EXISTS pais
DROP COLUMN IF EXISTS moneda;

-- Agregar columnas "Mapa" y "Bandera" en la tabla "pais" si no existen
ALTER TABLE IF EXISTS pais
ADD COLUMN IF NOT EXISTS mapa BYTEA,
ADD COLUMN IF NOT EXISTS bandera BYTEA;

SELECT * FROM moneda