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
// установить параметры плотности и размерности снега (параметризовать random)

float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        10000.5453123);
}

float todraw (vec2 coord, float xShift, float yShift) {
    mat2 rotationMatrix = mat2(
        cos(u_angle), -sin(u_angle),
        sin(u_angle), cos(u_angle)
    );
    vec2 shifted = vec2(coord.x + xShift, coord.y + yShift);
    vec2 rotatedFragCoord = rotationMatrix * shifted;

    return random(rotatedFragCoord);
}

vec3 getColor(int color) {
    float red = float(color / 256 / 256);
    float green = float(color / 256 - int(red * 256.0));
    float blue = float(color - int(red * 256.0 * 256.0) - int(green * 256.0));

    return vec3(red / 255.0, green / 255.0, blue / 255.0);
}



void main() {
    float d = todraw(gl_FragCoord.xy, u_time * u_speed, u_time * u_speed);

    d *= todraw(gl_FragCoord.xy, -u_time * u_speed, u_time * u_speed);
    d *= todraw(gl_FragCoord.xy, -u_time * u_speed, u_time * u_speed);
    d *= todraw(gl_FragCoord.xy, -u_time * u_speed * 0.5, -u_time * u_speed*.00000001);

    if (bool(d)) discard;

    vec3 color =  getColor(u_color);

    gl_FragColor = vec4(color, 1.0);
}
