using System.Collections.Generic;

namespace DataProcessor.OpenSource
{
    public class OpenSourceActivityGroup
    {
        public string Month { get; set; }
        public List<OpenSourceRepo> Repos { get; set; }
    }
}