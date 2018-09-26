---
layout: ru-post
title: "Странное поведение FindElementsInHostCoordinates в WinRT"
date: "2014-04-29"
lang: ru
type: post
tags:
- ".NET"
- C#
- Silverlight
- WinRT
redirect_from:
- /ru/blog/dotnet/findelementsinhostcoordinates/
- /ru/blog/post/findelementsinhostcoordinates/
---

Есть в Silverlight отличный метод: [VisualTreeHelper.FindElementsInHostCoordinates](http://msdn.microsoft.com/en-us/library/system.windows.media.visualtreehelper.findelementsinhostcoordinates(v=vs.95).aspx) — позволяет выполнять `HitTest`, т.е. для некоторой точки или прямоугольника искать все объекты визуального поддерева, которые с этими точкой или прямоугольником пересекаются. Внешне точно такой же метод [VisualTreeHelper.FindElementsInHostCoordinates](http://msdn.microsoft.com/en-us/library/windows/apps/windows.ui.xaml.media.visualtreehelper.findelementsinhostcoordinates.aspx) можно встретить в WinRT. И вроде выглядит-то он точно также, но есть нюанс: работает этот чудо-метод в разных версиях платформы по-разному. Давайте разберёмся.<!--more-->

Сначала создадим простое Silverlight 5 приложение. Основная вёрстка будет выглядеть следующим образом:

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

Тут всё очень просто: имеется `Canvas`, а на нём лежит `Ellipse` и `Path`. Прямо под этим чудесным произведением искусства находится `TextBlock` в который мы можем вывести что-нибудь полезное. Выглядит приложение следующим образом:

<p class="center">
  <img src="/img/posts/dotnet/findelementsinhostcoordinates/screen1.png" />
</p>

Теперь напишем обработчик события для клика мышкой по нашему `Canvas`-элементу: будем искать элементы, в которые мы попали. Для этого нам пригодятся две версии `VisualTreeHelper.FindElementsInHostCoordinates` (для точки и для прямоугольника):

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

Список полученных объектов будем выводить в `StatusBlock`:

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

Наше отличное приложение готово! Что-то внутри подсказывает, что ввиду размеров прямоугольника (1x1) результаты работы двух перегрузок метода не должны отличаться. Давайте проверим, потыкав в разные места. Следующая картинка показывает результаты проведённого опыта:

<p class="center">
  <img src="/img/posts/dotnet/findelementsinhostcoordinates/screen2.png" />
</p>

Ну, вроде всё хорошо, методы отработали, как и ожидалось. А теперь перейдём к WinRT. Создадим новое Windows Store приложение и снабдим его аналогичной вёрсткой:

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

Код обработчика `OnMainCanvasTapped` полностью совпадает с кодом `OnMainCanvasMouseLeftButtonDown`. Давайте запустим приложение и потыкаем в него. Результаты:

<p class="center">
  <img src="/img/posts/dotnet/findelementsinhostcoordinates/screen3.png" />
</p>

Вот это поворот! Недолгое кликанье по приложению быстро подведёт нас к выводу: точечный HitTest работает точно также, как и в Silverlight, а вот HitTest по прямоугольнику для Path-фигур работает не по самой фигуре, а по её BoundingBox-у (ограничивающему прямоугольнику). WinRT-приложения делаются по принципу Touch First, так что наиболее интересна именно Rect-версия метода. В большинстве случаев этот момент скорее всего будет не особо принципиален, но вот если приложение ориентировано на взаимодействие с различными изогнутыми элементами, то на особенность такого поведения `FindElementsInHostCoordinates` лучше бы обратить особое внимание.