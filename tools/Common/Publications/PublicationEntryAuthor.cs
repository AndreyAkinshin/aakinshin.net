using Common.Extensions;

namespace Common.Publications;

public class PublicationEntryAuthor
{
    public const string Me = "Andrey Akinshin";

    public string FirstName { get; }
    public string LastName { get; }

    private PublicationEntryAuthor(string firstName, string lastName)
    {
        FirstName = firstName;
        LastName = lastName;
    }

    public string ToText()
    {
        if (LastName.EqualsIgnoreCase("akinshin"))
            return Me;
        return (FirstName.Trim() + " " + LastName.Trim()).Replace("\\", "").Trim();
    }

    public static PublicationEntryAuthor[] Parse(string line)
    {
        var authorNames = line.Split([" and "], StringSplitOptions.RemoveEmptyEntries);
        var authors = new List<PublicationEntryAuthor>();
        foreach (var authorName in authorNames)
        {
            if (authorName.Contains(','))
            {
                var names = authorName.Split(',');

                var lastName = names[0].Trim();
                var firstName = names.Length > 1 ? names[1].Trim() : "";
                authors.Add(new PublicationEntryAuthor(firstName, lastName));
            }
            else if (authorName.Contains(' '))
            {
                var index = authorName.LastIndexOf(' ');
                var firstName = authorName.Substring(0, index);
                var lastName = authorName.Substring(index + 1);
                authors.Add(new PublicationEntryAuthor(firstName, lastName));
            }
            else
            {
                authors.Add(new PublicationEntryAuthor("", authorName));
            }
        }

        return authors.ToArray();
    }
}