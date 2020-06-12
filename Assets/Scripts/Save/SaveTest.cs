using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FlatBuffers;
using PCT.Save; // The `flatc` generated files. (Monster, Vec3, etc.)

public static class SaveTest
{
    //Objects are added to these lists by themselves.
    public static List<GameObject> mapObjectsList = new List<GameObject>(); //Terrain decoration (trees, rocks, buildings)
    //public static List<GameObject> dynObjects; //Dynamic Objects

    private static FlatBufferBuilder builder = new FlatBufferBuilder(1);
    //private static FileStream stream = new FileStream(Application.persistentDataPath + "/Test.sav", FileMode.OpenOrCreate);

    //public static readonly string path = Application.dataPath + Path.DirectorySeparatorChar + "Saves" + Path.DirectorySeparatorChar + Environment.MachineName + ".sav";
    //public static readonly string path = Application.persistentDataPath + Path.DirectorySeparatorChar + Environment.MachineName + ".sav";
    private static readonly string path = PCT.StaticDefines.dataDirectory + Path.DirectorySeparatorChar + Environment.MachineName + ".sav";
    //private static BinaryFormatter bf = new BinaryFormatter();
    //private static FileStream file = File.Open(path, FileMode.OpenOrCreate);

    public static void SaveMapObjects()
    {        
        TransformTable.StartPosVector(builder, mapObjectsList.Count);
        foreach (var obj in mapObjectsList)
        {
            Vec3.CreateVec3(builder, obj.transform.position.x, obj.transform.position.y, obj.transform.position.z);
        }
        var posvec = builder.EndVector();

        TransformTable.StartScaleVector(builder, mapObjectsList.Count);
        foreach (var obj in mapObjectsList)
        {
            Vec3.CreateVec3(builder, obj.transform.localScale.x, obj.transform.localScale.y, obj.transform.localScale.z);
        }
        var scalevec = builder.EndVector();

        TransformTable.StartRotVector(builder, mapObjectsList.Count);
        foreach (var obj in mapObjectsList)
        {
            Vec3.CreateVec3(builder, obj.transform.rotation.eulerAngles.x, obj.transform.rotation.eulerAngles.y, obj.transform.rotation.eulerAngles.z );
        }
        var rotvec = builder.EndVector();

        TransformTable.StartTransformTable(builder);
        TransformTable.AddPos(builder, posvec);
        TransformTable.AddScale(builder, scalevec);
        TransformTable.AddRot(builder, rotvec);
        var objects = TransformTable.EndTransformTable(builder);
        
        builder.Finish(objects.Value, "TST1");

        byte[] buf = builder.SizedByteArray();
        //Debug.Log(buf.Length);

        FileHelper.WriteByteArray(path, buf);

        //Debug.Log(Application.persistentDataPath);
    }

    public static TransformTable LoadMapObjects()
    {
        byte[] buf;
        if (File.Exists(path))
        {
            /*using (BinaryReader reader = new BinaryReader(File.Open(path, FileMode.Open)))
            {
                buf = reader.ReadBytes((int)reader.BaseStream.Length);
            }*/
            buf = FileHelper.GetByteArray(path);
            ByteBuffer bb = new ByteBuffer(buf);
            //Broken unless there is a root table. Will need to develop a schema for one.
            /*if (!.mapObjectsBufferHasIdentifier(bb))
            {
                //throw new Exception("ID Test Failed.");
            }*/

            TransformTable objs = TransformTable.GetRootAsTransformTable(bb);
            return objs;
        }
        else
        {
            Debug.LogError("Couldn't Read File");
            return default;
        }
    }
}