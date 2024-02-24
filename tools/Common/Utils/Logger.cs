namespace Common.Utils;

public static class Logger
{
    public static void Info(string message) => Console.WriteLine(message);

    public static void Trace(string message)
    {
        // Console.WriteLine(message);
    }

    public static void Error(string message)
    {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.Error.WriteLine(message);
        Console.ResetColor();
    }
}