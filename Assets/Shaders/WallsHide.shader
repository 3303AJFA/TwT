Shader "CustomShaders/WallsHide"
{
    Properties
    {
        [NoScaleOffset]_MainTexture("MainTexture", 2D) = "white" {}
        _Tint("Tint", Color) = (0, 0, 0, 0)
        _Position("PlayerPosition", Vector) = (0.5, 0.5, 0, 0)
        _Size("Size", Float) = 1
        _Opacity("Opacity", Range(0, 1)) = 0
        _NoiseScale("NoiseScale", Float) = 500
        _NoiseStrength("NoiseStrength", Float) = 2
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Opacity;
        float _NoiseScale;
        float _NoiseStrength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTexture);
            float4 _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D.tex, _Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D.samplerstate, _Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_R_4_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.r;
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_G_5_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.g;
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_B_6_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.b;
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_A_7_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.a;
            float4 _Property_f6789ba6a4034e0f9e935d37d25559fd_Out_0_Vector4 = _Tint;
            float4 _Multiply_ac939a0fef8a41ecb779fcd8537732d9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4, _Property_f6789ba6a4034e0f9e935d37d25559fd_Out_0_Vector4, _Multiply_ac939a0fef8a41ecb779fcd8537732d9_Out_2_Vector4);
            float _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float = _NoiseScale;
            float _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(IN.uv0.xy, _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float, _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float);
            float _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float = _NoiseStrength;
            float _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float, _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float);
            float4 _ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2 = _Position;
            float2 _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2;
            Unity_Remap_float2(_Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2);
            float2 _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2, _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2);
            float2 _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), float2 (1, 1), _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2, _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2);
            float2 _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2, float2(2, 2), _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2);
            float2 _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2, float2(1, 1), _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2);
            float _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float);
            float _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float = _Size;
            float _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float, _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float);
            float2 _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2 = float2(_Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float);
            float2 _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2, _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2, _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2);
            float _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float;
            Unity_Length_float2(_Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2, _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float);
            float _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float;
            Unity_OneMinus_float(_Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float, _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float);
            float _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float;
            Unity_Saturate_float(_OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float);
            float _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float;
            Unity_Smoothstep_float(0, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float, _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float);
            float _Property_bd9094e9fd51437180156838d125c171_Out_0_Float = _Opacity;
            float _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float, _Property_bd9094e9fd51437180156838d125c171_Out_0_Float, _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float);
            float _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            Unity_OneMinus_float(_Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float, _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float);
            surface.BaseColor = (_Multiply_ac939a0fef8a41ecb779fcd8537732d9_Out_2_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            surface.AlphaClipThreshold = 0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Opacity;
        float _NoiseScale;
        float _NoiseStrength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTexture);
            float4 _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D.tex, _Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D.samplerstate, _Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_R_4_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.r;
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_G_5_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.g;
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_B_6_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.b;
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_A_7_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.a;
            float4 _Property_f6789ba6a4034e0f9e935d37d25559fd_Out_0_Vector4 = _Tint;
            float4 _Multiply_ac939a0fef8a41ecb779fcd8537732d9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4, _Property_f6789ba6a4034e0f9e935d37d25559fd_Out_0_Vector4, _Multiply_ac939a0fef8a41ecb779fcd8537732d9_Out_2_Vector4);
            float _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float = _NoiseScale;
            float _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(IN.uv0.xy, _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float, _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float);
            float _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float = _NoiseStrength;
            float _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float, _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float);
            float4 _ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2 = _Position;
            float2 _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2;
            Unity_Remap_float2(_Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2);
            float2 _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2, _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2);
            float2 _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), float2 (1, 1), _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2, _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2);
            float2 _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2, float2(2, 2), _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2);
            float2 _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2, float2(1, 1), _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2);
            float _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float);
            float _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float = _Size;
            float _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float, _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float);
            float2 _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2 = float2(_Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float);
            float2 _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2, _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2, _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2);
            float _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float;
            Unity_Length_float2(_Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2, _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float);
            float _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float;
            Unity_OneMinus_float(_Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float, _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float);
            float _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float;
            Unity_Saturate_float(_OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float);
            float _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float;
            Unity_Smoothstep_float(0, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float, _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float);
            float _Property_bd9094e9fd51437180156838d125c171_Out_0_Float = _Opacity;
            float _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float, _Property_bd9094e9fd51437180156838d125c171_Out_0_Float, _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float);
            float _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            Unity_OneMinus_float(_Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float, _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float);
            surface.BaseColor = (_Multiply_ac939a0fef8a41ecb779fcd8537732d9_Out_2_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            surface.AlphaClipThreshold = 0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Opacity;
        float _NoiseScale;
        float _NoiseStrength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float = _NoiseScale;
            float _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(IN.uv0.xy, _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float, _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float);
            float _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float = _NoiseStrength;
            float _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float, _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float);
            float4 _ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2 = _Position;
            float2 _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2;
            Unity_Remap_float2(_Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2);
            float2 _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2, _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2);
            float2 _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), float2 (1, 1), _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2, _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2);
            float2 _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2, float2(2, 2), _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2);
            float2 _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2, float2(1, 1), _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2);
            float _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float);
            float _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float = _Size;
            float _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float, _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float);
            float2 _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2 = float2(_Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float);
            float2 _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2, _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2, _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2);
            float _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float;
            Unity_Length_float2(_Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2, _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float);
            float _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float;
            Unity_OneMinus_float(_Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float, _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float);
            float _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float;
            Unity_Saturate_float(_OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float);
            float _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float;
            Unity_Smoothstep_float(0, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float, _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float);
            float _Property_bd9094e9fd51437180156838d125c171_Out_0_Float = _Opacity;
            float _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float, _Property_bd9094e9fd51437180156838d125c171_Out_0_Float, _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float);
            float _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            Unity_OneMinus_float(_Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float, _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float);
            surface.Alpha = _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            surface.AlphaClipThreshold = 0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Opacity;
        float _NoiseScale;
        float _NoiseStrength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float = _NoiseScale;
            float _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(IN.uv0.xy, _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float, _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float);
            float _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float = _NoiseStrength;
            float _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float, _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float);
            float4 _ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2 = _Position;
            float2 _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2;
            Unity_Remap_float2(_Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2);
            float2 _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2, _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2);
            float2 _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), float2 (1, 1), _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2, _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2);
            float2 _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2, float2(2, 2), _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2);
            float2 _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2, float2(1, 1), _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2);
            float _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float);
            float _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float = _Size;
            float _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float, _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float);
            float2 _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2 = float2(_Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float);
            float2 _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2, _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2, _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2);
            float _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float;
            Unity_Length_float2(_Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2, _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float);
            float _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float;
            Unity_OneMinus_float(_Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float, _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float);
            float _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float;
            Unity_Saturate_float(_OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float);
            float _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float;
            Unity_Smoothstep_float(0, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float, _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float);
            float _Property_bd9094e9fd51437180156838d125c171_Out_0_Float = _Opacity;
            float _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float, _Property_bd9094e9fd51437180156838d125c171_Out_0_Float, _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float);
            float _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            Unity_OneMinus_float(_Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float, _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            surface.AlphaClipThreshold = 0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Opacity;
        float _NoiseScale;
        float _NoiseStrength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTexture);
            float4 _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D.tex, _Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D.samplerstate, _Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_R_4_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.r;
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_G_5_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.g;
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_B_6_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.b;
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_A_7_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.a;
            float4 _Property_f6789ba6a4034e0f9e935d37d25559fd_Out_0_Vector4 = _Tint;
            float4 _Multiply_ac939a0fef8a41ecb779fcd8537732d9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4, _Property_f6789ba6a4034e0f9e935d37d25559fd_Out_0_Vector4, _Multiply_ac939a0fef8a41ecb779fcd8537732d9_Out_2_Vector4);
            float _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float = _NoiseScale;
            float _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(IN.uv0.xy, _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float, _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float);
            float _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float = _NoiseStrength;
            float _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float, _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float);
            float4 _ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2 = _Position;
            float2 _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2;
            Unity_Remap_float2(_Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2);
            float2 _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2, _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2);
            float2 _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), float2 (1, 1), _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2, _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2);
            float2 _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2, float2(2, 2), _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2);
            float2 _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2, float2(1, 1), _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2);
            float _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float);
            float _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float = _Size;
            float _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float, _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float);
            float2 _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2 = float2(_Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float);
            float2 _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2, _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2, _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2);
            float _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float;
            Unity_Length_float2(_Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2, _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float);
            float _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float;
            Unity_OneMinus_float(_Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float, _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float);
            float _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float;
            Unity_Saturate_float(_OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float);
            float _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float;
            Unity_Smoothstep_float(0, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float, _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float);
            float _Property_bd9094e9fd51437180156838d125c171_Out_0_Float = _Opacity;
            float _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float, _Property_bd9094e9fd51437180156838d125c171_Out_0_Float, _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float);
            float _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            Unity_OneMinus_float(_Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float, _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float);
            surface.BaseColor = (_Multiply_ac939a0fef8a41ecb779fcd8537732d9_Out_2_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            surface.AlphaClipThreshold = 0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Opacity;
        float _NoiseScale;
        float _NoiseStrength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float = _NoiseScale;
            float _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(IN.uv0.xy, _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float, _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float);
            float _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float = _NoiseStrength;
            float _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float, _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float);
            float4 _ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2 = _Position;
            float2 _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2;
            Unity_Remap_float2(_Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2);
            float2 _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2, _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2);
            float2 _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), float2 (1, 1), _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2, _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2);
            float2 _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2, float2(2, 2), _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2);
            float2 _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2, float2(1, 1), _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2);
            float _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float);
            float _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float = _Size;
            float _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float, _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float);
            float2 _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2 = float2(_Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float);
            float2 _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2, _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2, _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2);
            float _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float;
            Unity_Length_float2(_Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2, _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float);
            float _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float;
            Unity_OneMinus_float(_Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float, _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float);
            float _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float;
            Unity_Saturate_float(_OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float);
            float _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float;
            Unity_Smoothstep_float(0, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float, _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float);
            float _Property_bd9094e9fd51437180156838d125c171_Out_0_Float = _Opacity;
            float _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float, _Property_bd9094e9fd51437180156838d125c171_Out_0_Float, _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float);
            float _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            Unity_OneMinus_float(_Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float, _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float);
            surface.Alpha = _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            surface.AlphaClipThreshold = 0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Opacity;
        float _NoiseScale;
        float _NoiseStrength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float = _NoiseScale;
            float _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(IN.uv0.xy, _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float, _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float);
            float _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float = _NoiseStrength;
            float _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float, _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float);
            float4 _ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2 = _Position;
            float2 _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2;
            Unity_Remap_float2(_Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2);
            float2 _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2, _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2);
            float2 _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), float2 (1, 1), _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2, _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2);
            float2 _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2, float2(2, 2), _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2);
            float2 _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2, float2(1, 1), _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2);
            float _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float);
            float _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float = _Size;
            float _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float, _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float);
            float2 _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2 = float2(_Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float);
            float2 _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2, _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2, _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2);
            float _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float;
            Unity_Length_float2(_Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2, _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float);
            float _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float;
            Unity_OneMinus_float(_Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float, _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float);
            float _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float;
            Unity_Saturate_float(_OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float);
            float _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float;
            Unity_Smoothstep_float(0, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float, _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float);
            float _Property_bd9094e9fd51437180156838d125c171_Out_0_Float = _Opacity;
            float _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float, _Property_bd9094e9fd51437180156838d125c171_Out_0_Float, _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float);
            float _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            Unity_OneMinus_float(_Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float, _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float);
            surface.Alpha = _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            surface.AlphaClipThreshold = 0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Opacity;
        float _NoiseScale;
        float _NoiseStrength;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        float Unity_SimpleNoise_ValueNoise_Deterministic_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_Tchou_2_1_float(c0, r0);
            float r1; Hash_Tchou_2_1_float(c1, r1);
            float r2; Hash_Tchou_2_1_float(c2, r2);
            float r3; Hash_Tchou_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_Deterministic_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_Deterministic_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTexture);
            float4 _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D.tex, _Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D.samplerstate, _Property_5ee003174cdb41e2b52244aab4d5e4ef_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_R_4_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.r;
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_G_5_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.g;
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_B_6_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.b;
            float _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_A_7_Float = _SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4.a;
            float4 _Property_f6789ba6a4034e0f9e935d37d25559fd_Out_0_Vector4 = _Tint;
            float4 _Multiply_ac939a0fef8a41ecb779fcd8537732d9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_2241d3ac1834462492f448c3607d56d4_RGBA_0_Vector4, _Property_f6789ba6a4034e0f9e935d37d25559fd_Out_0_Vector4, _Multiply_ac939a0fef8a41ecb779fcd8537732d9_Out_2_Vector4);
            float _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float = _NoiseScale;
            float _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float;
            Unity_SimpleNoise_Deterministic_float(IN.uv0.xy, _Property_d59fb5e2866e4e9bb40dc19d1ebbf3e4_Out_0_Float, _SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float);
            float _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float = _NoiseStrength;
            float _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_43c95bf1cc1a4f9f9b18cbcd6f240095_Out_2_Float, _Property_06bae5912bd04592b3044ea4b3f7adc3_Out_0_Float, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float);
            float4 _ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2 = _Position;
            float2 _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2;
            Unity_Remap_float2(_Property_79e8072d926b46bc929bca879837b346_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2);
            float2 _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), _Remap_878ec42c85ec4b408dcb5912a701eaed_Out_3_Vector2, _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2);
            float2 _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_696ff4fe751d44ce87bb26273ad1eae5_Out_0_Vector4.xy), float2 (1, 1), _Add_7fd904ea1e854510a8f721ec3bfea14e_Out_2_Vector2, _TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2);
            float2 _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_1763bdb76718464e9f089afe0bfdb448_Out_3_Vector2, float2(2, 2), _Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2);
            float2 _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_779c5e91d02749ad8b7ccc2ac85168b4_Out_2_Vector2, float2(1, 1), _Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2);
            float _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float);
            float _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float = _Size;
            float _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float;
            Unity_Multiply_float_float(_Divide_3fe97c91f01a47f9978b4680a8d729cf_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float, _Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float);
            float2 _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2 = float2(_Multiply_baf8fe31348d40c4a7880bbbc098554a_Out_2_Float, _Property_67ea4dedb4ac4f3c88d1814c76fef245_Out_0_Float);
            float2 _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_f8af4af8bd39440d94d9ef4763e995d7_Out_2_Vector2, _Vector2_3cb23875bba74bcd85fa1ddabc99a95b_Out_0_Vector2, _Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2);
            float _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float;
            Unity_Length_float2(_Divide_225cd534a932418f81b7bbf6c13b5c25_Out_2_Vector2, _Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float);
            float _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float;
            Unity_OneMinus_float(_Length_b0b7efbb72bc410fb166e929df023674_Out_1_Float, _OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float);
            float _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float;
            Unity_Saturate_float(_OneMinus_af872025e3c540eaa3dbc46d4a537eda_Out_1_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float);
            float _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float;
            Unity_Smoothstep_float(0, _Multiply_4cef48fdbc22455ab5629e522261bcfd_Out_2_Float, _Saturate_c04caaf8c17145b688161613b87ac3c5_Out_1_Float, _Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float);
            float _Property_bd9094e9fd51437180156838d125c171_Out_0_Float = _Opacity;
            float _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_a4267e1fd20b4b4087b6a24c66e5f640_Out_3_Float, _Property_bd9094e9fd51437180156838d125c171_Out_0_Float, _Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float);
            float _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            Unity_OneMinus_float(_Multiply_b50b0c5313f84156915fce6259b8520f_Out_2_Float, _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float);
            surface.BaseColor = (_Multiply_ac939a0fef8a41ecb779fcd8537732d9_Out_2_Vector4.xyz);
            surface.Alpha = _OneMinus_4e370c25eac9456bbcc87edf46526f3e_Out_1_Float;
            surface.AlphaClipThreshold = 0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}