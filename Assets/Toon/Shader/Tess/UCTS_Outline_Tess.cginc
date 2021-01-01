//UCTS_Outline_tess.cginc
//Unitychan Toon Shader ver.2.0
//v.2.0.7.5
//nobuyuki@unity3d.com
//https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//(C)Unity Technologies Japan/UCL
// カメラオフセット付きアウトライン（BaseColorライトカラー反映修正版/Tessellation対応版）
// 2018/02/05 Outline Tex対応版
// #pragma multi_compile _IS_OUTLINE_CLIPPING_NO _IS_OUTLINE_CLIPPING_YES 
// _IS_OUTLINE_CLIPPING_YESは、Clippigマスクを使用するシェーダーでのみ使用できる. OutlineのブレンドモードにBlend SrcAlpha OneMinusSrcAlphaを追加すること.
// ※Tessellation対応
//   対応部分のコードは、Nora氏の https://github.com/Stereoarts/UnityChanToonShaderVer2_Tess を参考にしました.
//
#include "../UCTS_Outline.cginc";
#ifdef TESSELLATION_ON
			#include "UCTS_Tess.cginc"
#endif
#ifndef TESSELLATION_ON
			uniform float4 _LightColor0;
#endif
#ifndef TESSELLATION_ON
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
#endif

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

