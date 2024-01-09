using System;
using System.Collections.Generic;

namespace DataProcessor.Publications
{
    internal class PublicationEntryAuthor
    {
        public string FirstName { get; }
        public string LastName { get; }

        private PublicationEntryAuthor(string firstName, string lastName)
        {
            FirstName = firstName;
            LastName = lastName;
        }

        public static PublicationEntryAuthor[] Parse(string line)
        {
            var split = line.Split(new[] {" and "}, StringSplitOptions.RemoveEmptyEntries);
            var authors = new List<PublicationEntryAuthor>();
            foreach (var item in split)
            {
                var names = item.Split(',');
                var lastName = names[0].Trim();
                var firstName = names.Length > 1 ? names[1].Trim() : "";
                if (firstName.Length == 1)
                    firstName = firstName[0] + ".";
                else if (firstName.Length == 2)
                    firstName = firstName[0] + ". " + firstName[1] + ".";
                else if (firstName.Length == 3 && firstName[1] == ' ')
                    firstName = firstName[0] + ". " + firstName[2] + ".";
                else if (firstName.Length == 4 && firstName[2] == ' ')
                    firstName = firstName.Substring(0, 2) + ". " + firstName[3] + ".";
                authors.Add(new PublicationEntryAuthor(firstName, lastName));
            }

            return authors.ToArray();
        }
    }
}