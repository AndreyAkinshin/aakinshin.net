---
layout: ru-post
title: "Рисуем комиксы в стиле xkcd"
date: "2013-06-03"
lang: ru
type: post
tags:
- R
- R-plots
- R-packages
- Fun
- xkcd
redirect_from:
- /ru/blog/r/xkcd/
- /ru/blog/post/r-xkcd/
---

Многие слышали о таком замечательном комиксе, как [xkcd](http://www.xkcd.com/r-xkcd.md). Это веб-комикс от [Рэндела Манро](http://ru.wikipedia.org/wiki/%D0%9C%D0%B0%D0%BD%D1%80%D0%BE,_%D0%A0%D1%8D%D0%BD%D0%B4%D0%B5%D0%BB) о романтике, сарказме, математике и языке. Для некоторых комиксов есть
[переводы на русский](http://www.xkcd.ru/r-xkcd.md). Для поиска и просмотра ваших любимых комиксов в R есть отдельный пакет:
[RXKCD](http://cran.r-project.org/web/packages/RXKCD/index.html). Давайте установим этот пакет и подключим его:

``` r
install.packages("RXKCD")
library("RXKCD")
```

Давайте поищем какой-нибудь комикс, а затем нарисуем его. Функция <i>searchXKCD</i>
выдаст нам список всех комиксов, в описании которых встречается заданная фраза. А <i>getXKCD</i>
выдаст нам полную информацию о комиксе по заданному номеру (включая рисование картинки).

``` r
searchXKCD("someone is wrong")
getXKCD(386)
```

<p class="center">
  <img src="/img/posts/r/xkcd/screen1.png" />
</p>

А теперь помимо стандартных комиксов научимся рисовать свои! <!--more--> Но только вот нарисовать целиком комикс будет не так просто, но вот график в стиле xkcd &mdash; проще простого. На Stackoverflow однажды был [вопрос](http://stackoverflow.com/questions/12675147/how-can-we-make-xkcd-style-graphs-in-r) о том, как это сделать. Прежде всего, нам понадобится основной шрифт комиксов xkcd &mdash; [Humor-Sans](http://r-language.ru/wp-admin/post.php?post=104&action=edit&message=10). Чтобы работать с разными клёвыми шрифтами, нужно прописать следующие строчки:

``` r
library(extrafont)
loadfonts()
```

Но в некоторых случаях конкретно с Humor-Sans у вас могут быть проблемы (подробнее можно почитать [тут](http://www.r-bloggers.com/change-fonts-in-ggplot2-and-create-xkcd-style-graphs/r-xkcd.md)). Если, например, [вы работаете на ОС Windows](http://stackoverflow.com/questions/13989644/xkcd-style-graph-error-with-registered-fonts), то вам необходимо вручную [скачать](http://antiyawn.com/uploads/Humor-Sans.ttf) этот шрифт, а затем подключить его:

``` r
font_import(paths = c("path/to/humor-sans"))
loadfonts(device = "win")
```

Теперь мы готовы нарисовать график. Для начала посмотрим способ через [ggplot2](http://ggplot2.org/). Подготовим данные для рисования:

``` r
data <- NULL
data$x <- seq(1, 10, 0.1)
data$y1 <- sin(data$x)
data$y2 <- cos(data$x)
data$xaxis <- -1.5
data <- as.data.frame(data)
```

А теперь подключим ggplot2, подготовим тему для рисования xkcd-комиксов, нарисуем график и сохраним его в картинку:

``` r
library("ggplot2")
 
# XKCD theme
theme_xkcd <- theme(
  panel.background = element_rect(fill="white"), 
  axis.ticks = element_line(colour=NA),
  panel.grid = element_line(colour="white"),
  axis.text.y = element_text(colour=NA), 
  axis.text.x = element_text(colour="black"),
  text = element_text(size=16, family="Humor Sans")
)
 
# Plot the chart
p <- ggplot(data=data, aes(x=x, y=y1))+
  geom_line(aes(y=y2), position="jitter")+
  geom_line(colour="white", size=3, position="jitter")+
  geom_line(colour="red", size=1, position="jitter")+
  geom_text(family="Humor Sans", x=6, y=-1.2, label="A SIN AND COS CURVE")+
  geom_line(aes(y=xaxis), position = position_jitter(h = 0.005), colour="black")+
  scale_x_continuous(breaks=c(2, 5, 6, 9), 
                     labels = c("YARD", "STEPS", "DOOR", "INSIDE"))+labs(x="", y="")+
  theme_xkcd
 
# Save to png
ggsave("xkcd_ggplot.jpg", plot=p, width=8, height=5)
```

<p class="center">
  <img src="/img/posts/r/xkcd/screen2.png" />
</p>

<br />

Мы рассмотрели способ рисования графика через jitter-функциональность пакета ggplot2. А [в другом ответе](http://stackoverflow.com/a/12680841/184842) предлагается способ эмуляции рисования "от руки" вручную. Создаётся функция рисования линии:

``` r
xkcd_line <- function(x, y, color) {
  len <- length(x);
  rg <- par("usr");
  yjitter <- (rg[4] - rg[3]) / 1000;
  xjitter <- (rg[2] - rg[1]) / 1000;
  x_mod <- x + rnorm(len) * xjitter;
  y_mod <- y + rnorm(len) * yjitter;
  lines(x_mod, y_mod, col='white', lwd=10);
  lines(x_mod, y_mod, col=color, lwd=5);
}
```

И функция рисования осей:

``` r
xkcd_axis <- function() {
  rg <- par("usr");
  yaxis <- 1:100 / 100 * (rg[4] - rg[3]) + rg[3];
  xaxis <- 1:100 / 100 * (rg[2] - rg[1]) + rg[1];
  xkcd_line(1:100 * 0 + rg[1] + (rg[2]-rg[1])/100, yaxis,'black')
  xkcd_line(xaxis, 1:100 * 0 + rg[3] + (rg[4]-rg[3])/100, 'black')
}
```

А теперь давайте нарисуем простенький график:

``` r
data <- data.frame(x=1:100)
data$one <- exp(-((data$x - 50)/10)^2)
data$two <- sin(data$x/10)
plot.new()
plot.window(
    c(min(data$x),max(data$x)),
    c(min(c(data$one,data$two)),max(c(data$one,data$two))))
xkcd_axis()
xkcd_line(data$x, data$one, 'red')
xkcd_line(data$x, data$two, 'blue')
```

В результате получим следующее изображение:

<p class="center">
  <img src="/img/posts/r/xkcd/screen3.png" />
</p>

Есть и другие варианты рисования картинок в стилистике xkcd. [Например](http://blog.phytools.org/2012/10/actual-xkcd-tree.html), можно рисовать древовидные структуры следующего вида:

<p class="center">
  <img src="/img/posts/r/xkcd/screen4.png" />
</p>

А поможет нам в этом пакет [phytools](http://cran.r-project.org/web/packages/phytools/index.html). Пользоваться им достаточно просто. К примеру, вот такой код:

``` r
require(phytools)
require("extrafont")
tree<-read.tree(text="((mammals,(birds,reptiles)),amphibians);")
tree<-compute.brlen(tree)
xkcdTree(tree,file="herpetology.pdf",lwd=2,color="black", 
         dim=c(4,4),jitter=0.001,waver=c(0.03,0.03))
```

даст нам такую вот замечательную картинку:

<p class="center">
  <img src="/img/posts/r/xkcd/screen5.png" />
</p>
