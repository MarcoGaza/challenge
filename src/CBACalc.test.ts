// CBACalc.test.ts (Tests the CBA Home Loan Calculator implementation)

import calculateResults from './CBACalc'; // Import the calculator function
import scenarios from './scenarios.csv'; // Import test scenarios
import results from './results.json'; // Import expected results

describe('CBA Home Loan Calculator', () => {
    scenarios.forEach((scenario, i) => {
        it(should calculate results for scenario , () => {
            const calculatedResults = calculateResults(scenario); // Run the calculator
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
