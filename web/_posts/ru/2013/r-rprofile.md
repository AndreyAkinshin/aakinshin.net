---
layout: ru-post
title: Rprofile — кастомизируем рабочее окружение
date: "2013-06-03"
lang: ru
type: post
tags:
- R
- R-settings
redirect_from:
- /ru/blog/r/rprofile/
- /ru/blog/post/r-rprofile/
---

Давайте поговорим о задании окружения в R. Для этой цели имеется два волшебных файла:

*  `Rprofile.site` — глобальный файл настроек для всех сессий. Путь в Windows: `c:\Program Files\R\R-x.y.z\etc\Rprofile.site`, путь в Linux: `/etc/R/Rprofile.site`.
*  `.Rprofile` — локальный файл настроек для текущей сессии. Лежит в домашней директории пользователя.

Эти файлы строятся единообразно, в них можно задать глобальные настройки окружения и объявить две полезных функции:

* `.First <- function() { ... }` — функция, которая запускается в начале R-сессии
* `.Last <- function() { ... }` — функция, которая запускается в конце R-сессии

На Stackoverflow [можно посмотреть](http://stackoverflow.com/questions/1189759/expert-r-users-whats-in-your-rprofile) какие .Rprofile-файлы используют люди. Взглянем, что же можно полезного сделать в таком файле на небольших примерах. <!--more-->

### Подключение часто используемых пакетов

Есть ли у вас любимые пакеты, которые вы используете в каждой R-сессии? Вас утомляет каждый раз их импортировать? Так давай те же сделаем это единожды:

``` r
library(ggplot2)
library(rgl)
```

### Создание псевдонимов для часто используемых функций

А есть ли у вас любимые функции, которые вы вызываете очень часто? Их названия слишком длинные? Так давайте же создадим для них псевдонимы:

``` r
s <- base::summary; # используем s(obj) вместо summary(obj)
h <- utils::head;   # используем h(obj) вместо head(obj)
n <- base::names;   # используем n(obj) вместо names(obj)
```

### Задание предпочитаемого репозитория

У стандартного репозитория [CRAN](http://cran.r-project.org/) есть много [зеркал](http://cran.r-project.org/mirrors.html). Вы можете задать любимый репозиторий несколькими строчками кода:

``` r
 local({r <- getOption("repos")
       r["CRAN"] <- "http://cran.gis-lab.info/"
       options(repos=r)})
```

### Задание основного языка

А давайте сделаем так, чтобы по умолчанию язык был английский:

``` r
Sys.setenv(lang = "en")
```

### Установка различных опций

Вы можете установить любые опции на свой вкус:

``` r
options(papersize="a4")
options(editor="notepad")
options(pager="internal")
options(help_type="html")
options("width"=160)
options("digits.secs"=3)
options(prompt="R> ", digits=4, show.signif.stars=FALSE)
```