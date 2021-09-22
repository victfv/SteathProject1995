shader_type spatial;
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform int depth_min_layers = 8;
uniform int depth_max_layers = 16;
uniform vec2 depth_flip = vec2(1.0);
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}

vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}

vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


float perlin(vec2 uv, vec2 size, int iterations, float persistence, int seed) {
	vec2 seed2 = rand2(vec2(float(seed), 1.0-float(seed)));
    float rv = 0.0;
    float coef = 1.0;
    float acc = 0.0;
    for (int i = 0; i < iterations; ++i) {
    	vec2 step = vec2(1.0)/size;
		vec2 xy = floor(uv*size);
        float f0 = rand(seed2+mod(xy, size));
        float f1 = rand(seed2+mod(xy+vec2(1.0, 0.0), size));
        float f2 = rand(seed2+mod(xy+vec2(0.0, 1.0), size));
        float f3 = rand(seed2+mod(xy+vec2(1.0, 1.0), size));
        vec2 mixval = smoothstep(0.0, 1.0, fract(uv*size));
        rv += coef * mix(mix(f0, f1, mixval.x), mix(f2, f3, mixval.x), mixval.y);
        acc += coef;
        size *= 2.0;
        coef *= persistence;
    }
    
    return rv / acc;
}

float shape_circle(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
    float distance = length(uv);
    return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}

float shape_polygon(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
    float angle = atan(uv.x, uv.y)+3.14159265359;
    float slice = 6.28318530718/sides;
    return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}

float shape_star(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
    float angle = atan(uv.x, uv.y);
    float slice = 6.28318530718/sides;
    return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(fract(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}

float shape_curved_star(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
    float angle = 2.0*(atan(uv.x, uv.y)+3.14159265359);
    float slice = 6.28318530718/sides;
    return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}

float shape_rays(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
    float angle = mod(atan(uv.x, uv.y)+3.14159265359, slice)/slice;
    return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}


vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}

vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}

vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}

vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}

float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}

vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}

vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}

float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}

vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}

float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}

vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}

float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}

vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}

vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}

vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}

vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}

const float p_o4217_albedo_color_r = 1.000000000;
const float p_o4217_albedo_color_g = 1.000000000;
const float p_o4217_albedo_color_b = 1.000000000;
const float p_o4217_albedo_color_a = 1.000000000;
const float p_o4217_metallic = 0.000000000;
const float p_o4217_roughness = 1.000000000;
const float p_o4217_emission_energy = 1.000000000;
const float p_o4217_normal = 1.000000000;
const float p_o4217_ao = 1.000000000;
const float p_o4217_depth_scale = 0.500000000;
float o4217_input_depth_tex(vec2 uv) {

return 0.0;
}
const float p_o210046_amount = 0.660000000;
const float p_o201254_repeat = 1.000000000;
const float p_o201254_rotate = 90.000000000;
const float p_o201254_gradient_0_pos = 0.832225914;
const float p_o201254_gradient_0_r = 1.000000000;
const float p_o201254_gradient_0_g = 1.000000000;
const float p_o201254_gradient_0_b = 1.000000000;
const float p_o201254_gradient_0_a = 1.000000000;
const float p_o201254_gradient_1_pos = 0.850498339;
const float p_o201254_gradient_1_r = 0.000000000;
const float p_o201254_gradient_1_g = 0.000000000;
const float p_o201254_gradient_1_b = 0.000000000;
const float p_o201254_gradient_1_a = 1.000000000;
const float p_o201254_gradient_2_pos = 0.868770764;
const float p_o201254_gradient_2_r = 1.000000000;
const float p_o201254_gradient_2_g = 1.000000000;
const float p_o201254_gradient_2_b = 1.000000000;
const float p_o201254_gradient_2_a = 1.000000000;
vec4 o201254_gradient_gradient_fct(float x) {
  if (x < p_o201254_gradient_0_pos) {
    return vec4(p_o201254_gradient_0_r,p_o201254_gradient_0_g,p_o201254_gradient_0_b,p_o201254_gradient_0_a);
  } else if (x < p_o201254_gradient_1_pos) {
    return mix(vec4(p_o201254_gradient_0_r,p_o201254_gradient_0_g,p_o201254_gradient_0_b,p_o201254_gradient_0_a), vec4(p_o201254_gradient_1_r,p_o201254_gradient_1_g,p_o201254_gradient_1_b,p_o201254_gradient_1_a), ((x-p_o201254_gradient_0_pos)/(p_o201254_gradient_1_pos-p_o201254_gradient_0_pos)));
  } else if (x < p_o201254_gradient_2_pos) {
    return mix(vec4(p_o201254_gradient_1_r,p_o201254_gradient_1_g,p_o201254_gradient_1_b,p_o201254_gradient_1_a), vec4(p_o201254_gradient_2_r,p_o201254_gradient_2_g,p_o201254_gradient_2_b,p_o201254_gradient_2_a), ((x-p_o201254_gradient_1_pos)/(p_o201254_gradient_2_pos-p_o201254_gradient_1_pos)));
  }
  return vec4(p_o201254_gradient_2_r,p_o201254_gradient_2_g,p_o201254_gradient_2_b,p_o201254_gradient_2_a);
}
const float p_o93820_amount = 0.660000000;
const float p_o74170_gradient_0_pos = 0.000000000;
const float p_o74170_gradient_0_r = 0.000000000;
const float p_o74170_gradient_0_g = 0.000000000;
const float p_o74170_gradient_0_b = 0.000000000;
const float p_o74170_gradient_0_a = 1.000000000;
const float p_o74170_gradient_1_pos = 1.000000000;
const float p_o74170_gradient_1_r = 1.000000000;
const float p_o74170_gradient_1_g = 1.000000000;
const float p_o74170_gradient_1_b = 1.000000000;
const float p_o74170_gradient_1_a = 1.000000000;
vec4 o74170_gradient_gradient_fct(float x) {
  if (x < p_o74170_gradient_0_pos) {
    return vec4(p_o74170_gradient_0_r,p_o74170_gradient_0_g,p_o74170_gradient_0_b,p_o74170_gradient_0_a);
  } else if (x < p_o74170_gradient_1_pos) {
    return mix(vec4(p_o74170_gradient_0_r,p_o74170_gradient_0_g,p_o74170_gradient_0_b,p_o74170_gradient_0_a), vec4(p_o74170_gradient_1_r,p_o74170_gradient_1_g,p_o74170_gradient_1_b,p_o74170_gradient_1_a), ((x-p_o74170_gradient_0_pos)/(p_o74170_gradient_1_pos-p_o74170_gradient_0_pos)));
  }
  return vec4(p_o74170_gradient_1_r,p_o74170_gradient_1_g,p_o74170_gradient_1_b,p_o74170_gradient_1_a);
}
const int seed_o67066 = -14538;
const float p_o67066_scale_x = 14.000000000;
const float p_o67066_scale_y = 5.000000000;
const float p_o67066_iterations = 5.000000000;
const float p_o67066_persistence = 0.500000000;
const float p_o51453_amount = 1.000000000;
const float p_o12738_gradient_0_pos = 0.000000000;
const float p_o12738_gradient_0_r = 0.093750000;
const float p_o12738_gradient_0_g = 0.093750000;
const float p_o12738_gradient_0_b = 0.093750000;
const float p_o12738_gradient_0_a = 1.000000000;
const float p_o12738_gradient_1_pos = 1.000000000;
const float p_o12738_gradient_1_r = 0.308593750;
const float p_o12738_gradient_1_g = 0.308593750;
const float p_o12738_gradient_1_b = 0.308593750;
const float p_o12738_gradient_1_a = 1.000000000;
vec4 o12738_gradient_gradient_fct(float x) {
  if (x < p_o12738_gradient_0_pos) {
    return vec4(p_o12738_gradient_0_r,p_o12738_gradient_0_g,p_o12738_gradient_0_b,p_o12738_gradient_0_a);
  } else if (x < p_o12738_gradient_1_pos) {
    return mix(vec4(p_o12738_gradient_0_r,p_o12738_gradient_0_g,p_o12738_gradient_0_b,p_o12738_gradient_0_a), vec4(p_o12738_gradient_1_r,p_o12738_gradient_1_g,p_o12738_gradient_1_b,p_o12738_gradient_1_a), ((x-p_o12738_gradient_0_pos)/(p_o12738_gradient_1_pos-p_o12738_gradient_0_pos)));
  }
  return vec4(p_o12738_gradient_1_r,p_o12738_gradient_1_g,p_o12738_gradient_1_b,p_o12738_gradient_1_a);
}
const int seed_o6131 = 34143;
const float p_o6131_scale_x = 38.000000000;
const float p_o6131_scale_y = 2.000000000;
const float p_o6131_iterations = 5.000000000;
const float p_o6131_persistence = 0.700000000;
const float p_o35849_gradient_0_pos = 0.426910299;
const float p_o35849_gradient_0_r = 1.000000000;
const float p_o35849_gradient_0_g = 1.000000000;
const float p_o35849_gradient_0_b = 1.000000000;
const float p_o35849_gradient_0_a = 1.000000000;
const float p_o35849_gradient_1_pos = 1.000000000;
const float p_o35849_gradient_1_r = 0.000000000;
const float p_o35849_gradient_1_g = 0.000000000;
const float p_o35849_gradient_1_b = 0.000000000;
const float p_o35849_gradient_1_a = 1.000000000;
vec4 o35849_gradient_gradient_fct(float x) {
  if (x < p_o35849_gradient_0_pos) {
    return vec4(p_o35849_gradient_0_r,p_o35849_gradient_0_g,p_o35849_gradient_0_b,p_o35849_gradient_0_a);
  } else if (x < p_o35849_gradient_1_pos) {
    return mix(vec4(p_o35849_gradient_0_r,p_o35849_gradient_0_g,p_o35849_gradient_0_b,p_o35849_gradient_0_a), vec4(p_o35849_gradient_1_r,p_o35849_gradient_1_g,p_o35849_gradient_1_b,p_o35849_gradient_1_a), ((x-p_o35849_gradient_0_pos)/(p_o35849_gradient_1_pos-p_o35849_gradient_0_pos)));
  }
  return vec4(p_o35849_gradient_1_r,p_o35849_gradient_1_g,p_o35849_gradient_1_b,p_o35849_gradient_1_a);
}
const float p_o31421_sides = 4.000000000;
const float p_o31421_radius = 0.530000000;
const float p_o31421_edge = 0.100000000;
const float p_o299791_gradient_0_pos = 0.000000000;
const float p_o299791_gradient_0_r = 0.000000000;
const float p_o299791_gradient_0_g = 0.000000000;
const float p_o299791_gradient_0_b = 0.000000000;
const float p_o299791_gradient_0_a = 1.000000000;
const float p_o299791_gradient_1_pos = 0.053156146;
const float p_o299791_gradient_1_r = 1.000000000;
const float p_o299791_gradient_1_g = 1.000000000;
const float p_o299791_gradient_1_b = 1.000000000;
const float p_o299791_gradient_1_a = 1.000000000;
vec4 o299791_gradient_gradient_fct(float x) {
  if (x < p_o299791_gradient_0_pos) {
    return vec4(p_o299791_gradient_0_r,p_o299791_gradient_0_g,p_o299791_gradient_0_b,p_o299791_gradient_0_a);
  } else if (x < p_o299791_gradient_1_pos) {
    return mix(vec4(p_o299791_gradient_0_r,p_o299791_gradient_0_g,p_o299791_gradient_0_b,p_o299791_gradient_0_a), vec4(p_o299791_gradient_1_r,p_o299791_gradient_1_g,p_o299791_gradient_1_b,p_o299791_gradient_1_a), ((x-p_o299791_gradient_0_pos)/(p_o299791_gradient_1_pos-p_o299791_gradient_0_pos)));
  }
  return vec4(p_o299791_gradient_1_r,p_o299791_gradient_1_g,p_o299791_gradient_1_b,p_o299791_gradient_1_a);
}


void fragment() {
	vec2 uv = fract(UV*uv1_scale.xy);
float o201254_0_r = 0.5+(cos(p_o201254_rotate*0.01745329251)*((uv).x-0.5)+sin(p_o201254_rotate*0.01745329251)*((uv).y-0.5))/(cos(abs(mod(p_o201254_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o201254_0_1_rgba = o201254_gradient_gradient_fct(fract(o201254_0_r*p_o201254_repeat));
float o67066_0_1_f = perlin((uv), vec2(p_o67066_scale_x, p_o67066_scale_y), int(p_o67066_iterations), p_o67066_persistence, seed_o67066);
vec4 o74170_0_1_rgba = o74170_gradient_gradient_fct(o67066_0_1_f);
float o6131_0_1_f = perlin((uv), vec2(p_o6131_scale_x, p_o6131_scale_y), int(p_o6131_iterations), p_o6131_persistence, seed_o6131);
vec4 o12738_0_1_rgba = o12738_gradient_gradient_fct(o6131_0_1_f);
float o31421_0_1_f = shape_polygon((uv), p_o31421_sides, p_o31421_radius*1.0, p_o31421_edge*1.0);
vec4 o35849_0_1_rgba = o35849_gradient_gradient_fct(o31421_0_1_f);
vec4 o51453_0_s1 = o12738_0_1_rgba;
vec4 o51453_0_s2 = o35849_0_1_rgba;
float o51453_0_a = p_o51453_amount*1.0;
vec4 o51453_0_2_rgba = vec4(blend_multiply((uv), o51453_0_s1.rgb, o51453_0_s2.rgb, o51453_0_a*o51453_0_s1.a), min(1.0, o51453_0_s2.a+o51453_0_a*o51453_0_s1.a));
vec4 o93820_0_s1 = o74170_0_1_rgba;
vec4 o93820_0_s2 = o51453_0_2_rgba;
float o93820_0_a = p_o93820_amount*1.0;
vec4 o93820_0_2_rgba = vec4(blend_multiply((uv), o93820_0_s1.rgb, o93820_0_s2.rgb, o93820_0_a*o93820_0_s1.a), min(1.0, o93820_0_s2.a+o93820_0_a*o93820_0_s1.a));
vec4 o210046_0_s1 = o201254_0_1_rgba;
vec4 o210046_0_s2 = o93820_0_2_rgba;
float o210046_0_a = p_o210046_amount*1.0;
vec4 o210046_0_2_rgba = vec4(blend_multiply((uv), o210046_0_s1.rgb, o210046_0_s2.rgb, o210046_0_a*o210046_0_s1.a), min(1.0, o210046_0_s2.a+o210046_0_a*o210046_0_s1.a));
vec4 o299791_0_1_rgba = o299791_gradient_gradient_fct((dot((o35849_0_1_rgba).rgb, vec3(1.0))/3.0));
vec4 o328733_0_1_rgba = vec4((dot((o210046_0_2_rgba).rgb, vec3(1.0))/3.0), (dot((o210046_0_2_rgba).rgb, vec3(1.0))/3.0), (dot((o210046_0_2_rgba).rgb, vec3(1.0))/3.0), (dot((o299791_0_1_rgba).rgb, vec3(1.0))/3.0));
vec4 o299791_0_3_rgba = o299791_gradient_gradient_fct((dot((o35849_0_1_rgba).rgb, vec3(1.0))/3.0));

	vec3 albedo_tex = ((o328733_0_1_rgba).rgb).rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*vec4(p_o4217_albedo_color_r, p_o4217_albedo_color_g, p_o4217_albedo_color_b, p_o4217_albedo_color_a).rgb;
	METALLIC = 1.0*p_o4217_metallic;
	ROUGHNESS = 1.0*p_o4217_roughness;
	NORMALMAP = vec3(0.5);
	EMISSION = vec3(0.0)*p_o4217_emission_energy;
	ALPHA = (dot((o299791_0_3_rgba).rgb, vec3(1.0))/3.0);

}



