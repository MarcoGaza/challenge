// src/CBACalc.ts
import { isEmpty, set } from "lodash";
import Data from './Data.csv';

// Import scenario interface
import { Scenario, LoanType, ExistingOrProposed, HomeLoan, Income, Liability } from "./types/types";
// Import results interface
import { Results, IncomeResult, LiabilityRepaymentResult, HomeLoanResult } from "./types/resultsTypes";
import { type } from "os";

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
            throw new Error(Unknown liability type: );
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
            throw new Error(Unknown home loan product type: );
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
