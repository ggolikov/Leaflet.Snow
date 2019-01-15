// inputs
// густота  1-4     число слоев снега
// размер   1-4     размер снежинок на верхнем слое
// цвет
// направление?

// 1 интерполировать значение числа слоев и размера снежинок

// density => layers
// density => расстояние между снежинками
// добавить связь между размером и скейлом

precision mediump float;
uniform vec2 u_resolution;
uniform float u_angle;
uniform float u_width;
uniform float u_spacing;
uniform float u_length;
uniform float u_interval;
uniform float u_speed;
uniform float u_density;
uniform float u_size;
uniform float u_time;
uniform int u_color;


vec2 rand(vec2 co){
    return vec2(
        fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453),
        fract(cos(dot(co.yx ,vec2(8.64947,45.097))) * 43758.5453)
    )*2.0-1.0;
}

/*
	Dot distance field.
*/
float dots(vec2 uv) {
    vec2 g = floor(uv);
    vec2 f = fract(uv)*2.0-1.0;
    vec2 r = rand(g);

    // vec2 _f = rand(f);
    // if (floor(length(r)) < floor(length(_f)) - 2.0);
    // if (floor(length(r))==floor(length(_f))) discard;

    // Return the distance to that point.
    return length(f+r);
}

vec2 rotate(vec2 uv, float angle) {
    mat2 rotationMatrix = mat2(
        cos(angle), -sin(angle),
        sin(angle), cos(angle)
    );

    return rotationMatrix * uv;
}

float _color(float a, float b, vec2 uv, float angle, vec2 shift, float scale) {
    return smoothstep(a, b, dots(vec2(rotate(uv, angle)+shift)*scale));
}

void main() {
    float layersCount = 4.0;
    float xShift = u_time * u_speed; // направление
    float yShift = u_time * u_speed; // направление
    vec2 uv = gl_FragCoord.xy;

    float PI = 3.14159265359;
    float angle = PI / 4.0;
    vec2 _sh = vec2(xShift, sin(xShift/50.0)*20.0);
    // vec2 _sh = vec2(xShift, xShift);

    float color;
        if (u_density == 1.0) {
            color = _color(0.1, 0.2, uv, PI/2.0, _sh, 0.1);
        } else if (u_density == 2.0) {
            color = _color(0.1, 0.2, uv, PI/2.0, _sh, 0.1);
            color *= _color(0.1, 0.2, uv, PI/6.0, _sh, 0.05);

        } else if (u_density == 3.0) {
            color = _color(0.1, 0.2, uv, PI/2.0, _sh, 0.1);

        } else if (u_density == 4.0) {
            color = _color(0.1, 0.2, uv, PI/2.0, _sh, 0.1);
        }
	    // color = smoothstep(0.1, 0.9, dots(vec2(uv.x + xShift, uv.y + yShift)*0.05));
	    // color *= smoothstep(
        //     0.1, 0.8, // пушистость
        //     dots(vec2(uv.x -xShift, uv.y + yShift)
        //         *0.05)); // размер

	gl_FragColor = vec4(1.0 - color);
}
