//UCTS_ShadingGradeMap_Tess.cginc
//Unitychan Toon Shader ver.2.0
//v.2.0.7.5
//nobuyuki@unity3d.com
//https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//(C)Unity Technologies Japan/UCL
//#pragma multi_compile _IS_TRANSCLIPPING_OFF _IS_TRANSCLIPPING_ON
//#pragma multi_compile _IS_ANGELRING_OFF _IS_ANGELRING_ON
//#pragma multi_compile _IS_PASS_FWDBASE _IS_PASS_FWDDELTA
//#include "UCTS_ShadingGradeMap.cginc"
// ※Tessellation対応
//   対応部分のコードは、Nora氏の https://github.com/Stereoarts/UnityChanToonShaderVer2_Tess を参考にしました.
//
#include "../UCTS_ShadingGradeMap.cginc";

            
//Tessellation OFF
#ifndef TESSELLATION_ON
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
//v.2.0.4
#ifdef _IS_ANGELRING_OFF
//
#elif _IS_ANGELRING_ON
                float2 texcoord1 : TEXCOORD1;
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
