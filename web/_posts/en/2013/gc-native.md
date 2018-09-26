---
layout: post
title: "Unexpected area to collect garbage in .NET"
date: "2013-08-08"
lang: en
type: post
tags:
- ".NET"
- GC
- OpenCV
redirect_from:
- /en/blog/dotnet/gc-native/
- /blog/post/gc-native/
---

The .NET framework provides an intelligent garbage collector that saves us a trouble of manual memory management. And in 95% of cases you can forget about memory and related issues. But the remaining 5% have some specific aspects connected to unmanaged resources, too big objects, etc. And it’s better to know how the garbage is collected. Otherwise, you can get surprises.

Do you think GC is able to collect an object till its last method is complete? It appears it is. But it is necessary to run an application in release mode without debugging. In this case JIT compiler will perform optimizations that will make this situation possible. Of course, JIT compiler does it when the remaining method body doesn’t contain references to the object or its fields. It should seem a very harmless optimization. But it can lead to the problems if you work with the unmanaged resources: object compilation can be executed before the operation over the unmanaged resource is finished. And most likely it will result in the application crash. <!--more-->

Let’s reproduce the situation. For a beginning, we will need something unmanaged, for example [OpenCvSharp](https://code.google.com/p/opencvsharp/) that is a wrapper for [OpenCV](http://opencv.org/), a computer vision and image processing library.

I am talking about this library since I got this irritating issue using it. Have a look the following class:

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

This is quite a simple class responsible for drawing a very big picture with a circle. There is a `Save()` method that saves a picture to a file. Logic of the work with a picture is stored in the `IplImage` class from OpenCvSharp. Run this code:

```cs
static void Main()
{
  new ImageWithCircle().Save();
}
```

The console will show an expected variant: we started `Save()` method and ended it. Only after it garbage was collected and the corresponding finalizer is invoked.

```
Save start
Save end
~ImageWithCircle
```

And now let’s call garbage collection while the picture is being saved. This is just a sample; that is why we won’t invent anything complicated and just enable `Timer` that will call `GC.Collect()` quite frequently. The picture is very big and we will call garbage collector at least once before it is saved to a file. So, the executable code now looks in the following way:

```cs
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

Probably, you expect to see something of this kind:

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

But if you run the application in release mode without debugging the app will crash:

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

The problem is that JIT executed its insidious optimization: our object was subject to garbage collection before the picture is completely saved to a file. Unfortunately, OpenCvSharp couldn’t stand it and threw an exception.

The issue can be easily fixed: it’s just necessary to keep reference to the current picture till the method completes its work. For example, you can use some static object to which the picture will write reference to itself in the beginning of the `Save()` method. But I prefer to use the [GC.KeepAlive](http://msdn.microsoft.com/en-us/library/system.gc.keepalive.aspx) method:

```cs
public void Save()
{
  Console.WriteLine("Save start");
  image.SaveImage("image.tif");
  Console.WriteLine("Save end");
  GC.KeepAlive(this);
}
```

Actually, it’s not important in what way you will fix the issue; the main thing is to understand how garbage collector works to foresee such problems. They are hard to discover: the application in the sample crashes only with definite start configuration, in case if the garbage collector is able to run while some time-consuming unmanaged method is executed. And if you occasionally get such application crash you will spend much time trying to reproduce it. To avoid such issues it is necessary to carefully design interaction with any native objects trying to foresee probable troubles before the code is written.

## Cross-posts

* [blogs.perpetuumsoft.com](http://blogs.perpetuumsoft.com/dotnet/unexpected-area-to-collect-garbage-in-net/)