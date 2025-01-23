shader_type canvas_item;

// Screen Texture
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Settings
uniform float Transparency : hint_range(1.0, 20.0) = 4.0; // Transparência do efeito
uniform float GrainScale : hint_range(50.0, 500.0) = 150.0; // Escala do granulado (tamanho dos pontos)
uniform float TransitionSpeed : hint_range(0.1, 5.0) = 0.5; // Velocidade de alternância entre padrões

// Função para gerar ruído aleatório baseado em coordenadas
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Função de mistura para alternar entre dois padrões
float alternating_noise(vec2 uv, float time) {
    float noise1 = random(uv);
    float noise2 = random(uv + vec2(0.5)); // Um segundo padrão com deslocamento
    float blend_factor = 0.5 + 0.5 * sin(time); // Alternância suave entre padrões
    return mix(noise1, noise2, blend_factor);
}

void fragment() {
    // Sample a cor da tela
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Garantir que a transparência não seja zero
    float effective_transparency = max(Transparency, 1.0);

    // Coordenadas ajustadas para granularidade
    vec2 noise_coords = SCREEN_UV * GrainScale;

    // Gerar valor de ruído com alternância dinâmica
    float noise_value = alternating_noise(noise_coords, TIME * TransitionSpeed);

    // Cor do ruído (escala de cinza)
    vec4 noise_color = vec4(vec3(noise_value), 1.0);

    // Combinar a cor da tela com o ruído ajustado pela transparência
    COLOR = mix(screen_color, noise_color, 1.0 / effective_transparency);
}
