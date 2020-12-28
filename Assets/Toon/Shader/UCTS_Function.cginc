#ifndef UCTS_FUNCTION
#define UCTS_FUNCTION
// UV回転をする関数：RotateUV()
//float2 rotatedUV = RotateUV(i.uv0, (_angular_Verocity*3.141592654), float2(0.5, 0.5), _Time.g);
float2 RotateUV(float2 _uv, float _radian, float2 _piv, float _time)
{
    float RotateUV_ang = _radian;
    float RotateUV_cos = cos(_time*RotateUV_ang);
    float RotateUV_sin = sin(_time*RotateUV_ang);
    return (mul(_uv - _piv, float2x2( RotateUV_cos, -RotateUV_sin, RotateUV_sin, RotateUV_cos)) + _piv);
}

float3 UTS_UnityWorldToViewDir(float3 dirWS)
{
    return mul((float3x3)UNITY_MATRIX_V, dirWS).xyz;
}

//
fixed3 DecodeLightProbe( fixed3 N ){
    return ShadeSH9(float4(N,1));
}
#endif