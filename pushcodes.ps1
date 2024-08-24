# This PowerShell script generates the necessary files for the CBA Home Loan Calculator challenge.

# Create the directory structure
New-Item -ItemType Directory -Path src\types # Creates the 'types' directory inside 'src' for type definitions

# Create package.json (Defines project metadata and dependencies)
@"
{
  "name": "cba-home-loan-calculator",
  "version": "1.0.0",
  "description": "CBA Home Loan Calculator implementation in TypeScript",
  "main": "src/CBACalc.ts", # Entry point of the application
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1" # Placeholder for test command
  },
  "author": "Bard",
  "license": "ISC",
  "devDependencies": {
    "@types/lodash": "^4.14.191", # Type definitions for Lodash
    "typescript": "^4.9.5" # TypeScript compiler
  },
  "dependencies": {
    "lodash": "^4.17.21" # Lodash library for utility functions
  }
}
"@ | Out-File -FilePath package.json -Encoding utf8 # Writes the JSON content to package.json

# Create types.ts (Defines TypeScript interfaces for input data)
@"
// src/types/types.ts

// Enums for loan types, existing/proposed status
export enum LoanType {
    CreditCard = 'credit_card',
    Personal = 'personal',
    Other = 'other',
    VariableRate = 'variable-rate',
    FixedRate = 'fixed-rate',
    LineOfCredit = 'line-of-credit',
    # Add other loan types as needed
}

export enum ExistingOrProposed {
    Existing = 'existing',
    Proposed = 'proposed',
}

# Interfaces for different data types

export interface Income {
    which_household: number; # Household this income belongs to
    payg: number; # PAYG income (annual)
    commission: number; # Annual commission
    bonus: number; # Annual bonus
    overtime: number; # Annual overtime
    essential_worker_overtime: number;
    pension: number; # Annual pension
    annuities: number; # Annual annuities
    foreign_income: number; # Annual foreign income
    investment_income: number; # Annual investment income
    interest_income: number; # Annual interest income
    car_allowance: number; # Annual car allowance
    second_job: number; # Annual income from second job
    social_security: number; # Annual social security income
    other_taxed: number; # Annual other taxed income
    other_tax_free: number; # Annual other tax-free income
    pre_tax_deductions: number; # Monthly pre-tax deductions
    post_tax_deductions: number; # Monthly post-tax deductions
    HECS: boolean; # Flag for HECS debt
    HECS_balance: number; # HECS debt balance
}

export interface Liability {
    loan_type: LoanType; # Type of liability
    repaid_by_loan: boolean; # Will be repaid by the proposed loan?
    balance: number; # Current balance
    limit: number; # Credit limit (if applicable)
    rate: number; # Interest rate (annual)
    monthly_repayment: number; # Monthly repayment amount
    monthly_charges: number; # Monthly charges/fees
    remaining_term: number; # Remaining term in months
}

export interface HomeLoan {
    product_type: LoanType; # Type of home loan
    existing_or_proposed: ExistingOrProposed; # Existing or proposed loan
    loan_type: LoanType; # owner_occupied or investment
    loan_amount: number; # Loan amount
    actual_rate: number; # Interest rate (annual)
    term: number; # Loan term in years
    interest_only_period: number; # Interest-only period in years
    monthly_charges: number; # Monthly charges/fees
    applicant_tax_benefit: number[]; # Percentage breakdown of tax benefit per applicant
}

export interface RentalIncome {
    address: string; # Address of the rental property
    suburb: string; # Suburb of the rental property
    postcode: number; # Postcode of the rental property
    value: number; # Estimated value of the rental property
    weekly_rental_income: number; # Weekly rental income
    existing_or_proposed: ExistingOrProposed; # Existing or proposed rental income
    applicant_ownership: number[]; # Percentage breakdown of ownership per applicant
}

export interface SelfEmployedIncome {
    most_recent_year_details: SelfEmployedYearDetails; # Details for most recent financial year
    previous_year_details: SelfEmployedYearDetails; # Details for the previous financial year
    applicant_ownership: number[]; # Percentage breakdown of ownership per applicant
    entity_type: string; # Type of self-employed entity (e.g., "sole-trader")
    business_liabilities: any[]; # Assuming no business liabilities for now
}

export interface SelfEmployedYearDetails {
    year_ended: number; # Financial year end
    net_profit_before_tax: number; # Net profit before tax
    personal_wages_before_tax: number[]; # Personal wages drawn from the business per applicant
    interest: number; # Interest expense add-back
    depreciation: number; # Depreciation expense add-back
    super_above_compulsory: number; # Superannuation above compulsory add-back
    other: number; # Other add-back
}

export interface Household {
    num_adults: number; # Number of adults in the household
    num_dependants: number; # Number of dependants in the household
    postcode: number; # Postcode of the household
}

export interface LivingExpenses {
    primary_residence: number; # Monthly cost of primary residence
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

# Main scenario interface combining all the data
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
"@ | Out-File -FilePath src\types\types.ts -Encoding utf8

# Create resultsTypes.ts (Defines TypeScript interfaces for results data)
@"
# src/types/resultsTypes.ts

export interface IncomeResult {
    gross_annual_income: number; # Calculated gross annual income
    assessable_annual_income: number; # Calculated assessable annual income
    net_annual_income: number; # Calculated net annual income
}

export interface LiabilityRepaymentResult {
    total_repayments: number; # Total monthly liability repayments
}

export interface HomeLoanResult {
    total_repayments: number; # Total monthly home loan repayments
}

# Main results interface combining all the calculated results
export interface Results {
    income: IncomeResult[];
    net_annual_income: number; # Total net annual income of all applicants
    liability_repayments: LiabilityRepaymentResult[];
    home_loans: HomeLoanResult[];
    total_existing_repayments: number; # Total monthly repayments for existing commitments
    total_proposed_repayments: number; # Total monthly repayments for proposed loans
    net_cash_position: number; # Calculated net monthly cash position
    debt_to_income_ratio: number; # Calculated Debt to Income Ratio
    maximum_borrowing_capacity: number; # Calculated maximum borrowing capacity
}
"@ | Out-File -FilePath src\types\resultsTypes.ts -Encoding utf8

# Create Data.csv (as a JSON file)
@"
{
    "Income Tax": [
      {
        "Upper Limit": 0,
        "Rate": 0,
        "Carry": 0,
        "Taxable_income": 37500,
        "Offset_tax": 700,
        "cent": 0
      },
      {
        "Upper Limit": 18200,
        "Rate": 0.19,
        "Carry": 0,
        "Taxable_income": 45000,
        "Offset_tax": 3572,
        "cent": 0.5
      },
      {
        "Upper Limit": 45000,
        "Rate": 0.325,
        "Carry": 5092,
        "Taxable_income": 120000,
        "Offset_tax": 29467,
        "cent": 0.5
      },
      {
        "Upper Limit": 120000,
        "Rate": 0.37,
        "Carry": 29467,
        "Taxable_income": 180000,
        "Offset_tax": 51667,
        "cent": 0.5
      },
      {
        "Upper Limit": 180000,
        "Rate": 0.45,
        "Carry": 51667,
        "Taxable_income": 180000,
        "Offset_tax": 51667,
        "cent": 0.5
      }
    ],
    "Medicare Levy": [
      {
        "Threshold": 0,
        "Rate": 0,
        "Carry": 0
      },
      {
        "Threshold": 22801,
        "Rate": 0.1,
        "Carry": 0
      },
      {
        "Threshold": 28501,
        "Rate": 0.02,
        "Carry": 0
      }
    ],
    "LITO": [
      {
        "Taxable_income": 37500,
        "Offset_tax": 700,
        "cent": 0
      },
      {
        "Taxable_income": 45000,
        "Offset_tax": 700,
        "cent": 5
      },
      {
        "Taxable_income": 66667,
        "Offset_tax": 445,
        "cent": 15
      },
      {
        "Taxable_income": 90000,
        "Offset_tax": 1080,
        "cent": 0
      },
      {
        "Taxable_income": 126000,
        "Offset_tax": 1080,
        "cent": 3
      }
    ],
    "LMITO": [
      {
        "Taxable_income": 37000,
        "Offset_tax": 255,
        "cent": 0
      },
      {
        "Taxable_income": 48000,
        "Offset_tax": 255,
        "cent": 75
      },
      {
        "Taxable_income": 90000,
        "Offset_tax": 1080,
        "cent": 0
      },
      {
        "Taxable_income": 126000,
        "Offset_tax": 1080,
        "cent": 3
      }
    ],
    "Sliding Scale Commitment Level": {
      "Income": [
        {
          "Lower": 0,
          "Upper": 10000
        },
        {
          "Lower": 10001,
          "Upper": 15000
        },
        {
          "Lower": 15001,
          "Upper": 20000
        },
        {
          "Lower": 20001,
          "Upper": 55000
        },
        {
          "Lower": 55001,
          "Upper": 180000
        },
        {
          "Lower": 180001,
          "Upper": 190000
        },
        {
          "Lower": 190001,
          "Upper": 200000
        },
        {
          "Lower": 200001,
          "Upper": 250000
        },
        {
          "Lower": 250001,
          "Upper": 300000
        },
        {
          "Lower": 300001,
          "Upper": 538000
        },
        {
          "Lower": 538001,
          "Upper": 9999999999
        }
      ],
      "C.L.": [
        0.1,
        0.15,
        0.25,
        0.35,
        0.4,
        0.45,
        0.5,
        0.55,
        0.6,
        0.65,
        0.7
      ]
    },
    "Sliding Scale Cash Buffer": {
      "Income": [
        {
          "Lower": 0,
          "Upper": 20000
        },
        {
          "Lower": 20001,
          "Upper": 55000
        },
        {
          "Lower": 55001,
          "Upper": 180000
        },
        {
          "Lower": 180001,
          "Upper": 999999999
        }
      ],
      "C.B.": [
        0,
        0,
        0.05,
        0.1
      ]
    },
    "Household Expenditure Measure": {
      "Lower": [
        0,
        22001,
        32001,
        43001,
        54001,
        65001,
        86001,
        108001,
        129001,
        151001,
        172001,
        215001,
        269001,
        323001,
        538001,
        538001
      ],
      "Upper": [
        22000,
        32000,
        43000,
        54000,
        65000,
        86000,
        108000,
        129000,
        151000,
        172000,
        215000,
        269000,
        323000,
        538000,
        999999999,
        999999999
      ],
      "Single Adult": [
        1103,
        1169,
        1230,
        1320,
        1481,
        1690,
        2010,
        2227,
        2639,
        2807,
        2974,
        3454,
        3920,
        4161,
        4396,
        4396
      ],
      "Additional Adult": [
        491,
        491,
        490,
        490,
        489,
        489,
        488,
        488,
        487,
        487,
        486,
        486,
        486,
        486,
        486,
        486
      ],
      "1 Dependent": [
        504,
        570,
        631,
        721,
        882,
        1091,
        1410,
        1626,
        2038,
        2206,
        2372,
        2852,
        3318,
        3558,
        3793,
        3793
      ],
      "2 Dependents": [
        895,
        961,
        1022,
        1112,
        1373,
        1681,
        2001,
        2217,
        2628,
        2796,
        2962,
        3441,
        3907,
        4147,
        4382,
        4382
      ],
      "3 Dependents": [
        1278,
        1344,
        1405,
        1494,
        1865,
        2272,
        2591,
        2807,
        3218,
        3387,
        3552,
        4031,
        4497,
        4737,
        4972,
        4972
      ],
      "Additional Dependent": [
        383,
        383,
        383,
        382,
        382,
        381,
        380,
        379,
        377,
        377,
        376,
        374,
        373,
        372,
        372,
        372
      ]
    },
    "Net to Gross": {
      "Multiplier": {
        "Weekly": 52,
        "Fortnightly": 26,
        "Monthly": 12,
        "Quarterly": 4,
        "Half Yearly": 2,
        "Yearly": 1
      }
    },
    "Existing Commitments": {
      "Commitment": {
        "Credit Card": 0.0382,
        "Access Advantage": "N/A",
        "Overdraft": 0.03,
        "Business Overdraft": 0.015,
        "Commercial Bill": 0.015
      }
    },
    "Credit Card Minimum": 25,
    "Assessment Rate": 0.051,
    "Assessment Rate Buffer": 0.025
  }
"@ | Out-File -FilePath Data.csv -Encoding utf8

# Generate scenarios for each milestone
$scenarios = @(
  # Milestone 1: Vanilla scenario
  Generate-Scenario -Milestone 1,
  # Milestone 2: Income Types
  Generate-Scenario -Milestone 2,
  # Milestone 3: Liabilities
  Generate-Scenario -Milestone 3,
  # Milestone 4: Minimum Living Expenses (2 dependants)
  Generate-Scenario -Milestone 4 -DependantCount 2,
  # Milestone 5: Investment Property 
  Generate-Scenario -Milestone 5 -RentalCount 1,
  # Milestone 6: Self Employed
  Generate-Scenario -Milestone 6 -SelfEmployedCount 1,
  # Milestone 7: Multiple Households and Applicants
  Generate-Scenario -Milestone 7 -ApplicantCount 2 -HouseholdCount 2 -RentalCount 1 -SelfEmployedCount 1
)

# Create scenarios.csv with all generated scenarios
$scenarios | Export-Csv -Path scenarios.csv -NoTypeInformation 

# Placeholder for results.json (you will need to populate with actual expected results)
@"
[
  {
    "income": [
      {
        "gross_annual_income": 70000,
        "assessable_annual_income": 70000,
        "net_annual_income": 53053.5
      }
    ],
    "net_annual_income": 53053.5,
    "liability_repayments": [],
    "home_loans": [
      {
        "total_repayments": 1609.25
      }
    ],
    "total_existing_repayments": 0,
    "total_proposed_repayments": 1609.25,
    "net_cash_position": 2834.8125,
    "debt_to_income_ratio": 0.09,
    "maximum_borrowing_capacity": 1682763
  },
  {
    "income": [
      {
        "gross_annual_income": 165120,
        "assessable_annual_income": 165120,
        "net_annual_income": 113864.5
      }
    ],
    "net_annual_income": 113864.5,
    "liability_repayments": [],
    "home_loans": [
      {
        "total_repayments": 1799
      }
    ],
    "total_existing_repayments": 0,
    "total_proposed_repayments": 1799,
    "net_cash_position": 7822.791666666667,
    "debt_to_income_ratio": 0.06,
    "maximum_borrowing_capacity": 4661898
  },
  {
    "income": [
      {
        "gross_annual_income": 165120,
        "assessable_annual_income": 165120,
        "net_annual_income": 113864.5
      }
    ],
    "net_annual_income": 113864.5,
    "liability_repayments": [
      {
        "total_repayments": 382
      },
      {
        "total_repayments": 200
      }
    ],
    "home_loans": [
      {
        "total_repayments": 1609.25
      }
    ],
    "total_existing_repayments": 582,
    "total_proposed_repayments": 1609.25,
    "net_cash_position": 6988.458333333333,
    "debt_to_income_ratio": 0.07,
    "maximum_borrowing_capacity": 4178236
  },
  {
    "income": [
      {
        "gross_annual_income": 70000,
        "assessable_annual_income": 70000,
        "net_annual_income": 53053.5
      }
    ],
    "net_annual_income": 53053.5,
    "liability_repayments": [],
    "home_loans": [
      {
        "total_repayments": 1609.25
      }
    ],
    "total_existing_repayments": 0,
    "total_proposed_repayments": 1609.25,
    "net_cash_position": 2834.8125,
    "debt_to_income_ratio": 0.09,
    "maximum_borrowing_capacity": 772085
  },
  {
    "income": [
      {
        "gross_annual_income": 165120,
        "assessable_annual_income": 165120,
        "net_annual_income": 113864.5
      }
    ],
    "net_annual_income": 113864.5,
    "liability_repayments": [],
    "home_loans": [
      {
        "total_repayments": 6118.92
      },
      {
        "total_repayments": 1609.25
      }
    ],
    "total_existing_repayments": 0,
    "total_proposed_repayments": 7728.17,
    "net_cash_position": 1867.2458333333333,
    "debt_to_income_ratio": 0.23,
    "maximum_borrowing_capacity": 2375000
  },
  {
    "income": [
      {
        "gross_annual_income": 275120,
        "assessable_annual_income": 275120,
        "net_annual_income": 181714.5
      }
    ],
    "net_annual_income": 181714.5,
    "liability_repayments": [],
    "home_loans": [
      {
        "total_repayments": 1609.25
      }
    ],
    "total_existing_repayments": 0,
    "total_proposed_repayments": 1609.25,
    "net_cash_position": 13800.125,
    "debt_to_income_ratio": 0.03,
    "maximum_borrowing_capacity": 8263184
  },
  {
    "income": [
      {
        "gross_annual_income": 230120,
        "assessable_annual_income": 230120,
        "net_annual_income": 154809.5
      },
      {
        "gross_annual_income": 230120,
        "assessable_annual_income": 230120,
        "net_annual_income": 154809.5
      }
    ],
    "net_annual_income": 309619,
    "liability_repayments": [
      {
        "total_repayments": 382
      },
      {
        "total_repayments": 200
      }
    ],
    "home_loans": [
      {
        "total_repayments": 6118.92
      },
      {
        "total_repayments": 1609.25
      }
    ],
    "total_existing_repayments": 6700.92,
    "total_proposed_repayments": 7728.17,
    "net_cash_position": 19677.1975,
    "debt_to_income_ratio": 0.15,
    "maximum_borrowing_capacity": 5875000
  }
]
"@ | Out-File -FilePath results.json -Encoding utf8

# Create CBACalc.ts (You will need to implement the actual logic based on provided spreadsheet)
@"
// src/CBACalc.ts
import { isEmpty, set } from "lodash";
import Data from './Data.csv';

// Import scenario interface
import { Scenario, LoanType, ExistingOrProposed } from "./types/types";
// Import results interface
import { Results, IncomeResult, LiabilityRepaymentResult, HomeLoanResult } from "./types/resultsTypes";

/**
 * Calculates gross annual income based on different income sources and frequencies.
 *
 * @param income - The income object.
 * @returns {number} - The calculated gross annual income.
 */
const calculateGrossAnnualIncome = (income: Income): number => {
    // Calculate gross annual income based on income type and frequency
    let grossAnnualIncome = 0;
    grossAnnualIncome += income.payg * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.commission * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.bonus * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.overtime * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.essential_worker_overtime * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.pension * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.annuities * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.foreign_income * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.investment_income * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.interest_income * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.car_allowance * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.second_job * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.social_security * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.other_taxed * Data['Net to Gross']['Multiplier']['Yearly'];
    grossAnnualIncome += income.other_tax_free * Data['Net to Gross']['Multiplier']['Yearly'];

    return grossAnnualIncome;
};

/**
 * Calculates assessable annual income by subtracting pre-tax deductions and HECS debt.
 *
 * @param income - The income object.
 * @returns {number} - The calculated assessable annual income.
 */
const calculateAssessableAnnualIncome = (income: Income): number => {
    // Calculate assessable annual income from gross annual income, deductions, and HECS
    let assessableAnnualIncome = calculateGrossAnnualIncome(income);
    assessableAnnualIncome -= income.pre_tax_deductions * 12;
    if (income.HECS) {
        assessableAnnualIncome -= income.HECS_balance * Data['Existing Commitments']['Commitment']['HECS'];
    }
    return assessableAnnualIncome;
};

/**
 * Calculates income tax based on the provided assessable annual income.
 *
 * @param assessableAnnualIncome - The assessable annual income.
 * @returns {number} - The calculated income tax.
 */
const calculateIncomeTax = (assessableAnnualIncome: number): number => {
    // Calculate income tax based on income tax brackets from Data sheet
    for (const bracket of Data['Income Tax']) {
        if (assessableAnnualIncome <= bracket['Upper Limit']) {
            return (
                (assessableAnnualIncome - bracket['Taxable_income']) * bracket['Rate'] +
                bracket['Offset_tax'] +
                bracket['cent'] / 100
            );
        }
    }
    // If income exceeds the highest bracket, use the highest bracket's rate
    const highestBracket = Data['Income Tax'][Data['Income Tax'].length - 1];
    return (
        (assessableAnnualIncome - highestBracket['Taxable_income']) * highestBracket['Rate'] +
        highestBracket['Offset_tax'] +
        highestBracket['cent'] / 100
    );
};

/**
 * Calculates the Medicare levy based on the provided assessable annual income.
 *
 * @param assessableAnnualIncome - The assessable annual income.
 * @returns {number} - The calculated Medicare levy.
 */
const calculateMedicareLevy = (assessableAnnualIncome: number): number => {
    // Calculate Medicare levy based on thresholds from Data sheet
    for (const levy of Data['Medicare Levy']) {
        if (assessableAnnualIncome <= levy['Threshold']) {
            return (assessableAnnualIncome - levy['Threshold']) * levy['Rate'] + levy['Carry'];
        }
    }
    // If income exceeds the highest threshold, use the highest threshold's rate
    const highestLevy = Data['Medicare Levy'][Data['Medicare Levy'].length - 1];
    return (assessableAnnualIncome - highestLevy['Threshold']) * highestLevy['Rate'] + highestLevy['Carry'];
};

/**
 * Calculates the Low Income Tax Offset (LITO) based on assessable annual income and income tax.
 *
 * @param assessableAnnualIncome - The assessable annual income.
 * @param incomeTax - The income tax.
 * @returns {number} - The calculated LITO.
 */
const calculateLITO = (assessableAnnualIncome: number, incomeTax: number): number => {
    // Calculate Low Income Tax Offset (LITO) based on LITO brackets and ensure it doesn't exceed income tax
    for (const bracket of Data['LITO']) {
        if (assessableAnnualIncome <= bracket['Taxable_income']) {
            let lito =
                (assessableAnnualIncome - bracket['Taxable_income']) * bracket['Rate'] +
                bracket['Offset_tax'] +
                bracket['cent'] / 100;
            // LITO cannot be negative
            lito = Math.max(lito, 0);
            return Math.min(lito, incomeTax); // LITO cannot exceed income tax
        }
    }
    return 0; // No LITO for income exceeding the highest bracket
};

/**
 * Calculates the Low and Middle Income Tax Offset (LMITO) based on assessable annual income and income tax.
 *
 * @param assessableAnnualIncome - The assessable annual income.
 * @param incomeTax - The income tax.
 * @returns {number} - The calculated LMITO.
 */
const calculateLMITO = (assessableAnnualIncome: number, incomeTax: number): number => {
    // Calculate Low and Middle Income Tax Offset (LMITO) based on LMITO bracket
    // and ensure LITO + LMITO doesn't exceed income tax
    for (const bracket of Data['LMITO']) {
        if (assessableAnnualIncome <= bracket['Taxable_income']) {
            let lmito =
                (assessableAnnualIncome - bracket['Taxable_income']) * bracket['Rate'] +
                bracket['Offset_tax'] +
                bracket['cent'] / 100;
            // LMITO cannot be negative
            lmito = Math.max(lmito, 0);
            // Ensure the sum of LITO and LMITO does not exceed the total income tax
            return Math.min(lmito, incomeTax - calculateLITO(assessableAnnualIncome, incomeTax));
        }
    }
    return 0; // No LMITO for income exceeding the highest bracket
};

/**
 * Calculates liability repayments based on loan type and repayment details.
 *
 * @param liability - The liability object.
 * @returns {number} - The calculated monthly liability repayments.
 */
const calculateLiabilityRepayments = (liability: Liability): number => {
    // Calculate monthly liability repayments based on loan type
    switch (liability.loan_type) {
        case LoanType.CreditCard:
            // If repaid by proposed loan, use provided monthly repayment or 0
            if (liability.repaid_by_loan) {
                return liability.monthly_repayment || 0;
            } else {
                // Otherwise, calculate based on the higher of 3% of the limit/balance or the credit card minimum
                return Math.max(
                    (liability.limit || liability.balance) * Data['Existing Commitments']['Commitment']['Credit Card'],
                    Data['Credit Card Minimum']
                );
            }
        case LoanType.Personal:
            // Use provided monthly repayment or calculate using PMT function
            return liability.monthly_repayment ||
                -PMT(
                    liability.rate / 12,
                    liability.remaining_term,
                    liability.balance,
                    0,
                    0
                ) +
                liability.monthly_charges;
        case LoanType.Other:
            // Use provided monthly repayment or calculate using PMT function
            return liability.monthly_repayment ||
                -PMT(
                    liability.rate / 12,
                    liability.remaining_term * 12,
                    liability.balance,
                    0,
                    0
                ) +
                liability.monthly_charges;
        default:
            throw new Error(`Unknown liability type: ${liability.loan_type}`);
    }
};

/**
 * Calculates monthly home loan repayments based on loan details and assessment rate.
 *
 * @param homeLoan - The home loan object.
 * @returns {number} - The calculated monthly home loan repayments.
 */
const calculateHomeLoanRepayments = (homeLoan: HomeLoan): number => {
    // Calculate monthly home loan repayments based on loan type
    let assessmentRate =
        homeLoan.actual_rate + Data['Assessment Rate Buffer'];
    if (homeLoan.product_type !== LoanType.LineOfCredit) {
        assessmentRate = Math.max(
            assessmentRate,
            Data['Assessment Rate']
        );
    }
    let repayments = 0;
    switch (homeLoan.product_type) {
        case LoanType.VariableRate:
        case LoanType.FixedRate:
            // Calculate repayments using PMT function
            repayments = -PMT(
                assessmentRate / 12,
                (homeLoan.term - homeLoan.interest_only_period) * 12,
                homeLoan.loan_amount
            );
            break;
        case LoanType.LineOfCredit:
            // Calculate repayments based on 3% of the limit/balance
            repayments =
                (homeLoan.loan_amount || homeLoan.limit) *
                Data['Existing Commitments']['Commitment']['LineOfCredit'];
            break;
        default:
            throw new Error(`Unknown home loan product type: ${homeLoan.product_type}`);
    }
    repayments += homeLoan.monthly_charges || 0;
    return Math.ceil(repayments);
};

/**
 * Calculates the net cash position by subtracting total repayments from net annual income.
 *
 * @param netAnnualIncome - The net annual income.
 * @param totalExistingRepayments - The total monthly existing repayments.
 * @param totalProposedRepayments - The total monthly proposed repayments.
 * @returns {number} - The calculated net monthly cash position.
 */
const calculateNetCashPosition = (
    netAnnualIncome: number,
    totalExistingRepayments: number,
    totalProposedRepayments: number
): number => {
    // Calculate net cash position based on annual income and repayments
    return (
        (netAnnualIncome - totalExistingRepayments * 12 - totalProposedRepayments * 12) / 12
    );
};

/**
 * Calculates the Debt to Income Ratio (DTI) based on total debt and net annual income.
 *
 * @param totalDebt - The total debt.
 * @param netAnnualIncome - The net annual income.
 * @returns {number} - The calculated DTI rounded to two decimal places.
 */
const calculateDebtToIncomeRatio = (
    totalDebt: number,
    netAnnualIncome: number
): number => {
    // Calculate Debt to Income Ratio (DTI)
    return +(totalDebt / netAnnualIncome).toFixed(2);
};

/**
 * Calculates the maximum borrowing capacity based on income, existing commitments,
 *  and assessment rates.
 *
 * @param results - The calculated results object.
 * @returns {number} - The calculated maximum borrowing capacity.
 */
const calculateMaximumBorrowingCapacity = (results: Results): number => {
    // Calculate maximum borrowing capacity based on various factors
    const netMonthlyIncome = results.net_annual_income / 12;
    const assessmentRate = Math.max(
        Data['Assessment Rate'],
        Data['Assessment Rate']
    );
    // Determine loan term based on the scenario
    // TODO: Implement logic to determine loan term based on scenario
    const maxLoanTerm = 30; // Default to 30 years

    // Determine interest-only period based on the scenario
    // TODO: Implement logic to determine interest-only period based on scenario
    const maxInterestOnlyPeriod = 5; // Default to 5 years

    // Determine monthly surplus for borrowing capacity based on commitment level
    const monthlySurplusForBorrowingCapacity =
        netMonthlyIncome *
        (1 -
            Data['Sliding Scale Commitment Level']['C.L.'][
                getCommitmentLevelIndex(results.net_annual_income)
            ]);

    const monthlyRepayments = -PMT(
        assessmentRate / 12,
        (maxLoanTerm - maxInterestOnlyPeriod) * 12,
        1
    );
    let maximumBorrowingCapacity =
        (monthlySurplusForBorrowingCapacity - 0) / monthlyRepayments;
    if (
        results.total_existing_repayments + results.total_proposed_repayments >
        0
    ) {
        maximumBorrowingCapacity *=
            1 -
            Data['Sliding Scale Cash Buffer']['C.B.'][
                getCashBufferIndex(
                    results.total_existing_repayments +
                        results.total_proposed_repayments
                )
            ];
    }
    return Math.floor(maximumBorrowingCapacity);
};

/**
 * Get the index for the commitment level based on the provided income.
 *
 * @param income - The annual income.
 * @returns {number} - The index of the commitment level in the 'Data' sheet.
 */
const getCommitmentLevelIndex = (income: number): number => {
    // Find the appropriate income bracket for the commitment level
    for (let i = 0; i < Data['Sliding Scale Commitment Level']['Income'].length; i++) {
        const bracket = Data['Sliding Scale Commitment Level']['Income'][i];
        if (income <= bracket['Upper']) {
            return i;
        }
    }
    // If income exceeds the highest bracket, return the index of the highest bracket
    return Data['Sliding Scale Commitment Level']['Income'].length - 1;
};

/**
 * Get the index for the cash buffer based on the provided total repayments.
 *
 * @param totalRepayments - The total monthly repayments.
 * @returns {number} - The index of the cash buffer in the 'Data' sheet.
 */
const getCashBufferIndex = (totalRepayments: number): number => {
    // Find the appropriate repayment bracket for the cash buffer
    for (let i = 0; i < Data['Sliding Scale Cash Buffer']['Income'].length; i++) {
        const bracket = Data['Sliding Scale Cash Buffer']['Income'][i];
        if (totalRepayments * 12 <= bracket['Upper']) {
            return i;
        }
    }
    // If repayments exceed the highest bracket, return the index of the highest bracket
    return Data['Sliding Scale Cash Buffer']['Income'].length - 1;
};

/**
 * Calculates the payment for a loan based on constant payments and a constant interest rate.
 *
 * @param rate - The interest rate for the loan.
 * @param nper - The total number of payments for the loan.
 * @param pv - The present value, or the total amount that a series of future payments is worth now.
 * @param fv - The future value, or a cash balance you want to attain after the last payment is made. Defaults to 0.
 * @param type - When payments are due: 0 = end of period, 1 = beginning of period. Defaults to 0.
 * @returns {number} - The calculated payment for the loan.
 */
function PMT(rate, nper, pv, fv = 0, type = 0) {
    if (rate === 0) return -(pv + fv) / nper;

    const pvif = Math.pow(1 + rate, nper);
    let pmt = (rate / (pvif - 1)) * -(pv * pvif + fv);

    if (type === 1) pmt /= 1 + rate;

    return pmt;
}

/**
 * Main function to calculate financial results based on a given scenario.
 *
 * @param scenario - The scenario object.
 * @returns {Results} - The calculated results object.
 */
const calculateResults = (scenario: Scenario): Results => {
    // Initialize results object
    let results: Results = {
        income: [],
        net_annual_income: 0,
        liability_repayments: [],
        home_loans: [],
        total_existing_repayments: 0,
        total_proposed_repayments: 0,
        net_cash_position: 0,
        debt_to_income_ratio: 0,
        maximum_borrowing_capacity: 0,
    };

    // Calculate income for each applicant
    scenario.income.forEach((income) => {
        let incomeResults: IncomeResult = {
            gross_annual_income: calculateGrossAnnualIncome(income),
            assessable_annual_income: calculateAssessableAnnualIncome(
                income
            ),
            net_annual_income: 0,
        };
        incomeResults.net_annual_income =
            incomeResults.assessable_annual_income -
            calculateIncomeTax(incomeResults.assessable_annual_income) -
            calculateMedicareLevy(incomeResults.assessable_annual_income) +
            calculateLITO(
                incomeResults.assessable_annual_income,
                calculateIncomeTax(incomeResults.assessable_annual_income)
            ) +
            calculateLMITO(
                incomeResults.assessable_annual_income,
                calculateIncomeTax(incomeResults.assessable_annual_income)
            );
        results.income.push(incomeResults);
        results.net_annual_income += incomeResults.net_annual_income;
    });

    // Calculate liability repayments
    scenario.liabilities.forEach((liability) => {
        let liabilityResult: LiabilityRepaymentResult = {
            total_repayments: calculateLiabilityRepayments(liability),
        };
        results.liability_repayments.push(liabilityResult);
        results.total_existing_repayments += liabilityResult.total_repayments;
    });

    // Calculate home loan repayments
    scenario.home_loans.forEach((homeLoan) => {
        let homeLoanResult: HomeLoanResult = {
            total_repayments: calculateHomeLoanRepayments(homeLoan),
        };
        results.home_loans.push(homeLoanResult);
        if (homeLoan.existing_or_proposed === ExistingOrProposed.Proposed) {
            results.total_proposed_repayments +=
                homeLoanResult.total_repayments;
        } else {
            results.total_existing_repayments +=
                homeLoanResult.total_repayments;
        }
    });

    // Calculate final results
    results.net_cash_position = calculateNetCashPosition(
        results.net_annual_income,
        results.total_existing_repayments,
        results.total_proposed_repayments
    );
    results.debt_to_income_ratio = calculateDebtToIncomeRatio(
        results.total_existing_repayments + results.total_proposed_repayments,
        results.net_annual_income
    );
    results.maximum_borrowing_capacity = calculateMaximumBorrowingCapacity(
        results
    );

    return results;
};

export default calculateResults;
"@ | Out-File -FilePath src\CBACalc.ts -Encoding utf8

# Create a sample test file (CBACalc.test.ts)
@"
// CBACalc.test.ts (Tests the CBA Home Loan Calculator implementation)

import calculateResults from './CBACalc'; # Import the calculator function
import scenarios from './scenarios.json'; # Import test scenarios
import results from './results.json'; # Import expected results

describe('CBA Home Loan Calculator', () => {
    scenarios.forEach((scenario, i) => {
        it(`should calculate results for scenario ${i + 1}`, () => {
            const calculatedResults = calculateResults(scenario); # Run the calculator
            expect(calculatedResults.income[0].gross_annual_income).toBeCloseTo(results[i].income[0].gross_annual_income);
            expect(calculatedResults.income[0].assessable_annual_income).toBeCloseTo(results[i].income[0].assessable_annual_income);
            expect(calculatedResults.income[0].net_annual_income).toBeCloseTo(results[i].income[0].net_annual_income);
            expect(calculatedResults.net_annual_income).toBeCloseTo(results[i].net_annual_income);

            expect(calculatedResults.liability_repayments.length).toBe(results[i].liability_repayments.length);
            calculatedResults.liability_repayments.forEach((liabilityRepayment, j) => {
                expect(liabilityRepayment.total_repayments).toBeCloseTo(results[i].liability_repayments[j].total_repayments);
            });

            expect(calculatedResults.home_loans.length).toBe(results[i].home_loans.length);
            calculatedResults.home_loans.forEach((homeLoan, j) => {
                expect(homeLoan.total_repayments).toBeCloseTo(results[i].home_loans[j].total_repayments);
            });

            expect(calculatedResults.total_existing_repayments).toBeCloseTo(results[i].total_existing_repayments);
            expect(calculatedResults.total_proposed_repayments).toBeCloseTo(results[i].total_proposed_repayments);
            expect(calculatedResults.net_cash_position).toBeCloseTo(results[i].net_cash_position);
            expect(calculatedResults.debt_to_income_ratio).toBeCloseTo(results[i].debt_to_income_ratio);
            expect(calculatedResults.maximum_borrowing_capacity).toBeCloseTo(results[i].maximum_borrowing_capacity);
        });
    });
});
"@ | Out-File -FilePath src\CBACalc.test.ts -Encoding utf8
