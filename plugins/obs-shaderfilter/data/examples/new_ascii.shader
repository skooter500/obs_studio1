// ASCII shader for obs-shaderfilter - Fixed version
uniform int scale<
    string label = "Scale";
    string widget_type = "slider";
    int minimum = 1;
    int maximum = 10;
    int step = 1;
> = 4;

uniform float4 base_color<
    string label = "Base color";
> = {0.0, 1.0, 0.0, 1.0};

uniform bool monochrome<
    string label = "Monochrome";
> = false;

uniform int character_set<
    string label = "Character set";
    string widget_type = "select";
    int option_0_value = 0;
    string option_0_label = "Large set of non-letters";
    int option_1_value = 1;
    string option_1_label = "Small set of capital letters";
> = 0;

float character(int n, float2 p)
{
    p = floor(p * float2(4.0, 4.0) + 2.5);
    if (clamp(p.x, 0.0, 4.0) == p.x && clamp(p.y, 0.0, 4.0) == p.y)	
    {
        int a = int(round(p.x) + 5.0 * round(p.y));
        // Replace bitwise operations with mathematical equivalent
        int divisor = 1;
        for (int i = 0; i < a; i++) {
            divisor *= 2;
        }
        if (((n / divisor) % 2) == 1) return 1.0;
    }
    return 0.0;
}

float2 mod289(float2 x) {
    return x - floor(x / 289.0) * 289.0;
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 iResolution = uv_size;
    float2 pix = v_in.uv * iResolution;
    
    // Sample the input texture
    float2 sampleUV = floor(pix / float2(scale * 8.0, scale * 8.0)) * float2(scale * 8.0, scale * 8.0) / iResolution;
    float4 c = image.Sample(textureSampler, sampleUV);
    
    // Calculate grayscale
    float gray = dot(c.rgb, float3(0.3, 0.59, 0.11));
    
    // Character selection based on brightness
    int n = 0;
    int charset = clamp(character_set, 0, 1);
    
    if (charset == 0) {
        if (gray <= 0.2) n = 4096;     // .
        else if (gray <= 0.3) n = 65600;    // :
        else if (gray <= 0.4) n = 332772;   // *
        else if (gray <= 0.5) n = 15255086; // o 
        else if (gray <= 0.6) n = 23385164; // &
        else if (gray <= 0.7) n = 15252014; // 8
        else if (gray <= 0.8) n = 13199452; // @
        else n = 11512810; // #
    } else {
        if (gray <= 0.1) n = 0;
        else if (gray <= 0.3) n = 9616687;  // R
        else if (gray <= 0.5) n = 32012382; // S
        else if (gray <= 0.7) n = 16303663; // D
        else if (gray <= 0.8) n = 15255086; // O
        else n = 16301615; // B
    }
    
    // Calculate character position
    float2 charPos = fmod(pix / float2(scale * 4.0, scale * 4.0), 2.0) - 1.0;
    
    // Apply character pattern
    float charValue = character(n, charPos);
    
    // Apply color
    if (monochrome) {
        c.rgb = base_color.rgb;
    }
    
    c *= charValue;
    return c;
}