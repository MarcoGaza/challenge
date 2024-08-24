// src/types/resultsTypes.ts

export interface IncomeResult {
    gross_annual_income: number; // Calculated gross annual income
    assessable_annual_income: number; // Calculated assessable annual income
    net_annual_income: number; // Calculated net annual income
}

export interface LiabilityRepaymentResult {
    total_repayments: number; // Total monthly liability repayments
}

export interface HomeLoanResult {
    total_repayments: number; // Total monthly home loan repayments
}

// Main results interface combining all the calculated results
export interface Results {
    income: IncomeResult[];
    net_annual_income: number; // Total net annual income of all applicants
    liability_repayments: LiabilityRepaymentResult[];
    home_loans: HomeLoanResult[];
    total_existing_repayments: number; // Total monthly repayments for existing commitments
    total_proposed_repayments: number; // Total monthly repayments for proposed loans
    net_cash_position: number; // Calculated net monthly cash position
    debt_to_income_ratio: number; // Calculated Debt to Income Ratio
    maximum_borrowing_capacity: number; // Calculated maximum borrowing capacity
}
