using System.Collections.Specialized;

namespace Common.Collections;

public class OrderedDictionary<TKey, TValue>  where TValue : class
{
    private readonly OrderedDictionary dictionary = new();
    public IEnumerable<TKey> Keys => GetKeys();

    public bool ContainsKey(TKey key) => dictionary.Contains(key);

    public TValue this[TKey key]
    {
        get => dictionary[key] as TValue;
        set => dictionary[key] = value;
    }

    public IEnumerable<TKey> GetKeys() => dictionary.Keys.Cast<TKey>();

    public TValue? GetValueOrDefault(string key) => dictionary.Contains(key) ? (TValue)dictionary[key] : null;

    public void Remove(string key) => dictionary.Remove(key);
}