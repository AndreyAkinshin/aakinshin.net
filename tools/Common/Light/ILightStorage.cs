namespace Common.Light;

public interface ILightStorage
{
    void SaveAll();
    ILightFile? GetFile(string id);
    Task FetchAsync();
}