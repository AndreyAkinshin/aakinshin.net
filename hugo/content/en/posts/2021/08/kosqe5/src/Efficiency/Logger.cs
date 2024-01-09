using System;
using System.IO;

namespace Efficiency
{
    public static class Logger
    {
        private static readonly StreamWriter Writer = new("log.txt");
        
        static Logger()
        {
        }

        public static void WriteLine(string message)
        {
            Console.WriteLine(message);
            Writer.WriteLine(message);
            Writer.Flush();
        }
    }
}