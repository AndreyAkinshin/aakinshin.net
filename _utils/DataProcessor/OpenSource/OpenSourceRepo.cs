using System;

namespace DataProcessor.OpenSource
{
    public class OpenSourceRepo
    {
        public string Url { get; set; }
        public string Title { get; set; }

        public string RepoOwner => Url.Split(new[] {'/'}, StringSplitOptions.RemoveEmptyEntries)[0];
        public string RepoName => Url.Split(new[] {'/'}, StringSplitOptions.RemoveEmptyEntries)[1];

        public override string ToString() => Url + ": " + Title;
    }
}