#include "UCTS_Function.cginc"
uniform sampler2D _MatCap_Sampler; uniform float4 _MatCap_Sampler_ST;
uniform float4 _MatCapColor;
uniform fixed _Is_LightColor_MatCap;
uniform float _Tweak_MatCapUV;
uniform float _Rotate_MatCapUV;
//MatcapMask
uniform sampler2D _Set_MatcapMask; uniform float4 _Set_MatcapMask_ST;
uniform float _Tweak_MatcapMaskLevel;
//v.2.0.6
uniform float _CameraRolling_Stabilizer;
uniform fixed _BlurLevelMatcap;
uniform fixed _Inverse_MatcapMask;


struct UTSMatCapStruct
{
    float3 _Is_LightColor_MatCap_var;
    float _Tweak_MatcapMaskLevel_var;
};

UTSMatCapStruct MatCapColorCalc(float2 Set_UV0,float _sign_Mirror,float2 _ViewNormalAsMatCapUV,float3 Set_LightColor){
    float3 _Camera_Right = UNITY_MATRIX_V[0].xyz;
    float3 _Camera_Front = UNITY_MATRIX_V[2].xyz;
    float3 _Up_Unit = float3(0, 1, 0);
    float3 _Right_Axis = cross(_Camera_Front, _Up_Unit);
    //鏡の中なら反転.
    if (_sign_Mirror < 0)
    {
        _Right_Axis = -1 * _Right_Axis;
        _Rotate_MatCapUV = -1 * _Rotate_MatCapUV;
    }
    else
    {
        _Right_Axis = _Right_Axis;
    }
    //_Camera_Right_Magnitudeは常に１になる。謎
    float _Camera_Right_Magnitude = length(_Camera_Right.xyz);
    float _Right_Axis_Magnitude = length(_Right_Axis.xyz);
    float _Camera_Roll_Cos = dot(_Right_Axis, _Camera_Right) / (_Right_Axis_Magnitude * _Camera_Right_Magnitude);
    float _Camera_Roll = acos(clamp(_Camera_Roll_Cos, -1, 1));
    fixed _Camera_Dir = _Camera_Right.y < 0 ? -1 : 1;
    float _Rot_MatCapUV_var_ang;
    if (_CameraRolling_Stabilizer)
    {
        _Rot_MatCapUV_var_ang = _Rotate_MatCapUV * 3.141592654 - _Camera_Dir * _Camera_Roll;
    }
    else
    {
        _Rot_MatCapUV_var_ang = _Rotate_MatCapUV * 3.141592654;
    }
    //v.2.0.7
    
    //v.2.0.7
    //(0.5,0.5)を基準に_Rotate_NormalMapForMatCapUV×π回転させる。
    float2 _Rot_MatCapUV_var = RotateUV((_ViewNormalAsMatCapUV - _Tweak_MatCapUV) / (1.0 - 2 * _Tweak_MatCapUV),
                                        _Rot_MatCapUV_var_ang, float2(0.5, 0.5), 1.0);
    //鏡の中ならUV左右反転.
    if (_sign_Mirror < 0)
    {
        _Rot_MatCapUV_var.x = 1 - _Rot_MatCapUV_var.x;
    }
    else
    {
        _Rot_MatCapUV_var = _Rot_MatCapUV_var;
    }
    //v.2.0.6 : LOD of Matcap
    float4 _MatCap_Sampler_var = tex2Dlod(_MatCap_Sampler,
                                          float4(
                                              TRANSFORM_TEX(_Rot_MatCapUV_var, _MatCap_Sampler), 0.0,
                                              _BlurLevelMatcap));
    //
    //MatcapMask
    float4 _Set_MatcapMask_var = tex2D(_Set_MatcapMask,TRANSFORM_TEX(Set_UV0, _Set_MatcapMask));
    float _Tweak_MatcapMaskLevel_var = saturate(
        lerp(_Set_MatcapMask_var.g, (1.0 - _Set_MatcapMask_var.g), _Inverse_MatcapMask) + _Tweak_MatcapMaskLevel);
    if (_Inverse_MatcapMask)
    {
        _Tweak_MatcapMaskLevel_var = saturate((1.0 - _Set_MatcapMask_var.g) + _Tweak_MatcapMaskLevel);
    }
    else
    {
        _Tweak_MatcapMaskLevel_var = saturate(_Set_MatcapMask_var.g + _Tweak_MatcapMaskLevel);
    }
    //
    float3 _Is_LightColor_MatCap_var;
    if (_Is_LightColor_MatCap)
    {
        _Is_LightColor_MatCap_var = (_MatCap_Sampler_var.rgb * _MatCapColor.rgb) * Set_LightColor;
    }
    else
    {
        _Is_LightColor_MatCap_var = _MatCap_Sampler_var.rgb * _MatCapColor.rgb;
    }
    UTSMatCapStruct uts_mat_cap_struct = {
        _Is_LightColor_MatCap_var,
        _Tweak_MatcapMaskLevel_var
    };
    return uts_mat_cap_struct;
}
float3 matCapColorFinalCalc(UTSMatCapStruct uts_mat_cap_struct)
{
    
}
