using System.IO;
using System.IO.Compression;
using System.Text;

namespace Efficiency
{
    public static class FileUtil
    {
        public static void WriteAllTextCompressed(string fileName, string contents)
        {
            using var inputStream = new MemoryStream(Encoding.UTF8.GetBytes(contents));
            using var outputStream = File.Create(fileName);
            using var gZipOutputStream = new GZipStream(outputStream, CompressionMode.Compress);

            inputStream.CopyTo(gZipOutputStream);
        }
    }
}