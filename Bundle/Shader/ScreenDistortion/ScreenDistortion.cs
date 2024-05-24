//----------------------------------------------------------------------------------------------------------
// X-PostProcessing Library
// https://github.com/QianMo/X-PostProcessing-Library
// Copyright (C) 2020 QianMo. All rights reserved.
// Licensed under the MIT License 
// You may not use this file except in compliance with the License.You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
//----------------------------------------------------------------------------------------------------------

using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.PostProcessing;

namespace XPostProcessing1
{

    [Serializable]
    [PostProcess(typeof(ScreenDistortionRenderer), PostProcessEvent.AfterStack, "我的/屏幕失真")]
    public class ScreenDistortion : PostProcessEffectSettings
    {
        [Range(0.0f, 1.0f)]
        //[Header("热扰动速率")]
        public FloatParameter DistortVelocity = new FloatParameter { value = 0.363f };
        [Range(0, 1)]
        //[Header("热扰动强度")]
        public FloatParameter DistortStrength = new FloatParameter { value = 0.005f };
        //[Header("噪声纹理")]
        public TextureParameter NoiseTexture = new TextureParameter { value = null };
        //[Header("遮罩贴图")]
        public TextureParameter MaskTex = new TextureParameter { value = null };
        //[Header("遮罩位移")]
        public FloatParameter Offset_x = new FloatParameter { value = 0.0f };
        public FloatParameter Offset_y = new FloatParameter { value = -0.34f };
        //[Header("噪声竖直密度")]
        public FloatParameter YDensity = new FloatParameter { value = 4.21f };
        //[Header("噪声水平密度")]
        public FloatParameter XDensity = new FloatParameter { value = 2.46f };

        //[Range(0.0f, 50.0f)]
        //public FloatParameter BlurRadius = new FloatParameter { value = 5.0f };

        //[Range(1, 8)]
        //public IntParameter Iteration = new IntParameter { value = 4 };

        //[Range(1, 10)]
        //public FloatParameter RTDownScaling = new FloatParameter { value = 1 };
    }

    #if UNITY_2017_1_OR_NEWER
        [UnityEngine.Scripting.Preserve]
    #endif
    public sealed class ScreenDistortionRenderer : PostProcessEffectRenderer<ScreenDistortion>
    {

        private const string PROFILER_TAG = "X-ScreenDistortion";
        private Shader shader;

        public override void Init()
        {
            shader = Shader.Find("Hidden/Postprocessing/ScreenDistortion");
        }

        public override void Release()
        {
            base.Release();
        }

        static class ShaderIDs
        {
            internal static readonly int noiseTex = Shader.PropertyToID("_NoiseTex");
            internal static readonly int maskTex = Shader.PropertyToID("_MaskTex");
            internal static readonly int distortVelocity = Shader.PropertyToID("_DistortVelocity");
            internal static readonly int distortStrength = Shader.PropertyToID("_DistortStrength");
            internal static readonly int yDensity = Shader.PropertyToID("_YDensity");
            internal static readonly int xDensity = Shader.PropertyToID("_XDensity");
            internal static readonly int maskTex_ST = Shader.PropertyToID("_MaskTex_ST");
            internal static readonly int timeY = Shader.PropertyToID("_TimeY");
        }

        private float timeY = 1f;
        public override void Render(PostProcessRenderContext context)
        {
            CommandBuffer cmd = context.command;
            PropertySheet sheet = context.propertySheets.Get(shader);

            cmd.BeginSample(PROFILER_TAG);

            sheet.properties.SetTexture(ShaderIDs.noiseTex, settings.NoiseTexture);
            sheet.properties.SetTexture(ShaderIDs.maskTex, settings.MaskTex);
            sheet.properties.SetFloat(ShaderIDs.distortVelocity, settings.DistortVelocity);
            //Debug.LogError(settings.DistortStrength.value);
            sheet.properties.SetFloat("_DistortStrength", settings.DistortStrength);
            sheet.properties.SetFloat(ShaderIDs.yDensity, settings.YDensity);
            sheet.properties.SetFloat(ShaderIDs.xDensity, settings.XDensity);
            sheet.properties.SetVector(ShaderIDs.maskTex_ST, new Vector4(1.0f, 1.56f, settings.Offset_x, settings.Offset_y));

            timeY += Time.deltaTime * 60;
            if(timeY > 100 * 60) { timeY = 0; }
            sheet.properties.SetFloat(ShaderIDs.timeY, Time.time);

            cmd.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
            cmd.EndSample(PROFILER_TAG);
        }

    }
}