using System.Text.Json;
using System.Text.RegularExpressions;
using Common.Extensions;
using Common.Helpers;
using Common.Light;

namespace Generate.Books;

public class BookEntry(LightContent content) : LightEntry(content)
{
    public async Task FetchAsync()
    {
        try
        {
            var existingUrlCover = Content.Yaml.GetScalar("urlCover");
            if (existingUrlCover.IsNotBlank()) return;

            var goodReadsId = Content.Yaml.GetScalar("goodreads");
            if (goodReadsId.IsBlank()) return;

            var url = $"https://www.goodreads.com/book/show/{goodReadsId}";
            var html = await WebHelper.DownloadStringAsync(url);

            var jsonPattern = @"<script type=""application/ld\+json"">(.*?)</script>";
            var jsonMatch = Regex.Match(html, jsonPattern, RegexOptions.Singleline);
            if (jsonMatch.Success)
            {
                var jsonContent = jsonMatch.Groups[1].Value;
                var jsonDocument = JsonDocument.Parse(jsonContent);
                var imageUrl = jsonDocument.RootElement.GetProperty("image").GetString();
                if (imageUrl != null && imageUrl.IsNotBlank())
                {
                    Content.Yaml.Set("urlCover", imageUrl);
                    LogInfo("Fetched cover");
                }
            }
        }
        catch (Exception ex)
        {
            LogError(ex);
        }
    }
}