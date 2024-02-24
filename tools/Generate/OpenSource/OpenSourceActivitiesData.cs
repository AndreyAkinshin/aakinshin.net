namespace Generate.OpenSource;

public class OpenSourceActivitiesData
{
    public List<OpenSourceActivityGroup> Ru { get; }
    public List<OpenSourceActivityGroup> En { get; }

    public OpenSourceActivitiesData(List<OpenSourceActivityGroup> ru, List<OpenSourceActivityGroup> en)
    {
        Ru = ru;
        En = en;
    }
}