using Common.Extensions;

namespace Common.Helpers;

public static class StringHelper
{
    public static string Captialize(string s)
    {
        var lowerCaseWords = new HashSet<string>
        {
            "a", "an", "and", "as", "at", "but", "by", "for", "in", "nor",
            "of", "on", "or", "so", "the", "to", "yet", "with", "from",
            "that", "is", "so", "via", "about", "did"
        };
        var words = s.Split(' ');

        for (int i = 0; i < words.Length; i++)
        {
            if (words[i].Contains('/'))
                continue;

            if (words[i].Length > 1 && words[i].Skip(1).Where(char.IsLetter).Any(char.IsUpper))
                continue;

            var isLower = lowerCaseWords.ContainsIgnoreCase(words[i].ToLower());
            if (i > 0 && isLower && words[i - 1].EndsWith(','))
            {
                words[i] = words[i].ToLowerInvariant();
                continue;
            }

            if (i == 0 || char.IsPunctuation(words[i - 1].Last()))
            {
                words[i] = CapitalizeWord(words[i]);
                continue;
            }

            if (isLower)
            {
                words[i] = words[i].ToLowerInvariant();
                continue;
            }

            if (words[i].All(char.IsLetter))
                words[i] = CapitalizeWord(words[i]);
        }

        var result = string.Join(' ', words)
            .ReplaceIgnoreCase("Cohen’s d", "Cohen’s d");
        return result;
    }

    private static string CapitalizeWord(string word)
    {
        return word.Split('-').Select(CapitalizePart).JoinToString('-');
    }


    private static string CapitalizePart(string part)
    {
        if (part.IsBlank())
            return part;
        if (char.IsPunctuation(part[0]))
            return part[0] + CapitalizePart(part[1..]);

        return char.ToUpper(part[0]) + part[1..].ToLower();
    }

    public static string ToSlug(this string s) =>
        new string(s.Where(c => !char.IsPunctuation(c)).ToArray())
            .Trim()
            .Replace(" ", "-")
            .Replace("+", "")
            .ToLowerInvariant();
}