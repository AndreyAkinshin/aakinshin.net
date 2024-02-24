using System.Diagnostics;
using System.Text;
using Common.Extensions;
using Common.Io;

namespace Common.Helpers;

public static class ProcessHelper
{
  public static async Task<string> RunAndGetOutput(FilePath filePath, string arguments = "", TimeSpan? timeout = null)
  {
    using var process = new Process();
    process.StartInfo = new ProcessStartInfo
    {
      FileName = filePath,
      Arguments = arguments,
      RedirectStandardOutput = true,
      RedirectStandardError = true,
      UseShellExecute = false,
      CreateNoWindow = true
    };

    try
    {
      var outputBuilder = new StringBuilder();
      process.OutputDataReceived += (_, args) => outputBuilder.AppendLine(args.Data ?? "");
      process.Start();
      process.BeginOutputReadLine();
      await Task.Run(() => process.WaitForExit(timeout ?? Timeout.InfiniteTimeSpan));
      if (process.ExitCode != 0)
        throw new Exception($"Failed to get output of {filePath} with arguments {arguments}.");

      var output = outputBuilder.ToString();
      if (output.IsNotBlank())
        return output;

      throw new Exception($"Failed to get output of {filePath} with arguments {arguments}.");
    }
    catch (Exception ex)
    {
      throw new Exception($"An error occurred running {filePath} with arguments {arguments}: {ex.Message}");
    }
  }
}