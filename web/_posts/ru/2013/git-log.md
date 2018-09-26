---
layout: ru-post
title: "Просмотр истории коммитов в Git"
date: "2013-06-19T00:38:00.000+07:00"
lang: ru
type: post
tags:
- git
- VCS
redirect_from:
- /ru/blog/git/log/
- /ru/blog/post/git-log/
---

Изучение истории коммитов — важная составляющая работы с репозиторием. Увы, ввиду ветвления с этой историей не всегда просто разобраться. Обычно я для этой цели пользуюсь различными визуальными оболочками, но не всегда есть такая возможность. Временами приходится пользоваться средствами консоли, а именно командой
[git log](https://www.kernel.org/pub/software/scm/git/docs/git-log.html). Основы работы с этой командой можно почитать в чудесной книге
[ProGit](http://git-scm.com/book/ru/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%9F%D1%80%D0%BE%D1%81%D0%BC%D0%BE%D1%82%D1%80-%D0%B8%D1%81%D1%82%D0%BE%D1%80%D0%B8%D0%B8-%D0%BA%D0%BE%D0%BC%D0%BC%D0%B8%D1%82%D0%BE%D0%B2)
.
`git log`
имеет множество различных полезных параметров. Рассмотрим несколько примеров их использования.

### Древовидный вид

```
git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all
```

Выводим полный граф коммитов c сокращёнными хешами, ссылками на коммиты и относительной датой. Используемый формат: синий сокращённый хеш коммита, зелёная дата, белые сообщение и автор, жёлтые ссылки на коммит.

<p class="center">
  <img src="/img/posts/git/log/git-log1.png" />
</p>

<!--more-->

---

```
git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all
```

Выводим полный граф коммитов c сокращёнными хешами, ссылками на коммиты и абсолютной датой. Используемый формат: синий сокращённый хеш коммита, голубая абсолютная дата, зелёная относительная дата, жёлтые ссылки на коммит, перевод строки, белые сообщение и автор.

<p class="center">
  <img src="/img/posts/git/log/git-log2.png" />
</p>

---

```
git log --graph --oneline --all
```

Выводим полный граф коммитов, отводя по одной строке на коммит.

<p class="center">
  <img src="/img/posts/git/log/git-log3.png" />
</p>

---

```
git log --graph --date-order --pretty=format:"<%h> %ad [%an] %Cgreen%d%Creset %s" --all --date=short
```

Выводим полный граф коммитов c сортировкой по дате, отображаемой в краткой форме. Используемый формат: сокращённый хеш, дата, автор, зелёные ссылки на коммит, сообщение.

<p class="center">
  <img src="/img/posts/git/log/git-log4.png" />
</p>

---

### Линейный вид

```
git log
```

Вывод списка коммитов с параметрами по умолчанию.

<p class="center">
  <img src="/img/posts/git/log/git-log5.png" />
</p>

---

```
git log -p
```

Выводим список коммитов и показываем diff для каждого.

<p class="center">
  <img src="/img/posts/git/log/git-log6.png" />
</p>

---

```
git log --stat
```

Выводим список коммитов и показываем статистику по каждому.

<p class="center">
  <img src="/img/posts/git/log/git-log7.png" />
</p>

---

```
git log --pretty=oneline
```

Выводим список коммитов по одному на строчке.

<p class="center">
  <img src="/img/posts/git/log/git-log8.png" />
</p>

---

```
git log --pretty=format:"%h - %an, %ar : %s"
```

Выводим список коммитов с использованием следуюещго формата: сокращённый хеш коммита, автор, относительная дата, сообщение.

<p class="center">
  <img src="/img/posts/git/log/git-log9.png" />
</p>

---

### Визуальный интерфейс

Если есть возможность, то всё таки коммиты приятнее изучать через специализированный интерфейс, а не из консоли. Лично я очень люблю
[GitExtensions](https://code.google.com/p/gitextensions/):

<p class="center">
  <img src="/img/posts/git/log/git-log10.png" />
</p>

Также удобно использовать встроенную утилиту [gitk](https://www.kernel.org/pub/software/scm/git/docs/gitk.html):

<p class="center">
  <img src="/img/posts/git/log/git-log11.png" />
</p>

### Полезные параметры

Все параметры команды `git log` не нужны, но некоторые самые полезные хорошо бы помнить. Приведу несколько примеров использования ходовых параметров.

* `--graph` Показывать древовидную структуру графа истории в ASCII-виде
* `-5` Посмотреть последних пять коммитов
* `--skip=3` Пропустить три коммита
* `--pretty=oneline` Отводить по одной строчке на коммит
* `--since="today"` Показать коммиты за сегодня
* `--since=2.weeks` Показать коммиты за последние две недели
* `-p` Показывать diff каждого коммита
* `--decorate` Показывать ссылки на этот коммит
* `--stat` Показывать подробную статистику по каждому коммиту
* `--shortstat` Показывать краткую статистику по каждому коммиту
* `--name-only ` Показывать список изменённых файлов
* `--name-status ` Показывать список изменённых файлов с информацией о них
* `--abbrev-commit` Показывать только несколько первых цифр SHA-1
* `--relative-date` Показывать дату в относительной форме

C помощью замечательного параметра `--pretty=format:""` можно указать, какие именно данные о коммите нужно выводить, определив внутри кавычек общий паттерн, используя следующие обозначения:

* `%H` Хеш коммита
* `%h` Сокращённый хеш коммита
* `%d` Имена ссылок на коммит
* `%s` Сообщение к коммиту
* `%an` Автор
* `%ad` Дата автора
* `%cn` Коммитер
* `%cd` Дата коммитера
* `%Cred` Переключить цвет на красный
* `%Cgreen` Переключить цвет на зелёный
* `%Cblue` Переключить цвет на синий
* `%Creset` Сбросить цвет

Полный список обозначений можно найти в [мануале](https://www.kernel.org/pub/software/scm/git/docs/git-log.html) , в разделе «PRETTY FORMATS».

---

### Ссылки

* [Официальный мануал](https://www.kernel.org/pub/software/scm/git/docs/git-log.html)
* [ProGit](http://git-scm.com/book/ru/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%9F%D1%80%D0%BE%D1%81%D0%BC%D0%BE%D1%82%D1%80-%D0%B8%D1%81%D1%82%D0%BE%D1%80%D0%B8%D0%B8-%D0%BA%D0%BE%D0%BC%D0%BC%D0%B8%D1%82%D0%BE%D0%B2)
* [Советы со Stackoverflow](http://stackoverflow.com/questions/1057564/pretty-git-branch-graphs)
* [Репозиторий Twitter bootstrap](https://github.com/twitter/bootstrap)
