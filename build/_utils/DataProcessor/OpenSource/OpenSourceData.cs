using System.Collections.Generic;

namespace DataProcessor.OpenSource
{
    public class OpenSourceData
    {
        public List<OpenSourceRepoGroup> Ru { get; }
        public List<OpenSourceRepoGroup> En { get; }

        public OpenSourceData(List<OpenSourceRepoGroup> ru, List<OpenSourceRepoGroup> en)
        {
            Ru = ru;
            En = en;
        }
    }
}