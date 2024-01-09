using System.Globalization;

namespace Simulation;

public static class DefaultCultureInfo
{
    public static readonly CultureInfo Instance;

    static DefaultCultureInfo()
    {
        Instance = (CultureInfo) CultureInfo.InvariantCulture.Clone();
        Instance.NumberFormat.NumberDecimalSeparator = ".";
        Instance.NumberFormat.NumberGroupSeparator = "";
    }
}