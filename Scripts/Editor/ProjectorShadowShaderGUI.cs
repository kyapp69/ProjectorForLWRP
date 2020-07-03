﻿//
// ProjectorShadowShaderGUI.cs
//
// Projector For LWRP
//
// Copyright (c) 2020 NYAHOON GAMES PTE. LTD.
//

using UnityEngine;
using UnityEditor;

namespace ProjectorForLWRP.Editor
{
    public class ProjectorShadowShaderGUI : ShaderGUI
    {
        static ProjectorShadowShaderGUI()
        {
            ShaderKeywords.Projector.Activate();
        }
        public static void ShowColorChannelSelectGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Material material = materialEditor.target as Material;
            HelperFunctions.MaterialKeywordSelectGUI<ShaderKeywords.Projector.ShadowTextureChannel>(material, "Color Channel");
        }
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            base.OnGUI(materialEditor, properties);
            ShowColorChannelSelectGUI(materialEditor, properties);
            ProjectorFalloffShaderGUI.ShowProjectorFallOffGUI(materialEditor, properties);
        }
    }
}