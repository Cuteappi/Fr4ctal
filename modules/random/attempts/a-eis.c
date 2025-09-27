#include <stdio.h>
#include <stdlib.h>
#include <complex.h> // For complex number support (C99 standard)
#include <math.h>    // For M_PI, cabs, cos, sin
#include <time.h>    // For seeding the random number generator
#include <stdbool.h> // For the bool type

// Define a shorter name for a complex double
typedef double complex cplx;

/**
 * @brief Prints a polynomial in a human-readable format.
 */
void print_polynomial(const cplx coeffs[], int degree) {
    bool first_term = true;
    for (int i = 0; i <= degree; i++) {
        double coeff = creal(coeffs[i]);
        int power = degree - i;

        if (coeff == 0.0) continue;

        if (!first_term) {
            printf(coeff > 0 ? " + " : " - ");
            coeff = fabs(coeff);
        } else {
            if (coeff < 0) {
                printf("-");
                coeff = fabs(coeff);
            }
        }
        
        if (coeff != 1.0 || power == 0) {
            printf("%.2f", coeff);
        }
        
        if (power > 1) {
            printf("x^%d", power);
        } else if (power == 1) {
            printf("x");
        }
        first_term = false;
    }
    printf("\n");
}

/**
 * @brief Evaluates a polynomial at a complex point x using Horner's method.
 */
cplx evaluate_poly(const cplx coeffs[], int degree, cplx x) {
    cplx result = 0;
    for (int i = 0; i <= degree; i++) {
        result = result * x + coeffs[i];
    }
    return result;
}

/**
 * @brief Generates initial guesses for the roots based on the paper's method.
 */
void generate_initial_guesses(const cplx coeffs[], int degree, cplx roots[]) {
    double c_n_abs = cabs(coeffs[0]);
    double c_0_abs = cabs(coeffs[degree]);
    double max_abs_coeffs = 0;
    for (int i = 1; i < degree; i++) {
        if (cabs(coeffs[i]) > max_abs_coeffs) {
            max_abs_coeffs = cabs(coeffs[i]);
        }
    }
    double U = 1.0 + max_abs_coeffs / c_n_abs;
    double V = c_0_abs / (c_0_abs + max_abs_coeffs);
    for (int i = 0; i < degree; i++) {
        double r = V + (double)rand() / RAND_MAX * (U - V);
        double theta = (double)rand() / RAND_MAX * 2.0 * M_PI;
        roots[i] = r * (cos(theta) + I * sin(theta));
    }
}

/**
 * @brief Finds all roots of a polynomial using the Aberth-Ehrlich method.
 */
int aberth_ehrlich_solve(const cplx coeffs[], int degree, cplx roots[], int max_iterations, double tolerance) {
    cplx* deriv_coeffs = (cplx*)malloc(degree * sizeof(cplx));
    for (int i = 0; i < degree; i++) {
        deriv_coeffs[i] = coeffs[i] * (degree - i);
    }
    generate_initial_guesses(coeffs, degree, roots);
    cplx* corrections = (cplx*)malloc(degree * sizeof(cplx));
    int iterations = 0;
    for (iterations = 0; iterations < max_iterations; iterations++) {
        bool all_converged = true;
        for (int i = 0; i < degree; i++) {
            cplx p_val = evaluate_poly(coeffs, degree, roots[i]);
            cplx p_prime_val = evaluate_poly(deriv_coeffs, degree - 1, roots[i]);
            cplx alpha = (p_prime_val != 0) ? p_val / p_prime_val : 0;
            cplx beta = 0;
            for (int j = 0; j < degree; j++) {
                if (i == j) continue;
                beta += 1.0 / (roots[i] - roots[j]);
            }
            cplx denominator = 1.0 - alpha * beta;
            corrections[i] = (denominator != 0) ? alpha / denominator : alpha;
            if (cabs(corrections[i]) > tolerance) {
                all_converged = false;
            }
        }
        for (int i = 0; i < degree; i++) {
            roots[i] -= corrections[i];
        }
        if (all_converged) {
            iterations++;
            break;
        }
    }
    free(deriv_coeffs);
    free(corrections);
    return iterations;
}

/**
 * @brief Prompts the user to change the max iterations value.
 */
void change_max_iterations(int* max_iters_ptr) {
    int new_iters;
    printf("Enter new maximum iterations (current: %d): ", *max_iters_ptr);
    if (scanf("%d", &new_iters) == 1 && new_iters > 0) {
        *max_iters_ptr = new_iters;
        printf("Maximum iterations set to %d.\n", *max_iters_ptr);
    } else {
        printf("Invalid input. Please enter a positive integer.\n");
        while (getchar() != '\n'); // Clear bad input
    }
}


int main() {
    srand(time(NULL));
    int max_iterations = 100; // Default value

    // Variables to store the last user-entered polynomial
    cplx* last_coeffs = NULL;
    int last_degree = 0;

    for (;;) {
        int choice;
        printf("\n--- Polynomial Root Finder Menu ---\n");
        printf("1. Solve a new polynomial\n");
        printf("2. Retry last polynomial\n");
        printf("3. Change max iterations (current: %d)\n", max_iterations);
        printf("4. Exit\n");
        printf("Enter your choice: ");
        
        if (scanf("%d", &choice) != 1) {
            while (getchar() != '\n'); 
            choice = -1;
        }

        switch (choice) {
            case 1: { // Solve a new polynomial
                // Free memory of the previous polynomial before creating a new one
                if (last_coeffs != NULL) {
                    free(last_coeffs);
                    last_coeffs = NULL;
                }

                printf("\nEnter the degree of the new polynomial: ");
                scanf("%d", &last_degree);

                if (last_degree < 1) {
                    printf("Error: Degree must be at least 1.\n");
                    break;
                }

                last_coeffs = (cplx*)malloc((last_degree + 1) * sizeof(cplx));
                if (last_coeffs == NULL) {
                    printf("Error: Memory allocation failed.\n");
                    break;
                }

                printf("Enter coefficients from the highest power down to the constant term.\n");
                for (int i = 0; i <= last_degree; i++) {
                    double real_part;
                    printf("Enter coefficient for x^%d: ", last_degree - i);
                    scanf("%lf", &real_part);
                    last_coeffs[i] = real_part + 0.0 * I;
                }
                // Fall-through to case 2 to solve the newly entered polynomial
            }
            case 2: { // Retry last polynomial
                if (last_coeffs == NULL) {
                    printf("No polynomial has been entered yet. Please choose option 1 first.\n");
                    break;
                }

                cplx* user_roots = (cplx*)malloc(last_degree * sizeof(cplx));
                if (user_roots == NULL) {
                    printf("Error: Memory allocation for roots failed.\n");
                    break;
                }

                printf("\n--- Solving Polynomial ---\n");
                printf("p(x) = ");
                print_polynomial(last_coeffs, last_degree);

                clock_t start_user = clock();
                int iters_user = aberth_ehrlich_solve(last_coeffs, last_degree, user_roots, max_iterations, 1e-15);
                clock_t end_user = clock();
                double time_user = ((double)(end_user - start_user)) / CLOCKS_PER_SEC;

                printf("Converged in %d of %d iterations.\n", iters_user, max_iterations);
                printf("Execution time: %f seconds.\n", time_user);
                printf("Found roots:\n");
                for (int i = 0; i < last_degree; i++) {
                    printf("  %.6f + %.6fi\n", creal(user_roots[i]), cimag(user_roots[i]));
                }
                free(user_roots);
                break;
            }
            case 3: // Change max iterations
                change_max_iterations(&max_iterations);
                break;
            case 4: // Exit
                printf("Exiting application. Goodbye!\n");
                if (last_coeffs != NULL) {
                    free(last_coeffs); // Final cleanup
                }
                return 0;
            default:
                printf("Invalid choice. Please try again.\n");
                break;
        }
    }

    return 0;
}