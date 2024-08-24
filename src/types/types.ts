// src/types/types.ts

// Enums for loan types, existing/proposed status
export enum LoanType {
    CreditCard = 'credit_card',
    Personal = 'personal',
    Other = 'other',
    VariableRate = 'variable-rate',
    FixedRate = 'fixed-rate',
    LineOfCredit = 'line-of-credit',
    // Add other loan types as needed
}

export enum ExistingOrProposed {
    Existing = 'existing',
    Proposed = 'proposed',
}

// Interfaces for different data types

export interface Income {
    which_household: number; // Household this income belongs to
    payg: number; // PAYG income (annual)
    commission: number; // Annual commission
    bonus: number; // Annual bonus
    overtime: number; // Annual overtime
    essential_worker_overtime: number;
    pension: number; // Annual pension
    annuities: number; // Annual annuities
    foreign_income: number; // Annual foreign income
    investment_income: number; // Annual investment income
    interest_income: number; // Annual interest income
    car_allowance: number; // Annual car allowance
    second_job: number; // Annual income from second job
    social_security: number; // Annual social security income
    other_taxed: number; // Annual other taxed income
    other_tax_free: number; // Annual other tax-free income
    pre_tax_deductions: number; // Monthly pre-tax deductions
    post_tax_deductions: number; // Monthly post-tax deductions
    HECS: boolean; // Flag for HECS debt
    HECS_balance: number; // HECS debt balance
}

export interface Liability {
    loan_type: LoanType; // Type of liability
    repaid_by_loan: boolean; // Will be repaid by the proposed loan?
    balance: number; // Current balance
    limit: number; // Credit limit (if applicable)
    rate: number; // Interest rate (annual)
    monthly_repayment: number; // Monthly repayment amount
    monthly_charges: number; // Monthly charges/fees
    remaining_term: number; // Remaining term in months
}

export interface HomeLoan {
    limit: number;
    product_type: LoanType; // Type of home loan
    existing_or_proposed: ExistingOrProposed; // Existing or proposed loan
    loan_type: LoanType; // owner_occupied or investment
    loan_amount: number; // Loan amount
    actual_rate: number; // Interest rate (annual)
    term: number; // Loan term in years
    interest_only_period: number; // Interest-only period in years
    monthly_charges: number; // Monthly charges/fees
    applicant_tax_benefit: number[]; // Percentage breakdown of tax benefit per applicant
}

export interface RentalIncome {
    address: string; // Address of the rental property
    suburb: string; // Suburb of the rental property
    postcode: number; // Postcode of the rental property
    value: number; // Estimated value of the rental property
    weekly_rental_income: number; // Weekly rental income
    existing_or_proposed: ExistingOrProposed; // Existing or proposed rental income
    applicant_ownership: number[]; // Percentage breakdown of ownership per applicant
}

export interface SelfEmployedIncome {
    most_recent_year_details: SelfEmployedYearDetails; // Details for most recent financial year
    previous_year_details: SelfEmployedYearDetails; // Details for the previous financial year
    applicant_ownership: number[]; // Percentage breakdown of ownership per applicant
    entity_type: string; // Type of self-employed entity (e.g., "sole-trader")
    business_liabilities: any[]; // Assuming no business liabilities for now
}

export interface SelfEmployedYearDetails {
    year_ended: number; // Financial year end
    net_profit_before_tax: number; // Net profit before tax
    personal_wages_before_tax: number[]; // Personal wages drawn from the business per applicant
    interest: number; // Interest expense add-back
    depreciation: number; // Depreciation expense add-back
    super_above_compulsory: number; // Superannuation above compulsory add-back
    other: number; // Other add-back
}

export interface Household {
    num_adults: number; // Number of adults in the household
    num_dependants: number; // Number of dependants in the household
    postcode: number; // Postcode of the household
}

export interface LivingExpenses {
    primary_residence: number; // Monthly cost of primary residence
    phone_internet_media: number; 
    food_and_groceries: number; 
    recreation_and_holidays: number; 
    clothing_and_personal_care: number; 
    medical_and_health: number; 
    transport: number; 
    public_education: number; 
    higher_education_and_vocational_training: number;
    childcare: number; 
    general_insurance: number; 
    other_insurance: number; 
    other: number; 
    strata_fees_and_body_corporate_fees: number; 
    private_non_government_school_fees: number; 
    child_support_maintenance_payments: number; 
    life_accident_illness_insurance: number;
    investment_property: number; 
    secondary_residence_costs: number; 
    ongoing_rent: number; 
    use_notional_rent: boolean; 
    ongoing_board: number; 
}

// Main scenario interface combining all the data
export interface Scenario {
    households: Household[];
    income: Income[];
    rental_income: RentalIncome[];
    self_employed_income: SelfEmployedIncome[];
    home_loans: HomeLoan[];
    liabilities: Liability[];
    comment_for_below: string;
    living_expenses: LivingExpenses[];
}
