#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>

#define MAX_ITER_SAFEGUARD 200
#define CONVERGENCE_WINDOW 30
#define CONVERGENCE_TOLERANCE 1e-6

typedef struct { double real; double imag; } Complex;
typedef struct { double a4, a3, a2, a1, a0; } QuinticPolynomial;
typedef enum { CONVERGED, OSCILLATING, UNKNOWN } ConvStatus;

void solve(QuinticPolynomial poly, Complex roots[5]);
void generate_p1_sequence(QuinticPolynomial poly, double* p1);
void generate_p_other_sequences(const double* p1, QuinticPolynomial poly, double* p2, double* p3, double* p4, double* p5);
ConvStatus analyze_convergence(const double* seq);
void calculate_limits(const double* p1, const double* p2, const double* p3, const double* p4, const double* p5, double L[5]);
void solve_all_real(const double L[5], Complex roots[5]);
void solve_two_complex_pairs(QuinticPolynomial poly, const double L[5], const double* p1, Complex roots[5]);
void print_roots(const Complex roots[5]);

int main() {
    Complex roots[5] = {0};

    printf("--- Solving Polynomial 1 (All Real Roots) ---\n");
    QuinticPolynomial poly1 = {0.3, -13.29, 2.393, 29.064, -17.199};
    solve(poly1, roots);
    print_roots(roots);
    printf("\n------------------------------------------------\n\n");

    printf("--- Solving Polynomial 2 (Degen-Abel, Complex Roots) ---\n");
    QuinticPolynomial poly2 = {-2, -13, 2, 29, -17};
    solve(poly2, roots);
    print_roots(roots);

    return 0;
}

void solve(QuinticPolynomial poly, Complex roots[5]) {
    double *p1 = (double *)calloc(3 * MAX_ITER_SAFEGUARD + 1, sizeof(double));
    double *p2 = (double *)calloc(MAX_ITER_SAFEGUARD + 1, sizeof(double));
    double *p3 = (double *)calloc(MAX_ITER_SAFEGUARD + 1, sizeof(double));
    double *p4 = (double *)calloc(MAX_ITER_SAFEGUARD + 1, sizeof(double));
    double *p5 = (double *)calloc(MAX_ITER_SAFEGUARD + 1, sizeof(double));

    generate_p1_sequence(poly, p1);
    generate_p_other_sequences(p1, poly, p2, p3, p4, p5);
    
    ConvStatus status[4] = {
        analyze_convergence(p1), analyze_convergence(p2),
        analyze_convergence(p3), analyze_convergence(p4)
    };
    
    double L[5];
    calculate_limits(p1, p2, p3, p4, p5, L);
    
    printf("Convergence Analysis:\n P_I: %s, P_II: %s, P_III: %s, P_IV: %s\n\n", 
           status[0] == CONVERGED ? "Converged" : "Oscillating", status[1] == CONVERGED ? "Converged" : "Oscillating",
           status[2] == CONVERGED ? "Converged" : "Oscillating", status[3] == CONVERGED ? "Converged" : "Oscillating");

    if (status[0] == CONVERGED && status[1] == CONVERGED && status[2] == CONVERGED && status[3] == CONVERGED) {
        printf("Method: All real roots.\n\n");
        solve_all_real(L, roots);
    } else if (status[0] == OSCILLATING && status[1] == CONVERGED) {
        printf("Method: Two pairs of complex roots (Degen-Abel type).\n\n");
        solve_two_complex_pairs(poly, L, p1, roots);
    } else {
        printf("Method: Unhandled or ambiguous case.\n\n");
    }

    free(p1); free(p2); free(p3); free(p4); free(p5);
}

// CORRECTED sequence generation using standard Newton's Sums
void generate_p1_sequence(QuinticPolynomial poly, double* p1) {
    // Initial values (k <= n) using correct Newton's Sums
    p1[0] = 5.0; // By definition
    p1[1] = -poly.a4;
    p1[2] = -(poly.a4 * p1[1] + 2 * poly.a3);
    p1[3] = -(poly.a4 * p1[2] + poly.a3 * p1[1] + 3 * poly.a2);
    p1[4] = -(poly.a4 * p1[3] + poly.a3 * p1[2] + poly.a2 * p1[1] + 4 * poly.a1);
    p1[5] = -(poly.a4 * p1[4] + poly.a3 * p1[3] + poly.a2 * p1[2] + poly.a1 * p1[1] + 5 * poly.a0);

    // Recurrence for k > n
    for (int n = 6; n < 3 * MAX_ITER_SAFEGUARD + 1; ++n) {
        p1[n] = -(poly.a4 * p1[n-1] + poly.a3 * p1[n-2] + poly.a2 * p1[n-3] + poly.a1 * p1[n-4] + poly.a0 * p1[n-5]);
    }
}

void generate_p_other_sequences(const double* p1, QuinticPolynomial poly, double* p2, double* p3, double* p4, double* p5) {
    double *p1_neg = (double *)calloc(MAX_ITER_SAFEGUARD + 1, sizeof(double));
    if (fabs(poly.a0) > 1e-9) {
        // Recurrence for P_I(-n) must also use standard coefficients
        double k0 = -poly.a0; double k1 = poly.a1; double k2 = -poly.a2; double k3 = poly.a3; double k4 = -poly.a4;
        p1_neg[0] = p1[0];
        p1_neg[1] = (p1[4] - k4*p1[3] - k3*p1[2] - k2*p1[1] - k1*p1[0]) / k0;
        p1_neg[2] = (p1[3] - k4*p1[2] - k3*p1[1] - k2*p1[0] - k1*p1_neg[1]) / k0;
        p1_neg[3] = (p1[2] - k4*p1[1] - k3*p1[0] - k2*p1_neg[1] - k1*p1_neg[2]) / k0;
        p1_neg[4] = (p1[1] - k4*p1[0] - k3*p1_neg[1] - k2*p1_neg[2] - k1*p1_neg[3]) / k0;
        for (int n = 5; n < MAX_ITER_SAFEGUARD + 1; ++n) {
           p1_neg[n] = (p1_neg[n-5] - k4*p1_neg[n-4] - k3*p1_neg[n-3] - k2*p1_neg[n-2] - k1*p1_neg[n-1]) / k0;
        }
    }

    for (int n = 0; n < MAX_ITER_SAFEGUARD + 1; ++n) {
        p2[n] = (p1[n] * p1[n] - p1[2*n]) / 2.0;
        p3[n] = (pow(p1[n], 3) - 3.0 * p1[n] * p1[2*n] + 2.0 * p1[3*n]) / 6.0;
        p5[n] = pow(-poly.a0, n); // e5 = -a0
        p4[n] = p1_neg[n] * p5[n];
    }
    free(p1_neg);
}

ConvStatus analyze_convergence(const double* seq) {
    int start_n = MAX_ITER_SAFEGUARD - CONVERGENCE_WINDOW;
    double prev_ratio;
    if (fabs(seq[start_n - 2]) < 1e-30) return OSCILLATING;
    prev_ratio = seq[start_n - 1] / seq[start_n - 2];

    for (int i = 0; i < CONVERGENCE_WINDOW; ++i) {
        int n = start_n + i;
        if (fabs(seq[n-1]) < 1e-30) return OSCILLATING;
        double current_ratio = seq[n] / seq[n-1];
        if (fabs(prev_ratio) > 1e-20) {
            if (fabs(current_ratio - prev_ratio) / fabs(prev_ratio) > CONVERGENCE_TOLERANCE) return OSCILLATING;
        } else {
            if (fabs(current_ratio - prev_ratio) > 1e-9) return OSCILLATING;
        }
        prev_ratio = current_ratio;
    }
    return CONVERGED;
}

void calculate_limits(const double* p1, const double* p2, const double* p3, const double* p4, const double* p5, double L[5]) {
    int i = MAX_ITER_SAFEGUARD - 1;
    L[0] = p1[i] / p1[i-1]; L[1] = p2[i] / p2[i-1]; L[2] = p3[i] / p3[i-1];
    L[3] = p4[i] / p4[i-1]; L[4] = p5[i] / p5[i-1];
}

void solve_all_real(const double L[5], Complex roots[5]) {
    roots[0] = (Complex){L[0], 0}; roots[1] = (Complex){L[1] / L[0], 0};
    roots[2] = (Complex){L[2] / L[1], 0}; roots[3] = (Complex){L[3] / L[2], 0};
    roots[4] = (Complex){L[4] / L[3], 0};
}

void solve_two_complex_pairs(QuinticPolynomial poly, const double L[5], const double* p1, Complex roots[5]) {
    double rho1_sq = L[1]; double p = L[2] / L[1]; double rho2_sq = L[4] / L[2];
    roots[0] = (Complex){p, 0};
    
    // Use P_I(1) and P_I(2) from the correctly generated sequence
    double P1_1 = p1[1]; double P1_2 = p1[2];

    double term_under_sqrt = (P1_1 - p)*(P1_1 - p) - 2 * (P1_1*P1_1 - P1_2 - 2*P1_1*p + 2*p*p - 2*rho1_sq - 2*rho2_sq);
    if (term_under_sqrt < 0) term_under_sqrt = 0;

    double a1 = (P1_1 - p + sqrt(term_under_sqrt)) / 4.0;
    double a2 = (P1_1 - p - sqrt(term_under_sqrt)) / 4.0;
    double b1_sq = rho1_sq - a1*a1; double b2_sq = rho2_sq - a2*a2;
    double b1 = (b1_sq > 0) ? sqrt(b1_sq) : 0; double b2 = (b2_sq > 0) ? sqrt(b2_sq) : 0;

    roots[1] = (Complex){a1, b1}; roots[2] = (Complex){a1, -b1};
    roots[3] = (Complex){a2, b2}; roots[4] = (Complex){a2, -b2};
}

void print_roots(const Complex roots[5]) {
    printf("Calculated Roots:\n");
    for (int i = 0; i < 5; ++i) {
        if (fabs(roots[i].imag) < 1e-9) {
            printf(" p%d: %.12f\n", i + 1, roots[i].real);
        } else {
            printf(" p%d: %.12f +/- %.12fi\n", i + 1, roots[i].real, fabs(roots[i].imag));
            i++; 
        }
    }
}