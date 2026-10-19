-- =====================================================================
-- PUMAS CORP · SQL 38 — Registrar portal 'corp' en tabla portales
-- Corre en Supabase SQL Editor
-- =====================================================================

-- Agrega el portal 'corp' si no existe
INSERT INTO portales (id, nombre)
VALUES ('corp', 'Corp')
ON CONFLICT (id) DO UPDATE SET nombre = EXCLUDED.nombre;

-- Verifica que quedó
SELECT id, nombre FROM portales WHERE id = 'corp';

-- ── Filas en sitio_config para actividades y canales corp ─────────────
INSERT INTO sitio_config (clave, valor) VALUES ('corp_actividades', '[]'::jsonb) ON CONFLICT (clave) DO NOTHING;
INSERT INTO sitio_config (clave, valor) VALUES ('corp_canales',     '[]'::jsonb) ON CONFLICT (clave) DO NOTHING;

-- Permitir que anon escriba en sitio_config (necesario para el panel admin)
-- Si ya existe la política, la siguiente línea lanza un error inocuo:
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'sitio_config' AND policyname = 'sitio_config_anon_all'
  ) THEN
    EXECUTE 'CREATE POLICY sitio_config_anon_all ON sitio_config FOR ALL TO anon USING (true) WITH CHECK (true)';
  END IF;
END $$;
