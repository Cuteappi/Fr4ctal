/**
* @file bezier_solver_v4.c
* @brief A TUI application to find the minimum distance from a point to a cubic Bézier curve.
*
* v4 Changes:
* - Added a display for the coefficients of the quintic polynomial being solved.
*
* Original GLSL Shader License: CC BY-NC-SA 4.0
* C Port and TUI by: Gemini
*
* Compilation:
* gcc -o bezier_solver bezier_solver_v4.c -lncurses -lm
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ncurses.h>
#include <string.h>
#include <time.h>

//====================================================================
// Data Structures and Math
//====================================================================

typedef struct { double x; double y; } Vec2;
Vec2 vec2_add(Vec2 a, Vec2 b) { return (Vec2){a.x + b.x, a.y + b.y}; }
Vec2 vec2_sub(Vec2 a, Vec2 b) { return (Vec2){a.x - b.x, a.y - b.y}; }
Vec2 vec2_scale(Vec2 v, double s) { return (Vec2){v.x * s, v.y * s}; }
double dot(Vec2 a, Vec2 b) { return a.x * b.x + a.y * b.y; }
double vec2_length(Vec2 v) { return sqrt(dot(v, v)); }
double clamp(double val, double min, double max) { return fmax(min, fmin(val, max)); }

//====================================================================
// Complex Number Operations
//====================================================================
Vec2 vec2_conj(Vec2 c) { return (Vec2){c.x, -c.y}; }
Vec2 vec2_cmul(Vec2 a, Vec2 b) { return (Vec2){a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x}; }
Vec2 vec2_cexp(Vec2 c) { return (Vec2){exp(c.x) * cos(c.y), exp(c.x) * sin(c.y)}; }
Vec2 vec2_cln(Vec2 c) { return (Vec2){log(dot(c, c)) * 0.5, atan2(c.y, c.x)}; }
Vec2 vec2_cdiv(Vec2 a, Vec2 b) { double d = dot(b, b); if (d < 1e-15) return (Vec2){NAN, NAN}; Vec2 res = vec2_cmul(a, vec2_conj(b)); return vec2_scale(res, 1.0 / d); }
Vec2 vec2_csqrt(Vec2 a) { double r = vec2_length(a); if (fabs(a.y) < 1e-9 && a.x < 0) return (Vec2){0.0, sqrt(r)}; Vec2 h = vec2_add(a, (Vec2){r, 0.0}); return vec2_scale(h, sqrt(r / dot(h, h))); }
Vec2 vec2_ccbrt(Vec2 a) { return vec2_cexp(vec2_scale(vec2_cln(a), 1.0/3.0)); }

//====================================================================
// Root Solvers (Cubic and Quintic)
//====================================================================

void cubic_roots(Vec2 a, Vec2 b, Vec2 c, Vec2 d, Vec2* x0, Vec2* x1, Vec2* x2) {
	if (dot(a, a) < 1e-15) { *x0 = *x1 = *x2 = (Vec2){NAN,NAN}; return; }
	Vec2 ac=vec2_cmul(a, c), bb=vec2_cmul(b, b), aa=vec2_cmul(a, a);
	Vec2 d0=vec2_sub(bb, vec2_scale(ac, 3.0));
	Vec2 d1_t1=vec2_cmul(vec2_scale(b, 2.0), bb), d1_t2=vec2_cmul(vec2_scale(ac, 9.0), b), d1_t3=vec2_cmul(aa, vec2_scale(d, 27.0));
	Vec2 d1=vec2_add(vec2_sub(d1_t1, d1_t2), d1_t3);
	Vec2 s=vec2_csqrt(vec2_sub(vec2_cmul(d1, d1), vec2_scale(vec2_cmul(vec2_cmul(d0, d0), d0), 4.0)));
	Vec2 opt=dot(vec2_sub(d1,s),vec2_sub(d1,s)) < dot(vec2_add(d1,s),vec2_add(d1,s)) ? vec2_add(d1,s) : vec2_sub(d1,s);
	Vec2 cb=vec2_ccbrt(vec2_scale(opt, 0.5));
	if (dot(cb, cb) < 1e-15) { *x0 = *x1 = *x2 = vec2_cdiv(b, vec2_scale(a, -3.0)); return; }
	Vec2 inv_3a=vec2_cdiv((Vec2){-1,0}, vec2_scale(a, 3.0)), root={-0.5, 0.8660254};
	*x0 = vec2_cmul(vec2_add(b, vec2_add(cb, vec2_cdiv(d0, cb))), inv_3a);
	cb = vec2_cmul(cb, root); *x1 = vec2_cmul(vec2_add(b, vec2_add(cb, vec2_cdiv(d0, cb))), inv_3a);
	cb = vec2_cmul(cb, root); *x2 = vec2_cmul(vec2_add(b, vec2_add(cb, vec2_cdiv(d0, cb))), inv_3a);
}

double newton_quintic(double a, double b, double c, double d, double e, double f, double x0) {
	double v = ((((a * x0 + b) * x0 + c) * x0 + d) * x0 + e) * x0 + f;
	double dv = (((5.0*a*x0 + 4.0*b)*x0 + 3.0*c)*x0 + 2.0*d)*x0 + e;
	if (fabs(dv) < 1e-6) return x0;
	return x0 - v / dv;
}

double refine_root(const double* q, double x0) {
	x0 = clamp(x0, 0.0, 1.0);
	for (int i = 0; i < 4; i++) {
		x0 = clamp(newton_quintic(q[0], q[1], q[2], q[3], q[4], q[5], x0), 0.0, 1.0);
	}
	return x0;
}

//====================================================================
// TUI Application Logic
//====================================================================

// --- Global State ---
Vec2 points[5];
char point_strs[10][20];
int active_field = 0;
Vec2 g_roots[3], g_closest_point;
double g_quintic_coeffs[6];
double g_calc_time_us = 0.0, g_best_t = 0.0, g_min_distance = 0.0;

Vec2 get_bezier_point(double t) {
	Vec2 p0=points[0], p1=points[1], p2=points[2], p3=points[3];
	double omt=1.0-t, omt2=omt*omt, t2=t*t;
	return vec2_add(vec2_add(vec2_scale(p0, omt2*omt), vec2_scale(p1, 3.0*omt2*t)),
					vec2_add(vec2_scale(p2, 3.0*omt*t2), vec2_scale(p3, t2*t)));
}

void perform_calculation() {
	struct timespec start, end;
	clock_gettime(CLOCK_MONOTONIC, &start);

	Vec2 p0=points[0], p1=points[1], p2=points[2], p3=points[3], uv=points[4];
	Vec2 a=vec2_add(vec2_sub(p3, p0), vec2_scale(vec2_sub(p1, p2), 3.0));
	Vec2 b=vec2_scale(vec2_add(vec2_sub(p0, vec2_scale(p1, 2.0)), p2), 3.0);
	Vec2 c=vec2_scale(vec2_sub(p1, p0), 3.0);
	Vec2 d=vec2_sub(p0, uv);

	cubic_roots(a, b, c, d, &g_roots[0], &g_roots[1], &g_roots[2]);

	g_quintic_coeffs[0] = 3.0*dot(a,a); // A (t^5)
	g_quintic_coeffs[1] = 5.0*dot(a,b); // B (t^4)
	g_quintic_coeffs[2] = 2.0*dot(b,b)+4.0*dot(a,c); // C (t^3)
	g_quintic_coeffs[3] = 3.0*dot(c,b)+3.0*dot(a,d); // D (t^2)
	g_quintic_coeffs[4] = 2.0*dot(b,d)+dot(c,c); // E (t^1)
	g_quintic_coeffs[5] = dot(c,d); // F (t^0)
	
	double candidates[] = {g_roots[0].x, g_roots[1].x, g_roots[2].x, 0.0, 1.0};
	g_min_distance = vec2_length(vec2_sub(get_bezier_point(0.0), uv));
	g_best_t = 0.0;

	for (int i=0; i < 5; ++i) {
		if (isnan(candidates[i])) continue;
		double t = refine_root(g_quintic_coeffs, candidates[i]);
		double dist = vec2_length(vec2_sub(get_bezier_point(t), uv));
		if (dist < g_min_distance) {
			g_min_distance = dist;
			g_best_t = t;
		}
	}
	g_closest_point = get_bezier_point(g_best_t);

	clock_gettime(CLOCK_MONOTONIC, &end);
	g_calc_time_us = (end.tv_sec - start.tv_sec) * 1e6 + (end.tv_nsec - start.tv_nsec) / 1e3;
}

void init_values() {
	points[0] = (Vec2){-0.4, 0.0};  points[1] = (Vec2){-0.4, 0.2};
	points[2] = (Vec2){0.4, -0.2}; points[3] = (Vec2){0.4, 0.0};
	points[4] = (Vec2){0.1, 0.15};
	for (int i = 0; i < 5; ++i) {
		snprintf(point_strs[i*2], 20, "%.4f", points[i].x);
		snprintf(point_strs[i*2+1], 20, "%.4f", points[i].y);
	}
	perform_calculation();
}

void draw_ui() {
	clear();
	attron(A_BOLD); mvprintw(0, 2, "Cubic Bézier Minimum Distance Finder v4"); attroff(A_BOLD);
	mvprintw(1, 2, "Use Arrow Keys to navigate, numbers to edit, 'q' to quit.");
	mvprintw(2, 2, "Select the button and press Enter to recalculate.");

	char* labels[] = {"P0.x","P0.y","P1.x","P1.y","P2.x","P2.y","P3.x","P3.y","UV.x","UV.y"};
	char* descs[] = {"Start Point","","Control Point 1","","Control Point 2","","End Point","","Sample Point",""};
	for (int i=0; i<10; ++i) {
		if(i==active_field) attron(A_REVERSE);
		mvprintw(5+i, 4, "%-4s: %-12s", labels[i], point_strs[i]);
		if(i==active_field) attroff(A_REVERSE);
		attron(A_DIM); mvprintw(5+i, 25, "(%s)", descs[i]); attroff(A_DIM);
	}
	if (active_field == 10) attron(A_REVERSE);
	mvprintw(16, 4, "[ Recalculate ]");
	if (active_field == 10) attroff(A_REVERSE);
	
	int results_x = 48;
	attron(A_UNDERLINE); mvprintw(4, results_x, "Final Results"); attroff(A_UNDERLINE);
	attron(A_BOLD);
	mvprintw(6, results_x, "Min Distance: %.6f", g_min_distance);
	mvprintw(7, results_x, "Closest Point: (%.4f, %.4f)", g_closest_point.x, g_closest_point.y);
	mvprintw(8, results_x, "Curve Param t: %.6f", g_best_t);
	attroff(A_BOLD);

	attron(A_UNDERLINE); mvprintw(10, results_x, "Intermediate Values"); attroff(A_UNDERLINE);
	mvprintw(11, results_x, "Quintic Poly (At^5+...+F=0) Coeffs:");
	mvprintw(12, results_x, "A=%-9.2f B=%-9.2f C=%-9.2f", g_quintic_coeffs[0], g_quintic_coeffs[1], g_quintic_coeffs[2]);
	mvprintw(13, results_x, "D=%-9.2f E=%-9.2f F=%-9.2f", g_quintic_coeffs[3], g_quintic_coeffs[4], g_quintic_coeffs[5]);
	mvprintw(15, results_x, "Complex Roots (t guesses):");
	mvprintw(16, results_x, "t0: %9.4f + %9.4fi", g_roots[0].x, g_roots[0].y);
	mvprintw(17, results_x, "t1: %9.4f + %9.4fi", g_roots[1].x, g_roots[1].y);
	mvprintw(18, results_x, "t2: %9.4f + %9.4fi", g_roots[2].x, g_roots[2].y);
	mvprintw(20, results_x, "Total Calc Time: %.2f µs", g_calc_time_us);
	refresh();
}

int main() {
	initscr(); cbreak(); noecho(); keypad(stdscr, TRUE);
	init_values();
	int ch;
	do {
		draw_ui();
		ch = getch();
		if (active_field < 10) {
			int len = strlen(point_strs[active_field]);
			if ((ch>='0'&&ch<='9' || ch=='.'||ch=='-') && len < 19) {
				point_strs[active_field][len] = ch;
				point_strs[active_field][len+1] = '\0';
			}
		}
		switch (ch) {
			case KEY_UP:   active_field = (active_field - 1 + 11) % 11; break;
			case KEY_DOWN: active_field = (active_field + 1) % 11; break;
			case KEY_BACKSPACE: case 127:
				if (active_field < 10) {
					int len = strlen(point_strs[active_field]);
					if (len > 0) point_strs[active_field][len-1] = '\0';
				}
				break;
			case '\n':
				if (active_field < 10) {
					sscanf(point_strs[active_field], "%lf", (active_field%2==0) ? &points[active_field/2].x : &points[active_field/2].y);
					snprintf(point_strs[active_field], 20, "%.4f", (active_field%2==0) ? points[active_field/2].x : points[active_field/2].y);
				} else if (active_field == 10) {
					perform_calculation();
				}
				break;
		}
	} while (ch != 'q');
	endwin();
	return 0;
}