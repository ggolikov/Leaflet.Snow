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
const float MAX_DENSITY = 5.0;
const float MAX_SPEED = 5.0;

float rand1d(float x) {
    return fract(sin(x)*1000000.0);
}

vec2 rand(vec2 uv) {
    return vec2(
        fract(sin(dot(uv.xy ,vec2(12.9898,78.233))) * 43758.5453),
        fract(cos(dot(uv.yx ,vec2(8.64947,45.097))) * 43758.5453)
    );
}

vec2 rotate(vec2 uv, float angle) {
    mat2 rotationMatrix = mat2(
        cos(angle), -sin(angle),
        sin(angle), cos(angle)
    );

    return rotationMatrix * uv;
}

// minSize
// maxSize
// minDensity?
// maxDensity?

vec2 shift(float speedCoef) {
    float xShift = (u_time * u_speed * speedCoef)/ u_resolution.x;
    float yShift = (u_time * u_speed * speedCoef) / u_resolution.y;


    return vec2(xShift, sin(yShift/50.0)*20.0);
    // return vec2(xShift, 0.0);
    // return vec2(0.0);

    // float i = floor(xShift);  // integer
    // float f = fract(xShift);  // fraction
    // return vec2(xShift, mix(rand1d(i), rand1d(i + 1.0), smoothstep(0.,1.,f)));
}

float drawCircle(vec2 uv, float angle, float scale, float sizeScale) {
    float density = u_density * scale;
    // умножим размер на 2, чтобы был зазор между точками
    float doubleSize = u_size * sizeScale * 2.0;
    // разобъем пространство на doubleSize частей
    vec2 splitCount = u_resolution / vec2(doubleSize);
    uv *= splitCount;

    uv = rotate(uv, angle) + shift(scale);
    // radius в долях целого
    float radius = 0.25;
    // выделим целую и частную фракции от координат
    vec2 integerCoord = floor(uv);
    vec2 fractionalCoord = fract(uv);
    // randomCoord располагается в промежутке от 0.0 до sqrt(2.0)
    vec2 randomCoord = rand(integerCoord);
    // в зависимости от плотности удаляем снег
    float minRadius = density * sqrt(2.0) / MAX_DENSITY;
    if (length(randomCoord) > minRadius) return 0.0;

    // радиус равен 0,25, чтобы очертить круг вокруг точки 0.5,0.5
    // но само положение центр должно быть в пределах от 0,25 до 0,75 * размытие
    // размытие
    float smoothCoeff = 1.3;
    float smoothRadius = radius * (1.0 + smoothCoeff);
    vec2 normalizedRandomCoord = mix(vec2(smoothRadius), vec2(1.0 - smoothRadius), randomCoord);

    // при l = fractionalCoord центр находится в точке 0,0
    // при l = fractionalCoord -vec2(0.5); центр смещается в середину квадрата
    // при l = fractionalCoord - randomCoord; центр смещается произвольную точку. И это смещение одинаково для текущего uv! Это называется псевдослучайная величина
    vec2 l = fractionalCoord - normalizedRandomCoord;

    return 1.0 - smoothstep(radius*(1.0 - smoothCoeff),radius*(1.0 + smoothCoeff), length(l));
    // return 1.0 - smoothstep(radius*(1.0),radius*(10.0), length(l));
}

// Скорость затухает с каждым верхним слоем
float getspeedCoeff(float layerIndex) {
    return (MAX_SPEED + 1.0 - layerIndex) / MAX_SPEED;
}

void main() {
    vec2 uv = gl_FragCoord.xy/u_resolution;
    float _size = mix(0.0, 1.0, u_size / length(u_resolution));

    float angle = PI / 4.0;

    // каждый слой *= -0.2 к скорости
    // каждый слой *= -0.2 к плотности
    // каждый слой *= +0.2 к размеру

    float speedCoeff = getspeedCoeff(u_layersCount);

    float scale = 1.0;
    float sizeScale = 1.0 / u_layersCount;
    float color = drawCircle(uv, PI * 3.0/8.0, scale, sizeScale);

    if (u_layersCount >= 2.0) {
        sizeScale = 2.0 / u_layersCount;
        scale = 0.8;
        color += drawCircle(uv, PI * 5.0/8.0, scale, sizeScale);
    }

    if (u_layersCount >= 3.0) {
        sizeScale = 3.0 / u_layersCount;
        scale = 0.6;
        color += drawCircle(uv, PI * 1.0/8.0, scale, sizeScale);
    }

    if (u_layersCount >= 4.0) {
        sizeScale = 4.0 / u_layersCount;
        scale = 0.4;
        color += drawCircle(uv, PI * 7.0/8.0, scale, sizeScale);
    }

    if (u_layersCount >= 5.0) {
        sizeScale = 5.0 / u_layersCount;
        scale = 0.2;
        color += drawCircle(uv, PI*PI * 4.0/8.0, scale, sizeScale);
    }

    // костыль
    // if (color < 0.1) discard;
    vec3 _color = vec3(color);
    // _color += vec3(uv, 0.7);
    color += (uv, 0.7);

    gl_FragColor = vec4(_color, 1.0);
}
