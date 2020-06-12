using System;
using UnityEngine;

namespace PCT.UI
{
    public interface IThemeable
    {
        void Theme(ThemeObject theme);
    }
    public interface IMenuComponent
    {
        void Create(GameObject panel);
    }

}
