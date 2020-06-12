using NaughtyAttributes;
using System;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace PCT.UI
{
    [Serializable]
    public class Button : IMenuComponent, IThemeable
    {
        [Header("A button, with UnityEvents.")]
        public string label = "[No Label]";

        [Required]
        public GameObject buttonPrefab;

        public UnityEvent events;

        private GameObject buttonInstance;

        public void Create(GameObject panel)
        {
            buttonInstance = GameObject.Instantiate(buttonPrefab, panel.transform);

            var buttonLabel = buttonInstance.GetComponentInChildren<TextMeshProUGUI>();
            buttonLabel.SetText(label);

            var button = buttonInstance.GetComponentInChildren<UnityEngine.UI.Button>();
            button.onClick.AddListener(() => events.Invoke());
        }

        public void Theme(ThemeObject theme)
        {
            var button = buttonInstance.GetComponentInChildren<UnityEngine.UI.Button>();
            ColorBlock colors = button.colors;
            Debug.Log(colors);
            //button.colors.highlightedColor = theme.background;
            colors.highlightedColor = theme.background;
            Debug.Log(colors);
            button.colors = colors;
            Debug.Log(button.colors);
        }
    }
}