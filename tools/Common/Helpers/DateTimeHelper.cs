using System.Globalization;

namespace Common.Helpers;

public static class DateTimeHelper
{
    private static readonly CultureInfo Culture = CultureInfo.InvariantCulture;
    private const DateTimeStyles Styles = DateTimeStyles.None;

    private const string Format = "yyyy-MM-dd";
    public static string FormatNice(this DateTime dateTime) => dateTime.ToString(Format, Culture);
    public static string FormatNice(this DateOnly dateOnly) => dateOnly.ToString(Format, Culture);
    public static string FormatNice(this TimeOnly timeOnly) => timeOnly.ToString("HH:mm", Culture);

    public static DateTime? ParseDateTime(string dateTime)
    {
        if (DateTime.TryParseExact(dateTime, Format, Culture, Styles, out var result))
            return result;
        return null;
    }

    public static DateOnly? ParseDateOnly(string dateTime)
    {
        if (DateOnly.TryParseExact(dateTime, Format, Culture, Styles, out var result))
            return result;
        return null;
    }

    public static DateOnly ToDateOnly(this DateTime dateTime) => DateOnly.FromDateTime(dateTime);
    public static TimeOnly ToTimeOnly(this DateTime dateTime) => TimeOnly.FromDateTime(dateTime);
}