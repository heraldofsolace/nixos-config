#version 300 es
// Burst screen shader: chromatic aberration + grain seeded by `time` so it
// flickers. Off by default (decoration.screen_shader = "" in hyprland.lua)
// and only swapped in for a short window on window move/focus (see
// hyprland.lua's shaderBurst()), since `time` requires
// debug:damage_tracking=false to animate - a real, ongoing GPU/battery
// cost if left on permanently, hence keeping this to brief bursts only.

precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;
out vec4 fragColor;

const float ABERRATION = 0.0025;
const float GRAIN_STRENGTH = 0.06;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void main() {
    vec2 uv = v_texcoord;

    float r = texture(tex, uv + vec2(ABERRATION, 0.0)).r;
    float g = texture(tex, uv).g;
    float b = texture(tex, uv - vec2(ABERRATION, 0.0)).b;
    float a = texture(tex, uv).a;

    vec3 color = vec3(r, g, b);
    float grain = (hash(floor(uv * vec2(1920.0, 1080.0)) + time * 60.0) - 0.5) * GRAIN_STRENGTH;
    color += grain;

    fragColor = vec4(clamp(color, 0.0, 1.0), a);
}
