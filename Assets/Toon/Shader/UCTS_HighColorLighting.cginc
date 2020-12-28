uniform float4 _HighColor;
uniform sampler2D _HighColor_Tex;
uniform float4 _HighColor_Tex_ST;
uniform fixed _Is_LightColor_HighColor;
uniform float _HighColor_Power;
uniform fixed _Is_SpecularToHighColor;
uniform fixed _Is_BlendAddToHiColor;
uniform fixed _Is_UseTweakHighColorOnShadow;
uniform float _TweakHighColorOnShadow;
uniform sampler2D _Set_HighColorMask;
uniform float4 _Set_HighColorMask_ST;
uniform float _Tweak_HighColorMaskLevel;

struct UTSHighColorStruct
{
    float3 add_HighColor_var;
    float _TweakHighColorMask_var;
};

UTSHighColorStruct UTSHighColorCalc(float2 Set_UV0,float _Specular_var,float3 Set_LightColor,float Set_FinalShadowMask)
{
    float4 _Set_HighColorMask_var = tex2D(_Set_HighColorMask,TRANSFORM_TEX(Set_UV0, _Set_HighColorMask));
    UTSHighColorStruct o;
    //  Specular
    if (_Is_SpecularToHighColor)
    {
        o._TweakHighColorMask_var = saturate(_Set_HighColorMask_var.g + _Tweak_HighColorMaskLevel) *
            pow(_Specular_var, exp2(lerp(11, 1, _HighColor_Power)));
    }
    else
    {
        o._TweakHighColorMask_var = saturate(_Set_HighColorMask_var.g + _Tweak_HighColorMaskLevel) *
            (1.0 - step(_Specular_var, 1.0 - pow(_HighColor_Power, 5)));
    }
    float4 _HighColor_Tex_var = tex2D(_HighColor_Tex,TRANSFORM_TEX(Set_UV0, _HighColor_Tex));
    float3 _HighColor_var;
    if (_Is_LightColor_HighColor)
    {
        _HighColor_var = _HighColor_Tex_var.rgb * _HighColor.rgb * Set_LightColor * o._TweakHighColorMask_var;
    }
    else
    {
        _HighColor_var = _HighColor_Tex_var.rgb * _HighColor.rgb * o._TweakHighColorMask_var;
    }
    //Composition: 3 Basic Colors and HighColor as Set_HighColor
    if (_Is_UseTweakHighColorOnShadow)
    {
        o.add_HighColor_var = _HighColor_var * lerp(1, _TweakHighColorOnShadow, Set_FinalShadowMask);
    }
    else
    {
        o.add_HighColor_var = _HighColor_var;
    }
    return o;
}
float3 UTSHighColorBlend(UTSHighColorStruct uts_high_color_out,float3 Set_FinalBaseColor)
{
    float3 Set_HighColor;
    if (_Is_BlendAddToHiColor)
    {
        Set_HighColor = Set_FinalBaseColor + uts_high_color_out.add_HighColor_var;
    }
    else
    {
        if (_Is_SpecularToHighColor)
        {
            Set_HighColor = Set_FinalBaseColor + uts_high_color_out.add_HighColor_var;
        }
        else
        {
            Set_HighColor = saturate(Set_FinalBaseColor - uts_high_color_out._TweakHighColorMask_var) + uts_high_color_out.add_HighColor_var;
        }
    }
    return Set_HighColor;
}