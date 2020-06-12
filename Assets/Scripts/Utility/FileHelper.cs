using System.IO;
using UnityEngine;

public static class FileHelper
{
    public static Texture2D GetTextureByPath(string path)
    {
        if (File.Exists(path))
        {
            Texture2D getTexture = new Texture2D(1, 1);
            getTexture.LoadImage(File.ReadAllBytes(path));
            return getTexture;
        }
        return null;
    }

    public static byte[] GetByteArray(string path)
    {
        byte[] buf;
        if (File.Exists(path))
        {
            using (BinaryReader reader = new BinaryReader(File.Open(path, FileMode.Open)))
            {
                buf = reader.ReadBytes((int)reader.BaseStream.Length);
            }
            return buf;
        }
        return null;
    }

    public static bool WriteByteArray(string path, byte[] buf)
    {
        using (BinaryWriter writer = new BinaryWriter(File.Open(path, FileMode.Create)))
        {
            try
            {
                writer.Write(buf);
                return true;
            }
            catch (System.Exception)
            {
                return false;
            }
            
        }
    }

}
