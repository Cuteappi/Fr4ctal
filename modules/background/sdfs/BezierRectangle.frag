#version 440

// The MIT License
// Copyright © 2024 (Adapted by Gemini)
// Original Bezier SDF and Gem Shape Shader: Copyright © 2018 Inigo Quilez

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 u_resolution;
    // Define the rectangle by two opposite corner points instead of size
    vec2 u_start_point;
    vec2 u_end_point;
    float u_radius;       // The corner radius, now a normalized value (0.0 to 1.0)
    float u_strength;     // The rounding strength (handle offset)
    float u_smoothness;   // The smoothness of the shape
    bool u_inverted;
} ubuf;

// --- Tunable Parameters ---
#define ITERATIONS 1 // Iterations for the Newton's method refinement.

//====================================================================
// Utility and Basic Math Functions
//====================================================================

float dot2(vec2 v) {
    return dot(v, v);
}

float cro(vec2 a, vec2 b) {
    return a.x * b.y - a.y * b.x;
}

//====================================================================
// Complex Number Operations
//====================================================================

vec2 cmul(vec2 a, vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 conj(vec2 c) {
    return vec2(c.x, -c.y);
}

vec2 cdiv(vec2 a, vec2 b) {
    float d = dot(b,b);
    if (d < 1e-15) return vec2(1e10, 1e10);
    return cmul(a, conj(b)) / d;
}

vec2 cexp(vec2 c) {
    return exp(c.x) * vec2(cos(c.y), sin(c.y));
}

vec2 cln(vec2 c) {
    return vec2(log(dot(c, c)) * 0.5, atan(c.y, c.x));
}

vec2 csqrt(vec2 a) {
    float r = length(a);
    if ((a.y + a.x) - a.x == 0.0) {
        return a.x >= 0.0 ? vec2(sqrt(r), 0.0) : vec2(0.0, sqrt(r));
    }
    vec2 h = a / r + vec2(1.0, 0.0);
    return h * sqrt(r / dot(h, h));
}

vec2 ccbrt(vec2 a) {
    return cexp(cln(a) / 3.0);
}

//====================================================================
// Polynomial Solver and Refinement
//====================================================================

void cubic_roots(vec2 a, vec2 b, vec2 c, vec2 d, out vec2 x0, out vec2 x1, out vec2 x2) {
    if (dot(a, a) < 1e-14) {
        if (dot(b, b) < 1e-14) {
            x0 = cdiv(-d, c);
            x1 = x2 = vec2(1e10);
            return;
        }
        vec2 delta = csqrt(cmul(c, c) - 4.0 * cmul(b, d));
        vec2 two_b = 2.0 * b;
        x0 = cdiv(-c + delta, two_b);
        x1 = cdiv(-c - delta, two_b);
        x2 = vec2(1e10);
        return;
    }
    vec2 ac = cmul(a, c);
    vec2 bb = cmul(b, b);
    vec2 aa = cmul(a, a);
    vec2 d0 = bb - 3.0 * ac;
    vec2 d1 = 2.0 * cmul(b, bb) - 9.0 * cmul(ac, b) + 27.0 * cmul(aa, d);
    vec2 s = csqrt(cmul(d1, d1) - 4.0 * cmul(cmul(d0, d0), d0));
    vec2 opta = d1 - s;
    vec2 optb = d1 + s;
    vec2 opt = dot(opta, opta) < dot(optb, optb) ? optb : opta;
    vec2 cb = ccbrt(opt * 0.5);
    if (dot(cb, cb) < 1e-14) {
        x0 = x1 = x2 = cdiv(-b, 3.0 * a);
        return;
    }
    x0 = cdiv(b + cb + cdiv(d0, cb), -3.0 * a);
    vec2 root = vec2(-0.5, 0.866025403784439);
    cb = cmul(cb, root);
    x1 = cdiv(b + cb + cdiv(d0, cb), -3.0 * a);
    cb = cmul(cb, root);
    x2 = cdiv(b + cb + cdiv(d0, cb), -3.0 * a);
}

float newton_quintic(float a, float b, float c, float d, float e, float f, float x0) {
    float v = ((((a * x0 + b) * x0 + c) * x0 + d) * x0 + e) * x0 + f;
    float dv = (((5.0 * a * x0 + 4.0 * b) * x0 + 3.0 * c) * x0 + 2.0 * d) * x0 + e;
    if (abs(dv) < 1e-9) return x0;
    float ddv = ((20.0 * a * x0 + 12.0 * b) * x0 + 6.0 * c) * x0 + 2.0 * d;
    float p = dv / ddv;
    float q = v / ddv * 2.0;
    float dx = p - sqrt(max(p * p - q, 0.0)) * sign(p);
    return x0 - dx;
}

float newton_bezier(float a, float b, float c, float d, float e, float f, float x0) {
    x0 = clamp(x0, 0.0, 1.0);
    for (int i = 0; i < ITERATIONS; i++) {
        x0 = clamp(newton_quintic(a, b, c, d, e, f, x0), 0.0, 1.0);
    }
    return x0;
}

//====================================================================
// Signed Distance Function for Cubic Bezier
//====================================================================

float sdCubicBezier(vec2 pos, vec2 A, vec2 B, vec2 C, vec2 D, out vec2 outQ) {
    vec2 c3 = -A + 3.0 * (B - C) + D;
    vec2 c2 = 3.0 * (A - 2.0 * B + C);
    vec2 c1 = 3.0 * (B - A);
    vec2 d_poly = A - pos;

    vec2 t0, t1, t2;
    cubic_roots(c3, c2, c1, d_poly, t0, t1, t2);

    float qa = 3.0 * dot(c3, c3);
    float qb = 5.0 * dot(c3, c2);
    float qc = 2.0 * dot(c2, c2) + 4.0 * dot(c3, c1);
    float qd = 3.0 * dot(c1, c2) + 3.0 * dot(c3, d_poly);
    float qe = dot(c1, c1) + 2.0 * dot(c2, d_poly);
    float qf = dot(c1, d_poly);

    float best_t = 0.0;
    float min_dist_sq = dot(A - pos, A - pos);

    float t_cand = newton_bezier(qa, qb, qc, qd, qe, qf, t0.x);
    vec2 p_on_curve = ((c3 * t_cand + c2) * t_cand + c1) * t_cand + A;
    float dist_sq = dot(p_on_curve - pos, p_on_curve - pos);
    if (dist_sq < min_dist_sq) { min_dist_sq = dist_sq; best_t = t_cand; }

    t_cand = newton_bezier(qa, qb, qc, qd, qe, qf, t1.x);
    p_on_curve = ((c3 * t_cand + c2) * t_cand + c1) * t_cand + A;
    dist_sq = dot(p_on_curve - pos, p_on_curve - pos);
    if (dist_sq < min_dist_sq) { min_dist_sq = dist_sq; best_t = t_cand; }

    t_cand = newton_bezier(qa, qb, qc, qd, qe, qf, t2.x);
    p_on_curve = ((c3 * t_cand + c2) * t_cand + c1) * t_cand + A;
    dist_sq = dot(p_on_curve - pos, p_on_curve - pos);
    if (dist_sq < min_dist_sq) { min_dist_sq = dist_sq; best_t = t_cand; }

    dist_sq = dot(D - pos, D - pos);
    if (dist_sq < min_dist_sq) { min_dist_sq = dist_sq; best_t = 1.0; }

    outQ = ((c3 * best_t + c2) * best_t + c1) * best_t + A;
    vec2 tangent = (3.0 * c3 * best_t + 2.0 * c2) * best_t + c1;

    float dist = sqrt(min_dist_sq);
    float sgn = sign(cro(tangent, outQ - pos));
    if (dot(tangent, tangent) < 1e-8) sgn = 1.0;

    return -dist * sgn;
}

//====================================================================
// Unsigned Distance to a Line Segment
//====================================================================
float sdLineSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    if (dot(ba, ba) < 1e-9) return length(pa);
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

//====================================================================
// SDF for the Rounded Rectangle Shape
//====================================================================
float sdRoundedRect(vec2 p, vec2 size, float corner_radius_in_pixels, float handle_strength) {
    // Convert the pixel-based radius to the shader's normalized coordinate space
    float scaled_radius = corner_radius_in_pixels / ubuf.u_resolution.y;
    
    float corner_radius_unclamped = min(scaled_radius, min(size.x, size.y));
    scaled_radius = clamp(corner_radius_unclamped, 0.0, corner_radius_unclamped - 0.0000001);
    handle_strength = clamp(handle_strength, 0.0, 1.0);
    float handle_offset = scaled_radius * handle_strength;

    p = abs(p);

    vec2 midTop = vec2(0.0, size.y);
    vec2 midRight = vec2(size.x, 0.0);
    vec2 bez_A = vec2(size.x - scaled_radius, size.y);
    vec2 bez_D = vec2(size.x, size.y - scaled_radius);

    vec2 dummyQ;
    vec2 bez_B = vec2(size.x - scaled_radius + handle_offset, size.y);
    vec2 bez_C = vec2(size.x, size.y - scaled_radius + handle_offset);

    float d_line1 = sdLineSegment(p, midTop, bez_A);
    float d_line2 = sdLineSegment(p, midRight, bez_D);
    float d_bez = abs(sdCubicBezier(p, bez_A, bez_B, bez_C, bez_D, dummyQ));

    float unsigned_dist = min(d_line1, min(d_line2, d_bez));

    bool inside_line1 = cro(bez_A - midTop, p - midTop) < 0.0;
    bool inside_line2 = cro(midRight - bez_D, p - bez_D) < 0.0;
    bool inside_bez = sdCubicBezier(p, bez_A, bez_B, bez_C, bez_D, dummyQ) < 0.0;

    bool is_inside = (p.x < size.x && p.y < size.y) && (inside_line1 && inside_line2 && inside_bez);

    return is_inside ? -unsigned_dist : unsigned_dist;
}

