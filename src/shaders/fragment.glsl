precision mediump float;
uniform vec2 u_resolution;
uniform float u_angle;
uniform float u_width;
uniform float u_spacing;
uniform float u_length;
uniform float u_interval;
uniform float u_speed;
uniform float u_time;
uniform int u_color;

/*
	The same old random function with a different signature.
*/
vec2 rand(vec2 co){
    return vec2(
        fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453),
        fract(cos(dot(co.yx ,vec2(8.64947,45.097))) * 43758.5453)
    )*2.0-1.0;
}

/*
	Dot distance field.
*/
float dots(vec2 uv, float scale) {
    // Consider the integer component of the UV coordinate
    // to be an ID of a local coordinate space.
    vec2 g = floor(uv);
	// "What 'local coordinate space'?" you say? Why the one
    // implicitly defined by the fractional component of
    // the UV coordinate. Here we translate the origin to the
    // center.
    vec2 f = fract(uv)*8.0-2.0;

    // Get a random value based on the "ID" of the coordinate
    // system. This value is invariant across the entire region.
    vec2 r = rand(g)/* * scale*/;

    // Return the distance to that point.
    return length(f+r);
}

void main() {
    float d;
    float scale = 1.;
    float xShift = u_time * u_speed;
    float yShift = u_time * u_speed * 2.0;
    vec2 uv = gl_FragCoord.xy;

    // uv /= 10.0;

    // d = draw(uv, xShift, yShift, scale);

    // vec2 shifted = vec2(uv.x + xShift, uv.y + yShift);
    float color;
        color = smoothstep(0.1, 0.5, dots(vec2(uv.x, uv.y + yShift)*0.9,0.9));
	    // color *= smoothstep(0.1, 0.5, dots(vec2(uv.x + xShift, uv.y + yShift)*0.8,0.8));
	    color *= smoothstep(0.1, 0.5, dots(vec2(uv.x -xShift, uv.y + yShift)*0.01,0.01));

	gl_FragColor = vec4(1.0 - color);
}
