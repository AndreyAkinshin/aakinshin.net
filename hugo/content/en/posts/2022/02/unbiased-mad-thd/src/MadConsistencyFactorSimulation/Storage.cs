using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Simulation;

public class Storage
{
    private const string DefaultCsvHeader = "n,factor";

    public string Name { get; }
    public string FilePath => Name + ".csv";

    private readonly object sync = new();

    private class Data
    {
        public Dictionary<int, double> ConsistencyFactors { get; } = new();
    }

    public Storage(string name)
    {
        Name = name;
    }

    public double? Get(int sampleSize)
    {
        lock (sync)
        {
            var factors = Load().ConsistencyFactors;
            return factors.ContainsKey(sampleSize) ? factors[sampleSize] : null;
        }
    }

    public void Add(int sampleSize, double consistencyFactor)
    {
        lock (sync)
        {
            var data = Load();
            data.ConsistencyFactors[sampleSize] = consistencyFactor;
            Save(data);
        }
    }

    private Data Load()
    {
        var data = new Data();
        if (!File.Exists(FilePath))
            return data;

        using var streamReader = new StreamReader(FilePath);
        var header = streamReader.ReadLine();
        if (header != DefaultCsvHeader)
            throw new InvalidDataException($"Wrong csv header in {FilePath}");

        while (!streamReader.EndOfStream)
        {
            var line = streamReader.ReadLine();
            if (string.IsNullOrEmpty(line))
                continue;

            var parts = line.Split(',');
            var sampleSize = int.Parse(parts[0]);
            var consistencyFactor = double.Parse(parts[1]);
            data.ConsistencyFactors[sampleSize] = consistencyFactor;
        }

        return data;
    }

    private void Save(Data data)
    {
        using var streamWriter = new StreamWriter(FilePath);
        streamWriter.WriteLine(DefaultCsvHeader);
        foreach (var sampleSize in data.ConsistencyFactors.Keys.OrderBy(key => key))
            streamWriter.WriteLine($"{sampleSize},{data.ConsistencyFactors[sampleSize]}");
    }
}