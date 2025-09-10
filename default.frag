#version 440

layout(location = 0) in vec2 qt_TexCoord0;         // coords for source image
layout(location = 1) in vec2 maskSourceTexCoord;   // coords for mask shape

layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
} ubuf;

layout(binding = 1) uniform sampler2D source;      // image
layout(binding = 2) uniform sampler2D mask;        // mask (shape)

void main() {
    vec4 srcColor = texture(source, qt_TexCoord0);
    float maskAlpha = texture(mask, maskSourceTexCoord).a;

    // Multiply the image alpha by the mask
    fragColor = vec4(srcColor.rgb, srcColor.a * maskAlpha) * ubuf.qt_Opacity;
}
