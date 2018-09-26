---
layout: ru-post
title: "Функции в R"
date: "2013-06-03"
lang: ru
type: post
tags:
- R
- R-functions
redirect_from:
- /ru/blog/r/functions/
- /ru/blog/post/r-functions/
---

В R очень много разных полезных функций. И многие большие вещи можно сделать весьма быстро, написав очень мало кода. На официальном сайте есть замечательная шпаргалка на английском языке: [R reference card](http://cran.r-project.org/doc/contrib/Short-refcard.pdf). В сети есть несколько вольных урезанных переводов, но они не очень удобные. Ниже вашему вниманию представляется русифицированная модифицированная версия обзора основных функций R. Команды снабжены ссылками на [online-мануал](http://stat.ethz.ch/R-manual/).

<!--more-->

### Оглавление

* [Помощь](#section-help)
* [Текущее окружение](#section-environment)
* [Общая работа с объектами](#section-objects-common)
* [Ввод и вывод](#section-io)
* [Создание объектов](#section-objects-creation)
* [Индексирование](#section-indexers)
* [Работа с переменными](#section-variables)
* [Манипуляция данными](#section-data-manipulation)
* [Математика](#section-math)
* [Матрицы](#section-math)
* [Обработка данных](#section-data-processing)
* [Строки](#section-strings)
* [Дата и время](#section-date)
* [Рисование графиков](#section-plots)
* [Рисование графиков на низком уровне](#section-plots-lowlevel)
* [Lattice-графика](#section-plots-lattice)
* [Оптимизация и подбор параметров](#section-optimization)
* [Статистика](#section-statistic)
* [Распределения](#section-distributions)
* [Программирование](#section-programming)

<h3 id="section-help">Помощь</h3>

* [help(topic)](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/help.html), `?topic` — справка про `topic`
* [help.search("pattern")](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/help.search.html), `??pattern` — глобальный поиск `pattern`
* [help(package = )](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/help.html) — справка о заданном пакете
* [help.start()](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/help.start.html) — запустить помощь в браузере
* [apropos(what)](http://stat.ethz.ch/R-manual/R-devel/library/utils/html/apropos.html) — имена объектов, которые соответствуют `what`
* [args(name)](http://stat.ethz.ch/R-manual/R-devel/library/base/html/args.html) — аргументы команды `name`
* [example(topic)](http://stat.ethz.ch/R-manual/R-devel/library/utils/html/example.html) — примеры использования `topic`

<h3 id="section-environment">Текущее окружение</h3>

* [ls()](http://stat.ethz.ch/R-manual/R-devel/library/base/html/ls.html) — список всех объектов
* [rm(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/rm.html) — удалить объект
* [dir()](http://stat.ethz.ch/R-manual/R-patched/library/base/html/list.files.html) — показать все файлы в текущей директории
* [getwd()](http://stat.ethz.ch/R-manual/R-patched/library/base/html/getwd.html) — получить текущую директорию
* [setwd(dir)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/getwd.html) — поменять текущую директорию на `dir`

<h3 id="section-objects-common">Общая работа с объектами</h3>

* [str(object)](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/str.html) — внутренняя структура объекта `object`
* [summary(object)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/summary.html) — общая информация об объекте `object`
* [dput(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/dput.html) — получить представление объекта в R-синтаксисе
* [head(x)](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/head.html) — посмотреть начальные строки объекта
* [tail(x)](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/head.html) — посмотреть последние строки объекта

<h3 id="section-io">Ввод и вывод</h3>

* [library(package)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/library.html) — подключить пакет `package`
* [save(file, ...)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/save.html) — сохраняет указанные объекты в двочином XDR-формате, который не зависит от платформы
* [load()](http://stat.ethz.ch/R-manual/R-patched/library/base/html/load.html) — загружает данные, сохранённые ранее с помощью команды `save()`
* [read.table](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/read.table.html) — считывает таблицу данных и создаёт по ним `data.frame`
* [write.table](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/write.table.html) — печатает объект, конвертируя его в `data.frame`
* [read.csv](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/read.table.html) — считывает `csv`-файл
* [read.delim](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/read.table.html) — считывание данных, разделённых знаками табуляции
* [save.image](http://stat.ethz.ch/R-manual/R-patched/library/base/html/save.html) — сохраняет все объекты в файл
* [cat(..., file= , sep= )](http://stat.ethz.ch/R-manual/R-patched/library/base/html/cat.html) — сохраняет аргументы, конкатенируя их через `sep`
* [sink(file)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/sink.html) — выводит результаты выполнения других команд в файл в режиме реального времени до момента вызова этой же команды без аргументов

<h3 id="section-objects-creation">Создание объектов</h3>

* `from:to` — генерирует последовательность чисел от `from` до `to` с шагом `1`, например `1:3`
* [с(...)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/c.html) — объединяет аргументы в вектор, например `c(1, 2, 3)`
* [seq(from, to, by = )](http://stat.ethz.ch/R-manual/R-patched/library/base/html/seq.html) — генерирует последовательность числел от `from` до `to` с шагом `by`
* [seq(from, to, len = )](http://stat.ethz.ch/R-manual/R-patched/library/base/html/seq.html) — генерирует последовательность числел от `from` до `to` длины `len`
* [rep(x, times)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/rep.html) — повторяет `x` ровно `times` раз
* [list(...)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/list.html) — создаёт список объектов
* [data.frame(...)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/data.frame.html) — создаёт фрейм данных
* [array(data, dims)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/array.html) — создаёт из `data` многомерные массив размерностей `dim`
* [matrix(data, nrow = , ncol = , byrow = )](http://stat.ethz.ch/R-manual/R-patched/library/base/html/matrix.html) — создаёт из `data` матрицу `nrow` на `ncol`, порядок заполнения определяется `byrow`
* [factor(x, levels = )](http://stat.ethz.ch/R-manual/R-patched/library/base/html/factor.html) — создаёт из `x` фактор с уровнями `levels`
* [gl(n, k, length = n*k, labels = 1:n)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/gl.html) — создаёт фактор из `n` уровней, каждый из которых повторяется `k` раз длины
`length` с именами `labels`
* [rbind(...)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/cbind.html) — объединяет аргументы по строкам
* [cbind(...)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/cbind.html) — объединяет аргументы по столбцам

<h3 id="section-indexers">Индексирование</h3>

#### Векторы

<table>
	<tr>
		<td width="40%"><code>x[n]</code></td>
		<td><code>n</code>-ый элемент</td>
	</tr>
	<tr>
		<td><code>x[-n]</code></td>
		<td>все элементы, кроме <code>n</code>-го</td>
	</tr>
	<tr>
		<td><code>x[1:n]</code></td>
		<td>первые <code>n</code> элементов</td>
	</tr>
	<tr>
		<td><code>x[-(1:n)]</code></td>
		<td>все элементы, кроме первых <code>n</code></td>
	</tr>
	<tr>
		<td><code>x[c(1,4,2)]</code></td>
		<td>элементы с заданными индексами</td>
	</tr>
	<tr>
		<td><code>x["name"]</code></td>
		<td>элемент с заданным именем</td>
	</tr>
	<tr>
		<td><code>x[x > 3]</code></td>
		<td>все элементы, большие 3</td>
	</tr>
	<tr>
		<td>
			<code>x[x > 3 & x < 5]</code>
		</td>
		<td>все элементы между 3 и 5</td>
	</tr>
	<tr>
		<td><code>x[x %in% c("a","and","the")]</code></td>
		<td>все элементы из заданного множества</td>
	</tr>
</table>

#### Списки

<table>
	<tr>
		<td width="40%"><code>x[n]</code></td>
		<td>список, состоящий из элемента <code>n</code></td>
	</tr>
	<tr>
		<td><code>x[[n]]</code></td>
		<td><code>n</code>-ый элемент списка</td>
	</tr>
	<tr>
		<td><code>x[["name"]]</code></td>
		<td>элемент списка с именем <code>name</code></td>
	</tr>
	<tr>
		<td><code>x$name</code></td>
		<td>элемент списка с именем <code>name</code></td>
	</tr>
</table>

#### Матрицы

<table>
	<tr>
		<td width="40%"><code>x[i, j]</code></td>
		<td>элемент на пересечении <code>i</code>-ой строки и <code>j</code>-го столбца</td>
	</tr>
	<tr>
		<td><code>x[i,]</code></td>
		<td><code>i</code>-ая строка</td>
	</tr>
	<tr>
		<td><code>x[,j]</code></td>
		<td><code>j</code>-ый столбец</td>
	</tr>
	<tr>
		<td><code>x[,c(1,3)]</code></td>
		<td>заданное подмножество столбцов</td>
	</tr>
	<tr>
		<td><code>x["name", ]</code></td>
		<td>строка с именем <code>name</code></td>
	</tr>
</table>

#### Фреймы

<table>
	<tr>
		<td width="40%"><code>x[["name"]]</code></td>
		<td>столбец с именем <code>name</code></td>
	</tr>
	<tr>
		<td><code>x$name</code></td>
		<td>столбец с именем <code>name</code></td>
	</tr>
</table>

<h3 id="section-variables">Работа с переменными</h3>

* [as.array(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/array.html), [as.data.frame(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/as.data.frame.html), [as.numeric(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/numeric.html), [as.logical(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/logical.html), [as.complex(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/complex.html), [as.character(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/character.html) — преобразование переменной к заданному типу [is.na(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/NA.html), [is.null(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/NULL.html),
[is.array(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/array.html), [is.data.frame(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/array.html), [is.numeric(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/numeric.html), [is.complex(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/complex.html), [is.character(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/character.html) — проверка на то, что данный объект обладает указанным типом
* [length(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/length.html) — число элементов в `x`
* [dim(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/dim.html) — размерности объекта `x`
* [dimnames(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/dimnames.html) — имена размерностей объекта `x`
* [names(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/names.html) — имена объекта `x`
* [nrow(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/nrow.html) — число строк `x`
* [ncol(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/nrow.html) — число столбцов `x`
* [class(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/class.html) — класс объекта `x`
* [unclass(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/class.html) — удаляет атрибут класса у объекта `x`
* [attr(x,which)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/attr.html) — атрибут `which` объекта `x`
* [attributes(obj)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/attributes.html) — список атрибутов объекта `obj`

<h3 id="section-data-manipulation">Манипуляция данными</h3>

* [which.max(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/which.min.html) — индекс элемента с максимальным значением
* [which.min(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/which.min.html) — индекс элемента с минимальным значением
* [rev(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/rev.html) — реверсирует порядок элементов
* [sort(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/sort.html) — сортирует элементы объекта по возрастанию
* [cut(x,breaks)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/cut.html) — делит вектор на равные интервалы
* [match(x, y)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/match.html) — ищет элементы `x`, которые есть в `y`
* [which(x == a)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/which.html) — возвращает порядковые элементы `x`, которые равны `a`
* [na.omit(x)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/na.fail.html) — исключает отсутствующие значения объекта
* [na.fail(x)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/na.fail.html) — бросает исключение, если объект содержит отсутствующие значения
* [unique(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/unique.html) — исключает из объекта повторяющиеся элементы
* [table(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/unique.html) — создаёт таблицу с количеством повторений каждого уникального элемента
* [subset(x, ...)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/subset.html) — возвращает подмножество элемента, которое соответствует заданному условию
* [sample(x, size)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/sample.html) — возвращает случайный набор размера `size` из элементов `x`
* [replace(x, list, values)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/replace.html) — заменяет значения `x` c индексами из `list` значениями из `values`
* [append(x, values)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/append.html) — добавляет элементы `values` в вектор `x`

<h3 id="section-math">Математика</h3>

* [sin(x), cos(x), tan(x), asin(x), acos(x), atan(x), atan2(y, x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/Trig.html), [log(x), log(x, base), log10(x), exp(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/Log.html) — элементарные математические функции
* [min(x), max(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/Extremes.html) — минимальный и максимальный элементы объекта
* [range(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/range.html) — вектор из минимального и максимального элемента объекта
* [pmin(x, y), pmax(x, y)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/Extremes.html) — возвращают вектор с минимальными (максимальными) для каждой пары `x[i]`, `y[i]`
* [sum(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/sum.html) — сумма элементов объекта
* [prod(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/prod.html) — произведение элементов объекта
* [diff(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/diff.html) — возвращает вектор из разниц между соседними элементами
* [mean(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/mean.html) — среднее арифметическое элементов объекта
* [median(x)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/median.html) — медиана (средний элемент) объекта
* [weighted.mean(x, w)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/weighted.mean.html) — средневзвешенное объекта `x` (`w` определяет веса)
* [round(x, n)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/Round.html) — округляет `x` до `n` знаков после запятой
* [cumsum(x), cumprod(x), cummin(x), cummax(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/cumsum.html) — кумулятивные суммы, произведения, минимумы и максимумы вектора `x` (i-ый элемент содержит статистику по элементам `x[1:i]`)
* [union(x, y), intersect(x, y), setdiff(x,y), setequal(x,y), is.element(el,set)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/sets.html) — операции над множествами: объединение, пересечение, разность, сравнение, принадлежность
* [Re(x), Im(x), Mod(x), Arg(x), Conj(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/complex.html) — операции над комплексными числами: целая часть, мнимая часть, модуль, аргумент, сопряжённое число
* [fft(x), mvfft(x)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/fft.html) — быстрое преобразование Фурье
* [choose(n, k)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/which.html) — количество сочетаний
* [rank(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/rank.html) — ранжирует элементы объекта

<h3 id="section-math">Матрицы</h3>

* `%*%` — матричное умножение
* [t(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/t.html) — транспонированная матрица
* [diag(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/diag.html) — диагональ матрицы
* [solve(a, b)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/solve.html) — решает систему уравнений `a %*% x = b`
* [solve(a)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/solve.html) — обратная матрица
* [colSums, rowSums, colMeans, rowMeans](http://stat.ethz.ch/R-manual/R-patched/library/base/html/colSums.html) — суммы и средние по столбцам и по строкам

<h3 id="section-data-processing">Обработка данных</h3>

* [apply(X,INDEX,FUN=)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/apply.html) — возвращает вектор, массив или список значений, полученных путем применения функции `FUN` к определенным элементам массива или матрицы `x`; подлежащие обработке элементы `х` указываются при помощи аргумента `MARGIN`;
* [lapply(X,FUN)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/lapply.html) — возвращает список той же длины, что и `х`; при этом значения в новом списке будут результатом применения функции `FUN` к элементам исходного объекта `х`
* [tapply(X,INDEX,FUN=)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/tapply.html) —  применяет функцию `FUN` к каждой совокупности значений х, созданной в соответствии с уровнями определенного фактора; перечень факторов указывается при помощи аргумента `INDEX`
* [by(data,INDEX,FUN)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/by.html) — аналог `tapply()`, применяемый к таблицам данных
* [merge(a,b)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/merge.html) — объединяет две таблицы данных (`а` и `b`) по общим столбцами или строкам
* [aggregate(x,by,FUN)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/aggregate.html) — разбивает таблицу данных `х` на отдельные наборы данных, применяет к этим наборам определенную функцию `FUN` и возвращает результат в удобном для чтения формате
* [stack(x, ...)](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/stack.html) — преобразует данные, представленные в объекте `х` в виде отдельных столбцов, в таблицу данных
* [unstack(x, ...)](http://stat.ethz.ch/R-manual/R-patched/library/utils/html/stack.html) —  выполняет операцию, обратную действию функции `stack()`
* [reshape(x, ...)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/reshape.html) — преобразует таблицу данных из «широкого формата» (повторные измерения какой-либо величины записаны в отдельных столбцах таблицы) в таблицу "узкого формата" (повторные измерения идут одно под одним в пределах одного столбца)

<h3 id="section-strings">Строки</h3>

* [print(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/print.html) — выводит на экран `x`
* [sprintf(fmt, ...)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/sprintf.html) — форматирование текста в `C-style` (можно использовать `%s, %.5f` и т.п.)
* [format(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/format.html) — форматирует объект `x` так, чтобы он выглядел красиво при выводе на экран
* [paste(...)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/paste.html) — конвертирует векторы в текстовые переменные и объединяет их в одно текстовое выражение
* [substr(x,start,stop)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/substr.html) — получение подстроки
* [strsplit(x,split)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/strsplit.html) — разбивает строку `х` на подстроки в соответствии с `split`
* [grep(pattern,x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/grep.html) (а также `grepl`, `regexpr`, `gregexpr`, `regexec`) — поиск по регулярному выражению
* [gsub(pattern,replacement,x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/grep.html) (а также `sub`) — замена по регулярному выражению
* [tolower(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/chartr.html) — привести строку к нижнему регистру
* [toupper(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/chartr.html) — привести строку к верхнему регистру
* [match(x,table)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/match.html), `x %in% table` — выполняет поиск элементов в векторе `table`, которые совпадают со значениями из вектора `х`
* [pmatch(x,table)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/pmatch.html) — выполняет поиск элементов в векторе `table`, которые частично совпадают с элементами вектора х
* [nchar(x)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/nchar.html) — возвращает количество знаков в строке `х`

<h3 id="section-date">Дата и время</h3>

* [as.Date(s)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/as.Date.html) — конвертирует вектор `s` в объект класса `Date`
* [as.POSIXct(s)](http://stat.ethz.ch/R-manual/R-patched/library/base/html/as.POSIXlt.html) — конвертирует вектор `s` в объект класса POSIXct

<h3 id="section-plots">Рисование графиков</h3>

* [plot(x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/plot.html) — график `x`
* [plot(x, y)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/plot.html) — график зависимости `y` от `x`
* [hist(x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/hist.html) — гистограмма
* [barplot(x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/barplot.html) — столбчатая диаграмма
* [dotchart(x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/dotchart.html) — диаграмма Кливленда
* [pie(x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/pie.html) — круговая диаграмма
* [boxplot(x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/boxplot.html) — график типа "коробочки с усами"
* [sunflowerplot(x, y)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/sunflowerplot.html) — то же, что и `plot()`, однако точки с одинаковыми координатами изображаются в виде "ромашек", количество лепестков у которых пропорционально количеству таких точек
* [coplot(x˜y | z)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/coplot.html) — график зависимости y от x для каждого интервала значений `z`
* [interaction.plot(f1, f2, y)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/interaction.plot.html) — если `f1` и `f2` — факторы, эта фукнция создаст график со средними значениями `y` в соответствии со значениями `f1` (по оси `х`) и `f2` (по оси `у`, разные кривые)
* [matplot(x, y)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/matplot.html) — график зависимости столбцов y от столбцов `x`
* [fourfoldplot(x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/fourfoldplot.html) — изображает (в виде частей окружности) связь между двумя бинарными переменными в разных совокупностях
* [assocplot(x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/assocplot.html) — график Кохена-Френдли
* [mosaicplot(x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/mosaicplot.html) — мозаичный график остатков лог-линейной регрессии
* [pairs(x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/pairs.html) —  если х - матрица или таблица данных, эта функция изобразит диаграммы рассеяния для всех возможных пар переменных из `х`
* [plot.ts(x)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/plot.ts.html), [ts.plot(x)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/ts.plot.html) — изображает временной ряд
* [qqnorm(x)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/qqnorm.html) — квантили
* [qqplot(x, y)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/qqnorm.html) — график зависимости квантилей y от квантилей `х`
* [contour(x, y, z)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/contour.html) — выполняет интерполяцию данных и создает контурный график
* [filled.contour(x, y, z)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/filled.contour.html) —  то же, что `contour()`, но заполняет области между контурами определёнными цветами
* [image(x, y, z)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/image.html) — изображает исходные данные в виде квадратов, цвет которых определяется значениями `х` и `у`
* [persp(x, y, z)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/persp.html) — то же, что и `image()`, но в виде трехмерного графика
* [stars(x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/stars.html) — если `x` — матрица или таблица данных, изображает график в виде "звезд" так, что каждая строка представлена "звездой", а столбцы задают длину сегментов этих "звезд"
* [symbols(x, y, ...)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/symbols.html) —  изображает различные символы в соответствии с координатами
* [termplot(mod.obj)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/termplot.html) — зображает частные эффекты переменных из регрессионной модели

<h3 id="section-plots-lowlevel">Рисование графиков на низком уровне</h3>

* [points(x, y)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/points.html) — рисование точек
* [lines(x, y)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/lines.html) — рисование линии
* [text(x, y, labels, ...)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/text.html) — добавление текстовой надписи
* [mtext(text, side=3, line=0, ...)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/mtext.html) — добавление текстовой надписи
* [segments(x0, y0, x1, y1)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/segments.html) — рисование отрезка
* [arrows(x0, y0, x1, y1, angle= 30, code=2)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/arrows.html) — рисование стрелочки
* [abline(a,b)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/abline.html) — рисование наклонной прямой
* [abline(h=y)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/abline.html) — рисование вертикальной прямой
* [abline(v=x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/abline.html) — рисование горизонтальной прямой
* [abline(lm.obj)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/abline.html) — рисование регрессионной прямой
* [rect(x1, y1, x2, y2)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/rect.html) — рисование прямоугольника
* [polygon(x, y)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/polygon.html) — рисование многоугольника
* [legend(x, y, legend)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/legend.html) — добавление легенды
* [title()](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/title.html) — добавление заголовка
* [axis(side, vect)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/axis.html) — добавление осей
* [rug(x)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/rug.html) — рисование засечек на оси `X`
* [locator(n, type = "n", ...)](http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/locator.html) — возвращает координаты на графике, в которые кликнул пользователь

<h3 id="section-plots-lattice">Lattice-графика</h3>

* [xyplot(y˜x)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/xyplot.html) — график зависимости `у` от `х`
* [barchart(y˜x)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/xyplot.html) — столбчатая диаграмма
* [dotplot(y˜x)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/xyplot.html) — диаграмма Кливленда
* [densityplot(˜x)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/histogram.html) — график плотности распределения значений `х`
* [histogram(˜x)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/histogram.html) — гистограмма значений `х`
* [bwplot(y˜x)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/xyplot.html) — график типа "коробочки с усами"
* [qqmath(˜x)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/qqmath.html) — аналог функции `qqnorm()`
* [stripplot(y˜x)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/xyplot.html) — аналог функции `stripplot(x)`
* [qq(y˜x)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/qq.html) — изображает квантили распределений `х` и `у` для визуального сравнения этих распределений; переменная `х` должна быть числовой, переменная `у` - числовой, текстовой, или фактором с двумя уровнями
* [splom(˜x)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/splom.html) — матрица диаграмм рассеяния (аналог функции `pairs()`)
* [levelplot(z˜x*y|g1*g2)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/levelplot.html) —  цветной график значений `z`, координаты которых заданы переменными `х` и `у` (очевидно, что `x`, `y` и `z` должны иметь одинаковую длину); `g1`, `g2`... (если присутствуют) —  факторы или числовые переменные, чьи значения автоматически разбиваются на равномерные отрезки
* [wireframe(z˜x*y|g1*g2)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/cloud.html) — функция для построения трехмерных диаграмм рассеяния и плоскостей; `z`, `x` и `у` - числовые векторы; `g1`, `g2`... (если присутствуют) - факторы или числовые переменные, чьи значения автоматически разбиваются на равномерные отрезки
* [cloud(z˜x*y|g1*g2)](http://stat.ethz.ch/R-manual/R-patched/library/lattice/html/cloud.html) — трёхмерная диаграмма рассеяния

<h3 id="section-optimization">Оптимизация и подбор параметров</h3>

* [optim(par, fn, method = )](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/optim.html) — оптимизация общего назначения
* [nlm(f,p)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/nlm.html) — минимизация функции `f` алгоритмом Ньютона
* [lm(formula)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/lm.html) — подгонка линейной модели
* [glm(formula,family=)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/glm.html) — подгонка обобщённой линейной модели
* [nls(formula)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/nls.html) — нелинейный метод наименьших квадратов
* [approx(x,y=)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/approxfun.html) — линейная интерполяция
* [spline(x,y=)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/splinefun.html) — интерполяция кубическими сплайнами
* [loess(formula)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/loess.html) — подгонка полиномиальной поверхности
* [predict(fit,...)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/predict.html) — построение прогнозов
* [coef(fit)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/coef.html) — расчётные коэффициенты

<h3 id="section-statistic">Статистика</h3>

* [sd(x)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/sd.html) — стандартное отклонение
* [var(x)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/cor.html) — дисперсия
* [cor(x)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/cor.html) — корреляционная матрица
* [var(x, y)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/cor.html) — ковариация между `x` и `y`
* [cor(x, y)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/cor.html) — линейная корреляция между `x` и `y`
* [aov(formula)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/aov.html) — дисперсионный анализ
* [anova(fit,...)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/anova.html) — дисперсионный анализ для подогнанных моделей `fit`
* [density(x)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/density.html) — ядерные плотности вероятностей
* [binom.test()](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/binom.test.html) — точный тест простой гипотезы о вероятности успеха в испытаниях Бернулли
* [pairwise.t.test()](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/pairwise.t.test.html) — попарные сравнения нескольки независимых или зависимых выборок
* [prop.test()](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/prop.test.html) —  проверка гипотезы о том, что частоты какого-либо признака равны во всех анализируемых группах
* [t.test()](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/t.test.html) — тест Стьюдента

<h3 id="section-distributions">Распределения</h3>

* [rnorm(n, mean=0, sd=1)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Normal.html) — нормальное распределение
* [rexp(n, rate=1)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Exponential.html) — экспоненциальное распределение
* [rgamma(n, shape, scale=1)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/GammaDist.html) — гамма-распределение
* [rpois(n, lambda)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Poisson.html) — распределение Пуассона
* [rweibull(n, shape, scale=1)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Weibull.html) — распределение Вейбулла
* [rcauchy(n, location=0, scale=1)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Cauchy.html) — распределение Коши
* [rbeta(n, shape1, shape2)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Beta.html) — бета-распределение
* [rt(n, df)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/TDist.html) — распределение Стьюдента
* [rf(n, df1, df2)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Fdist.html) — распределение Фишера
* [rchisq(n, df)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Chisquare.html) — распределение Пирсона
* [rbinom(n, size, prob)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Binomial.html) — биномиальное распределение
* [rgeom(n, prob)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Geometric.html) — геометрическое распределение
* [rhyper(nn, m, n, k)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Hypergeometric.html) — гипергеометрическое распределение
* [rlogis(n, location=0, scale=1)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Logistic.html) — логистическое распределение
* [rlnorm(n, meanlog=0, sdlog=1)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Lognormal.html) — логнормальное распределение
* [rnbinom(n, size, prob)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/NegBinomial.html) — отрицательное биномиальное распределение
* [runif(n, min=0, max=1)](http://stat.ethz.ch/R-manual/R-patched/library/stats/html/Uniform.html) — равномерное распределение

<h3 id="section-programming">Программирование</h3>

Работа с функциями:

* `function(arglist) { expr }` — создание пользовательской функции
* `return(value)` — возвращение значения
* `do.call(funname, args)` — вызывает функцию по имени

Условные операторы:

* `if(cond) expr`
* `if(cond) cons.expr else alt.expr`
* `ifelse(test, yes, no)`

Циклы:

* `for(var in seq) expr`
* `while(cond) expr`
* `repeat expr`
* `break` — остановка цикла
