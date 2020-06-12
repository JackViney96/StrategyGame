using NaughtyAttributes;
using PCT.UI;
using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class DropdownMenu : MonoBehaviour, IThemeable
{
    public string label = "[No Label]";

    [SerializeReference]
    [SerializeReferenceButton]
    [ReorderableList]
    public List<IMenuComponent> elements = new List<IMenuComponent>();
    [Space]
    [Required]
    public TextMeshProUGUI text;
    [Required]
    public GameObject panel;

    private void Start()
    {
        text.SetText(label);
        foreach (var x in elements)
        {
            addItem(x);
        }
    }

    private void addItem(PCT.UI.IMenuComponent item)
    {
        if (item == null)
        {
            return;
        }
        item.Create(panel);
    }

    public void Theme(ThemeObject theme)
    {
        
    }
}