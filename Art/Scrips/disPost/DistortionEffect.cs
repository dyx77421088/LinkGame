using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
[ExecuteInEditMode]
public class DistortionEffect : PostEffectBase
{
    [Range(0, 1)]
    [Header("热扰动速率")]
    public float DistortVelocity = 0.5f;

    [Range(0, 1)]
    [Header("热扰动强度")]
    public float DistortStrength = 0.8f;

    [Header("噪声纹理")]
    public Texture NoiseTexture = null;

    [Header("遮罩贴图")]
    public Texture MaskTex = null;
    [Header("遮罩位移")]
    public float Offset_x=0.0f;
    public float Offset_y=0.0f;
    [Header("噪声竖直密度")]
    public float YDensity = 1.0f;

    [Header("噪声水平密度")]
    public float XDensity = 1.0f;


    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            material.SetTexture("_NoiseTex", NoiseTexture);
            material.SetTexture("_MaskTex", MaskTex);
            material.SetFloat("_DistortVelocity", DistortVelocity);
            material.SetFloat("_DistortStrength", DistortStrength);
            material.SetFloat("_YDensity", YDensity);
            material.SetFloat("_XDensity", XDensity);
            material.SetVector("_MaskTex_ST", new Vector4(1.0f, 1.56f, Offset_x, Offset_y));
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}