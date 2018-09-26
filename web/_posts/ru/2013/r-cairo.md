---
layout: ru-post
title: Cairo — делаем графики гладкими
date: "2013-06-03"
lang: ru
type: post
tags:
- R
- R-plots
- R-packages
redirect_from:
- /ru/blog/r/cairo/
- /ru/blog/post/r-cairo/
---

R обладает богатейшим функционалом по формированию различных графиков. К сожалению, иногда графики получается не настолько красивыми, как бы нам хотелось. Давайте нарисуем график синуса: 

{% highlight r %}
x <- seq(0, 10, by = 0.1)
y <- sin(x)
plot(x, y, type="l")
{% endhighlight %}

Если вы хорошо вглядитесь в это изображение, то увидите, что функция получилась не совсем гладкой. Дело в том, что стандартное графическое устройство не поддерживает [anti-aliasing](http://ru.wikipedia.org/wiki/%D0%A1%D0%B3%D0%BB%D0%B0%D0%B6%D0%B8%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5). Но не стоит грустить! Нам поможет *Cairo*!  [Cairo](http://ru.wikipedia.org/wiki/Cairo) — это программная библиотека, предназначенная для рендеринга векторной графики с не зависящим от оборудования API. А для языка R есть [одноимённый пакет](http://cran.r-project.org/web/packages/Cairo/index.html). Вы можете почитать [документацию](http://cran.r-project.org/web/packages/Cairo/Cairo.pdf) к этому пакету, но пока что мы посмотрим работу на примере. Для начала установим пакет и подключим его: 

{% highlight r %}
install.packages("Cairo")
library("Cairo")
{% endhighlight %}

Допустим, я работаю под операционной системой Windows и хочу просто посмотреть на гладкий график функции. Нет ничего проще:

{% highlight r %}
CairoWin()
plot(x, y, type="l")
{% endhighlight %}

<p class="center">
  <img src="/img/posts/r/cairo/sin.png" />
</p>

А теперь давайте ещё раз нарисуем наш график, но результат получим в виде png-файла:

{% highlight r %}
CairoPNG("sin.png")
plot(x, y, type="l")
dev.off() # Завершаем формирование файла
{% endhighlight %}

<p class="center">
  <img src="/img/posts/r/cairo/sin-antialiasing.png" />
</p>

В Cairo-функциях можно указывать множество дополнительных параметров, таких как ширина и высота изображения, тип файла, его качество, цвет фона и многое другое. Конечно, для рабочего процесса Cairo не так уж и нужен, но при формировании отчётов о проделанной работе он поможет сделать ваши графики более привлекательными.