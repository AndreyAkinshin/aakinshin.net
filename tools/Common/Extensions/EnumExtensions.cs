namespace Common.Extensions;

public static class EnumExtensions
{
  public static ArgumentOutOfRangeException CreateUnknownException<T>(this T value, string? paramName = null)
    where T : Enum
  {
    return new ArgumentOutOfRangeException(paramName, value, $"Unknown {typeof(T)}: {value}");
  }
}