-- =====================================================================
-- PUMAS CORP · SQL 37 — Tablas y políticas nuevas
-- Corre en Supabase SQL Editor
-- =====================================================================

-- ── Relampagos (torneos relámpago) ───────────────────────────────────
CREATE TABLE IF NOT EXISTS corp_relampagos (
  id           BIGSERIAL PRIMARY KEY,
  portal       TEXT        NOT NULL DEFAULT 'corp',
  nombre       TEXT        NOT NULL,
  juego        TEXT,
  descripcion  TEXT,
  premio       TEXT,
  es_gratis    BOOLEAN     NOT NULL DEFAULT true,
  costo        TEXT,                          -- "5000 COP", "$3 USD", etc.
  metodo_pago  TEXT,                          -- "Nequi", "Binance", etc.
  org_wa       TEXT,                          -- WhatsApp del organizador
  org_ig       TEXT,                          -- Instagram del organizador
  logo_url     TEXT,
  banner_url   TEXT,
  estado       TEXT        NOT NULL DEFAULT 'activo',   -- activo | en_juego | finalizado
  fecha        TIMESTAMPTZ,
  publico      BOOLEAN     NOT NULL DEFAULT true,
  creado       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Resultados de Relampagos ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS corp_relampago_equipos (
  id           BIGSERIAL PRIMARY KEY,
  relampago_id BIGINT      NOT NULL REFERENCES corp_relampagos(id) ON DELETE CASCADE,
  nombre       TEXT        NOT NULL,
  logo_url     TEXT,
  puesto       INTEGER,
  puntos       INTEGER     NOT NULL DEFAULT 0,
  kills        INTEGER     NOT NULL DEFAULT 0,
  jugador1     TEXT,
  jugador2     TEXT,
  jugador3     TEXT,
  jugador4     TEXT,
  creado       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Eventos Aliados ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS corp_eventos_aliados (
  id           BIGSERIAL PRIMARY KEY,
  portal       TEXT        NOT NULL DEFAULT 'corp',
  nombre       TEXT        NOT NULL,
  juego        TEXT,
  descripcion  TEXT,
  premio       TEXT,
  es_gratis    BOOLEAN     NOT NULL DEFAULT true,
  costo        TEXT,
  ig           TEXT,
  whatsapp     TEXT,
  discord      TEXT,
  fecha        DATE,
  logo_url     TEXT,
  banner_url   TEXT,
  activo       BOOLEAN     NOT NULL DEFAULT true,
  orden        INTEGER     NOT NULL DEFAULT 0,
  creado       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Subpáginas dinámicas ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS corp_subpaginas (
  id              BIGSERIAL PRIMARY KEY,
  portal          TEXT        NOT NULL DEFAULT 'corp',
  slug            TEXT        UNIQUE NOT NULL,
  nombre          TEXT        NOT NULL,
  descripcion     TEXT,
  logo_url        TEXT,
  banner_url      TEXT,
  color_primary   TEXT        NOT NULL DEFAULT '#D8C395',
  color_accent    TEXT        NOT NULL DEFAULT '#F4EEDC',
  color_bg        TEXT        NOT NULL DEFAULT '#0A0A0A',
  contenido       JSONB       NOT NULL DEFAULT '{}',
  activo          BOOLEAN     NOT NULL DEFAULT true,
  creado          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── RLS ──────────────────────────────────────────────────────────────
ALTER TABLE corp_relampagos         ENABLE ROW LEVEL SECURITY;
ALTER TABLE corp_relampago_equipos  ENABLE ROW LEVEL SECURITY;
ALTER TABLE corp_eventos_aliados    ENABLE ROW LEVEL SECURITY;
ALTER TABLE corp_subpaginas         ENABLE ROW LEVEL SECURITY;

-- Lectura pública
CREATE POLICY "relampagos_pub_read"  ON corp_relampagos        FOR SELECT USING (publico = true);
CREATE POLICY "relampago_eq_pub"     ON corp_relampago_equipos FOR SELECT USING (
  relampago_id IN (SELECT id FROM corp_relampagos WHERE publico = true)
);
CREATE POLICY "eventos_pub_read"     ON corp_eventos_aliados   FOR SELECT USING (activo = true);
CREATE POLICY "subpag_pub_read"      ON corp_subpaginas        FOR SELECT USING (activo = true);

-- Escritura con clave anon (la autenticación la gestiona el admin a nivel de app)
CREATE POLICY "relampagos_anon_all"  ON corp_relampagos        FOR ALL  TO anon USING (true) WITH CHECK (true);
CREATE POLICY "relampago_eq_all"     ON corp_relampago_equipos FOR ALL  TO anon USING (true) WITH CHECK (true);
CREATE POLICY "eventos_anon_all"     ON corp_eventos_aliados   FOR ALL  TO anon USING (true) WITH CHECK (true);
CREATE POLICY "subpag_anon_all"      ON corp_subpaginas        FOR ALL  TO anon USING (true) WITH CHECK (true);

-- ── Config corp en sitio_config ───────────────────────────────────────
-- Si no existe la tabla sitio_config ya, esta fila guarda canales y actividades:
-- INSERT INTO sitio_config (clave, valor) VALUES ('corp_canales',    '[]') ON CONFLICT DO NOTHING;
-- INSERT INTO sitio_config (clave, valor) VALUES ('corp_actividades','[]') ON CONFLICT DO NOTHING;
-- INSERT INTO sitio_config (clave, valor) VALUES ('corp_calendar_img', null) ON CONFLICT DO NOTHING;
