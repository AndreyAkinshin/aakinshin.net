namespace Common.Publications;

public class PublicationEntryAuthor
{
    public string FirstName { get; }
    public string LastName { get; }

    private PublicationEntryAuthor(string firstName, string lastName)
    {
        FirstName = firstName;
        LastName = lastName;
    }

    public string ToText()
    {
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
                if (firstName.Length == 1)
                    firstName = firstName[0] + ".";
                else if (firstName.Length == 2 && firstName[1] != '.')
                    firstName = firstName[0] + ". " + firstName[1] + ".";
                else if (firstName.Length == 3 && firstName[1] == ' ')
                    firstName = firstName[0] + ". " + firstName[2] + ".";
                else if (firstName.Length == 4 && firstName[2] == ' ')
                    firstName = firstName.Substring(0, 2) + ". " + firstName[3] + ".";
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