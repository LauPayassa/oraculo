CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  "passwordHash" text NOT NULL,
  name text,
  "createdAt" timestamptz DEFAULT now()
);

CREATE TABLE card (
  id serial PRIMARY KEY,
  name text NOT NULL,
  "arcanaType" text NOT NULL,
  suit text,
  number int,
  "uprightMeaning" jsonb NOT NULL,
  "reversedMeaning" jsonb,
  keywords text,
  "imageUrl" text
);

CREATE TABLE reading (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId" uuid REFERENCES users(id) ON DELETE SET NULL,
  type text NOT NULL,
  cards jsonb NOT NULL,
  meta jsonb,
  notes text,
  "createdAt" timestamptz DEFAULT now()
);