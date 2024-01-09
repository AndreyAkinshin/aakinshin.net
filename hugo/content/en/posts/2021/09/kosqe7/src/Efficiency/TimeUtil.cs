using System;

namespace Efficiency
{
    public static class TimeUtil
    {
        public static string Format(TimeSpan timeSpan)
        {
            if (timeSpan.TotalMinutes < 0)
                return timeSpan.TotalSeconds.ToString("N1") + "s";

            var minutes = (int)Math.Floor(timeSpan.TotalMinutes);
            var seconds = (int)Math.Round(timeSpan.TotalSeconds - minutes * 60);
            return minutes + "m" + seconds + "s";
        }
    }
}