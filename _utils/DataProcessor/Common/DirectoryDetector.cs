using System;
using System.IO;

namespace DataProcessor.Common
{
    public static class DirectoryDetector
    {
        public static string GetUtilDirectory()
        {
            var current = Directory.GetCurrentDirectory();
            while (current != null && new DirectoryInfo(current).Name != "DataProcessor")
                current = Directory.GetParent(current)?.FullName;
            if (current == null)
                throw new Exception("Failed to find 'DataProcessor' directory");
            return new DirectoryInfo(current).Parent?.FullName;
        }
        
        public static string GetRootDirectory()
        {
            var current = Directory.GetCurrentDirectory();
            while (current != null && new DirectoryInfo(current).Name != "DataProcessor")
                current = Directory.GetParent(current)?.FullName;
            if (current == null)
                throw new Exception("Failed to find 'DataProcessor' directory");
            return new DirectoryInfo(current).Parent?.Parent?.FullName;
        }

        public static string GetDataDirectory()
            => Path.Combine(GetRootDirectory(), "data");

        public static string GetDataRawDirectory()
            => Path.Combine(GetUtilDirectory(), "raw");
        
        public static string GetDataGenDirectory()
            => Path.Combine(GetDataDirectory(), "gen");
    }
}