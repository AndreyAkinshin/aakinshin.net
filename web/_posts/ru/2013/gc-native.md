---
layout: ru-post
title: "Неожиданное место для сборки мусора в .NET"
date: "2013-08-08"
lang: ru
type: post
tags:
- ".NET"
- GC
- OpenCV
redirect_from:
- /ru/blog/dotnet/gc-native/
- /ru/blog/post/gc-native/
---

Платформа .NET обеспечивает нас высокоинтеллектуальным сборщиком мусора, который избавляет от рутины ручного управления памятью. И в 95% случаев можно действительно забыть про память и связанные с ней нюансы. Но вот оставшиеся 5% обладают своей спецификой, связанной с неуправляемыми ресурсами, слишком большими объектами и т.д. И тут лучше бы хорошо разбираться в том, как производится сборка мусора. В противном случае вас могут ждать очень неприятные сюрпризы.

Как вы думаете, может ли GC собрать объект до того, как выполнится последний из его методов? Оказывается, может. Правда, для этого необходимо запустить приложение в Release mode и отдельно от студии (without debugging). В этом случае JIT-компилятор сделает определённые оптимизации, в результате которых такая ситуация возможна. Разумеется, делает он это только тогда, когда в оставшемся теле метода нет ссылок на сам объект или его поля. Казалось бы, достаточно невинная оптимизация. Но она может привести к проблемам, если мы имеем дело с неуправляемыми ресурсами: сборка объекта может произойти *до того*, как закончится операция над неуправляемым объектом, что вполне вероятно повлечёт падение приложения.<!--more-->

Давайте воспроизведём ситуацию. Для начала нам понадобится что-нибудь неуправляемое, скажем библиотека [OpenCvSharp](https://code.google.com/p/opencvsharp/)
, которая представляет собой обёртку над [OpenCV](http://opencv.org/) — библиотекой компьютерного зрения и обработки изображений. Взята именно эта библиотека, т.к. на ней и была обнаружена неприятная ситуация. Рассмотрим следующий класс:

```cs
public class ImageWithCircle
{
  private const int Size = 10000;
  private readonly IplImage image;

  public ImageWithCircle()
  {            
    image = Cv.CreateImage(new CvSize(Size, Size), BitDepth.U8, 3);
    DrawCircle();
  }

  ~ImageWithCircle()
  {
    Console.WriteLine("~ImageWithCircle");
    Cv.ReleaseImage(image);
  }

  public void Save()
  {
    Console.WriteLine("Save start");
    image.SaveImage("image.tif");
    Console.WriteLine("Save end");
  }

  public void DrawCircle()
  {
    image.FloodFill(new CvPoint(Size / 2, Size / 2), CvColor.White);
    image.Circle(new CvPoint(Size / 2, Size / 2), Size / 4, 
                 CvColor.Random(), 10);
  }
}
```

Это весьма простой класс, который отвечает за рисование очень большой картинки с кружочком. Имеется метод `Save()`, который сохраняет картинку в файл. Логика работы с изображением заключена в классе `IplImage` из библиотеки OpenCvSharp. Запустим этот код:

```
static void Main()
{
  new ImageWithCircle().Save();
}
```

На консоли появится ожидаемый вариант: мы зашли в метод `Save()`, мы вышли из него, а только потом выполнилась сборка мусора и был вызван соответствующий финализатор.

```
Save start
Save end
~ImageWithCircle
```

А теперь вызовем сборку мусора *во время сохранения картинки*. Это всего лишь пример, поэтому не будет изобретать что-то умное, а просто включим `Timer`, который будет весьма часто запускать `GC.Collect()`. Картинка очень большая, и мы навярника запустим сборку мусора хотя бы раз до окончания её сохранения. Итак, исполняемый код теперь выглядит следующим образом:

```
private static void Main()
{
  var timer = new Timer(100);
  timer.Elapsed += RunGc;
  timer.Start();
  new ImageWithCircle().Save();
}

private static void RunGc(object sender, ElapsedEventArgs e)
{
  Console.WriteLine("Gc.Collect();");
  GC.Collect();
}
```

Наверное, вы ожидаете увидеть что-нибудь вроде:

```
Gc.Collect();
Gc.Collect();
Gc.Collect();
Save start
Gc.Collect();
Gc.Collect();
Gc.Collect();
Gc.Collect();
Gc.Collect();
Gc.Collect();
Save end
~ImageWithCircle
```

Но если выполнить запуск в Release mode without debugging, то приложение упадёт:

```
Gc.Collect();
Gc.Collect();
Gc.Collect();
Save start
Gc.Collect();
~ImageWithCircle

Unhandled Exception: System.AccessViolationException: Attempted to read or write
 protected memory. This is often an indication that other memory is corrupt.
   at OpenCvSharp.CvInvoke.cvSaveImage(String filename, IntPtr image, Int32[] pa
rams)
   at OpenCvSharp.Cv.SaveImage(String filename, CvArr image, ImageEncodingParam[
] prms)
   at ConsoleApplication.ImageWithCircle.Save() in d:\Tests\ConsoleApplica
tion\ConsoleApplication\ImageWithCircle.cs:line 28
   at ConsoleApplication.Program.Main() in d:\Tests\ConsoleApplication\Co
nsoleApplication\Program.cs:line 18
Gc.Collect();
Gc.Collect();
```

Проблема в том, что JIT всё-таки выполнил свою коварную оптимизацию: наш объект подвергся сборке мусора прежде, чем картинка полностью успела сохраниться в файл. Увы, OpenCvSharp не смог такого пережить и выбросил исключение.

Ситуацию исправить очень легко: достаточно удерживать ссылку на текущую картинку до окончания работы метода. Например, можно воспользоваться каким-нибудь статическим объектом, в который картинка будет записывать ссылку на себя в начале метода `Save()`. Но я предпочитаю использовать метод [GC.KeepAlive](http://msdn.microsoft.com/en-us/library/system.gc.keepalive.aspx):

```cs
public void Save()
{
  Console.WriteLine("Save start");
  image.SaveImage("image.tif");
  Console.WriteLine("Save end");
  GC.KeepAlive(this);
}
```

Собственно говоря, не так важно, как именно вы исправите ситуацию, главное — понимать нюансы работы сборщика мусора, чтобы предвидеть подобные проблемы, ведь их очень сложно обнаружить: падение приложения в примере возникает только при определённой конфигурации запуска в случае, если сборщику мусора доведётся запуститься во время исполнения какого-то достаточно продолжительного выполнения неуправляемого метода. И если вы случайно натолкнётесь на такое падение приложения, то потом будете ещё долго ломать голову над тем, как же его теперь воспроизвести. Для избежания таких ситуаций необходимо тщательно проектировать взаимодействие с любыми нативными объектами, стараясь предвидеть возможные проблемы до этапа написания кода.