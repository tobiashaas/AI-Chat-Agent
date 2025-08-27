-- Realtime setup for Supabase
CREATE TABLE IF NOT EXISTS _realtime.schema_migrations (
    version bigint PRIMARY KEY,
    inserted_at timestamp DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS _realtime.subscription (
    id bigserial PRIMARY KEY,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] NOT NULL DEFAULT '{}',
    claims jsonb NOT NULL,
    claims_role regrole NOT NULL GENERATED ALWAYS AS ((claims ->> 'role')::regrole) STORED,
    created_at timestamp DEFAULT timezone('utc'::text, now())
);

-- Enable realtime for auth.users
ALTER PUBLICATION supabase_realtime ADD TABLE auth.users;
