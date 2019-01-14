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

// todo:
// Уменьшить яркость дальних слоев
// задать функцию рандомных углов снега (параметризовать снег)
// переписать линейное движение снега на синусоидальное
// убрать задвоение сверху
// установить параметры плотности и размерности снега

// размер
// 1 - Это random - gl_FragCoord
// нужен множитель
// 2 - gl_FragCoord * 2.0;

// направление
// надо сделать вертикальный снег
// и управлять его движением при помощи уравнений

// bugs:
// ускоряется снег при redraw(), в том чисмле и при пане, и при зуме.

// при scale не увеличивается размер точки, а увеличивается скорость
// значит, scale должен передаваться в матрицу масштабирования

vec3 getColor(int color) {
    float red = float(color / 256 / 256);
    float green = float(color / 256 - int(red * 256.0));
    float blue = float(color - int(red * 256.0 * 256.0) - int(green * 256.0));

    return vec3(red / 255.0, green / 255.0, blue / 255.0);
}

// a, b - параметры вектора
// tan(a / b) определяет угол
// c определяет разреженность (количество рандомных точек)
float random (vec2 st) {
    float a;
    float b;

    a = 1.0;
    b = 1.0;
    float c = 1000.0;
    // c = ;

    return fract(sin(dot(st.xy,vec2(a, b)))*c);
}

// скейл изменяет количество рандомных точек
// но не размер точки!

float draw (vec2 coord, float xShift, float yShift, float scale) {
    // mat2 rotationMatrix = mat2(
    //     cos(u_angle), -sin(u_angle),
    //     sin(u_angle), cos(u_angle)
    // );

    mat2 scaleMatrix = mat2(
        scale, 0.0,
        0.0, scale
    );

    vec2 shifted = vec2(coord.x + xShift, coord.y + yShift);
    // vec2 rotatedFragCoord = rotationMatrix * shifted;

    // vec2 finalCoord = scaleMatrix * rotatedFragCoord;
    // return random(rotatedFragCoord);
    return random(shifted);
}

void main() {
    float d;
    float scale = 1.;
    float xShift = u_time * u_speed * 0.0001;
    float yShift = u_time * u_speed * 0.0001;
    // vec2 st = gl_FragCoord.xy/* / u_resolution*/;
    vec2 st = gl_FragCoord.xy / u_resolution;
    // st *= scale;
    // d = draw(st, 0.0, 0.0, scale);
    d = draw(gl_FragCoord.xy / u_resolution, xShift, yShift, scale);

    if (bool(d)) discard;

    vec3 color =  getColor(u_color);

    gl_FragColor = vec4(color, 1.0);
}
