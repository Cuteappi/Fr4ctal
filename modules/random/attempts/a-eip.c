
#include <stdio.h>
#include <stdlib.h>
#include <complex.h> // For complex number support (C99 standard)
#include <math.h>    // For M_PI, cabs, cos, sin
#include <time.h>    // For seeding the random number generator
#include <stdbool.h> // For the bool type
#include <omp.h>     // Include the OpenMP library header

// Define a shorter name for a complex double
typedef double complex cplx;

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
    // Calculate the upper (U) and lower (V) bounds for the root magnitudes
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
    // Calculate Derivative Coefficients
    cplx* deriv_coeffs = (cplx*)malloc(degree * sizeof(cplx));
    for (int i = 0; i < degree; i++) {
        deriv_coeffs[i] = coeffs[i] * (degree - i);
    }

    // Generate Initial Guesses
    generate_initial_guesses(coeffs, degree, roots);

    // Main Iteration Loop
    cplx* corrections = (cplx*)malloc(degree * sizeof(cplx));
    int iterations = 0;
    for (iterations = 0; iterations < max_iterations; iterations++) {
        bool all_converged = true;

        // This pragma tells OpenMP to parallelize the following for-loop.
        // The work of calculating corrections for each root is split among threads.
        // The reduction clause safely handles the update of 'all_converged'.
        #pragma omp parallel for reduction(&&:all_converged)
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
        
        // This loop can also be parallelized as each update is independent.
        #pragma omp parallel for
        for (int i = 0; i < degree; i++) {
            roots[i] -= corrections[i];
        }

        if (all_converged) {
            iterations++;
            break;
        }
    }

    // Clean up allocated memory
    free(deriv_coeffs);
    free(corrections);

    return iterations;
}

int main() {
    srand(time(NULL));

    // You can set the number of threads OpenMP should use
    // omp_set_num_threads(4); // Example: use 4 threads

    // --- Polynomial 1: p(x) = x^4 - 5x^2 + 4 ---
    int degree1 = 4;
    cplx coeffs1[] = {1, 0, -5, 0, 4};
    cplx roots1[degree1];

    printf("--- Solving Polynomial 1: x^4 - 5x^2 + 4 ---\n");
    double start1 = omp_get_wtime(); // Use OpenMP's timer
    int iters1 = aberth_ehrlich_solve(coeffs1, degree1, roots1, 100, 1e-15);
    double end1 = omp_get_wtime();
    
    printf("Converged in %d iterations.\n", iters1);
    printf("Execution time: %f seconds.\n", end1 - start1);
    printf("Found roots:\n");
    for (int i = 0; i < degree1; i++) {
        printf("  %.6f + %.6fi\n", creal(roots1[i]), cimag(roots1[i]));
    }
    printf("----------------------------------------\n\n");

    // --- Polynomial 2: A higher degree polynomial for a better test ---
    int degree2 = 12;
    cplx coeffs2[degree2 + 1];
    for(int i = 0; i <= degree2; ++i) { // (x-1)(x-2)...(x-12)
        coeffs2[i] = (double)rand() / RAND_MAX;
    }
    cplx roots2[degree2];

    printf("--- Solving Polynomial 2: Random 12th degree ---\n");
    double start2 = omp_get_wtime();
    int iters2 = aberth_ehrlich_solve(coeffs2, degree2, roots2, 200, 1e-15);
    double end2 = omp_get_wtime();
    
    printf("Converged in %d iterations.\n", iters2);
    printf("Execution time: %f seconds.\n", end2 - start2);
    // printf("Found roots:\n"); // Omitted for brevity
    printf("----------------------------------------\n\n");

    return 0;
}