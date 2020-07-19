using NaughtyAttributes;
using System;
using TMPro;
using UnityEngine;

namespace PCT.UI
{
    [Serializable]
    public class Submenu : IMenuComponent
    {
        [Header("A placeholder element that will grab a prefab into its menu.")]
        public string label = "[No Label]";

        [Required]
        public GameObject menu;

        public void Create(GameObject panel)
        {
            //TODO:
            //var buttonInstance = GameObject.Instantiate(menu, panel.transform);
            menu.transform.parent = panel.transform;

            var buttonLabel = menu.GetComponentInChildren<TextMeshProUGUI>();
            buttonLabel.SetText(label);

            //var button = menu.GetComponentInChildren<UnityEngine.UI.Button>();
            //button.onClick.AddListener(() => events.Invoke());
        }
    }
}