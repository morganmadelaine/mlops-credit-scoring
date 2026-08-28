-- Applicant age must fall within a plausible range.
-- Fails if any row is outside 18-100 years.

select
    application_id,
    age_years
from {{ ref('stg_application_train') }}
where age_years < 18 or age_years > 100
