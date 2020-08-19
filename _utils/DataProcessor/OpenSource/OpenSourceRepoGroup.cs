using System.Collections.Generic;

namespace DataProcessor.OpenSource
{
    public class OpenSourceRepoGroup
    {
        public string Role { get; set; }
        public List<OpenSourceRepo> Repos { get; set; }
    }
}