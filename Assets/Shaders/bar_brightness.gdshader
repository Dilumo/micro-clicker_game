shader_type canvas_item;
render_mode blend_add;

uniform vec2 bar_size = vec2(1.0, 0.1); // Tamanho da barra
uniform float progress : hint_range(0.0, 1.0); // Progresso da barra (0 a 1)
uniform float glow_intensity = 1.0; // Intensidade do brilho
uniform float glow_spread = 0.2; // Controle da expansão do brilho na vertical
uniform float edge_softness = 0.05; // Suavização nas bordas horizontais

void fragment() {
    // Coordenadas UV ajustadas ao tamanho da barra
    vec2 local_uv = UV - vec2(0.5); // Centraliza as UVs em torno de (0,0)
    local_uv *= bar_size; // Escala as UVs para o tamanho da barra

    // Define o limite horizontal ativo com base no progresso
    float horizontal_core = bar_size.x / 2.0; // Mantém as bordas horizontais nas extremidades

    // Calculo de suavização horizontal para evitar cortes abruptos
    float horizontal_falloff = smoothstep(horizontal_core - edge_softness, horizontal_core, abs(local_uv.x));

    // Brilho na vertical com base na distância do núcleo
    float vertical_glow = max(0.0, glow_spread - abs(local_uv.y)) * glow_intensity;

    // Combina o brilho horizontal e vertical
    float glow = vertical_glow * (1.0 - horizontal_falloff);

    // Aplica o brilho ao pixel
    vec4 tex_color = texture(TEXTURE, UV); // Cor base da textura
    COLOR = tex_color + vec4(vec3(glow), glow); // Combinação de brilho e textura
}
