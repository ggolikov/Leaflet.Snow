// inputs
// густота  1-4     число слоев снега
// размер   1-4     размер снежинок на верхнем слое
// цвет
// направление?

// 1 интерполировать значение числа слоев и размера снежинок

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
uniform float u_layersCount;
uniform float u_density;
uniform float u_size;
uniform float u_time;
uniform int u_color;

float rand1d(float x) {
    return fract(sin(x)*1000000.0);
}

vec2 rand(vec2 co) {
    return vec2(
        fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453),
        fract(cos(dot(co.yx ,vec2(8.64947,45.097))) * 43758.5453)
    )*2.0-1.0;
}

/*
	Dot distance field.
*/
float dots(vec2 uv, float density) {
    vec2 g = floor(uv);
    vec2 f = fract(uv)*2.0-1.0;
    vec2 r = rand(g);

    vec2 _f = rand(f);
    // if (floor(length(r)) < floor(length(_f)) - 2.0);
    // if (floor(length(r))==floor(length(_f))) discard;

    // разреженность - вопрос?
    if (length(mod(r, 4.0)) > density) return 1.0;

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

// a пушистость
// b пушистость
// uv координаты
// angle поворот слоя
// shift ф-ция движения
// density плотность снежинок в слое
// scale размер снежинок


float _color(float a, float b, vec2 uv, float angle, vec2 shift, float density, float scale) {
    return smoothstep(a, b, dots(vec2(rotate(uv, angle)+shift)*scale, density));
}

vec2 getShift(float speedCoef) {
    float xShift = u_time * u_speed * speedCoef;
    float yShift = u_time * u_speed * speedCoef;

    float i = floor(xShift);  // integer
    float f = fract(xShift);  // fraction

    // return vec2(xShift, sin(yShift/50.0)*20.0);
    return vec2(xShift, mix(rand1d(i), rand1d(i + 1.0), smoothstep(0.,1.,f)));
}

void main() {
    float layersCount = 4.0;

    vec2 uv = gl_FragCoord.xy;

    float PI = 3.14159265359;
    float angle = PI / 4.0;

    float color;
        color = _color(0.1, 0.2, uv, PI/2.0, getShift(1.0), u_density, 0.1);
        if (u_layersCount == 2.0) {
            color *= _color(0.1, 0.3, uv, PI/6.0, getShift(1.5), u_density, 0.08);
        } else if (u_layersCount == 3.0) {
            color *= _color(0.1, 0.3, uv, PI/6.0, getShift(1.5), u_density, 0.08);
            color *= _color(0.1, 0.5, uv, PI/1.2, getShift(2.0), u_density, 0.05);

        } else if (u_layersCount == 4.0) {
            color *= _color(0.1, 0.2, uv, PI/6.0, getShift(1.5), u_density, 0.08);
            color *= _color(0.1, 0.5, uv, PI/1.2, getShift(2.0), u_density, 0.05);
            color *= _color(0.1, 0.6, uv, PI, getShift(2.5), u_density, 0.045);
        }
	    // color = smoothstep(0.1, 0.9, dots(vec2(uv.x + xShift, uv.y + yShift)*0.05));
	    // color *= smoothstep(
        //     0.1, 0.8, // пушистость
        //     dots(vec2(uv.x -xShift, uv.y + yShift)
        //         *0.05)); // размер

	gl_FragColor = vec4(1.0 - color);
}
