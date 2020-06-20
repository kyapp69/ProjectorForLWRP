﻿Shader "Projector For LWRP/ShadowBuffer/Apply Shadow Buffer"
{
    Properties
    {
		_Offset ("Offset", Range (-1, -10)) = -1.0
		_OffsetSlope ("Offset Slope Factor", Range (0, -1)) = -1.0
    }
    SubShader
    {
		Tags {"Queue"="Transparent-1" "P4LWRPProjectorType"="ApplyShadowBuffer" "P4LWRPApplyShadowBufferType"="Shadow"}
        Pass
        {
			ZWrite Off
			ColorMask RGB
			Blend DstColor Zero
			Offset [_OffsetSlope], [_Offset]
			Fog { Color (1, 1, 1) }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_local _ P4LWRP_MIXED_LIGHT_SUBTRACTIVE P4LWRP_MIXED_LIGHT_SHADOWMASK
            #pragma multi_compile_local _ P4LWRP_ADDITIONAL_LIGHT_SHADOW P4LWRP_ADDITIONAL_VERTEX_LIGHT_SHADOW
            #pragma multi_compile_local _ P4LWRP_MAINLIGHT_BAKED
            #pragma multi_compile_local _ P4LWRP_ADDITIONALLIGHTS_BAKED
            #pragma multi_compile_local _ P4LWRP_AMBIENT_INCLUDE_ADDITIONAL_LIGHT
            #pragma multi_compile_local _ P4LWRP_LIGHTSOURCE_POINT P4LWRP_LIGHTSOURCE_SPOT
            #pragma multi_compile_local P4LWRP_SHADOWTEX_CHANNEL_R P4LWRP_SHADOWTEX_CHANNEL_G P4LWRP_SHADOWTEX_CHANNEL_B P4LWRP_SHADOWTEX_CHANNEL_A P4LWRP_SHADOWTEX_CHANNEL_RGB

            // keywards defined by Lightweight RP 
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

            // keywords defined by Unity 
            #pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ UNITY_HDR_ON
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #define FSR_PROJECTOR_FOR_LWRP
            #include "../P4LWRPShadow.cginc"

            P4LWRP_ShadowProjectorVertexOutput vert (P4LWRP_ShadowProjectorVertexAttributes v)
            {
                UNITY_SETUP_INSTANCE_ID(v);

                float3 worldPos;
                float4 clipPos;
            	P4LWRP_TransformObjectToWorldAndClip(v.vertex.xyz, worldPos, clipPos);
                half3 worldNormal = TransformObjectToWorldNormal(v.normal.xyz);
                half4 uvShadow = ComputeScreenPos(clipPos); // Is this correct if USING_STEREO_MATRICES is defined??? Anyway, Lightweight RP also uses this for screen space shadow.
                P4LWRP_ShadowProjectorVertexOutput o = P4LWRP_CalculateShadowProjectorVertexOutput(v, worldNormal, worldPos, clipPos, uvShadow);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                return o;
            }

			sampler2D _ShadowTex;

            fixed4 frag (P4LWRP_ShadowProjectorVertexOutput i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                fixed alpha = (0 < i.uvShadow.z) ? 1 : 0;
                return P4LWRP_CalculateShadowProjectorFragmentOutput(i, alpha * tex2Dproj(_ShadowTex, UNITY_PROJ_COORD(i.uvShadow)).P4LWRP_SHADOWTEX_CHANNELMASK);
            }
            ENDHLSL
        }
    }
}
