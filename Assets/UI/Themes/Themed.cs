using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PCT.UI
{
    public class Themed : MonoBehaviour
    {
        public ThemeObject theme;

        private List<IThemeable> themeableComponents = new List<IThemeable>();
        public void Start()
        {
            GetComponentsInChildren(true, themeableComponents);

            foreach (var item in themeableComponents)
            {
                print(item);
                item.Theme(theme);
            }
            //BroadcastMessage("Theme", theme, SendMessageOptions.DontRequireReceiver);
        }
    }

}
