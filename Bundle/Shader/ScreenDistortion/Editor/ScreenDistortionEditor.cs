
//----------------------------------------------------------------------------------------------------------
// X-PostProcessing Library
// https://github.com/QianMo/X-PostProcessing-Library
// Copyright (C) 2020 QianMo. All rights reserved.
// Licensed under the MIT License 
// You may not use this file except in compliance with the License.You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
//----------------------------------------------------------------------------------------------------------

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

using UnityEditor.Rendering.PostProcessing;
using UnityEngine.Rendering.PostProcessing;

namespace XPostProcessing1
{
    [PostProcessEditor(typeof(ScreenDistortion))]
    public sealed class ScreenDistortionEditor : PostProcessEffectEditor<ScreenDistortion>
    {
        SerializedParameterOverride DistortVelocity;
        SerializedParameterOverride DistortStrength;
        SerializedParameterOverride NoiseTexture;
        SerializedParameterOverride MaskTex;
        SerializedParameterOverride Offset_x;
        SerializedParameterOverride Offset_y;
        SerializedParameterOverride YDensity;
        SerializedParameterOverride XDensity;


        public override void OnEnable()
        {
            DistortVelocity = FindParameterOverride(x => x.DistortVelocity);
            DistortStrength = FindParameterOverride(x => x.DistortStrength);
            NoiseTexture = FindParameterOverride(x => x.NoiseTexture);
            MaskTex = FindParameterOverride(x => x.MaskTex);
            Offset_x = FindParameterOverride(x => x.Offset_x);
            Offset_y = FindParameterOverride(x => x.Offset_y);
            YDensity = FindParameterOverride(x => x.YDensity);
            XDensity = FindParameterOverride(x => x.XDensity);
        }

        public override string GetDisplayTitle()
        {
            //return XPostProcessingEditorUtility.DISPLAY_TITLE_PREFIX + base.GetDisplayTitle();
            return "屏幕失真";
        }
        public override void OnInspectorGUI()
        {
            //EditorGUILayout.Space();
            EditorUtilities.DrawHeaderLabel("热扰动速率");
            PropertyField(DistortVelocity);
            EditorUtilities.DrawHeaderLabel("热扰动强度");
            PropertyField(DistortStrength);
            EditorUtilities.DrawHeaderLabel("噪声纹理");
            PropertyField(NoiseTexture);
            EditorUtilities.DrawHeaderLabel("遮罩贴图");
            PropertyField(MaskTex);
            EditorUtilities.DrawHeaderLabel("遮罩位移");
            PropertyField(Offset_x);
            PropertyField(Offset_y);
            EditorUtilities.DrawHeaderLabel("噪声竖直密度");
            PropertyField(YDensity);
            EditorUtilities.DrawHeaderLabel("噪声水平密度");
            PropertyField(XDensity);
        }

    }
}
        
