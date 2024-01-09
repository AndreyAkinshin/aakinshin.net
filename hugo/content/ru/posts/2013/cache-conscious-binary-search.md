---
title: Cache-Conscious Binary Search
date: "2013-11-20"
tags:
- Algorithms
- CacheConscious
- BinarySearch
- dotnet
- Cache
- cs
aliases:
- /ru/blog/dotnet/cache-conscious-binary-search/
- /ru/blog/post/cache-conscious-binary-search/
---

<p>
	Рассмотрим простую задачу: есть некоторый достаточно большой неизменный набор чисел, к нему осуществляется множество запросов на наличие некоторого числа в этом наборе, необходимо максимально быстро эти запросы обрабатывать. Одно из классических решений заключается в формировании отсортированного массива и обработке запросов через бинарный поиск. Но можно ли добиться более высокой производительности, чем в классической реализации? В этой статье мне хотелось бы рассказать про Cache-Conscious Binary Search. В данном алгоритме предлагается переупорядочить элементы массива таким образом, чтобы использование кэша процессора происходило максимально эффективно.
</p>
<!--more-->
<p> <b>Дисклеймер:</b>
	я не пытаюсь создать самое эффективное решение данной задачи. Мне хотелось бы просто обсудить подход к построению структур данных на основе учёта особенностей работы с кэшом процессора, т.к. многие при решении оптимизационных задач в принципе не задумываются о процессорной архитектуре. Я также не собираюсь писать идеальную реализацию Cache-Conscious Binary Search, мне хотелось бы посмотреть эффект от подобного подхода на достаточно простом примере (также в целях упрощения кода количество вершин берётся равным N=2^K-1). В качестве языка программирования я буду использовать C# (общее быстродействие для нас не принципиально, т.к. основной акцент делается не на создании самой быстрой программы в мире, а на относительном сравнении различных подходов к решению задачи). Стоит также отметить, что алгоритм эффективен только на больших массивах, поэтому не следует использовать данный подход во всех задачах, сперва нужно убедиться в его целесообразности. Предполагается, что у читателя имеются базовые представления о том, что такое кэш процессора, и как он работает.
</p>
<p>
	Рассмотрим классическую реализацию бинарного поиска: пусть у нас имеется отсортированный массив
	<code>a</code>
	и некоторый элемент
	<code>x</code>
	, который мы будем в нём искать:
</p>

```cs
public bool Contains(int x)
{
    int l = 0, r = N - 1;
    while (l <= r)
    {
        int m = (l + r) / 2;
        if (a[m] == x)
            return true;
        if (a[m] > x)
            r = m - 1;
        else
            l = m + 1;
    }
    return false;
}
```

<p>
	В данной реализации на первых итерациях алгоритма запросы будут осуществляться к элементам массива, которые находятся далеко друг от друга. Изобразим дерево поиска для массива из 15-и элементов:
</p>
<div class="separator" style="clear: both; text-align: center;">
	<a href="http://3.bp.blogspot.com/-lS77713GjIQ/Uoygymx31cI/AAAAAAAAAOw/o37c1lotLHo/s1600/img1.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;">
		<img border="0" src="http://3.bp.blogspot.com/-lS77713GjIQ/Uoygymx31cI/AAAAAAAAAOw/o37c1lotLHo/s640/img1.png" />
	</a>
</div>
<p>
	Из рисунка видно, что при проходе по такому дереву сперва будет обращение к 7-му элементу, а затем (в случае
	<code>a[7]!=x</code>
	) к 3-ему или 11-ому. На таком маленьком массиве это не критично, но в большом массиве эти обращения будут соответствовать разным строчкам кэша процессора, что негативно скажется на производительности. Давайте попробуем переупорядочить элементы так, чтобы последовательные обращения к массиву приходились на близкие участки памяти. В первом приближении можно попробовать расположить друг за другом каждый уровень дерева с помощью простого поиска в ширину. На нашем тестовом дереве получим следующий результат:
</p>
<div class="separator" style="clear: both; text-align: center;">
	<a href="http://4.bp.blogspot.com/-7v_UqTv09FM/UoyhCIEiIII/AAAAAAAAAO0/EJmozES7E2w/s1600/img2.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;">
		<img border="0" src="http://4.bp.blogspot.com/-7v_UqTv09FM/UoyhCIEiIII/AAAAAAAAAO0/EJmozES7E2w/s640/img2.png" />
	</a>
</div>
<p>
	Теперь элементы массива, к которым мы будем обращаться на первых итерациях, находятся недалеко друг от друга. Но с ростом номера итерации мы всё равно получим большое количество cache miss-ов. Чтобы исправить данную ситуацию, разобьём наше «большое» дерево бинарного поиска на небольшие поддеревья. Каждое такое поддерево будет соответствовать нескольким уровням оригинального дерева, а элементы поддерева будут находится недалеко друг от друга. Таким образом, cache miss будут образовываться в основном при переходе к очередному поддереву. Высоту поддерева можно варьировать, подбирая её в соответствии с процессорной архитектурой. Проиллюстрируем данные построения на нашем примере, взяв высоту поддерева равным 2:
</p>
<div class="separator" style="clear: both; text-align: center;">
	<a href="http://4.bp.blogspot.com/-w7UB4jgCGEQ/UoyhFYPW4YI/AAAAAAAAAO8/BUDzRYVmjCY/s1600/img3.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;">
		<img border="0" src="http://4.bp.blogspot.com/-w7UB4jgCGEQ/UoyhFYPW4YI/AAAAAAAAAO8/BUDzRYVmjCY/s640/img3.png" />
	</a>
</div>
<p>
	А теперь перейдём к практическим исследованиям. Для чистоты эксперимента и получения точных результатов будем замерять время с помощью проекта
	<a href="https://github.com/AndreyAkinshin/BenchmarkDotNet">BenchmarkDotNet</a>
	. Рассмотрим самую тривиальную реализацию рассмотренного алгоритма без каких-либо дополнительных оптимизаций (исходный код
	<a href="https://github.com/AndreyAkinshin/BenchmarkDotNet/blob/master/Benchmarks/CacheConsciousBinarySearchCompetition.cs">приведён</a>
	на GitHub). Сравнивать будем классическую реализацию и cache-conscious-реализации с разными высотами поддеревьев (CacheConsciousSearchK соответствует поддереву с высотой K). Высоту дерева возьмём равной 24. На моей машине (Intel Core i7-3632QM CPU 2.20GHz) получились следующие результаты (алгоритм очень чувствителен к процессорной архитектуре, поэтому у вас могут получиться совсем другие временные оценки):
</p>

```txt
// Microsoft.NET 4.5 x64
SimpleSearch          : 6725ms
CacheConsciousSearch1 : 4428ms
CacheConsciousSearch2 : 3963ms
CacheConsciousSearch3 : 3778ms
CacheConsciousSearch4 : 3774ms
CacheConsciousSearch5 : 3762ms
```

Исходный код бенчмарка:

```cs
public class CacheConsciousBinarySearchCompetition : BenchmarkCompetition
{
    private const int K = 24, N = (1 << K) - 1, IterationCount = 10000000;
    private readonly Random random = new Random();

    private Tree originalTree;
    private int[] bfs;

    protected override void Prepare()
    {
        originalTree = new Tree(Enumerable.Range(0, N).Select(x => 2 * x).ToArray());
        bfs = originalTree.Bfs();
    }

    [BenchmarkMethod]
    public void SimpleSearch()
    {
        SingleRun(originalTree);
    }

    [BenchmarkMethod]
    public void CacheConsciousSearch1()
    {
        SingleRun(new CacheConsciousTree(bfs, 1));
    }

    [BenchmarkMethod]
    public void CacheConsciousSearch2()
    {
        SingleRun(new CacheConsciousTree(bfs, 2));
    }

    [BenchmarkMethod]
    public void CacheConsciousSearch3()
    {
        SingleRun(new CacheConsciousTree(bfs, 3));
    }

    [BenchmarkMethod]
    public void CacheConsciousSearch4()
    {
        SingleRun(new CacheConsciousTree(bfs, 4));
    }

    [BenchmarkMethod]
    public void CacheConsciousSearch5()
    {
        SingleRun(new CacheConsciousTree(bfs, 5));
    }
    
    private int SingleRun(ITree tree)
    {
        int searchedCount = 0;
        for (int iteration = 0; iteration < IterationCount; iteration++)
        {
            int x = random.Next(N * 2);
            if (tree.Contains(x))
                searchedCount++;
        }
        return searchedCount;
    }

    interface ITree
    {
        bool Contains(int x);
    }

    class Tree : ITree
    {
        private readonly int[] a;

        public Tree(int[] a)
        {
            this.a = a;
        }

        public bool Contains(int x)
        {
            int l = 0, r = N - 1;
            while (l <= r)
            {
                int m = (l + r) / 2;
                if (a[m] == x)
                    return true;
                if (a[m] > x)
                    r = m - 1;
                else
                    l = m + 1;
            }
            return false;
        }

        public int[] Bfs()
        {
            int[] bfs = new int[N], l = new int[N], r = new int[N];
            int tail = 0, head = 0;
            l[head] = 0;
            r[head++] = N - 1;
            while (tail < head)
            {
                int m = (l[tail] + r[tail]) / 2;
                bfs[tail] = a[m];
                if (l[tail] < m)
                {
                    l[head] = l[tail];
                    r[head++] = m - 1;
                }
                if (m < r[tail])
                {
                    l[head] = m + 1;
                    r[head++] = r[tail];
                }
                tail++;
            }
            return bfs;
        }
    }

    class CacheConsciousTree : ITree
    {
        private readonly int[] a;
        private readonly int level;

        public CacheConsciousTree(int[] bfs, int level)
        {
            this.level = level;
            int size = (1 << level) - 1, counter = 0;
            a = new int[N];
            var was = new bool[N];
            var queue = new int[size];
            for (int i = 0; i < N; i++)
                if (!was[i])
                {
                    int head = 0;
                    queue[head++] = i;
                    for (int tail = 0; tail < head; tail++)
                    {
                        a[counter++] = bfs[queue[tail]];
                        was[queue[tail]] = true;
                        if (queue[tail] * 2 + 1 < N && head < size)
                            queue[head++] = queue[tail] * 2 + 1;
                        if (queue[tail] * 2 + 2 < N && head < size)
                            queue[head++] = queue[tail] * 2 + 2;
                    }
                }
        }

        public bool Contains(int x)
        {
            int u = 0, deep = 0, leafCount = 1 << (level - 1);
            int root = 0, rootOffset = 0;
            while (deep < K)
            {
                int value = a[root + u];
                if (value == x)
                    return true;
                if (++deep % level != 0)
                {
                    if (value > x)
                        u = 2 * u + 1;
                    else
                        u = 2 * u + 2;
                }
                else
                {
                    int subTreeSize = (1 << Math.Min(level, K - deep)) - 1;
                    if (value > x)
                        rootOffset = rootOffset * leafCount * 2 + (u - leafCount + 1) * 2;
                    else
                        rootOffset = rootOffset * leafCount * 2 + (u - leafCount + 1) * 2 + 1;
                    root = (1 << deep) - 1 + rootOffset * subTreeSize;
                    u = 0;
                }
            }
            return false;
        }
    }
}
```

</div>
<p>
	На всякий случай я запустил бенчмарк под различными версиями .NET Framework и с различной битностью. Все конфигурации дали схожие результаты:
</p>
<div class="separator" style="clear: both; text-align: center;">
	<a href="http://3.bp.blogspot.com/-vup5W3aaqRg/UoyhK7lTPaI/AAAAAAAAAPE/JHDLACXG7Eg/s1600/ms.net.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;">
		<img border="0" src="http://3.bp.blogspot.com/-vup5W3aaqRg/UoyhK7lTPaI/AAAAAAAAAPE/JHDLACXG7Eg/s640/ms.net.png" />
	</a>
</div>
<p>Под Mono результаты также получились аналогичными:</p>
<div class="separator" style="clear: both; text-align: center;">
	<a href="http://2.bp.blogspot.com/-L8WX6UDHCA4/UoyhOjLKhvI/AAAAAAAAAPM/RBnImyRSQk0/s1600/mono.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;">
		<img border="0" src="http://2.bp.blogspot.com/-L8WX6UDHCA4/UoyhOjLKhvI/AAAAAAAAAPM/RBnImyRSQk0/s640/mono.png" />
	</a>
</div>
<p>
	Из этих картинок видно, что классическая реализация бинарного поиска значительно уступает Cache-Conscious-реализации. Стоит отметить, что по началу с ростом высоты поддеревьев быстродействие возрастает, но эта тенденция наблюдается недолго (поддеревья начинают приносить мало пользы, если внутри поддерева возникает большое количество cashe miss-ов).
</p>
<p>
	Разумеется, Cache-Conscious Binary Search является лишь примером того, как можно адаптировать программу к особенностям работы кэша процессора. Подобные Cache-Conscious Data Structures могут оказать неоценимую помощь при оптимизации приложения, если ваши структуры данных имеют достаточно большой объём, а последовательные запросы к ним приходятся на разные участки памяти. Но не стоит бездумно бросаться переписывать всё под Cache-Conscious: помните, что код станет намного сложнее, а повышение эффективности в значительной степени зависит от используемой процессорной архитектуры. В реальной жизни лучше сперва подумать о выборе наиболее оптимальных алгоритмов с хорошей асимптотикой, различных предподсчётах, эвристиках и т.п., а Cache-Conscious приберечь на времена, когда всё станет совсем плохо.
</p>
<p>
	Дополнение от Хабраюзера
	<a href="http://habrahabr.ru/users/MikeMirzayanov/">MikeMirzayanov</a>
	: Есть такой трюк. Если надо бинпоиском поискать в массиве длине n, то можно разбить его на sqrt(n) блоков по sqrt(n) элементов. Затем бинпоиском за log(sqrt(n)) подыскать нужный блок и в нём вторым бинпоиском за log(sqrt(n)) найти элемент. В сумме получается всё тот же log(n), но попаданий в кэш значительно больше, т.к. каждый раз ищем на довольно коротком массиве длины sqrt(n).
</p>
<p>Быстрых вам приложений!</p>
<hr />
<p>Также можно почитать по теме:</p>
<ul>
	<li>
		<a href="http://www.vldb.org/conf/1999/P7.pdf">Cache Conscious Indexing for Decision-Support in Main Memory</a>
	</li>
	<li>
		<a href="http://research.microsoft.com/en-us/um/people/trishulc/papers/ccds.pdf">Cache-Conscious Data Structures</a>
	</li>
	<li>
		<a href="http://mspiegel.github.io/publications/michael-spiegel-dissertation.pdf">Cache-Conscious Concurrent Data Structures</a>
	</li>
	<li>
		<a href="http://ftp.cse.buffalo.edu/users/azhang/disc/disc01/cd1/out/papers/sigmod/p475-rao/p475-rao.pdf">Making B+-Trees Cache Conscious in Main Memory</a>
	</li>
</ul>