// The MIT License
// Copyright © 2024 (Adapted by Gemini)
//
// This shader demonstrates a fast, approximate method for finding the Signed
// Distance Function (SDF) to a cubic Bézier curve.
//
// Instead of solving the full quintic polynomial to find the mathematically
// exact closest point, this version uses a few steps of a binary search
// (or gradient descent) to find a very good approximation. This is
// significantly faster and simpler, making it more suitable for real-time use,
// with the trade-off of losing perfect accuracy in some complex cases.

// --- Tunable Parameters ---
#define NUM_STEPS 100 // Number of refinement steps. 6-8 is usually enough.


//====================================================================
// Utility and Basic Math Functions
//====================================================================

float dot2(vec2 v) { return dot(v, v); }
float cro(vec2 a, vec2 b) { return a.x * b.y - a.y * b.x; }


//====================================================================
// Signed Distance Function for Cubic Bezier (Approximate)
//====================================================================

// Helper function to evaluate the quintic polynomial F(t) = dot(B(t)-pos, B'(t)).
// This is the derivative of the squared distance, and we search for its root.
float getQuinticValue(float t, vec2 pos, vec2 A, vec2 c1, vec2 c2, vec2 c3) {
    // Evaluate B(t) - pos
    vec2 p_on_curve_offset = ((c3 * t + c2) * t + c1) * t + A - pos;
    // Evaluate B'(t)
    vec2 tangent = (3.0*c3*t + 2.0*c2)*t + c1;
    return dot(p_on_curve_offset, tangent);
}

// Helper function to run the iterative search for a root starting from a given 't'
float findBestT(float t_start, vec2 pos, vec2 A, vec2 c1, vec2 c2, vec2 c3) {
    float t = t_start;
    float step = 0.25; // Initial step size, gets refined

    for(int i=0; i<NUM_STEPS; i++) {
        float f_val = getQuinticValue(t, pos, A, c1, c2, c3);
        // Bisection method step. We only care about the sign of the derivative.
        // This is much more stable than using the value, as it can't overshoot.
        t -= sign(f_val) * step;
        t = clamp(t, 0.0, 1.0);
        step *= 0.5; // Reduce step size for refinement
    }
    return t;
}


float sdCubicBezier(vec2 pos, vec2 A, vec2 B, vec2 C, vec2 D, out vec2 outQ) {
    // --- 1. Express Bezier in power basis: c3*t^3 + c2*t^2 + c1*t + c0 ---
    vec2 c3 = -A + 3.0*(B - C) + D;
    vec2 c2 = 3.0*(A - 2.0*B + C);
    vec2 c1 = 3.0*(B - A);
    // c0 is A

    // --- 2. Find best 't' by searching from multiple start points ---
    // A quintic can have up to 3 real roots, so we check 3 start points to be robust.
    float t1 = findBestT(0.15, pos, A, c1, c2, c3);
    float t2 = findBestT(0.50, pos, A, c1, c2, c3);
    float t3 = findBestT(0.85, pos, A, c1, c2, c3);

    // Compare the results to find the truly closest point
    vec2 p1 = ((c3 * t1 + c2) * t1 + c1) * t1 + A;
    float dist1_sq = dot2(p1 - pos);

    vec2 p2 = ((c3 * t2 + c2) * t2 + c1) * t2 + A;
    float dist2_sq = dot2(p2 - pos);

    vec2 p3 = ((c3 * t3 + c2) * t3 + c1) * t3 + A;
    float dist3_sq = dot2(p3 - pos);
    
    float best_t;
    if (dist1_sq < dist2_sq && dist1_sq < dist3_sq) {
        best_t = t1;
    } else if (dist2_sq < dist3_sq) {
        best_t = t2;
    } else {
        best_t = t3;
    }

    // --- 3. Calculate final signed distance from the found 't' ---
    vec2 p_closest = ((c3 * best_t + c2) * best_t + c1) * best_t + A;
    outQ = p_closest; // Output the closest point

    vec2 tangent = (3.0*c3*best_t + 2.0*c2)*best_t + c1;
    
    float dist2 = dot2(p_closest - pos);
    
    // Fallback: check endpoints just in case the search failed
    dist2 = min(dist2, dot2(A-pos));
    dist2 = min(dist2, dot2(D-pos));
    
    float dist = sqrt(dist2);
    float sgn = sign(cro(tangent, p_closest - pos));
    
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

