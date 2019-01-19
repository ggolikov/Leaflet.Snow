precision mediump float;
uniform vec2 u_resolution;
uniform float u_time;
uniform float u_speed;
uniform float u_layersCount;
uniform float u_density;
uniform float u_size;
uniform int u_color;
uniform float u_opacity;

const float PI = 3.14159265359;
const float MAX_DENSITY = 5.0;

// https://gist.github.com/gerard-geer/4d0be4fbefabe209c9b5
vec2 rand(vec2 uv) {
    return vec2(
        fract(sin(dot(uv.xy ,vec2(12.9898,78.233))) * 43758.5453),
        fract(cos(dot(uv.yx ,vec2(8.64947,45.097))) * 43758.5453)
    );
}

vec2 shift(float speedCoef) {
    float xShift = (u_time * u_speed * speedCoef)/ u_resolution.x;
    float yShift = (u_time * u_speed * speedCoef) / u_resolution.y;

    return vec2(xShift, sin(yShift/10.0));
}

vec2 rotate(vec2 uv, float angle) {
    mat2 rotationMatrix = mat2(
        cos(angle), -sin(angle),
        sin(angle), cos(angle)
    );

    return rotationMatrix * uv;
}

float drawSnowFlake(vec2 uv, float angle, float layerNumber) {

    float scale = (u_layersCount + 1.0 - layerNumber) / u_layersCount;
    float sizeScale = layerNumber / u_layersCount;

    // 1. split clipspace in 4*(snowflake size) parts
    float clipSpaceScaleCoeff =  4.0;
    vec2 splitCount = u_resolution / vec2(u_size * sizeScale * clipSpaceScaleCoeff);
    uv *= splitCount;

    // 2. transform snow movement
    uv = rotate(uv, angle) + shift(scale);

    // 3. get random position
    vec2 integerCoord = floor(uv);
    vec2 fractionalCoord = fract(uv);
    vec2 randomCoord = rand(integerCoord);

    // 4. remove some cells to get uniform density
    float minRadius = u_density * scale * sqrt(2.0) / MAX_DENSITY;
    if (length(randomCoord) > minRadius) return 0.0;

    // 5. to get more random distribution,
    // we assume, that snowflake size is 1/8 part of cell
    // then we get random coords between 0.125 and 0.875,
    // so that's why generated snowflakes in different cells are not overlapping
    float radius = 0.125;
    vec2 normalizedRandomCoord = mix(vec2(radius), vec2(1.0 - radius), randomCoord);

    vec2 position = fractionalCoord - normalizedRandomCoord;

    // 6. now snowflakes are just simple dots
    // we smooth dots edges, to make them more snow-alike
    return 1.0 - smoothstep(radius*(.10),radius*(sqrt(2.0)), length(position));
}

vec3 getColor(int color) {
    float red = float(color / 256 / 256);
    float green = float(color / 256 - int(red * 256.0));
    float blue = float(color - int(red * 256.0 * 256.0) - int(green * 256.0));

    return vec3(red / 255.0, green / 255.0, blue / 255.0);
}

void main() {
    vec2 uv = gl_FragCoord.xy/u_resolution;

    float scale = 1.0;
    float sizeScale = 1.0 / u_layersCount;
    float mask = drawSnowFlake(uv, PI * 3.0/8.0, 1.0);

    if (u_layersCount >= 2.0) {
        scale = 4.0 / u_layersCount;
        sizeScale = 2.0 / u_layersCount;
        mask += drawSnowFlake(uv, PI * 5.0/8.0, 2.0);
    }

    if (u_layersCount >= 3.0) {
        scale = 3.0 / u_layersCount;
        sizeScale = 3.0 / u_layersCount;
        mask += drawSnowFlake(uv, PI * 1.0/8.0, 3.0);
    }

    if (u_layersCount >= 4.0) {
        scale = 2.0 / u_layersCount;
        sizeScale = 4.0 / u_layersCount;
        mask += drawSnowFlake(uv, PI * 7.0/8.0, 4.0);
    }

    if (u_layersCount >= 5.0) {
        scale = 1.0 / u_layersCount;
        sizeScale = 5.0 / u_layersCount;
        mask += drawSnowFlake(uv, PI * 4.0/8.0, 5.0);
    }

    vec3 color = mask * getColor(u_color);
    float alpha = mask * u_opacity;

    gl_FragColor = vec4(color, alpha);
}
