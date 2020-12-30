#include "UCTS_Function.cginc"
uniform sampler2D _Emissive_Tex; uniform float4 _Emissive_Tex_ST;
uniform float4 _Emissive_Color;
//v.2.0.7
uniform fixed _Is_ViewCoord_Scroll;
uniform float _Rotate_EmissiveUV;
uniform float _Base_Speed;
uniform float _Scroll_EmissiveU;
uniform float _Scroll_EmissiveV;
uniform fixed _Is_PingPong_Base;
uniform float4 _ColorShift;
uniform float4 _ViewShift;
uniform float _ColorShift_Speed;
uniform fixed _Is_ColorShift;
uniform fixed _Is_ViewShift;



float3 EmissiveAnimationLightingCalc(float2 Set_UV0,CameraRollDirStruct camera_roll_dir_struct,float3 viewNormal_Emissive,float3 viewDirection,fixed _sign_Mirror)
{
        float3 NormalBlend_Emissive_Detail = viewNormal_Emissive * float3(-1,-1,1);
        float3 NormalBlend_Emissive_Base = UTS_UnityWorldToViewDir( viewDirection) * float3(-1,-1,1) + float3(0,0,1);
        float3 noSknewViewNormal_Emissive = NormalBlend_Emissive_Base*dot(NormalBlend_Emissive_Base, NormalBlend_Emissive_Detail)/NormalBlend_Emissive_Base.z - NormalBlend_Emissive_Detail;
        float2 _ViewNormalAsEmissiveUV = noSknewViewNormal_Emissive.xy * 0.5 + 0.5;
        float2 _ViewCoord_UV = RotateUV(_ViewNormalAsEmissiveUV, -(camera_roll_dir_struct._Camera_Dir*camera_roll_dir_struct._Camera_Roll), float2(0.5,0.5), 1.0);
        //鏡の中ならUV左右反転.
        if(_sign_Mirror < 0){
            _ViewCoord_UV.x = 1-_ViewCoord_UV.x;
        }else{
            _ViewCoord_UV = _ViewCoord_UV;
        }
        float2 emissive_uv;
        if(_Is_ViewCoord_Scroll)
        {
            emissive_uv =  _ViewCoord_UV;
        }else
        {
            emissive_uv = Set_UV0;
        }
        //
        float4 _time_var = _Time.g;
        float _base_Speed_var = (_time_var*_Base_Speed);
        float _Is_PingPong_Base_var;
        if(_Is_PingPong_Base)
        {
            _Is_PingPong_Base_var =  sin(_base_Speed_var);
        }else
        {
            _Is_PingPong_Base_var = _base_Speed_var;
        }
        float2 scrolledUV = emissive_uv - float2(_Scroll_EmissiveU, _Scroll_EmissiveV)*_Is_PingPong_Base_var;
        float rotateVelocity = _Rotate_EmissiveUV*UNITY_PI;
        float2 _rotate_EmissiveUV_var = RotateUV(scrolledUV, rotateVelocity, float2(0.5, 0.5), _Is_PingPong_Base_var);
        float4 _Emissive_Tex_var = tex2D(_Emissive_Tex,TRANSFORM_TEX(Set_UV0, _Emissive_Tex));
        float emissiveMask = _Emissive_Tex_var.a;
        _Emissive_Tex_var = tex2D(_Emissive_Tex,TRANSFORM_TEX(_rotate_EmissiveUV_var, _Emissive_Tex));
        float _colorShift_Speed_var = 1.0 - cos(_time_var*_ColorShift_Speed);
        float viewShift_var = smoothstep( 0.0, 1.0, max(0,dot(normalDirection,viewDirection)));
        float4 colorShift_Color;
        if (_Is_ColorShift)
        {
            colorShift_Color = lerp(_Emissive_Color, _ColorShift, _colorShift_Speed_var);
        }else
        {
            colorShift_Color = _Emissive_Color;
        }
        float4 viewShift_Color = lerp(_ViewShift, colorShift_Color, viewShift_var);
        float4 emissive_Color;
        if(_Is_ViewShift)
        {
            emissive_Color = viewShift_Color;
        }else
        {
            emissive_Color = colorShift_Color;
        }
        float3 emissive = emissive_Color.rgb * _Emissive_Tex_var.rgb * emissiveMask;
    return emissive;
}