﻿Shader "Projector For LWRP/Projector/Multiply" 
{
	Properties {
		[NoScaleOffset] _ShadowTex ("Cookie", 2D) = "gray" {}
		[HideInInspector][NoScaleOffset] _FalloffTex ("FallOff", 2D) = "white" {}
		_Offset ("Offset", Range (0, -10)) = -1.0
		_OffsetSlope ("Offset Slope Factor", Range (0, -1)) = -1.0
	}
	SubShader
	{
		Tags {"Queue"="Transparent-1"}
        // Shader code
		Pass
        {
			ZWrite Off
			Fog { Color (1, 1, 1) }
			ColorMask RGB
			Blend DstColor Zero
			Offset [_OffsetSlope], [_Offset]

			HLSLPROGRAM
			#pragma vertex p4lwrp_vert_projector
			#pragma fragment p4lwrp_frag_projector_shadow
			#pragma shader_feature_local FSR_PROJECTOR_FOR_LWRP
            #pragma shader_feature_local P4LWRP_FALLOFF_TEXTURE P4LWRP_FALLOFF_LINEAR P4LWRP_FALLOFF_SQUARE P4LWRP_FALLOFF_INV_SQUARE P4LWRP_FALLOFF_NONE
			#pragma multi_compile_fog
            #pragma multi_compile_instancing
			#include "../P4LWRP.cginc"
			#include "../P4LWRPFalloff.cginc"

			sampler2D _ShadowTex;

			fixed4 p4lwrp_frag_projector_shadow(P4LWRP_V2F_PROJECTOR i) : SV_Target
			{
				fixed4 col;
				fixed alpha = P4LWRP_GetFalloff(i.uvShadow);
				col.rgb = tex2Dproj(_ShadowTex, UNITY_PROJ_COORD(i.uvShadow)).rgb;
				col.a = 1.0f;
				col.rgb = lerp(fixed3(1,1,1), col.rgb, alpha);
				UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(1,1,1,1));
				return col;
			}
			ENDHLSL
		}
	} 
	CustomEditor "ProjectorForLWRP.ProjectorFalloffShaderGUI"
}