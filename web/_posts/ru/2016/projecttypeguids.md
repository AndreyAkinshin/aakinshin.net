---
layout: ru-post
title: "Visual Studio и ProjectTypeGuids.cs"
date: "2016-02-27"
lang: ru
type: post
tags:
- ".NET"
- C#
- VisualStudio
- Hate
redirect_from:
- /ru/blog/dotnet/projecttypeguids/
- /ru/blog/post/projecttypeguids/
---

Это история о том, как я несколько часов пытался открыть проект в Visual Studio. Как-то раз я решил немножко поработать: стянул себе последние коммиты из репозитория, открыл Visual Studio и собрался программировать. Увы, один из моих проектов не открылся, а в окошке Output я увидел странное сообщение:

```
error  : The operation could not be completed.
```

В Solution Explorer, рядом с названием проекта была надпись *"load failed"*, а вместо файлов было написано следующее: *"The project requires user input. Reload the project for more information."* Хмм, ну ок, я попробовал перегрузить проект. Увы, не помогло, я получил ещё два уже знакомых сообщения об ошибке:

```
error  : The operation could not be completed.
error  : The operation could not be completed.
```
<!--more-->

Не буду утомлять вас подробными рассказами о том, как я пытался понять происходящее. В числе прочего были сделаны следующие вещи:

* `del /s *.suo *.user`
* `git clean -xfd`
* `shutdown -r`

Увы, ничего не помогло. Тогда я стал искать коммит, после которого всё сломалось. Слава `git bisect`, вскоре коммит был найден. Но вот только он не содержал ничего подозрительного. В коммите был добавлен непримечательный файл под названием `ProjectTypeGuids.cs` и соответствующая строчка в `.csproj`-файле:

```xml
<Compile Include="ProjectTypeGuids.cs" />
```

Что может быть не так с подобным коммитом? Дальнейшее расследование выявило следюущий не особо очевидный факт: Visual Studio не может открыть проект, который содержит файл `ProjectTypeGuids.cs`. Я сейчас абсолютно серьёзно. Попробуйте сами, воспроизвести проблему очень легко:

1. Открываем Visual Studio (2013 или 2015).
2. Создаём новое консольное приложение или библиотеку.
3. Добавляем новый файл: `ProjectTypeGuids.cs`.
4. Сохраняем всё.
5. Закрываем всё.
6. Пытаемся снова открыть проект.

На connect.microsoft.com есть соответствующий баг: [Visual Studio Project Load bug](http://connect.microsoft.com/VisualStudio/feedbackdetail/view/763638/visual-studio-project-load-bug)

> There is a bug in Visual studio console project loader module.
> Usually the project file for most applications (e.g. silverlight) has certain XML attributes like "ProjectTypeGuids" and "OutputType" among several others. Some don't have them e.g. console.
> If i create a console project and add a file which is named similar (case sensitive) to one of the attributes (e.g. Add ProjectTypeGuids.cs to the console project), Unload it and then try to reload it; the project fails to load.
> "The project type is not supported by this installation" is the error that is thrown.
> If the case of file name is altered manually in csproj file, the correct file does get picked up and the project reloads succesfully.

Увы, статус бага "Closed as Won't Fix", так что исправлять его никто не будет, придётся с этим жить. В своём проекте я просто переименовал файл, теперь всё работает нормально.

Кстати говоря, а вот [Rider](https://blog.jetbrains.com/dotnet/2016/01/13/project-rider-a-csharp-ide/) открывает такие проекты вообще без проблем. =)

### См. также

* [Happy Monday!](/en/blog/dotnet/happy-monday/)