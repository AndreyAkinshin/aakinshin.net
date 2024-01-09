using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Serialization;
using static System.Math;

namespace Efficiency
{
    public class DoubleJsonConverter : JsonConverter<double>
    {
        public override double Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            return reader.GetDouble();
        }

        public override void Write(Utf8JsonWriter writer, double value, JsonSerializerOptions options)
        {
            writer.WriteStringValue(Format(value));
        }

        public static void Showcase()
        {
            double[] values = Enumerable
                .Range(-15, 21)
                .Select(scale => 123456789.123456789 * Math.Pow(10, scale))
                .Reverse()
                .ToArray();
            foreach (var value in values)
            {
                Console.WriteLine(Format(value));
            }
        }
        public static string Format(double value)
        {
            List<string> options = new List<string>();
            
            options.Add(value.ToString("E4", CultureInfo.InvariantCulture));
            
            options.Add(value.ToString(CultureInfo.InvariantCulture));
            
            if (Math.Abs(value) > 10000)
                options.Add(Math.Round(value).ToString(CultureInfo.InvariantCulture));

            try
            {
                options.Add(Round(value).ToString(CultureInfo.InvariantCulture));
            }
            catch 
            {
                // Ignore
            }

            return options.OrderBy(s => s.Length).First();
        }

        public static string Round(double value)
        {
            if (Abs(value) < 1e-18)
                return "0";
            var power = (int)Floor(Log10(Abs(value))) + 1;
            var scale = Pow(10, power);

            var result = Math.Round((decimal)(value / scale), 4);
            for (int i = 0; i < power; i++)
                result *= 10;
            for (int i = 0; i < -power; i++)
                result /= 10;

            string s = result.ToString(CultureInfo.InvariantCulture).TrimEnd('0');
            if (s.EndsWith("."))
                s = s.Substring(0, s.Length - 1);
            return s;
        }
    }
}