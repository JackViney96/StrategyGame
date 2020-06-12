using UnityEngine;
using NaughtyAttributes;
using System.IO;

namespace PCT
{
    [System.Serializable]
    public class MeshTerrainLayer
    {

        public string mapFilePath;
        public float noiseScale;
        public float heightScale;

        //Used either as a heightmap or as an exclusion/inclusion map for noise.
        private Texture2D map;
        private TextureSampler texSampler;

        public void Init()
        {
            if (mapFilePath != "")
            {
                map = FileHelper.GetTextureByPath(mapFilePath);
            }

            if (map != null)
            {
                texSampler = new TextureSampler(map, false);
            }
            else
            {
                texSampler = null;
            }
        }

        public Color Sample(float u, float v)
        {
            //Replace with a check to see if there is a texSampler.
            if (texSampler != null)
            {
                return texSampler.GetPixelBilinear(u, v);
            }
            else
            {
                float sample = Mathf.PerlinNoise(u * noiseScale, v * noiseScale);
                return new Color(sample, sample, sample);
            }
            
        }

    }
}