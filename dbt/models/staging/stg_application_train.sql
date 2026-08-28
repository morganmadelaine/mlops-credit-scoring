with source as (

    select * from {{ source('raw', 'application_train') }}

),

renamed as (

    select
        -- Identifiers
        sk_id_curr as application_id,
        target as is_default,

        -- Contract
        name_contract_type as contract_type,
        amt_credit as credit_amount,
        amt_annuity as annuity_amount,
        amt_goods_price as goods_price,

        -- Applicant demographics
        code_gender as gender,
        cast(days_birth / -365.25 as int64) as age_years,
        cnt_children as children_count,
        cnt_fam_members as family_size,
        name_family_status as family_status,
        name_education_type as education_level,
        name_housing_type as housing_type,

        -- Income and employment
        amt_income_total as income_total,
        name_income_type as income_type,
        occupation_type,
        organization_type,
        case
            when days_employed = 365243 then null
            else cast(days_employed / -365.25 as float64)
        end as employment_years,

        -- External credit scores
        ext_source_1,
        ext_source_2,
        ext_source_3,

        -- Ownership flags, normalised to boolean
        flag_own_car as owns_car,
        flag_own_realty as owns_realty,

        -- Contact flags, normalised from 0/1 integers to boolean
        cast(flag_mobil as bool) as has_mobile,
        cast(flag_emp_phone as bool) as has_employer_phone,
        cast(flag_work_phone as bool) as has_work_phone,
        cast(flag_phone as bool) as has_home_phone,
        cast(flag_email as bool) as has_email

    from source

)

select * from renamed
