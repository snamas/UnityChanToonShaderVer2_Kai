//UCTS_DoubleShadeWithFeather.cginc
//Unitychan Toon Shader ver.2.0
//v.2.0.7.5
//nobuyuki@unity3d.com
//https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//(C)Unity Technologies Japan/UCL
//#pragma multi_compile _IS_CLIPPING_OFF _IS_CLIPPING_MODE  _IS_CLIPPING_TRANSMODE
//#pragma multi_compile _IS_PASS_FWDBASE _IS_PASS_FWDDELTA
//
#include "UCTS_Function.cginc"
#include "UCTS_HighColorLighting.cginc"
#include "UCTS_RimLighting.cginc"
#include "UCTS_MatCapLighting.cginc"

            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _BaseColor;
            //v.2.0.5
            uniform float4 _Color;
            uniform fixed _Use_BaseAs1st;
            uniform fixed _Use_1stAs2nd;
            //
            uniform fixed _Is_LightColor_Base;
            uniform sampler2D _1st_ShadeMap; uniform float4 _1st_ShadeMap_ST;
            uniform float4 _1st_ShadeColor;
            uniform fixed _Is_LightColor_1st_Shade;
            uniform sampler2D _2nd_ShadeMap; uniform float4 _2nd_ShadeMap_ST;
            uniform float4 _2nd_ShadeColor;
            uniform fixed _Is_LightColor_2nd_Shade;
            uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
            uniform fixed _Is_NormalMapToBase;
            uniform fixed _Set_SystemShadowsToBase;
            uniform float _Tweak_SystemShadowsLevel;
            uniform float _BaseColor_Step;
            uniform float _BaseShade_Feather;
            uniform sampler2D _Set_1st_ShadePosition; uniform float4 _Set_1st_ShadePosition_ST;
            uniform float _ShadeColor_Step;
            uniform float _1st2nd_Shades_Feather;
            uniform sampler2D _Set_2nd_ShadePosition; uniform float4 _Set_2nd_ShadePosition_ST;

            uniform fixed _Is_NormalMapToHighColor;

            uniform fixed _RimLight;
            uniform fixed _Is_NormalMapToRimLight;

            uniform fixed _MatCap;
            uniform fixed _Is_BlendAddToMatCap;
            uniform fixed _Is_NormalMapForMatCap;
            uniform sampler2D _NormalMapForMatCap; uniform float4 _NormalMapForMatCap_ST;
            uniform float _Rotate_NormalMapForMatCapUV;
            uniform fixed _Is_UseTweakMatCapOnShadow;
            uniform float _TweakMatCapOnShadow;
            //v.2.0.6
            uniform float _BumpScale;
            uniform float _BumpScaleMatcap;

            //Emissive
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
            uniform float3 emissive;
            // 
            uniform float _Unlit_Intensity;
            //v.2.0.5
            uniform fixed _Is_Filter_HiCutPointLightColor;
            uniform fixed _Is_Filter_LightColor;
            //v.2.0.4.4
            uniform float _StepOffset;
            uniform fixed _Is_BLD;
            uniform float _Offset_X_Axis_BLD;
            uniform float _Offset_Y_Axis_BLD;
            uniform fixed _Inverse_Z_Axis_BLD;
//v.2.0.4
#ifdef _IS_CLIPPING_MODE
//DoubleShadeWithFeather_Clipping
            uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
            uniform float _Clipping_Level;
            uniform fixed _Inverse_Clipping;
#elif _IS_CLIPPING_TRANSMODE
//DoubleShadeWithFeather_TransClipping
            uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
            uniform fixed _IsBaseMapAlphaAsClippingMask;
            uniform float _Clipping_Level;
            uniform fixed _Inverse_Clipping;
            uniform float _Tweak_transparency;
#elif _IS_CLIPPING_OFF
//DoubleShadeWithFeather
#endif

            
            
            uniform float _GI_Intensity;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                //v.2.0.7
                float mirrorFlag : TEXCOORD5;
                LIGHTING_COORDS(6,7)
                UNITY_FOG_COORDS(8)
                //
            };
            VertexOutput vert(VertexInput v)
{
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                //v.2.0.7 鏡の中判定（右手座標系か、左手座標系かの判定）o.mirrorFlag = -1 なら鏡の中.
                float3 crossFwd = cross(UNITY_MATRIX_V[0], UNITY_MATRIX_V[1]);
                o.mirrorFlag = dot(crossFwd, UNITY_MATRIX_V[2]) < 0 ? 1 : -1;
                //
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i, fixed facing : VFACE) : SV_TARGET
{
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float2 Set_UV0 = i.uv0;
                //v.2.0.6
                //float3 _NormalMap_var = UnpackNormal(tex2D(_NormalMap,TRANSFORM_TEX(Set_UV0, _NormalMap)));
                float3 _NormalMap_var = UnpackScaleNormal(tex2D(_NormalMap,TRANSFORM_TEX(Set_UV0, _NormalMap)), _BumpScale);
                float3 normalLocal = _NormalMap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(Set_UV0, _MainTex));
//v.2.0.4
#ifdef _IS_CLIPPING_MODE
//DoubleShadeWithFeather_Clipping
                float4 _ClippingMask_var = tex2D(_ClippingMask,TRANSFORM_TEX(Set_UV0, _ClippingMask));
                float Set_Clipping;
                if(_Inverse_Clipping)
                {
                    Set_Clipping = saturate((1.0 - _ClippingMask_var.r) +_Clipping_Level);
                }else
                {
                    Set_Clipping = saturate(_ClippingMask_var.r +_Clipping_Level);
                }
                clip(Set_Clipping - 0.5);
#elif _IS_CLIPPING_TRANSMODE
//DoubleShadeWithFeather_TransClipping
                float4 _ClippingMask_var = tex2D(_ClippingMask,TRANSFORM_TEX(Set_UV0, _ClippingMask));
                float Set_MainTexAlpha = _MainTex_var.a;
                float _IsBaseMapAlphaAsClippingMask_var = lerp( _ClippingMask_var.r, Set_MainTexAlpha, _IsBaseMapAlphaAsClippingMask );
                float _Inverse_Clipping_var = lerp( _IsBaseMapAlphaAsClippingMask_var, (1.0 - _IsBaseMapAlphaAsClippingMask_var), _Inverse_Clipping );
                float Set_Clipping = saturate((_Inverse_Clipping_var+_Clipping_Level));
                clip(Set_Clipping - 0.5);

#elif _IS_CLIPPING_OFF
//DoubleShadeWithFeather
#endif

                UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld.xyz);

//v.2.0.4
#ifdef _IS_PASS_FWDBASE
    float3 defaultLightDirection = normalize(UNITY_MATRIX_V[2].xyz + UNITY_MATRIX_V[1].xyz);
    //v.2.0.5
    float3 defaultLightColor = saturate(max(half3(0.05,0.05,0.05)*_Unlit_Intensity,max(ShadeSH9(half4(0.0, 0.0, 0.0, 1.0)),ShadeSH9(half4(0.0, -1.0, 0.0, 1.0)).rgb)*_Unlit_Intensity));
    float3 customLightDirection = normalize(mul( unity_ObjectToWorld, float4(((float3(1.0,0.0,0.0)*_Offset_X_Axis_BLD*10)+(float3(0.0,1.0,0.0)*_Offset_Y_Axis_BLD*10)+(float3(0.0,0.0,-1.0)*lerp(-1.0,1.0,_Inverse_Z_Axis_BLD))),0)).xyz);
    float3 lightDirection;
    if (any(_WorldSpaceLightPos0.xyz))
    {
        lightDirection = normalize(_WorldSpaceLightPos0.xyz);
    }
    else
    {
        lightDirection = defaultLightDirection;
    }
    if (_Is_BLD)
    {
        lightDirection = customLightDirection;
    }
    
    //v.
                //v.2.0.5:
    float3 lightColor;
    if (_Is_Filter_LightColor)
    {
        lightColor = max(defaultLightColor, saturate(_LightColor0.rgb));
    }
    else
    {
        lightColor = max(defaultLightColor, _LightColor0.rgb);
    }
#elif _IS_PASS_FWDDELTA
    float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
    //v.2.0.5: 
    float3 addPassLightColor = (0.5*dot(lerp( i.normalDir, normalDirection, _Is_NormalMapToBase ), lightDirection)+0.5) * _LightColor0.rgb * attenuation;
    float pureIntencity = max(0.001,(0.299*_LightColor0.r + 0.587*_LightColor0.g + 0.114*_LightColor0.b));
    float3 lightColor;
    if(_Is_Filter_LightColor)
    {
        lightColor = max(0, lerp(0,min(addPassLightColor,addPassLightColor/pureIntencity),_WorldSpaceLightPos0.w));
    }else
    {
        lightColor = addPassLightColor;
    }
#endif
////// Lighting:
    float3 halfDirection = normalize(viewDirection+lightDirection);
    //v.2.0.5
    _Color = _BaseColor;

#ifdef _IS_PASS_FWDBASE
    float3 Set_LightColor = lightColor.rgb;
    float3 Set_BaseColor;
    if (_Is_LightColor_Base)
    {
        Set_BaseColor = (_BaseColor.rgb * _MainTex_var.rgb) * Set_LightColor;
    }
    else
    {
        Set_BaseColor = _BaseColor.rgb * _MainTex_var.rgb;
    }
    //v.2.0.5
    float4 _1st_ShadeMap_var;
    if (_Use_BaseAs1st)
    {
        _1st_ShadeMap_var = _MainTex_var;
    }
    else
    {
        _1st_ShadeMap_var = tex2D(_1st_ShadeMap,TRANSFORM_TEX(Set_UV0, _1st_ShadeMap));
    }
    float3 Set_1st_ShadeColor;
    if (_Is_LightColor_1st_Shade)
    {
        Set_1st_ShadeColor = (_1st_ShadeColor.rgb * _1st_ShadeMap_var.rgb) * Set_LightColor;
    }
    else
    {
        Set_1st_ShadeColor = _1st_ShadeColor.rgb * _1st_ShadeMap_var.rgb;
    }
    //v.2.0.5
    float4 _2nd_ShadeMap_var;
    if (_Use_1stAs2nd)
    {
        _2nd_ShadeMap_var = _1st_ShadeMap_var;
    }
    else
    {
        _2nd_ShadeMap_var = tex2D(_2nd_ShadeMap,TRANSFORM_TEX(Set_UV0, _2nd_ShadeMap));
    }
    float3 Set_2nd_ShadeColor;
    if (_Is_LightColor_2nd_Shade)
    {
        Set_2nd_ShadeColor = (_2nd_ShadeColor.rgb * _2nd_ShadeMap_var.rgb) * Set_LightColor;
    }
    else
    {
        Set_2nd_ShadeColor = _2nd_ShadeColor.rgb * _2nd_ShadeMap_var.rgb;
    }
    float _HalfLambert_var;
    if (_Is_NormalMapToBase)
    {
        _HalfLambert_var = 0.5 * dot(normalDirection, lightDirection) + 0.5;
    }
    else
    {
        _HalfLambert_var = 0.5 * dot(i.normalDir, lightDirection) + 0.5;
    }
    float4 _Set_2nd_ShadePosition_var = tex2D(_Set_2nd_ShadePosition,TRANSFORM_TEX(Set_UV0, _Set_2nd_ShadePosition));
    //ライティングに関係なく、１影色の位置を強制的に指定したい場合、ポジションマップを割り当てます。必ず影を落としたい部分を黒で指定します。
    float4 _Set_1st_ShadePosition_var = tex2D(_Set_1st_ShadePosition,TRANSFORM_TEX(Set_UV0, _Set_1st_ShadePosition));
    //v.2.0.6
    //Minmimum value is same as the Minimum Feather's value with the Minimum Step's value as threshold.
    float _SystemShadowsLevel_noclip = (attenuation * 0.5) + 0.5 + _Tweak_SystemShadowsLevel;
    float _SystemShadowsLevel_var = saturate(_SystemShadowsLevel_noclip > 0.001 ? _SystemShadowsLevel_noclip : 0.0001);
    float Set_FinalShadowMask;
    if (_Set_SystemShadowsToBase)
    {
        Set_FinalShadowMask = saturate(
            lerp(
                1,
                (_BaseColor_Step - _HalfLambert_var * _SystemShadowsLevel_var) / _BaseShade_Feather,
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
    //
    //Composition: 3 Basic Colors as Set_FinalBaseColor
    float3 Set_FinalBaseColor = lerp(Set_BaseColor,
                                     lerp(Set_1st_ShadeColor, Set_2nd_ShadeColor,
                                          saturate(
                                              lerp(1, (_ShadeColor_Step - _HalfLambert_var) / _1st2nd_Shades_Feather,
                                                   _Set_2nd_ShadePosition_var.r)
                                          )
                                     ),
                                     Set_FinalShadowMask); // Final Color
    
    
    float _Specular_var;
    if (_Is_NormalMapToHighColor)
    {
        _Specular_var = 0.5 * dot(halfDirection, normalDirection) + 0.5;
    }
    else
    {
        _Specular_var = 0.5 * dot(halfDirection, i.normalDir) + 0.5;
    }
    UTSHighColorStruct uts_high_color_out = UTSHighColorCalc(Set_UV0,_Specular_var,Set_LightColor,Set_FinalShadowMask);
    float3 Set_HighColor = UTSHighColorBlend(uts_high_color_out,Set_FinalBaseColor);
    
    
    //Composition: HighColor and RimLight as _RimLight_var
    float3 _RimLight_var;
    float3 Set_RimLight;
    if (_RimLight)
    {
        float _RimArea_var;
        if (_Is_NormalMapToRimLight)
        {
            _RimArea_var = 1.0 - dot(normalDirection, viewDirection);
        }
        else
        {
            _RimArea_var = 1.0 - dot(i.normalDir, viewDirection);
        }
        float _VertHalfLambert_var = saturate(0.5 * dot(i.normalDir, lightDirection) + 0.5);
        Set_RimLight = UTSRimLightCalc( Set_UV0, _RimArea_var, _VertHalfLambert_var, Set_LightColor);
        _RimLight_var = Set_HighColor + Set_RimLight;
    }
    else
    {
        _RimLight_var = Set_HighColor;
    }

    
    fixed _sign_Mirror = i.mirrorFlag;
    CameraRollDirStruct camera_roll_dir_struct = CameraRollDirCalc(_sign_Mirror);
   
    float3 finalColor; // Final Composition before Emissive
    if (_MatCap)
    {   //Matcap
        //v.2.0.6 : CameraRolling Stabilizer
        //鏡スクリプト判定：_sign_Mirror = -1 なら、鏡の中と判定.
        //v.2.0.7
        //
        float2 _Rot_MatCapNmUV_var = RotateUV(Set_UV0, (_Rotate_NormalMapForMatCapUV * 3.141592654), float2(0.5, 0.5), 1.0);
        //V.2.0.6
        float3 _NormalMapForMatCap_var = UnpackScaleNormal(tex2D(_NormalMapForMatCap,TRANSFORM_TEX(_Rot_MatCapNmUV_var, _NormalMapForMatCap)),_BumpScaleMatcap);
        //v.2.0.5: MatCap with camera skew correction
        float3 viewNormal;
        if (_Is_NormalMapForMatCap)
        {
            viewNormal = UTS_UnityWorldToViewDir(mul(_NormalMapForMatCap_var.rgb, tangentTransform));
            
        }
        else
        {
            viewNormal = UTS_UnityWorldToViewDir(i.normalDir);
        }
        UTSMatCapStruct uts_mat_cap_struct = MatCapColorCalc( Set_UV0, _sign_Mirror,camera_roll_dir_struct,  viewNormal, viewDirection, Set_LightColor);
        
        //v.2.0.6 : ShadowMask on Matcap in Blend mode : multiply
        
        //
        //Composition: RimLight and MatCap as finalColor
        //Broke down finalColor composition
        float3 Set_MatCap;
        float3 matCapColorFinal;
        if (_Is_BlendAddToMatCap)
        {
            if (_Is_UseTweakMatCapOnShadow)
            {
                Set_MatCap = uts_mat_cap_struct._Is_LightColor_MatCap_var * lerp(1, _TweakMatCapOnShadow, Set_FinalShadowMask);
            }
            else
            {
                Set_MatCap = uts_mat_cap_struct._Is_LightColor_MatCap_var;
            }
            float3 matCapColorOnAddMode = Set_MatCap * uts_mat_cap_struct._Tweak_MatcapMaskLevel_var;
            matCapColorFinal = matCapColorOnAddMode + _RimLight_var;
        }else
        {
            float _Tweak_MatcapMaskLevel_var_MultiplyMode;
            if (_Is_UseTweakMatCapOnShadow)
            {
                Set_MatCap = uts_mat_cap_struct._Is_LightColor_MatCap_var * lerp(1, _TweakMatCapOnShadow, Set_FinalShadowMask) + Set_HighColor
                    * Set_FinalShadowMask * (1.0 - _TweakMatCapOnShadow);
                _Tweak_MatcapMaskLevel_var_MultiplyMode = uts_mat_cap_struct._Tweak_MatcapMaskLevel_var * (1.0 - Set_FinalShadowMask * (1.0 -
                    _TweakMatCapOnShadow));
            }
            else
            {
                Set_MatCap = uts_mat_cap_struct._Is_LightColor_MatCap_var;
                _Tweak_MatcapMaskLevel_var_MultiplyMode = uts_mat_cap_struct._Tweak_MatcapMaskLevel_var;
            }
            if (_RimLight)
            {
                matCapColorFinal = lerp(Set_HighColor, Set_HighColor * Set_MatCap, _Tweak_MatcapMaskLevel_var_MultiplyMode) + Set_RimLight;
            }
            else
            {
                matCapColorFinal = lerp(Set_HighColor, Set_HighColor * Set_MatCap, _Tweak_MatcapMaskLevel_var_MultiplyMode);
            }
        }
        finalColor = matCapColorFinal;
    }
    else
    {
        finalColor = _RimLight_var;
    }
    //
    //v.2.0.6: GI_Intensity with Intensity Multiplier Filter
    float3 envLightColor = min(DecodeLightProbe(normalDirection),float3(1, 1, 1));
    float envLightIntensity = min(0.299 * envLightColor.r + 0.587 * envLightColor.g + 0.114 * envLightColor.b,1);
    //v.2.0.7
    float3 emissive;
    #ifdef _EMISSIVE_SIMPLE
        float4 _Emissive_Tex_var = tex2D(_Emissive_Tex,TRANSFORM_TEX(Set_UV0, _Emissive_Tex));
        float emissiveMask = _Emissive_Tex_var.a;
        emissive = _Emissive_Tex_var.rgb * _Emissive_Color.rgb * emissiveMask;
    #elif _EMISSIVE_ANIMATION
        //v.2.0.7 Calculation View Coord UV for Scroll
        float3 viewNormal_Emissive = UTS_UnityWorldToViewDir(i.normalDir);
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
            emissive_uv = i.uv0;
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
        emissive = emissive_Color.rgb * _Emissive_Tex_var.rgb * emissiveMask;
    #endif
    //
    //Final Composition
    finalColor = saturate(finalColor) + (envLightColor * envLightIntensity * _GI_Intensity * smoothstep(
        1, 0, envLightIntensity / 2)) + emissive;

#elif _IS_PASS_FWDDELTA
                //v.2.0.5:
    _BaseColor_Step = saturate(_BaseColor_Step + _StepOffset);
    _ShadeColor_Step = saturate(_ShadeColor_Step + _StepOffset);
    //
    //v.2.0.5: If Added lights is directional, set 0 as _LightIntensity
    float _LightIntensity;
    if(_WorldSpaceLightPos0.w)
    {
        _LightIntensity = (0.299*_LightColor0.r + 0.587*_LightColor0.g + 0.114*_LightColor0.b)*attenuation;
    }else
    {
        _LightIntensity = 0;
    }
                //v.2.0.5: Filtering the high intensity zone of PointLights
    float3 Set_LightColor;
    if(_Is_Filter_HiCutPointLightColor)
    {
        Set_LightColor = lerp(lightColor,min(lightColor,_LightColor0.rgb*attenuation*_BaseColor_Step),_WorldSpaceLightPos0.w);
    }else
    {
        Set_LightColor = lightColor;
    }
//
    float3 Set_BaseColor;
    if(_Is_LightColor_Base)
    {
        Set_BaseColor =  _BaseColor.rgb*_MainTex_var.rgb*Set_LightColor;
    }else
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
    float _HalfLambert_var = 0.5*dot(lerp( i.normalDir, normalDirection, _Is_NormalMapToBase ),lightDirection)+0.5;
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
    
    //v.2.0.6: Add HighColor if _Is_Filter_HiCutPointLightColor is False
    if(!_Is_Filter_HiCutPointLightColor)
    {
        float _Specular_var; //  Specular
        if(_Is_NormalMapToHighColor)
        {
            _Specular_var = 0.5*dot(halfDirection, normalDirection)+0.5;
        }
        else
        {
            _Specular_var = 0.5*dot(halfDirection, i.normalDir)+0.5;
        }//  Specular
        UTSHighColorStruct uts_high_color_out = UTSHighColorCalc(Set_UV0,_Specular_var,Set_LightColor,Set_FinalShadowMask);
        
        finalColor += uts_high_color_out.add_HighColor_var;
    }
    finalColor = saturate(finalColor);
#endif


//v.2.0.4
#ifdef _IS_CLIPPING_OFF
//DoubleShadeWithFeather
	#ifdef _IS_PASS_FWDBASE
	                fixed4 finalRGBA = fixed4(finalColor,1);
	#elif _IS_PASS_FWDDELTA
	                fixed4 finalRGBA = fixed4(finalColor,0);
	#endif
#elif _IS_CLIPPING_MODE
//DoubleShadeWithFeather_Clipping
	#ifdef _IS_PASS_FWDBASE
	                fixed4 finalRGBA = fixed4(finalColor,1);
	#elif _IS_PASS_FWDDELTA
	                fixed4 finalRGBA = fixed4(finalColor,0);
	#endif
#elif _IS_CLIPPING_TRANSMODE
//DoubleShadeWithFeather_TransClipping
    				float Set_Opacity = saturate((_Inverse_Clipping_var+_Tweak_transparency));
	#ifdef _IS_PASS_FWDBASE
                	fixed4 finalRGBA = fixed4(finalColor,Set_Opacity);
	#elif _IS_PASS_FWDDELTA
                	fixed4 finalRGBA = fixed4(finalColor * Set_Opacity,0);
	#endif
#endif
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
