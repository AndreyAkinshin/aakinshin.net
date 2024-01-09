using System;

namespace DataProcessor.Media
{
    public class MediaItem
    {
        public DateTime? Date { get; set; }
        public string Type { get; set; }
        public string Kind { get; set; }
        public string Host { get; set; }
        public string Title { get; set; }
        public string Lang { get; set; }
        public string Url { get; set; }

        public int Year => Date?.Year ?? throw new Exception("Undefined Date");
    }
}