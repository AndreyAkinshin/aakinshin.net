---
layout: post
title: "Strange behavior of FindElementsInHostCoordinates in WinRT"
date: "2014-04-29"
lang: en
type: post
tags:
- ".NET"
- C#
- Silverlight
- WinRT
redirect_from:
- /en/blog/dotnet/findelementsinhostcoordinates/
- /blog/post/findelementsinhostcoordinates/
---

Silverlight features a splendid method: [VisualTreeHelper.FindElementsInHostCoordinates](http://msdn.microsoft.com/en-us/library/system.windows.media.visualtreehelper.findelementsinhostcoordinates(v=vs.95).aspx). It allows the `HitTest`, i.e. makes it possible for a point or rectangle to search for all visual sub-tree objects that intersect this rectangle or point. Formally the same method [VisualTreeHelper.FindElementsInHostCoordinates](http://msdn.microsoft.com/en-us/library/windows/apps/windows.ui.xaml.media.visualtreehelper.findelementsinhostcoordinates.aspx) is available in WinRT. And it seems the method looks in the same way, but there is a little nuance. It works differently in different versions of the platform. So, let’s see what’s going on.<!--more-->

Let’s create a simple Silverlight 5 application. The markup will look like this:

``` xml
<Grid x:Name="LayoutRoot">
  <Grid.RowDefinitions>
    <RowDefinition Height="*"/>
    <RowDefinition Height="100"/>
  </Grid.RowDefinitions>

  <Canvas MouseLeftButtonDown="OnMainCanvasMouseLeftButtonDown" 
          x:Name="MainCanvas" Background="LightGreen">
    <Ellipse Width="200" Height="200" Fill="LightCoral" />
    <Path Fill="LightBlue" Data="M 10,100 C 10,300 300,-200 300,100"/>
  </Canvas>

  <TextBlock Grid.Row="1" x:Name="StatusBlock" />
</Grid>
```

It’s very simple: we have a `Canvas`, an `Ellipse` and a `Path` are on the Canvas. A `TextBlock` for entering some useful info is located under this wonderful masterpiece. The app looks in the following way:

<p class="center">
  <img src="/img/posts/dotnet/findelementsinhostcoordinates/screen1.png" />
</p>

Now we will add a mouse click event handler: we will get the elements we clicked on. Here we will use two versions of `VisualTreeHelper.FindElementsInHostCoordinates` (for point and for rectangle):

```cs
public static IEnumerable FindElementsInHostCoordinates(
 Point intersectingPoint,
 UIElement subtree
)
public static IEnumerable FindElementsInHostCoordinates(
 Rect intersectingRect,
 UIElement subtree
)
```

A list of elements we get will be displayed in `StatusBlock`:

```cs
private void OnMainCanvasMouseLeftButtonDown(object sender, 
                                             MouseButtonEventArgs e)
{
  var p = e.GetPosition(MainCanvas);
  var listPoint = VisualTreeHelper.FindElementsInHostCoordinates(
                    new Point(p.X, p.Y), MainCanvas).ToList();
  var listRect = VisualTreeHelper.FindElementsInHostCoordinates(
                    new Rect(p.X, p.Y, 1, 1), MainCanvas).ToList();
  var strPoint = string.Join(", ", 
                   listPoint.Select(el => el.GetType().Name.ToString()));
  var strRect = string.Join(", ", 
                   listRect.Select(el => el.GetType().Name.ToString()));
  StatusBlock.Text = string.Format("[{0}] vs [{1}]", strPoint, strRect);
}
```

Our perfect app is ready! Something tells me that considering the rectangle size (1×1) results of two method overloads won’t differ. Let’s check it by clicking on different areas. The picture below shows the result of this test:

<p class="center">
  <img src="/img/posts/dotnet/findelementsinhostcoordinates/screen2.png" />
</p>

Everything seems to be ok: all methods work as expected. Now let’s proceed to WinRT. Create a new Windows Store application and add the same markup to it:

``` xml
<Grid Background="{StaticResource ApplicationPageBackgroundThemeBrush}">
  <Grid.RowDefinitions>
    <RowDefinition Height="*"/>
    <RowDefinition Height="100"/>
  </Grid.RowDefinitions>

  <Canvas Tapped="OnMainCanvasTapped" 
          x:Name="MainCanvas" Background="LightGreen">
    <Ellipse Width="200" Height="200" Fill="LightCoral" />
    <Path Fill="LightBlue" Data="M 10,100 C 10,300 300,-200 300,100"/>
  </Canvas>

  <TextBlock Grid.Row="1" x:Name="StatusBlock" />
</Grid>
```

Code of the `OnMainCanvasTapped` handler matched `OnMainCanvasMouseLeftButtonDown` code. Let’s run the application and click on it. Results look as follows:

<p class="center">
  <img src="/img/posts/dotnet/findelementsinhostcoordinates/screen3.png" />
</p>

What a turn out! A short test of the app results in the following conclusion: point `HitTest` works in the same way as in the Silverlight application while rectangle HitTest for the Path-figures works not for the figure itself, but for its BoundingBox. WinRT applications are created based on the Touch First principle, that’s why Rect-version of the code if more interesting. In most cases this issue won’t be critical, but if an application is oriented to interaction with various arcuate elements, it’s better to pay special attention to the behavior of `FindElementsInHostCoordinates`.

## Cross-posts

* [blogs.perpetuumsoft.com](http://blogs.perpetuumsoft.com/silverlight/strange-behavior-of-findelementsinhostcoordinates-in-winrt/)