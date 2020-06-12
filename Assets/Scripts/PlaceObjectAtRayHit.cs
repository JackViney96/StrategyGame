using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using FlatBuffers;

public class PlaceObjectAtRayHit : MonoBehaviour
{
    public GameObject treePrefab;
    private GameObject treeObject;
    public void OnSpawnCubeasMapObject()
    {
        RaycastHit hit;
        var ray = Camera.main.ScreenPointToRay(new Vector3(Screen.width / 2f, Screen.height / 2f, 0f));

        if (Physics.Raycast(ray, out hit))
        {
            treeObject = Instantiate(treePrefab, hit.point, Quaternion.Euler(0, Random.Range(0, 359), 0));
            treeObject.transform.localScale = new Vector3(Random.Range(1f, 1.25f), Random.Range(1f, 1.25f), Random.Range(1f, 1.25f));
            SaveTest.mapObjectsList.Add(treeObject);
        }

        SaveTest.SaveMapObjects();
    }

    public void OnDeleteAll()
    {
        foreach (var obj in SaveTest.mapObjectsList)
        {
            Destroy(obj);
        }
        SaveTest.mapObjectsList.Clear();
        SaveTest.SaveMapObjects();
    }
}
