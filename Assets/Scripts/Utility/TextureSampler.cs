// I'd love to hear from you if you do anything cool with this or have any suggestions :)
// www.tenebrous.co.uk

using UnityEngine;

public class TextureSampler
{

    //Private
    private Color[] textureData;
    private int height;
    private int width;
    private bool doWrap;

    public Color GetPixelBilinear(float u, float v)
    {
        // from: http://en.wikipedia.org/wiki/Bilinear_filtering#Sample_code

        u *= width;
        v *= height;

        int x = Mathf.FloorToInt(u);
        int y = Mathf.FloorToInt(v);

        float u_ratio = u - x;
        float v_ratio = v - y;
        float u_opposite = 1 - u_ratio;
        float v_opposite = 1 - v_ratio;

        return (GetPixel(x, y) * u_opposite + GetPixel(x + 1, y) * u_ratio) * v_opposite + (GetPixel(x, y + 1) * u_opposite + GetPixel(x + 1, y + 1) * u_ratio) * v_ratio;
    }

    public Color GetPixel(float x, float y)
    {
        if (doWrap)
        {
            int xi = (int)WrapBetween(x, 0.0f, (float)width);
            int yi = (int)WrapBetween(y, 0.0f, (float)height);
            return textureData[yi * width + xi];
        }
        else
        {
            //Fixme
            //This -1 sucks - but without it, we could sample outside of array bounds. A solution is needed.
            int xi = (int)Mathf.Clamp(x, 0.0f, (float)width - 1);
            int yi = (int)Mathf.Clamp(y, 0.0f, (float)height - 1);
            return textureData[(int)yi * width + (int)xi];
        }
    }

    float Mod(float x, float y)
    {
        // from http://stackoverflow.com/questions/4633177/c-how-to-wrap-a-float-to-the-interval-pi-pi
        if (0 == y)
            return (x);

        return (x - y * Mathf.Floor(x / y));
    }

    float WrapBetween(float value, float min, float max)
    {
        return Mod(value - min, max - min) + min;
    }

    public TextureSampler(Texture2D source)
    {
        textureData = source.GetPixels();
        width = source.width;
        height = source.height;
        doWrap = true;
    }
    
    public TextureSampler(Texture2D source, bool doWrap)
    {
        textureData = source.GetPixels();
        width = source.width;
        height = source.height;
        this.doWrap = doWrap;
    }
}