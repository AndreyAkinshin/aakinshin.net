using System.Text;
using Common.Extensions;
using Common.Helpers;
using Common.Publications;

namespace Generate.Papers;

public class PaperHelper
{
    public static readonly PaperHelper Instance = new();

    public PublicationEntry? FetchEntryByDoi(string doi)
    {
        var bib = FormatBib(Doi2Bib(doi));
        if (bib.IsBlank()) return null;

        var bibReader = new StreamReader(new MemoryStream(Encoding.UTF8.GetBytes(bib)));
        return PublicationEntry.Read(PublicationLanguage.English, bibReader);
    }

    public string Doi2Bib(string doi) => ProcessHelper.RunAndGetOutput("doi2bib", doi).Result.Trim();

    public string FormatBib(string bib)
    {
        if (bib.IsBlank())
            return "";
        var newLineIndexes = new List<int>();
        var bibBuilder = new StringBuilder(bib);
        var nestedLevel = 0;
        for (var i = 0; i < bibBuilder.Length; i++)
        {
            switch (bibBuilder[i])
            {
                case '{':
                    nestedLevel++;
                    break;
                case '}':
                    nestedLevel--;
                    break;
                case ',':
                    if (nestedLevel == 1)
                        newLineIndexes.Add(i + 1);
                    break;
            }
        }

        foreach (var newLineIndex in newLineIndexes.Reversed())
            bibBuilder.Insert(newLineIndex, '\n');
        return bibBuilder.ToString();
    }
}