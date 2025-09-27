// The MIT License
// Copyright © 2024 (Adapted by Gemini)
// Original Quadratic Bezier Shader: Copyright © 2018 Inigo Quilez
//
// This shader demonstrates finding the Signed Distance Function (SDF) to a
// cubic Bézier curve. The core of the method involves solving a quintic
// (degree-5) polynomial to find the closest point on the curve.
//
// The quintic equation is solved numerically using the Aberth-Ehrlich algorithm,
// a powerful method for finding all complex roots of a polynomial simultaneously.
// This implementation is inspired by the paper "Improved Aberth-Ehrlich
// root-finding algorithm" by Fatheddin & Sajadian.

// --- Tunable Parameters ---
#define NUM_ITERATIONS 20   // Iterations for the Aberth-Ehrlich solver. 10-15 is usually sufficient.
#define TOLERANCE 1e-5      // Tolerance for considering a complex root as real (imaginary part near zero).


//====================================================================
// Utility and Basic Math Functions
//====================================================================

float dot2(vec2 v) { return dot(v, v); }
float cro(vec2 a, vec2 b) { return a.x * b.y - a.y * b.x; }

// Simple pseudo-random number generator for initial guesses
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

//====================================================================
// Complex Number Operations (represented as vec2)
//====================================================================

// Complex addition: (a.x+a.y*i) + (b.x+b.y*i)
vec2 cadd(vec2 a, vec2 b) { return a + b; }

// Complex subtraction: (a.x+a.y*i) - (b.x+b.y*i)
vec2 csub(vec2 a, vec2 b) { return a - b; }

// Complex multiplication: (a.x+a.y*i) * (b.x+b.y*i)
vec2 cmul(vec2 a, vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

// Complex division: (a.x+a.y*i) / (b.x+b.y*i)
vec2 cdiv(vec2 a, vec2 b) {
    float d = dot(b, b);
    // Return a large number on division by zero to prevent instability
    if (d < 1e-15) return vec2(1e10, 1e10);
    return vec2(dot(a, b), a.y * b.x - a.x * b.y) / d;
}


//====================================================================
// Polynomial Evaluation (using Horner's method)
//====================================================================

// Evaluates a polynomial with complex coefficients at a complex point z.
// Coeffs are ordered from highest degree to lowest.
vec2 evaluate_poly(const vec2 coeffs[6], vec2 z) {
    vec2 res = coeffs[0];
    for (int i = 1; i < 6; i++) {
        res = cadd(cmul(res, z), coeffs[i]);
    }
    return res;
}

// Evaluates the derivative of the polynomial.
vec2 evaluate_poly_deriv(const vec2 coeffs[6], vec2 z) {
    vec2 five = vec2(5.0, 0.0);
    vec2 four = vec2(4.0, 0.0);
    vec2 three = vec2(3.0, 0.0);
    vec2 two = vec2(2.0, 0.0);

    vec2 res = cmul(five, coeffs[0]);
    res = cadd(cmul(res, z), cmul(four, coeffs[1]));
    res = cadd(cmul(res, z), cmul(three, coeffs[2]));
    res = cadd(cmul(res, z), cmul(two, coeffs[3]));
    res = cadd(cmul(res, z), coeffs[4]);
    return res;
}


//====================================================================
// Aberth-Ehrlich Quintic Solver
//====================================================================

// Finds all 5 complex roots of a quintic polynomial.
void solve_quintic(const vec2 coeffs[6], inout vec2 roots[5]) {
    // --- 1. Generate Initial Guesses (based on the paper) ---
    // Calculate U (upper bound) and V (lower bound) for root magnitudes.
    float c_n_abs = length(coeffs[0]);
    float c_0_abs = length(coeffs[5]);

    float max_abs_coeffs = 0.0;
    for (int i = 1; i < 5; i++) {
        max_abs_coeffs = max(max_abs_coeffs, length(coeffs[i]));
    }
    
    // Add small epsilon to prevent division by zero
    c_n_abs += 1e-9;
    
    float U = 1.0 + max_abs_coeffs / c_n_abs;
    float V = c_0_abs / (c_0_abs + max_abs_coeffs + 1e-9);

    // Generate 5 random complex numbers within the U/V annulus.
    for (int i = 0; i < 5; i++) {
        float r = V + rand(vec2(float(i)*1.73, float(i)*2.61)) * (U - V);
        float theta = rand(vec2(float(i)*3.14, float(i)*1.59)) * 6.283185;
        roots[i] = vec2(r * cos(theta), r * sin(theta));
    }

    // --- 2. Main Aberth-Ehrlich Iteration Loop ---
    vec2 corrections[5];
    for (int i = 0; i < NUM_ITERATIONS; i++) {
        // --- Calculate corrections in parallel (explicitly unrolled loop) ---
        // Each of these 5 blocks is independent and can be run simultaneously.
        
        // Root 0
        vec2 p_val0 = evaluate_poly(coeffs, roots[0]);
        vec2 p_prime_val0 = evaluate_poly_deriv(coeffs, roots[0]);
        vec2 alpha0 = cdiv(p_val0, p_prime_val0);
        vec2 beta0 = cdiv(vec2(1.0,0.0),csub(roots[0],roots[1])) + cdiv(vec2(1.0,0.0),csub(roots[0],roots[2])) + cdiv(vec2(1.0,0.0),csub(roots[0],roots[3])) + cdiv(vec2(1.0,0.0),csub(roots[0],roots[4]));
        corrections[0] = cdiv(alpha0, csub(vec2(1.0,0.0), cmul(alpha0, beta0)));

        // Root 1
        vec2 p_val1 = evaluate_poly(coeffs, roots[1]);
        vec2 p_prime_val1 = evaluate_poly_deriv(coeffs, roots[1]);
        vec2 alpha1 = cdiv(p_val1, p_prime_val1);
        vec2 beta1 = cdiv(vec2(1.0,0.0),csub(roots[1],roots[0])) + cdiv(vec2(1.0,0.0),csub(roots[1],roots[2])) + cdiv(vec2(1.0,0.0),csub(roots[1],roots[3])) + cdiv(vec2(1.0,0.0),csub(roots[1],roots[4]));
        corrections[1] = cdiv(alpha1, csub(vec2(1.0,0.0), cmul(alpha1, beta1)));

        // Root 2
        vec2 p_val2 = evaluate_poly(coeffs, roots[2]);
        vec2 p_prime_val2 = evaluate_poly_deriv(coeffs, roots[2]);
        vec2 alpha2 = cdiv(p_val2, p_prime_val2);
        vec2 beta2 = cdiv(vec2(1.0,0.0),csub(roots[2],roots[0])) + cdiv(vec2(1.0,0.0),csub(roots[2],roots[1])) + cdiv(vec2(1.0,0.0),csub(roots[2],roots[3])) + cdiv(vec2(1.0,0.0),csub(roots[2],roots[4]));
        corrections[2] = cdiv(alpha2, csub(vec2(1.0,0.0), cmul(alpha2, beta2)));
        
        // Root 3
        vec2 p_val3 = evaluate_poly(coeffs, roots[3]);
        vec2 p_prime_val3 = evaluate_poly_deriv(coeffs, roots[3]);
        vec2 alpha3 = cdiv(p_val3, p_prime_val3);
        vec2 beta3 = cdiv(vec2(1.0,0.0),csub(roots[3],roots[0])) + cdiv(vec2(1.0,0.0),csub(roots[3],roots[1])) + cdiv(vec2(1.0,0.0),csub(roots[3],roots[2])) + cdiv(vec2(1.0,0.0),csub(roots[3],roots[4]));
        corrections[3] = cdiv(alpha3, csub(vec2(1.0,0.0), cmul(alpha3, beta3)));

        // Root 4
        vec2 p_val4 = evaluate_poly(coeffs, roots[4]);
        vec2 p_prime_val4 = evaluate_poly_deriv(coeffs, roots[4]);
        vec2 alpha4 = cdiv(p_val4, p_prime_val4);
        vec2 beta4 = cdiv(vec2(1.0,0.0),csub(roots[4],roots[0])) + cdiv(vec2(1.0,0.0),csub(roots[4],roots[1])) + cdiv(vec2(1.0,0.0),csub(roots[4],roots[2])) + cdiv(vec2(1.0,0.0),csub(roots[4],roots[3]));
        corrections[4] = cdiv(alpha4, csub(vec2(1.0,0.0), cmul(alpha4, beta4)));


        // --- Synchronize and apply corrections simultaneously ---
        roots[0] = csub(roots[0], corrections[0]);
        roots[1] = csub(roots[1], corrections[1]);
        roots[2] = csub(roots[2], corrections[2]);
        roots[3] = csub(roots[3], corrections[3]);
        roots[4] = csub(roots[4], corrections[4]);
    }
}


//====================================================================
// Signed Distance Function for Cubic Bezier
//====================================================================

float sdCubicBezier(vec2 pos, vec2 A, vec2 B, vec2 C, vec2 D, out vec2 outQ) {
    // --- 1. Express Bezier in power basis: c3*t^3 + c2*t^2 + c1*t + c0 ---
    vec2 c3 = -A + 3.0*(B - C) + D;
    vec2 c2 = 3.0*(A - 2.0*B + C);
    vec2 c1 = 3.0*(B - A);
    vec2 d = A - pos; // Vector from point to curve start (c0-pos)

    // --- 2. Form the quintic polynomial: k5*t^5 + ... + k0 = 0 ---
    // This comes from expanding dot( B(t)-pos, B'(t) ) = 0
    vec2 coeffs[6];
    coeffs[0] = vec2(3.0 * dot(c3, c3), 0.0);
    coeffs[1] = vec2(5.0 * dot(c3, c2), 0.0);
    coeffs[2] = vec2(4.0 * dot(c3, c1) + 2.0 * dot(c2, c2), 0.0);
    coeffs[3] = vec2(3.0 * dot(c2, c1) + 3.0 * dot(c3, d), 0.0);
    coeffs[4] = vec2(dot(c1, c1) + 2.0 * dot(c2, d), 0.0);
    coeffs[5] = vec2(dot(c1, d), 0.0);
    
    // Normalize coefficients to improve numerical stability for the solver
    float maxCoeff = 0.0001;
    for(int i=0; i<6; i++) maxCoeff = max(maxCoeff, abs(coeffs[i].x));
    for(int i=0; i<6; i++) coeffs[i] /= maxCoeff;


    // --- 3. Solve the quintic polynomial for t ---
    vec2 roots[5];
    solve_quintic(coeffs, roots);

    // --- 4. Find the best real root in [0,1] ---
    float minDist2 = -1.0;
    float best_t = -1.0;

    for (int i = 0; i < 5; i++) {
        // We only care about real roots (imaginary part is close to zero)
        if (abs(roots[i].y) < TOLERANCE) {
            float t = roots[i].x;
            t = clamp(t, 0.0, 1.0); // Clamp to the bezier segment

            vec2 p_on_curve = ((c3 * t + c2) * t + c1) * t + A;
            float dist2 = dot2(p_on_curve - pos);

            if (minDist2 < 0.0 || dist2 < minDist2) {
                minDist2 = dist2;
                best_t = t;
            }
        }
    }
    
    // Fallback: check endpoints if no valid root was found
    float dA = dot2(A-pos);
    if (minDist2 < 0.0 || dA < minDist2) {
        minDist2 = dA;
        best_t = 0.0;
    }
    float dD = dot2(D-pos);
    if (dD < minDist2) {
        minDist2 = dD;
        best_t = 1.0;
    }


    // --- 5. Calculate final signed distance ---
    vec2 p_closest = ((c3 * best_t + c2) * best_t + c1) * best_t + A;
    outQ = p_closest; // Output the closest point
    
    vec2 tangent = (3.0*c3*best_t + 2.0*c2)*best_t + c1;
    
    float dist = sqrt(minDist2);
    float sgn = sign(cro(tangent, p_closest - pos));
    
    // If tangent is zero (at a cusp), sign can be ambiguous.
    // We can leave it as is or handle it, but for most cases this works.
    if (dot2(tangent) < 1e-8) sgn = 1.0;

    return dist * sgn;
}


//====================================================================
// Main Image Rendering
//====================================================================

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 p = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    vec2 m = (2.0 * iMouse.xy - iResolution.xy) / iResolution.y;

    // Animated control points for the cubic Bézier curve
    vec2 v0 = 1.2 * cos(iTime * 0.5 + vec2(0.0, 1.5));
    vec2 v1 = 1.5 * cos(iTime * 0.9 + vec2(1.0, 0.5));
    vec2 v2 = 1.5 * cos(iTime * 0.7 + vec2(2.0, 2.5));
    vec2 v3 = 1.2 * cos(iTime * 0.5 + vec2(3.0, 0.0));

    // Calculate signed distance
    vec2 closestPoint;
    float d = sdCubicBezier(p, v0, v1, v2, v3, closestPoint);

    // Coloring based on distance
    vec3 col = (d > 0.0) ? vec3(0.9, 0.6, 0.3) : vec3(0.65, 0.85, 1.0);
    col *= 1.0 - exp(-5.0 * abs(d));
    col *= 0.8 + 0.2 * cos(120.0 * d);
    col = mix(col, vec3(1.0), 1.0 - smoothstep(0.0, 0.015, abs(d)));

    // Visualize control polygon
    if( cos(0.5*iTime) < -0.5 ) {
        float l_d = 1e10;
        l_d = min(l_d, distance(p,v0));
        l_d = min(l_d, distance(p,v1));
        l_d = min(l_d, distance(p,v2));
        l_d = min(l_d, distance(p,v3));
        col = mix( col, vec3(1,0,0), 1.0-smoothstep(0.0,0.02,l_d-0.01) );
    }

    // Visualize closest point and distance circle for mouse position
    if (iMouse.z > 0.001) {
        vec2 q;
        float md = sdCubicBezier(m, v0, v1, v2, v3, q);
        col = mix(col, vec3(1.0, 1.0, 0.0), 1.0 - smoothstep(0.0, 0.005, abs(length(p - m) - abs(md)) - 0.0025));
        col = mix(col, vec3(1.0, 1.0, 0.0), 1.0 - smoothstep(0.0, 0.005, length(p - m) - 0.015));
        col = mix(col, vec3(1.0, 1.0, 0.0), 1.0 - smoothstep(0.0, 0.005, length(p - q) - 0.015));
    }

    fragColor = vec4(col, 1.0);
}
