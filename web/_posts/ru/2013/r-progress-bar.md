---
layout: ru-post
title: Progress bar в R
date: "2013-06-03"
lang: ru
type: post
tags:
- R
- R-gui
redirect_from:
- /ru/blog/r/progress-bar/
- /ru/blog/post/r-progress-bar/
---

Давайте поговорим о долгих расчётах, ведь они не так редко встречаются в мире вычислений. Когда вы запускаете скрипт, который будет заведомо долго работать, то приятно смотреть на состояние прогресса. Эта информация поможет прикинуть время до конца вычислений (*&laquo;осталось ещё 30%, я успею выпить чашку кофе&raquo;*
) или просигнализировать о бесконечном цикле (<i>*1438% выполнено, что-то пошло не так...*</i>
). Давайте научим наш скрипт сообщать пользователю о проценте выполненных работ.<!--more-->

Пусть у нас есть очень полезная функция, которая делает что-то очень важное некоторое время:

``` r
foo <- function() {
  Sys.sleep(0.1)
}
```

И эта функция запускается несколько раз:

```
for (i in 1:10) {
  foo()
}
```

Казалось бы, самое простое решение — выводить на экран количество выполненных операцией:

```
for (i in 1:10) {
  foo()
  print(i)
}
```

Но такой фокус не всегда будет работать. Дело в том, что R любит буфферезировать вывод на консоль, т.е. не обязательно мы увидим вывод команды сразу после её выполнения. К счастью, [есть способ](http://cran.r-project.org/bin/windows/rw-FAQ.html#The-output-to-the-console-seems-to-be-delayed), победить эту проблему — нам поможет строчка для обновления консоли: *flush.console()*.

``` r
for (i in 1:10) {
  foo()
  print(i)
  flush.console()
}
```

Решение работает, но оно не такое уж и красивое. Давайте сделаем настоящий progress bar. Для начала простенький, текстовый. Сделать это весьма просто:

``` r
pb <- txtProgressBar(min = 0, max = 10, style = 3) # Создаём progress bar
for(i in 1:10){
   foo()
   setTxtProgressBar(pb, i) # Обновляем progress bar
}
close(pb) # Закрываем progress bar
```

Но можно пойти ещё дальше по пути к созданию прекраснейшего progress bar-а. А поможет нам в этом пакет tcltk:

``` r
pb <- tkProgressBar(title = "progress bar", min = 0,
                    max = 10, width = 300) # Создаём progress bar
 
for(i in 1:10){
   foo()
   setTkProgressBar(pb, i, label=paste(
                    round(i/10 * 100, 0), "% done")) # Обновляем progress bar
}
close(pb) # Закрываем progress bar
```

А для пользователей Windows можно предложить ещё один способ:

``` r
pb <- winProgressBar(title = "progress bar", min = 0,
                     max = 10, width = 300)  # Создаём progress bar
for(i in 1:10){
   foo()
   setWinProgressBar(pb, i, title=paste( 
                     round(i/10 * 100, 0), "% done"))  # Обновляем progress bar
}
close(pb)  # Закрываем progress bar
```

<p class="center">
  <img src="/img/posts/r/progress-bar/screen.png" />
</p>

Ну вот и всё, теперь вы умеете создавать разнообразные progress bar-ы и делать процесс выполнения R-скрипта более информативным.

### Ссылки

* [R: Monitoring the function progress with a progress bar](http://ryouready.wordpress.com/2009/03/16/r-monitor-function-progress-with-a-progress-bar/r-progress-bar.md).