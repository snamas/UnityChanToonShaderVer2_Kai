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

struct CameraRollDirStruct
{
    float _Camera_Roll;
    fixed _Camera_Dir;
};
CameraRollDirStruct CameraRollDirCalc(float _sign_Mirror)
{
    float3 _Camera_Right = UNITY_MATRIX_V[0].xyz;
    float3 _Camera_Front = UNITY_MATRIX_V[2].xyz;
    float3 _Up_Unit = float3(0, 1, 0);
    float3 _Right_Axis = cross(_Camera_Front, _Up_Unit);
    //鏡の中なら反転.
    if (_sign_Mirror < 0)
    {
        _Right_Axis = -1 * _Right_Axis;
    }
    //_Camera_Right_Magnitudeは常に１になる。謎
    float _Camera_Right_Magnitude = length(_Camera_Right.xyz);
    float _Right_Axis_Magnitude = length(_Right_Axis.xyz);
    float _Camera_Roll_Cos = dot(_Right_Axis, _Camera_Right) / (_Right_Axis_Magnitude * _Camera_Right_Magnitude);
    float _Camera_Roll = acos(clamp(_Camera_Roll_Cos, -1, 1));
    fixed _Camera_Dir = _Camera_Right.y < 0 ? -1 : 1;
    CameraRollDirStruct camera_roll_dir_struct = {
        _Camera_Roll,
        _Camera_Dir
    };
    return camera_roll_dir_struct;
    
}
#endif