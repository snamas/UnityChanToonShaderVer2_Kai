
uniform float4 _RimLightColor;
uniform fixed _Is_LightColor_RimLight;
uniform float _RimLight_Power;
uniform float _RimLight_InsideMask;
uniform fixed _RimLight_FeatherOff;
uniform fixed _LightDirection_MaskOn;
uniform float _Tweak_LightDirection_MaskLevel;
uniform fixed _Add_Antipodean_RimLight;
uniform float4 _Ap_RimLightColor;
uniform fixed _Is_LightColor_Ap_RimLight;
uniform float _Ap_RimLight_Power;
uniform fixed _Ap_RimLight_FeatherOff;
uniform sampler2D _Set_RimLightMask;
uniform float4 _Set_RimLightMask_ST;
uniform float _Tweak_RimLightMaskLevel;

float3 UTSRimLightCalc(float2 Set_UV0,float _RimArea_var,float _VertHalfLambert_var,float3 Set_LightColor)
{
    float4 _Set_RimLightMask_var = tex2D(_Set_RimLightMask,TRANSFORM_TEX(Set_UV0, _Set_RimLightMask));
    float3 _Is_LightColor_RimLight_var;
    if (_Is_LightColor_RimLight)
    {
        _Is_LightColor_RimLight_var = _RimLightColor.rgb * Set_LightColor;
    }
    else
    {
        _Is_LightColor_RimLight_var = _RimLightColor.rgb;
    }
    float _RimLightPower_var = pow(_RimArea_var, exp2(lerp(3, 0, _RimLight_Power)));
    float _Rimlight_InsideMask_var;
    if (_RimLight_FeatherOff)
    {
        _Rimlight_InsideMask_var = saturate(step(_RimLight_InsideMask, _RimLightPower_var));
    }
    else
    {
        //[_RimLight_InsideMask,1.0]の間にある_RimLightPower_varに当たるまで動かした点までの距離の比が得られる
        _Rimlight_InsideMask_var = saturate((_RimLightPower_var - _RimLight_InsideMask) / (1.0 - _RimLight_InsideMask));
    }
    float3 _LightDirection_MaskOn_var;
    if (_LightDirection_MaskOn)
    {
        _LightDirection_MaskOn_var = _Is_LightColor_RimLight_var * saturate(
            _Rimlight_InsideMask_var - (1.0 - _VertHalfLambert_var + _Tweak_LightDirection_MaskLevel));
    }
    else
    {
        _LightDirection_MaskOn_var = _Is_LightColor_RimLight_var * _Rimlight_InsideMask_var;
    }
    float _ApRimLightPower_var = pow(_RimArea_var, exp2(lerp(3, 0, _Ap_RimLight_Power)));

    float _Ap_Rimlight_InsideMask_var;
    if (_Ap_RimLight_FeatherOff)
    {
        _Ap_Rimlight_InsideMask_var = step(_RimLight_InsideMask, _ApRimLightPower_var);
    }
    else
    {
        _Ap_Rimlight_InsideMask_var = (_ApRimLightPower_var - _RimLight_InsideMask) / (1.0 - _RimLight_InsideMask);
    }
    float3 _Is_LightColor_Ap_RimLight_var;
    if (_Is_LightColor_Ap_RimLight)
    {
        _Is_LightColor_Ap_RimLight_var = _Ap_RimLightColor.rgb * Set_LightColor;
    }
    else
    {
        _Is_LightColor_Ap_RimLight_var = _Ap_RimLightColor.rgb;
    }
    float3 Set_RimLight;
    if (_Add_Antipodean_RimLight)
    {
        Set_RimLight = _LightDirection_MaskOn_var + _Is_LightColor_Ap_RimLight_var * saturate(
            _Ap_Rimlight_InsideMask_var - (_VertHalfLambert_var + _Tweak_LightDirection_MaskLevel));
    }
    else
    {
        Set_RimLight = saturate(_Set_RimLightMask_var.g + _Tweak_RimLightMaskLevel) * _LightDirection_MaskOn_var;
    }
    return Set_RimLight;
}