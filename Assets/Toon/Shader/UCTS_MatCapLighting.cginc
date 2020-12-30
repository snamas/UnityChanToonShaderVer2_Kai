#include "UCTS_Function.cginc"

//v.2.0.5
uniform fixed _Is_Ortho;
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

UTSMatCapStruct MatCapColorCalc(float2 Set_UV0,float _sign_Mirror,CameraRollDirStruct camera_roll_dir_struct,float3 viewNormal,float3 viewDirection,float3 Set_LightColor){
    
    float3 NormalBlend_MatcapUV_Detail = viewNormal.rgb * float3(-1, -1, 1);
    float3 NormalBlend_MatcapUV_Base = UTS_UnityWorldToViewDir(viewDirection) * float3(-1, -1, 1) + float3(0, 0, 1);
        
    float3 noSknewViewNormal = NormalBlend_MatcapUV_Base * dot(NormalBlend_MatcapUV_Base, NormalBlend_MatcapUV_Detail) /
        NormalBlend_MatcapUV_Base.b - NormalBlend_MatcapUV_Detail;
    float2 _ViewNormalAsMatCapUV;
    if (_Is_Ortho)
    {
        _ViewNormalAsMatCapUV = viewNormal.xy * 0.5 + 0.5;
    }
    else
    {
        _ViewNormalAsMatCapUV = noSknewViewNormal.xy * 0.5 + 0.5;
    }
    if (_sign_Mirror < 0)
    {
        _Rotate_MatCapUV = -1 * _Rotate_MatCapUV;
    }
    float _Rot_MatCapUV_var_ang;
    if (_CameraRolling_Stabilizer)
    {
        _Rot_MatCapUV_var_ang = _Rotate_MatCapUV * 3.141592654 - camera_roll_dir_struct._Camera_Dir * camera_roll_dir_struct._Camera_Roll;
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
