//UCTS_ShadowCaster_Tess.cginc
//Unitychan Toon Shader ver.2.0
//v.2.0.7.5
//nobuyuki@unity3d.com
//https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//(C)Unity Technologies Japan/UCL
//#pragma multi_compile _IS_CLIPPING_OFF _IS_CLIPPING_MODE  _IS_CLIPPING_TRANSMODE
// ※Tessellation対応
//   対応部分のコードは、Nora氏の https://github.com/Stereoarts/UnityChanToonShaderVer2_Tess を参考にしました.
//
#include "../UCTS_ShadowCaster.cginc";

//Tessellation OFF
#ifndef TESSELLATION_ON
            struct VertexInput {
                float4 vertex : POSITION;
#ifdef _IS_CLIPPING_MODE
//_Clipping
                 float2 texcoord0 : TEXCOORD0;
#elif _IS_CLIPPING_TRANSMODE
//_TransClipping
                 float2 texcoord0 : TEXCOORD0;
#elif _IS_CLIPPING_OFF
//Default
#endif
            };
#endif


//Tessellation ON
#ifdef TESSELLATION_ON
#ifdef UNITY_CAN_COMPILE_TESSELLATION
            // tessellation domain shader
            [UNITY_domain("tri")]
            VertexOutput ds_surf(UnityTessellationFactors tessFactors, const OutputPatch<InternalTessInterp_VertexInput, 3> vi, float3 bary : SV_DomainLocation)
            {
                VertexInput v = _ds_VertexInput(tessFactors, vi, bary);
                return vert(v);
            }
#endif // UNITY_CAN_COMPILE_TESSELLATION
#endif // TESSELLATION_ON
