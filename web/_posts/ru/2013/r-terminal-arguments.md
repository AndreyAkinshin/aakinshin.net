---
layout: ru-post
title: "Вызов R-скрипта с аргументами из консоли"
date: "2013-06-03"
lang: ru
type: post
tags:
- R
- Terminal
redirect_from:
- /ru/blog/r/terminal-arguments/
- /ru/blog/post/r-terminal-arguments/
---

Для выполнения R-скрипта из консоли нам понадобится помощь утилит `Rscript.exe` и `Rterm.exe`. Разница между ними состоит в том, что `Rscript.exe`
в результате выполнения выдаст нам только результат работы R-скрипта, а `Rterm.exe` выдаст полный лог R-сессии (включая стартовое приглашение к работе и все исполняемые команды). Если быть до конца честными, то `Rscript.exe` по сути вызывает `Rterm.exe` с специальными аргументами (об этом немного ниже). Рассмотрим пример запуска скрипта с аргументами командной строки:

```
Rterm.exe --no-restore --no-save --args 100 image <script.R >output.txt
Rscript.exe script.R 100 image >output.txt
```

Разберём эти команды чуть подробней.<!--more-->

Для начала напишем скрипт под названием `script.R` для рисования случайных точек, который будет принимать два аргумента: количество точек и имя файла, в который мы будем сохранять итоговую картинку. Код скрипта будет следующим:

``` r
args <- commandArgs(trailingOnly = T) # Получаем аргументы из командной строки
print(args)                           # Выводим их
n <- as.integer(args[1])              # Первый аргумент — количество точек
name <- args[2]                       # Второй аргумент — имя картинки
x <- rnorm(n)                         # Генерируем точки
png(paste0(name, ".png"))             # Создаём png-картинку
plot(1:n, x)                          # Рисуем картинку
dev.off()                             # Заканчиваем рисовать
summary(x)                            # И немного статистики напоследок
```

Особый интерес для нас представляет только первая строчка (остальной код приведён для иллюстрации). Для получения аргументов используется функция `commandArgs`
, принимающая единственный параметр — `trailingOnly`. Если `trailingOnly` выставлен в `FALSE` , то функция вернёт список вообще всех аргументов, которые были переданы исполняемому файлу `Rterm.exe` . В случае значения `TRUE` будут возвращены только аргументы, указанные после аргумента `--args` .

Вернёмся к двум строчкам запуска скрипта из консоли. Аргументы `--no-restore --no-save` в первой строчке означают, что перед выполнением скрипта нам не нужно восстанавливать никакое рабочее окружение, а после его выполнения — не нужно сохранять. `&gt;output` в самом конце каждой строчке означает, что вывод с консоли будет перенаправлен в файл `output.txt`. В конце работы скрипта в каждом случае будет создан файл `image.png` с распределением наших случайных точек. Разница будет заключаться в выводе `output.txt`. В первом случае мы получим примерно следующее:

```
R version 3.0.0 (2013-04-03) -- "Masked Marvel"
Copyright (C) 2013 The R Foundation for Statistical Computing
Platform: x86_64-w64-mingw32/x64 (64-bit)

R -- это свободное ПО, и оно поставляется безо всяких гарантий.
Вы вольны распространять его при соблюдении некоторых условий.
Введите 'license()' для получения более подробной информации.

R -- это проект, в котором сотрудничает множество разработчиков.
Введите 'contributors()' для получения дополнительной информации и
'citation()' для ознакомления с правилами упоминания R и его пакетов
в публикациях.

Введите 'demo()' для запуска демонстрационных программ, 'help()' -- для
получения справки, 'help.start()' -- для доступа к справке через браузер.
Введите 'q()', чтобы выйти из R.

> args <- commandArgs(trailingOnly = T)
> print(args)
[1] "100"   "image"
> n <- as.integer(args[1])
> name <- args[2]
> 
> x <- rnorm(n)
> png(paste0(name, ".png"))
> plot(1:n, x)
> dev.off()
null device 
          1 
> summary(x)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
-2.3830 -0.5616  0.0813 -0.0322  0.5742  2.1000 
>
```

А во втором случае:

``` r
[1] "100"   "image"
null device 
          1 
    Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
-2.58000 -0.61260 -0.03309  0.05922  0.87230  1.72800 
```

Теперь вернёмся к параметру
`trailingOnly`
. Напишем ещё один скрипт (под названием
`printArgs.R`
) для иллюстрации его работы:

``` r
print(commandArgs(trailingOnly = F))
```

И вызовем его уже знакомыми нам инструментами (на этот раз вывод будет осуществляться на консоль):

```
Rterm.exe --no-restore --no-save --args 100 image <printArgs.R
Rscript.exe printArgs.R 100 image
```

Первая команда даст нам:

```
[1] "c:\\Program Files\\R\\R-3.0.0\\bin\\x64\\Rterm.exe"
[2] "--no-restore"                                      
[3] "--no-save"                                         
[4] "--args"                                            
[5] "100"                                               
[6] "image"  
```

Как можно видеть, помимо наших основных аргументов `100` и `image` в список также попали исполняемый файл `Rterm` и передаваемые в него аргументы. Ниже представлен вывод второй команды:

```
[1] "c:\\Program Files\\R\\R-3.0.0\\bin\\x64\\Rterm.exe"
[2] "--slave"                                           
[3] "--no-restore"                                      
[4] "--file=printArgs.R"                                
[5] "--args"                                            
[6] "100"                                               
[7] "image"                                             
```

Отсюда становится понятно, что `Rscript` только и делает-то, что запускает `Rterm` с параметрами `--slave` (отключает приглашение и вывод текста выполняемых команд),
`--no-restore` не нужно восстанавливать рабочее окружение), `--file` (указывает выполняемый файл) и `--args` (означает, что далее следуют настоящие аргументы для основного скрипта; если бы мы выставили `trailingOnly = T`, то получили бы только их).

Ниже представлена полная справка по использованию `Rterm` и `Rscript`:

```
>Rterm.exe --help
Usage: Rterm [options] [< infile] [> outfile] [EnvVars]

Start R, a system for statistical computation and graphics, with the
specified options

EnvVars: Environmental variables can be set by NAME=value strings

Options:
  -h, --help            Print usage message and exit
  --version             Print version info and exit
  --encoding=enc        Specify encoding to be used for stdin
  --encoding enc        ditto
  --save                Do save workspace at the end of the session
  --no-save             Don't save it
  --no-environ          Don't read the site and user environment files
  --no-site-file        Don't read the site-wide Rprofile
  --no-init-file        Don't read the .Rprofile or ~/.Rprofile files
  --restore             Do restore previously saved objects at startup
  --no-restore-data     Don't restore previously saved objects
  --no-restore-history  Don't restore the R history file
  --no-restore          Don't restore anything
  --vanilla             Combine --no-save, --no-restore, --no-site-file,
                          --no-init-file and --no-environ
  --max-mem-size=N      Set limit for memory to be used by R
  --max-ppsize=N        Set max size of protect stack to N
  -q, --quiet           Don't print startup message
  --silent              Same as --quiet
  --slave               Make R run as quietly as possible
  --verbose             Print more information about progress
  --internet2           Use Internet Explorer for proxies etc.
  --args                Skip the rest of the command line
  --ess                 Don't use getline for command-line editing
                          and assert interactive use
  -f file               Take input from 'file'
  --file=file           ditto
  -e expression         Use 'expression' as input

One or more -e options can be used, but not together with -f or --file

An argument ending in .RData (in any case) is taken as the path
to the workspace to be restored (and implies --restore)
```

```
>Rscript.exe -- help
Usage: /path/to/Rscript [--options] [-e expr] file [args]

--options accepted are
  --help              Print usage and exit
  --version           Print version and exit
  --verbose           Print information on progress
  --default-packages=list
                      Where 'list' is a comma-separated set
                        of package names, or 'NULL'
or options to R, in addition to --slave --no-restore, such as
  --save              Do save workspace at the end of the session
  --no-environ        Don't read the site and user environment files
  --no-site-file      Don't read the site-wide Rprofile
  --no-init-file      Don't read the user R profile
  --restore           Do restore previously saved objects at startup
  --vanilla           Combine --no-save, --no-restore, --no-site-file
                        --no-init-file and --no-environ

'file' may contain spaces but not shell metacharacters
```