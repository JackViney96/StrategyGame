using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PCT.Save;

public class MapObjectScript : MonoBehaviour
{
    public GameObject treePrefab;

    private TransformTable ret;

    void Start()
    {
        ret = SaveTest.LoadMapObjects();
        if (EqualityComparer<TransformTable>.Default.Equals(ret, default(TransformTable)))
        {
            return;
        }
        StartCoroutine(SpawnObjects());
    }

    private IEnumerator SpawnObjects()
    {
        for (int i = 0; i < ret.PosLength; i++)
        {
            var temp3 = Instantiate(treePrefab,
                new Vector3(ret.Pos(i).Value.X, ret.Pos(i).Value.Y, ret.Pos(i).Value.Z),
                Quaternion.Euler(new Vector3(ret.Rot(i).Value.X, ret.Rot(i).Value.Y, ret.Rot(i).Value.Z))
                );
            temp3.transform.localScale = new Vector3(ret.Scale(i).Value.X, ret.Scale(i).Value.Y, ret.Scale(i).Value.Z);
            SaveTest.mapObjectsList.Add(temp3);
            yield return null;
        }
    }

    //TODO: all mapobjects should be a child of this gameobject
    //And it should be responsible for all saving and loading of them.
}
