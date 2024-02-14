namespace DataProcessor.Publications.Papers;

public class PublicationImporter
{
    public static readonly PublicationImporter Instance = new();

    public void Import(string filePath)
    {
        var storage = new PaperStorage();
        storage.ReadExistingPapers();
        storage.Import(filePath);
        storage.SaveAll();
    }
}