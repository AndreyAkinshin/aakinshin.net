namespace Common.Extensions;

public static class CollectionExtensions
{
  public static bool IsEmpty<T>(this IEnumerable<T> values) => !values.Any();
  public static bool IsNotEmpty<T>(this IEnumerable<T> values) => values.Any();

  public static bool IsNotEmpty(this string? value) => !string.IsNullOrEmpty(value);

  public static string JoinToString<T>(this IEnumerable<T> values, string separator)
  {
    return string.Join(separator, values);
  }

  public static string JoinToString<T>(this IEnumerable<T> values, string separator, Func<T, string> format)
  {
    return string.Join(separator, values.Select(format));
  }

  public static string JoinToString<T>(this IEnumerable<T> values, char separator)
  {
    return string.Join(separator, values);
  }

  public static bool IsOneOf<T>(this T value, params T[] values) => values.Any(v => v?.Equals(value) ?? false);

  public static IEnumerable<T> WhereNotNull<T>(this IEnumerable<T?> values) =>
    values.Where(value => value != null).Cast<T>();

  public static IEnumerable<T> Reversed<T>(this IEnumerable<T> values) => values.Reverse();

  public static int IndexOf<T>(this IReadOnlyCollection<T> self, Func<T, bool> predicate)
  {
    int i = 0;
    foreach (T element in self)
    {
      if (predicate(element))
        return i;
      i++;
    }

    return -1;
  }

  public static int IndexOf<T>(this IReadOnlyCollection<T> self, T toFind)
  {
    int i = 0;
    foreach (T element in self)
    {
      if (Equals(element, toFind))
        return i;
      i++;
    }

    return -1;
  }

  public static IReadOnlyList<T> Shuffle<T>(this IEnumerable<T> self, Random random)
  {
    var result = self.ToList();
    var n = result.Count;
    for (var i = 0; i < n; i++)
    {
      var index1 = random.Next(n);
      var index2 = random.Next(n);
      (result[index1], result[index2]) = (result[index2], result[index1]);
    }

    return result;
  }
}