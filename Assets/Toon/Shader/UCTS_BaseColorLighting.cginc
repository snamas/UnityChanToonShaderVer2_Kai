float3 BaseColorCalc(float _LightIntensity)
{
    if (_Is_LightColor_Base)
    {
        Set_BaseColor =  _BaseColor.rgb*_MainTex_var.rgb*Set_LightColor;
    }
    else
    {
        Set_BaseColor = _BaseColor.rgb*_MainTex_var.rgb*_LightIntensity;
    }
    //v.2.0.5
    float4 _1st_ShadeMap_var;
    if (_Use_BaseAs1st)
    {
        _1st_ShadeMap_var = _MainTex_var;
    }else
    {
        _1st_ShadeMap_var = tex2D(_1st_ShadeMap,TRANSFORM_TEX(Set_UV0, _1st_ShadeMap));
    }
    float3 Set_1st_ShadeColor;
    if(_Is_LightColor_1st_Shade)
    {
        Set_1st_ShadeColor = _1st_ShadeColor.rgb*_1st_ShadeMap_var.rgb*Set_LightColor;
    }else
    {
        Set_1st_ShadeColor = _1st_ShadeColor.rgb*_1st_ShadeMap_var.rgb*_LightIntensity;
    }
    //v.2.0.5
    float4 _2nd_ShadeMap_var;
    if(_Use_1stAs2nd)
    {
        _2nd_ShadeMap_var = _1st_ShadeMap_var;
    }else
    {
        _2nd_ShadeMap_var = tex2D(_2nd_ShadeMap,TRANSFORM_TEX(Set_UV0, _2nd_ShadeMap));
    }
    float3 Set_2nd_ShadeColor;
    if(_Is_LightColor_2nd_Shade)
    {
        Set_2nd_ShadeColor = _2nd_ShadeColor.rgb*_2nd_ShadeMap_var.rgb*Set_LightColor;
    }else
    {
        Set_2nd_ShadeColor = _2nd_ShadeColor.rgb*_2nd_ShadeMap_var.rgb*_LightIntensity;
    }
    float _HalfLambert_var;
    if(_Is_NormalMapToBase)
    {
        _HalfLambert_var = 0.5*dot(normalDirection,lightDirection)+0.5;
    }else
    {
        _HalfLambert_var = 0.5*dot(i.normalDir,lightDirection)+0.5;
    }
    float4 _Set_2nd_ShadePosition_var = tex2D(_Set_2nd_ShadePosition,TRANSFORM_TEX(Set_UV0, _Set_2nd_ShadePosition));
    float4 _Set_1st_ShadePosition_var = tex2D(_Set_1st_ShadePosition,TRANSFORM_TEX(Set_UV0, _Set_1st_ShadePosition));
    //v.2.0.5:
    float Set_FinalShadowMask;
    if (_Set_SystemShadowsToBase)
    {
        Set_FinalShadowMask = saturate(
            lerp(
                1,
                (_BaseColor_Step - _HalfLambert_var * saturate(1.0+_Tweak_SystemShadowsLevel)) / _BaseShade_Feather,
                _Set_1st_ShadePosition_var.r
            )
        );
    }
    else
    {
        Set_FinalShadowMask = saturate(
            lerp(
                1,
                (_BaseColor_Step - _HalfLambert_var) / _BaseShade_Feather,
                _Set_1st_ShadePosition_var.r
            )
        );
    }
    //Composition: 3 Basic Colors as finalColor
    float3 finalColor = lerp(Set_BaseColor,
                                lerp(Set_1st_ShadeColor, Set_2nd_ShadeColor,
                                     saturate(
                                         lerp(1, (_ShadeColor_Step - _HalfLambert_var) / _1st2nd_Shades_Feather,
                                              _Set_2nd_ShadePosition_var.r)
                                     )
                                ),
                                Set_FinalShadowMask); // Final Color
    return finalColor;
}