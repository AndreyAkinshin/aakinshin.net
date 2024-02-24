namespace Common.Extensions;

public static class StringExtensions
{
  public static bool IsBlank(this string? value) => string.IsNullOrEmpty(value);
  public static bool IsNotBlank(this string? value) => !IsBlank(value);

  public static bool EqualsIgnoreCase(this string? a, string? b) =>
    string.Equals(a, b, StringComparison.OrdinalIgnoreCase);

  public static string ReplaceIgnoreCase(this string input, string oldValue, string newValue) =>
    input.Replace(oldValue, newValue, StringComparison.OrdinalIgnoreCase);

  public static bool StartsWithIgnoreCase(this string a, string b) =>
    a.StartsWith(b, StringComparison.OrdinalIgnoreCase);

  public static bool ContainsIgnoreCase(this string? a, string b) =>
    a?.Contains(b, StringComparison.OrdinalIgnoreCase) ?? false;

  public static bool ContainsIgnoreCase(this IEnumerable<string>? values, string? value)
  {
    if (values == null)
      return false;
    return values.Contains(value, StringComparer.OrdinalIgnoreCase);
  }

  public static int IndexOfIgnoreCase(this IReadOnlyList<string> values, string? value)
  {
    for (var i = 0; i < values.Count; i++)
      if (values[i].EqualsIgnoreCase(value))
        return i;
    return -1;
  }

  public static bool? ParseBool(this string? value)
  {
    if (value == null)
      return null;
    return value.EqualsIgnoreCase("true") || value.EqualsIgnoreCase("1");
  }
}