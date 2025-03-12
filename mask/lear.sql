CREATE EXTENSION IF NOT EXISTS anon CASCADE;
SELECT anon.init();

SECURITY LABEL FOR anon ON COLUMN users.firstname
  IS 'MASKED WITH FUNCTION anon.fake_first_name()';

SECURITY LABEL FOR anon ON COLUMN users.lastname
  IS 'MASKED WITH FUNCTION anon.fake_last_name()';

SECURITY LABEL FOR anon ON COLUMN users.email
  IS 'MASKED WITH FUNCTION anon.fake_email()';

SECURITY LABEL FOR anon ON COLUMN users.middlename
  IS 'MASKED WITH FUNCTION anon.fake_first_name()';

SECURITY LABEL FOR anon ON COLUMN users_version.firstname
  IS 'MASKED WITH FUNCTION anon.fake_first_name()';

SECURITY LABEL FOR anon ON COLUMN users_version.lastname
  IS 'MASKED WITH FUNCTION anon.fake_last_name()';

SECURITY LABEL FOR anon ON COLUMN users_version.email
  IS 'MASKED WITH FUNCTION anon.fake_email()';

SECURITY LABEL FOR anon ON COLUMN users_version.middlename
  IS 'MASKED WITH FUNCTION anon.fake_first_name()';

SECURITY LABEL FOR anon ON COLUMN addresses.street
  IS 'MASKED WITH FUNCTION anon.fake_address()';

SECURITY LABEL FOR anon ON COLUMN addresses.street_additional
  IS 'MASKED WITH FUNCTION anon.fake_address()';

SECURITY LABEL FOR anon ON COLUMN addresses.city
  IS 'MASKED WITH FUNCTION anon.fake_city()';

SECURITY LABEL FOR anon ON COLUMN addresses.region
  IS 'MASKED WITH FUNCTION anon.fake_city()';

SECURITY LABEL FOR anon ON COLUMN addresses.postal_code
  IS 'MASKED WITH FUNCTION anon.fake_postcode()';

SECURITY LABEL FOR anon ON COLUMN addresses.delivery_instructions
  IS 'MASKED WITH FUNCTION anon.random_string(5)';

SECURITY LABEL FOR anon ON COLUMN addresses_version.street
  IS 'MASKED WITH FUNCTION anon.fake_address()';

SECURITY LABEL FOR anon ON COLUMN addresses_version.street_additional
  IS 'MASKED WITH FUNCTION anon.fake_address()';

SECURITY LABEL FOR anon ON COLUMN addresses_version.city
  IS 'MASKED WITH FUNCTION anon.fake_city()';

SECURITY LABEL FOR anon ON COLUMN addresses_version.region
  IS 'MASKED WITH FUNCTION anon.fake_city()';

SECURITY LABEL FOR anon ON COLUMN addresses_version.postal_code
  IS 'MASKED WITH FUNCTION anon.fake_postcode()';

SECURITY LABEL FOR anon ON COLUMN addresses_version.delivery_instructions
  IS 'MASKED WITH FUNCTION anon.random_string(5)';

SECURITY LABEL FOR anon ON COLUMN parties.first_name
  IS 'MASKED WITH FUNCTION anon.fake_first_name()';

SECURITY LABEL FOR anon ON COLUMN parties.last_name
  IS 'MASKED WITH FUNCTION anon.fake_last_name()';

SECURITY LABEL FOR anon ON COLUMN parties.middle_initial
  IS 'MASKED WITH FUNCTION anon.random_string(1)';

SECURITY LABEL FOR anon ON COLUMN parties.email
  IS 'MASKED WITH FUNCTION anon.fake_email()';

SECURITY LABEL FOR anon ON COLUMN parties_version.first_name
  IS 'MASKED WITH FUNCTION anon.fake_first_name()';

SECURITY LABEL FOR anon ON COLUMN parties_version.last_name
  IS 'MASKED WITH FUNCTION anon.fake_last_name()';

SECURITY LABEL FOR anon ON COLUMN parties_version.middle_initial
  IS 'MASKED WITH FUNCTION anon.random_string(1)';

SECURITY LABEL FOR anon ON COLUMN parties_version.email
  IS 'MASKED WITH FUNCTION anon.fake_email()';

SELECT anon.anonymize_database();
