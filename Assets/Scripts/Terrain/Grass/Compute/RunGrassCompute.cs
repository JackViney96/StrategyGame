using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RunGrassCompute : MonoBehaviour
{
    // The compute shader we want to execute
    public ComputeShader Shader;
    // The texture where the data come from
    private RenderTexture _target;
    private void InitRenderTexture()
    {
        // If a texture exists and doesn't match the screen size, release it.
        if (_target == null || _target.width != Screen.width || _target.height != Screen.height)
        {
            if (_target != null)
            {
                _target.Release();
            }
        }

        // Re-create a matching texture.
        _target = new RenderTexture(Screen.width, Screen.height, 0,
           RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);

        // Enable random write flag so we can modify the texture in CSMain
        _target.enableRandomWrite = true;
        _target.Create();
    }

    private void RunShader(RenderTexture destination)
    {
        InitRenderTexture();

        Shader.SetTexture(0, "Result", _target);
        int threadGroupX = Mathf.CeilToInt(Screen.width / 8.0f);
        int threadGroupY = Mathf.CeilToInt(Screen.height / 8.0f);
        Shader.Dispatch(0, threadGroupX, threadGroupY, 1);

        Graphics.Blit(_target, destination);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RunShader(destination);
    }
}
