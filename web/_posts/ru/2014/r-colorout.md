---
layout: ru-post
title: "Раскрашиваем R в терминале: пакет colorout"
date: "2014-07-11"
lang: ru
type: post
tags:
- R
- R-packages
- Terminal
redirect_from:
- /ru/blog/r/colorout/
- /ru/blog/post/r-colorout/
---


В последнее время мне часто приходится гонять R-скрипты на удалённом Linux-сервере. Большую часть работы я выполняю на домашней машине, но иногда приходится отлаживать скрипты прямо на сервере. В этом мне очень помогает пакет **colorout**, который умеет красиво раскрашивать R в терминале. Давайте взглянем на него чуть подробнее.

<p class="center">
  <img src="/img/posts/r/colorout/screen1.png" />
</p>

<!--more-->

Пакета нет в [CRAN](http://cran.r-project.org/), но зато он [выложен](https://github.com/jalvesaq/colorout) на GitHub-е, так что установить последнюю версию проще всего с помощью [devtools](http://cran.r-project.org/web/packages/devtools/index.html):

``` r
library(devtools)
install_github('jalvesaq/colorout')
```

Чтобы пакет подключался автоматически, необходимо прописать `library(colorout)` в `.Rprofile` или `Rprofile.site`. Если вы запускаете R из различных окружений, то сперва стоит проверить, что данная сессия запущена из терминала (в этом поможет `Sys.getenv("TERM")`). Давайте взглянем на то, как теперь выглядит работа с R. Для этого воспользуемся [примером](http://www.lepem.ufc.br/jaa/colorout.html) от автора пакета:

``` r
cat("Different colors for normal text, \"string\", dates (",
     as.character(Sys.Date()), ")\n",
     "numbers (12, -1.3), NULL, NA, NaN, Inf, TRUE and FALSE.\n", sep = "")
x <- data.frame(logic=c(T, T, F), factor=factor(c("abc", "def", "ghi")),
                string=c("ABC", "DEF", "GHI"), real=c(1.23, -4.56, 7.89),
                cien.not = c(1.234e-23, -4.56e+45, 7.89e78),
                date=as.Date(c("2012-02-21", "2013-02-12", "2014-03-04")),
                stringsAsFactors = FALSE)
rownames(x) <- 1:3
x
summary(x[, c(1, 2, 4, 6)])
# Warnings and erros are highlighted (even if not in English):
warning("This is an example of warning.")
example.of.error
# Messages sent to stderr are highlighted:
library(KernSmooth)
```

<p class="center">
  <img src="/img/posts/r/colorout/screen2.png" />
</p>

Если ваш терминал поддерживает 256 цветов (`Sys.getenv("TERM")` равно `"xterm-256color"`, а не просто `"xterm"`), то вы можете тонко подстроить цветовую гамму:

``` r
# The colors are customizable:
setOutputColors()
setOutputColors256(normal = 39, number = 51, negnum = 183, date = 43,
                   string = 79, const = 75, verbose = FALSE)
x
setOutputColors256(202, 214, 209, 184, 172, 179, verbose = FALSE)
x
```

<p class="center">
  <img src="/img/posts/r/colorout/screen3.png" />
</p>

Если поддержки 256 цветов нет, то выставить нужные цвета поможет обычный `setOutputColors`. На сегодняшний день у функций `setOutputColors` и `setOutputColors256`
имеются следующие аргументы:

```
  normal: Formating and color of normal text.
  number: Formating and color of numbers.
  negnum: Formating and color of negative numbers.
    date: Formating and color of dates (output in the format
          'yyyy-mm-dd').
  string: Formating and color of quoted text.
   const: Formating and color of 'TRUE', 'FALSE', 'NULL', 'NA', 'NaN'
          and 'Inf'.
stderror: Formating and color of text sent to stderr.
    warn: Formating and color of warnings.
   error: Formating and color of errors.
 verbose: Logical value indicating whether to print colored words
          showing the result of the setup.
```

Как и всегда, полную справку вы можете получить с помощью команд `?setOutputColors`, `?setOutputColors256`.

В общем, **colorout** — отличный штука! Всем рекомендую. А с помощью пакета **txtplot** можно прямо в консоли смотреть цветные графики =).

``` r
library(txtplot)
txtcurve(sin(pi*x),from=0,to=2)
```

<p class="center">
  <img src="/img/posts/r/colorout/screen4.png" />
</p>
