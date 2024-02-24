namespace Generate.Talks;

public class Talk
{
    public DateTime? Date { get; set; }
    public DateTime? Date2 { get; set; }
    public string Event { get; set; }
    public string EventHint { get; set; }
    public string Title { get; set; }
    public string Location { get; set; }
    public string Lang { get; set; }
    public string Abstract { get; set; }
    public int Year { get; set; }
    public List<TalkLink> Links { get; set; }
    public TalkLink GetLink(string key) => Links.FirstOrDefault(l => l.Key == key);
}