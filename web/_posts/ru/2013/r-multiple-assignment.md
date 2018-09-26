---
layout: ru-post
title: "Множественное присваивание в R"
date: "2013-06-03"
lang: ru
type: post
tags:
- R
- R-assignments
- R-operators
redirect_from:
- /ru/blog/r/multiple-assignment/
- /ru/blog/post/r-multiple-assignment/
---

R — мощный и лаконичный язык. С помощью коротких инструкций можно сделать очень многое. Но давайте сделаем R ещё лаконичнее.

Чего мне всегда не хватало в R — так это множественного присваивания. Из-за отсутствия этой возможности приходится иногда писать не совсем красивый код для получения результата функции, который должен распределиться по нескольким переменным:

``` r
x <- solve(matrix(c(2, 0, 0, 3), ncol=2), c(1, 1))
x1 <- x[1]
x2 <- x[2]
```

А вот было бы здорово если бы такие вещи можно было записывать в одну строчку, например так:

```
с(x1, x2) %=% solve(matrix(c(2, 0, 0, 3), ncol=2), c(1, 1))
```

Нет ничего проще!<!--more-->

Определим следующий бинарный оператор множественного присваивания:

``` r
'%=%' <- function(x, y) {
  x <- as.character(substitute(x)[-1])
  if (length(y) < length(x))
    y <- rep(y, ceiling(length(x) / length(y)))
  if (length(y) > length(x))
    y <- y[1:length(x)]
  mapply(assign, x, y, MoreArgs = list(envir = parent.frame()))
  invisible()
}
```

В лучших традициях R этот оператор устойчив к различным типам аргументов и к различной их длине. Все следующие инструкции будут прекрасно выполняться:

``` r
c(u1, u2) %=% c(1, 2)
c(u3, u4) %=% c(3, 4, 5)
c(u5, u6) %=% list("a", 6)
c(u7, u8, u9) %=% list("a", "b")
list(u10, u11, u12) %=% list(7, "second", c(8, 9))
```

А чтобы не объявлять этот замечательный оператор каждый раз заново, вы можете один раз прописать его в [rprofile](http://r-language.ru/articles/rprofile)-файле и пользоваться им повсеместно в своих вычислениях! 

### Ссылки

* [Stackoverflow](http://stackoverflow.com/questions/7519790/assign-multiple-new-variables-in-a-single-line-in-r).