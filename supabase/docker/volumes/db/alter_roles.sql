-- Set passwords for Supabase service users (LOCAL DEVELOPMENT)
DO $$
BEGIN
    -- Create roles if they don't exist
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticator') THEN
        CREATE ROLE authenticator WITH LOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_auth_admin') THEN
        CREATE ROLE supabase_auth_admin WITH LOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_admin') THEN
        CREATE ROLE supabase_admin WITH LOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_storage_admin') THEN
        CREATE ROLE supabase_storage_admin WITH LOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_realtime_admin') THEN
        CREATE ROLE supabase_realtime_admin WITH LOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'anon') THEN
        CREATE ROLE anon NOLOGIN NOINHERIT;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticated') THEN
        CREATE ROLE authenticated NOLOGIN NOINHERIT;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'service_role') THEN
        CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS;
    END IF;
END
$$;

-- Set passwords (using hardcoded secure password for local dev)
ALTER ROLE authenticator WITH PASSWORD 'supabase_local_dev_pass_2025';
ALTER ROLE supabase_auth_admin WITH PASSWORD 'supabase_local_dev_pass_2025';
ALTER ROLE supabase_admin WITH PASSWORD 'supabase_local_dev_pass_2025';
ALTER ROLE supabase_storage_admin WITH PASSWORD 'supabase_local_dev_pass_2025';
ALTER ROLE supabase_realtime_admin WITH PASSWORD 'supabase_local_dev_pass_2025';

-- Grant permissions
GRANT USAGE ON SCHEMA public TO authenticator, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticator, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticator, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO authenticator, service_role;
