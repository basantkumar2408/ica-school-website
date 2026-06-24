-- ============================================
-- ICA WEBSITE — SCHEMA UPDATE for Dynamic Forms,
-- Document Storage, Theme & Application Numbers
-- Run this AFTER your existing tables are created
-- ============================================

-- 1) SETTINGS table (key-value store for site-wide config)
-- If you already have ica_settings, skip create, just add keys below.
CREATE TABLE IF NOT EXISTS ica_settings (
  key   TEXT PRIMARY KEY,
  value TEXT
);
ALTER TABLE ica_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public_settings" ON ica_settings;
CREATE POLICY "public_settings" ON ica_settings FOR ALL USING (true) WITH CHECK (true);

-- Default settings (safe to re-run, will not duplicate)
INSERT INTO ica_settings (key, value) VALUES ('admission_open', 'false')
  ON CONFLICT (key) DO NOTHING;
INSERT INTO ica_settings (key, value) VALUES ('admission_year', '2026-27')
  ON CONFLICT (key) DO NOTHING;
INSERT INTO ica_settings (key, value) VALUES ('theme_primary', '#c9982a')
  ON CONFLICT (key) DO NOTHING;
INSERT INTO ica_settings (key, value) VALUES ('theme_navy', '#0a1628')
  ON CONFLICT (key) DO NOTHING;

-- 2) FORM SCHEMA table — admin-defined dynamic form (sections + fields as JSON)
CREATE TABLE IF NOT EXISTS ica_form_schema (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  form_key    TEXT NOT NULL,            -- e.g. 'admission' or custom form name
  title       TEXT NOT NULL,
  is_active   BOOLEAN DEFAULT false,    -- whether this form is live on website
  schema_json JSONB NOT NULL,           -- { sections: [ { title, icon, fields: [ {id,label,type,required,options} ] } ] }
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE ica_form_schema ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public_form_schema" ON ica_form_schema;
CREATE POLICY "public_form_schema" ON ica_form_schema FOR ALL USING (true) WITH CHECK (true);

-- 3) GENERIC FORM SUBMISSIONS — for any custom (non-admission) form created by admin
CREATE TABLE IF NOT EXISTS ica_form_submissions (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  form_key     TEXT NOT NULL,
  data_json    JSONB NOT NULL,
  status       TEXT DEFAULT 'New',
  created_at   TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE ica_form_submissions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public_form_submissions" ON ica_form_submissions;
CREATE POLICY "public_form_submissions" ON ica_form_submissions FOR ALL USING (true) WITH CHECK (true);

-- 4) Add application_number column to admissions (sequential per year, e.g. ICA/2026/0001)
ALTER TABLE ica_admissions ADD COLUMN IF NOT EXISTS application_number TEXT;
ALTER TABLE ica_admissions ADD COLUMN IF NOT EXISTS academic_year TEXT;

-- 5) Document URL columns — replace old boolean-text flags with real Storage URLs
ALTER TABLE ica_admissions ADD COLUMN IF NOT EXISTS photo_file_url TEXT;
ALTER TABLE ica_admissions ADD COLUMN IF NOT EXISTS birth_cert_url TEXT;
ALTER TABLE ica_admissions ADD COLUMN IF NOT EXISTS marksheet_url TEXT;
ALTER TABLE ica_admissions ADD COLUMN IF NOT EXISTS tc_url TEXT;
ALTER TABLE ica_admissions ADD COLUMN IF NOT EXISTS aadhaar_url TEXT;

-- 6) Sequence counter table for application numbers (per academic year)
CREATE TABLE IF NOT EXISTS ica_app_counters (
  academic_year TEXT PRIMARY KEY,
  last_number   INTEGER DEFAULT 0
);
ALTER TABLE ica_app_counters ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "public_app_counters" ON ica_app_counters;
CREATE POLICY "public_app_counters" ON ica_app_counters FOR ALL USING (true) WITH CHECK (true);

-- ============================================
-- STORAGE BUCKET (run in Supabase Dashboard -> Storage, or via SQL below)
-- ============================================
-- Create a public bucket named 'admission-docs' for storing uploaded files.
-- Go to: Supabase Dashboard -> Storage -> New Bucket
--   Name: admission-docs
--   Public: YES (so admin panel can view/download directly via URL)
--
-- Then run this policy SQL (Storage -> Policies, or SQL editor):

INSERT INTO storage.buckets (id, name, public)
VALUES ('admission-docs', 'admission-docs', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY IF NOT EXISTS "Public Access admission-docs read"
ON storage.objects FOR SELECT
USING (bucket_id = 'admission-docs');

CREATE POLICY IF NOT EXISTS "Public Access admission-docs insert"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'admission-docs');

CREATE POLICY IF NOT EXISTS "Public Access admission-docs delete"
ON storage.objects FOR DELETE
USING (bucket_id = 'admission-docs');

-- ══════════════════════════════════════════════════════
-- ADDITIONAL: Gallery Images Storage Bucket
-- Create this bucket in Supabase Dashboard > Storage:
-- Bucket name: gallery-images (PUBLIC bucket)
-- Used for: gallery photos, principal photo, about photo
-- ══════════════════════════════════════════════════════

-- Gallery table (already exists, confirm image_url column present)
-- If ica_gallery table doesn't have image_url column, add it:
alter table if exists ica_gallery add column if not exists image_url text default '';

-- Settings for new photo features
insert into ica_settings (key, value) values
  ('principal_photo_url', ''),
  ('about_photo_url', ''),
  ('school_phone', ''),
  ('principal_name', 'The Principal')
on conflict (key) do nothing;
