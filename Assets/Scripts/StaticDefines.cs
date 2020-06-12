using UnityEngine;

namespace PCT
{
    public static class StaticDefines
    {
        #if UNITY_EDITOR_WIN
            public static readonly string dataDirectory = Application.persistentDataPath;
        #elif UNITY_STANDALONE_WIN
            public static readonly string dataDirectory = Application.persistentDataPath;
        #elif UNITY_STANDALONE_OSX
            public static readonly string dataDirectory = Application.persistentDataPath;
        #elif UNITY_STANDALONE_LINUX
            public static readonly string dataDirectory = Application.persistentDataPath;
        #endif

        public const string saveFolder = "Saves";
        public const string scenarioFolder = "Scenarios";
    }
}