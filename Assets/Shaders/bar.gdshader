shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0); // Controle do progresso da barra

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV); // Usa a coordenada UV normalizada para acessar a textura

    // Adiciona brilho baseado no progresso
    float brightness = mix(1.0, 2.0, progress); // Interpola o brilho de 1.0 (normal) a 2.0 (máximo)

    vec4 bright_color = tex_color * brightness;
    bright_color.a = tex_color.a; // Preserva a transparência original

    COLOR = bright_color;
}
