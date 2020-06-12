using NaughtyAttributes;
using System;
using UnityEngine;

namespace PCT.UI
{
    [Serializable]
    public class SimpleComponent : IMenuComponent
    {
        [Header("A generic element with no customizability - dividers, etc.")]
        [Required]
        public GameObject prefab;
        public void Create(GameObject panel)
        {
            GameObject.Instantiate(prefab, panel.transform);
        }
    }
}
