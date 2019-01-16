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

// массив коэффициентов скоростей
// скорости затухают от нижнего слоя к верхнему (чем крупнее снежинки в слое, тем ниже скорость)
// const vec4 speedAttenuation = vec4(1.0, 0.8, 0.6, 0.4, 0.2);
const float PI = 3.14159265359;

float rand1d(float x) {
    return fract(sin(x)*1000000.0);
}

vec2 rand(vec2 uv) {
    return vec2(
        fract(sin(dot(uv.xy ,vec2(12.9898,78.233))) * 43758.5453),
        fract(cos(dot(uv.yx ,vec2(8.64947,45.097))) * 43758.5453)
    )*2.0-1.0;
}

/*
	Dot distance field.
*/
float dots(vec2 uv, float density) {
    // px
    // uv в пикселях
    // Consider the integer component of the UV coordinate
// to be an ID of a local coordinate space.
    vec2 g = floor(uv);
    // приводим к ПО
    // "What 'local coordinate space'?" you say? Why the one
// implicitly defined by the fractional component of
// the UV coordinate. Here we translate the origin to the
// center.
    vec2 f = fract(uv)*2.0-1.0;
    // приводим к ПО
    // Get a random value based on the "ID" of the coordinate
// system. This value is invariant across the entire region.
    vec2 r = rand(g)*0.5;

    // разреженность - не работает + непонятно, в чем мерять
    // if (length(mod(r, 5.0)) > density) return 1.0;

    // Return the distance(от 0,0) to that point. (в координатах ПО)
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
// size размер снежинок

float _color(float a, float b, vec2 uv, float angle, vec2 shift, float scale, float density) {
    // a = 0.1;
    // b = 0.3;
    return smoothstep(a, b, dots(vec2(rotate(uv, angle)+shift)*scale, density));
}

vec2 getShift(float speedCoef) {
    float xShift = (u_time * u_speed * speedCoef);
    float yShift = (u_time * u_speed * speedCoef);

    float i = floor(xShift);  // integer
    float f = fract(xShift);  // fraction

    // return vec2(xShift, sin(yShift/50.0)*20.0);
    return vec2(0.0);
    // return vec2(xShift, mix(rand1d(i), rand1d(i + 1.0), smoothstep(0.,1.,f)));
}

float getspeedCoeff(float layerIndex) {
    return (6.0 - layerIndex) / 5.0;
}

void main() {
    vec2 uv = gl_FragCoord.xy;
    vec2 _uv = uv/u_resolution;

    if (dots(uv, 1.0) < 0.69) discard;

    // float _size = u_size / length(u_resolution);
    float _size = u_size / u_resolution.x;


    // if (_size > 0.00111) discard;

    float angle = PI / 4.0;

    // каждый слой *= -0.2 к скорости
    // каждый слой *= -0.2 к плотности

    float speedCoeff = getspeedCoeff(u_layersCount);


    // float color = _color(_size, _size*1.5, uv, PI/2.0, getShift(1.0), 1.0, u_density * 1.0); - красивый эффект добавления точек
    float color = _color(_size, _size*1.5, uv, PI/2.0, getShift(1.0), u_size, u_density * 1.0);

    if (u_layersCount >= 2.0) {
        color *= _color(0.1, 0.3, uv, PI/6.0, getShift(0.8), 0.08, u_density * 0.8);
    }

    if (u_layersCount >= 3.0) {
        color *= _color(0.1, 0.5, uv, PI/1.2, getShift(0.6), 0.05, u_density * 0.6);
    }

    if (u_layersCount >= 4.0) {
        color *= _color(0.1, 0.6, uv, PI,     getShift(0.4), 0.045, u_density * 0.4);
    }

    if (u_layersCount >= 5.0) {
        color *= _color(0.1, 0.6, uv, PI*1.5,     getShift(0.2), 0.03, u_density* 0.2);
    }

	// gl_FragColor = vec4(1.0 - color);
	gl_FragColor = vec4(1.0);
}
