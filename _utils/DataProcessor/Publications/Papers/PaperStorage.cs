using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using DataProcessor.Common;

namespace DataProcessor.Publications.Papers;

public class PaperStorage
{
    private readonly Dictionary<string, PaperFile> hashIdToPaper = new();
    private readonly HashSet<string> keys = [];

    public static void Refresh()
    {
        var storage = new PaperStorage();
        storage.ReadExistingPapers();
        storage.SaveAll();
    }

    public void ReadExistingPapers()
    {
        if (!Directory.Exists(DirectoryDetector.GetPapersDirectory()))
            Directory.CreateDirectory(DirectoryDetector.GetPapersDirectory());

        var mdFiles = Directory.GetFiles(DirectoryDetector.GetPapersDirectory(), "*.md");
        foreach (var mdFile in mdFiles)
        {
            var paperFile = PaperFile.Read(mdFile);
            hashIdToPaper[paperFile.Entry.GetHashId()] = paperFile;
        }
    }

    public void Import(string filePath)
    {
        if (Directory.Exists(filePath))
        {
            foreach (var file in Directory.GetFiles(filePath, "*.bib"))
                Import(file);
            return;
        }

        foreach (var entry in PublicationEntry.ReadAll(PublicationLanguage.English, filePath))
        {
            if (entry.GetAuthors().Any(author => author.LastName == "Akinshin"))
                continue;
            AddEntry(entry);
            Console.WriteLine($"Imported: {entry.GetNiceKey()}");
        }
    }

    public void AddEntry(PublicationEntry entry)
    {
        if (hashIdToPaper.ContainsKey(entry.GetHashId()))
            return;
        var key = entry.GetNiceKey();
        if (keys.Contains(key))
        {
            for (var c = 'a'; c <= 'z'; c++)
                if (!keys.Contains(key + c))
                {
                    key += c;
                    break;
                }

            if (keys.Contains(key))
                throw new Exception("Key exists: " + key);
        }

        var filePath = Path.Combine(DirectoryDetector.GetPapersDirectory(), key + ".md");
        var paperFile = new PaperFile(filePath, entry, "", ["Mathematics", "Statistics"]);
        hashIdToPaper[paperFile.Entry.GetHashId()] = paperFile;
    }

    public void SaveAll()
    {
        var mdFiles = Directory.GetFiles(DirectoryDetector.GetPapersDirectory(), "*.md");
        foreach (var mdFile in mdFiles)
            File.Delete(mdFile);
        foreach (var paperFile in hashIdToPaper.Values)
            paperFile.Save();
    }
}