---
layout: ru-default
title: Андрей Акиньшин
permalink: /ru/about/
---
@model Pretzel.Logic.Templating.Context.PageContext

<h1>Андрей Акиньшин</h1>
<div id="profiles" class="fa-2x">
  <a href="https://github.com/AndreyAkinshin"><i class="fab fa-github" title="GitHub"></i></a>
  <a href="https://twitter.com/andrey_akinshin"><i class="fab fa-twitter" title="Twitter"></i></a>
  <a href="http://stackoverflow.com/users/184842/AndreyAkinshin"><i class="fab fa-stack-overflow" title="StackOverflow"></i></a>
  <a href="http://habrahabr.ru/users/dreamwalker"><i class="fas fa-hospital-symbol" title="Habrahabr"></i></a>
  <a href="https://www.youtube.com/channel/UCk25QhN-9_wwkqyeapuCh9w"><i class="fab fa-youtube" title="YouTube"></i></a>
  <a href="http://www.linkedin.com/in/AndreyAkinshin"><i class="fab fa-linkedin-in" title="LinkedIn"></i></a>
  <a href="http://www.slideshare.net/AndreyAkinshin"><i class="fab fa-slideshare" title="SlideShare"></i></a>
  <a href="http://www.goodreads.com/AndreyAkinshin"><i class="fab fa-goodreads" title="GoodReads"></i></a>
  <a href="http://scholar.google.ru/citations?user=rYVl83IAAAAJ"><i class="fab fa-google" title="Google Scholar"></i></a>
  <a href="http://elibrary.ru/author_items.asp?authorid=676806"><i class="fas fa-book" title="ELibrary"></i></a>
  <a href="http://www.mathnet.ru/php/person.phtml?personid=79053"><i class="far fa-clone" title="Math-Net"></i></a>
  <a href="https://www.researchgate.net/profile/Andrey_Akinshin"><i class="fab fa-researchgate" title="ResearchGate"></i></a>
</div>
<a href="mailto:andrey.akinshin@gmail.com">andrey.akinshin@gmail.com</a>
<hr />

Андрей Акиньшин работает в компании [JetBrains](https://www.jetbrains.com/),
  где он трудится над проектом [Rider](https://www.jetbrains.com/rider/)
  (кроссплатформенная .NET IDE, основанная на платформе [IntelliJ](https://www.jetbrains.com/idea/) и [ReSharper](https://www.jetbrains.com/resharper/)).
Его любимые темы — производительность и микрооптимизации,
  он также мейнтейнер проекта [BenchmarkDotNet](https://github.com/dotnet/BenchmarkDotNet)
  (библиотека для написания .NET-бенчмарков, поддержанная [.NET Foundation](https://dotnetfoundation.org/)).
Андрей — частый [спикер](#talks) на различных мероприятиях для разработчиков и
  председатель программного комитета конференции [DotNext](https://dotnext.ru/).
Он также 
  к.ф.-м.н.,
  Microsoft .NET MVP,
  серебрянный медалист [ACM ICPC](https://en.wikipedia.org/wiki/ACM_International_Collegiate_Programming_Contest).
В свободное время любит заниматься наукой,
  основные научные интересы — математическая биология и теория бифуркаций.
Раньше он работал
  постдоком в [Институте Вейцмана](http://www.weizmann.ac.il/) и
  научным сотрудником в [Институте математики СО РАН](http://www.math.nsc.ru/).

<div id="about">

<hr />
<section>
  <h3>Содержание</h3>

  Активности:
  [Публичные выступления (@Raw(Model.GeneratedFile("talks-ru-count.txt")))](#talks) **|**
  [Публикации (@Raw(Model.GeneratedFile("publications-ru-count.txt")))](#publications) **|**
  [Посты (@Model.Site.EnPosts.Count())](#posts) **|**
  [Open source](#open-source) <br />
  Опыт:
  [Программирование](#enterprise) **|**
  [Научная деятельность](#science) **|**
  [Олимпиады](#competitive) **|**
  [Преподавание](#teaching) <br />
  Квалификация:
  [Образование](#education) **|**
  [Сертификаты](#certificates)
  
</sections>

<hr />
<section>
  <h3 id="talks">Публичные выступления</h3>

  @Raw(Model.GeneratedFile("talks-ru.html"))
</section>

<hr />
<section>
  <h3 id="publications">Публикации</h3>

  @Raw(Model.GeneratedFile("publications-ru.html"))
</section>

<hr />
<section>
  <h3 id="posts">Посты</h3>
  <p><a href="/blog/content/">Последние посты доступны только в английской версии блога</a></p>
  @foreach(var year in Model.Site.RuPosts.Select(p => p.Date.Year).Distinct().OrderByDescending(y => y))
  {
      var posts = Model.Site.RuPosts.Where(p => p.Date.Year == year).OrderByDescending(p => p.Date).ToList();
      if (posts.Count() > 0)
      {
          <h3 id="@year">@year</h3>
          <ul>
          @foreach(var post in posts)
          {
              <li><a href='@post.Url.Replace("index.html", "")'>@post.Title</a> <i>(@post.Date.ToString("dd MMMM", new System.Globalization.CultureInfo("ru-RU")))</i></li>
          }
          </ul>
      }
  }
</section>

<hr />
<section>
  <h3 id="open-source">Open source</h3>

  <i class="fab fa-github" title="GitHub"></i>
  **GitHub:**
  [github.com/AndreyAkinshin](https://github.com/AndreyAkinshin/)
  <br /><br />

  @Raw(Model.GeneratedFile("opensource-ru.html"))
</section>

<hr />
<section>
  <h3 id="enterprise">Программирование</h3>

  *Software Developer в JetBrains, Microsoft .NET MVP (2015–2019)*<br />
  **Основные навыки:** .NET/C\#, R, Kotlin, Производительность, Бенчмаркинг, Алгоритмы, Математика
  <br /><br />

  ![](/img/icons/jetbrains.png)
  [JetBrains](https://www.jetbrains.com/)

  * *10/2015–Сейчас:* Software Developer

  **Проекты**
  * ![](/img/icons/rider.png)
    [Rider](https://www.jetbrains.com/rider/):
    Кроссплатформенная .NET IDE
  <br /><br />

  ![](/img/icons/perpetuum.png)
  [Perpetuum Software LLC](http://www.perpetuumsoft.com/)
  /
  ![](/img/icons/enterra.png)
  [Enterra, Inc](http://www.enterra-inc.com/)
  /
  ![](/img/icons/notariat.png)
  [Адаптивные технологии](http://notariatsoft.ru/)
  
  * *09/2010–08/2011:* Стажёр<br />
  * *09/2011–01/2013:* Программист<br />
  * *02/2013–09/2016:* Ведущий программист

  **Проекты**
  * ![](/img/icons/pv.png)
    [PassportVision](http://passportvision.ru/):
    Программа для распознавания паспортов на основе OpenCV, Tesseract<br />
    *Ведущий разработчик (управлением командой, проектирование архитектуры, алгоритмы распознавания)*
  * ![](/img/icons/grapholite.png)
    [Grapholite](http://grapholite.com/):
    Редактор диаграмм под
      [<img src="/img/icons/windows8.png" alt="Windows 8" title="Windows 8/10" />](http://apps.microsoft.com/windows/app/grapholite-diagrams-pro/99164828-b985-44ad-af71-58827d8d8a13)
      [<img src="/img/icons/winphone.png" alt="Windows Phone" title="Windows Phone" />](http://www.windowsphone.com/en-us/store/app/grapholite-diagrams-phone-edition/4e89fe82-db21-45c5-a284-8de9a443fb70)
      [<img src="/img/icons/wpf.png" alt="WPF" title="WPF" />](https://grapholite.com/Download/Grapholite.msi)
      [<img src="/img/icons/silverlight.png" alt="Silverlight" title="Silverlight" />](https://grapholite.com/Designer)
      [<img src="/img/icons/ios.png" alt="iPad" title="iPad" />](https://itunes.apple.com/us/app/grapholite-diagrams-flow-charts/id954302708?ls=1&mt=8)
      [<img src="/img/icons/android.png" alt="Android" title="Android" />](https://play.google.com/store/apps/details?id=com.grapholite.diagramsdemo)
    (аналог MS Visio).<br />
    *Разработчик (разработка алгоритмов, математика, проектирование части архитектуры)*
  * ![](/img/icons/knockout-mvc.png)
    [Knockout MVC](http://knockoutmvc.com/):
    ASP.NET MVC-обёртка для knockout.js<br />
    *Главный разработчик (проектирование архитектуры, API, клиентская/серверная логика, вёрстка, документация и т.д.)*
  * ![](/img/icons/ui-controls.png)
    [UI Controls for Windows 8](http://www.perpetuumsoft.com/Windows8-UI-Controls.aspx):
    Набор многофункциональных контролов под Windows 8<br />
    *Главный разработчик (проектирование архитектуры, API, XAML-вёрстка, демо-проект, документация и т. д.)*
</section>

<hr />
<section>
  <h3 id="science">Научная деятельность</h3>

  *Кандидат физико-математических наук (05.13.18)*
  <br /><br />

  ![](/img/icons/math-nsc.png)
  [Институт математики им С. Л. Соболева СО РАН](http://www.math.nsc.ru/), [Лаборатория обратных задач математической физики](http://a-server.math.nsc.ru/IM/lbrt.asp?CodLB=59) (Новосибирск)<br />

  * *08/2012–06/2014:* Инженер
  * *07/2014–12/2016:* [Научный сотрудник](http://a-server.math.nsc.ru/IM/sotrudl.asp?CodID=1573)

  **Интересы:** математическая биология, генные сети, диф. уравнения с запаздывающим аргументом, теория бифуркаций.<br />
  **Избранные стипендии и гранты**
  * *01/2012–12/2014:* Грант [РФФИ 12-01-00074](http://www.rfbr.ru/rffi/portal/project_search/o_387745) «Прямые и обратные задачи математического моделирования генных сетей»<br />
  * *07/2012–07/2014:* Стипендия президента РФ для молодых учёных и аспирантов [СП-561.2012.5](https://grants.extech.ru/grants/res/winners.php?OZ=5&TZ=U&year=2012) по направлению «Стратегические информационные технологии, включая вопросы создания суперкомпьютеров и разработки программного обеспечения» («Компьютерные методы моделирования и анализа моделей генных сетей»)<br />
  * *01/2015–12/2017:* Грант [РФФИ 15-01-00745 A](http://www.rfbr.ru/rffi/portal/project_search/o_1999519) «Динамические характеристики моделей генных сетей»
  * *01/2018-12/2020:* Грант **РФФИ 18-01-00057 А** «Кольцевые структуры в моделях генных сетей»
  <br /><br />

  ![](/img/icons/weizmann.png)
  [Институт Вейцмана](http://www.weizmann.ac.il/), [Факультет математики и информатики](http://wws.weizmann.ac.il/math/) (Израиль, Реховот)<br />

  * *10/2014–09/2016:* Postdoctoral Research Fellow

  **Интересы:** цифровая обработка сигналов, преобразование Фурье, эффект Гиббса, системы Прони.
</section>

<hr />
<section>
  <h3 id="competitive">Олимпиады</h3>

  **Избранные олимпиады (2002-2009)**
  * *04/2006:*
    ![](/img/icons/acm-icpc.png)
    Золотая медаль, 
    Всероссийская олимпиада школьников по информатике [РОИ 2006](http://neerc.ifmo.ru/school/archive/2005-2006/ru-olymp-roi-2006-standings.html) (Кисловодск)<br />
  * *04/2008:*
    ![](/img/icons/acm-icpc.png)
    Сертифицированный участник,
    [Чемпионат мира по программированию ACM ICPC 2008](http://icpc.baylor.edu/community/results-2008) (Канада)<br />
  * *04/2009:*
    ![](/img/icons/acm-icpc.png)
    Серебряная медаль,
    [Чемпионат мира по программированию ACM ICPC 2009](http://icpc.baylor.edu/community/results-2009) (Швеция)<br />
</section>

<hr />
<section>
  <h3 id="teaching">Преподавание</h3>

  * *09/2006–05/2012:*
    ![](/img/icons/s42.png)
    Тренер сборной по программированию и математике в <a href="http://gymnasium42.ru/">МБОУ «Гимназия №42»</a> г.&nbsp;Барнаула.
  * *09/2009–09/2016:*
    ![](/img/icons/aeli.png)
     Старший преподаватель информатики и математики в Алтайском Экономико-Юридическом Институте, кафедра общих математических и естественнонаучных дисциплин.
  * *09/2011–11/2011:*
    ![](/img/icons/ministry.png)
     Преподаватель в рамках федеральной программы Ф-263 №4 «Подготовка и переподготовка профильных специалистов на базе центров образования и разработок в сфере информационных технологий».
</section>

<hr />
<section>
  <h3 id="education">Образование</h3>

  ![](/img/icons/astu.png)
  <a href="http://www.altstu.ru/">Алтайский Государственный Технический Университет им И. И. Ползунова</a>,<a href="http://www.altstu.ru/structure/faculty/fit/">Факультет информационных технологий</a> (Барнаул)<br />
  
  * *09/2006–06/2011:* Студент по специальности <a href="http://www.altstu.ru/entrant/speciality/0026/">230105</a> «Программное обеспечение вычислительной техники и автоматизированных систем». Красный диплом, средний балл 5.0, студент года АлтГТУ 2009, староста группы.
  * *08/2011–12/2013:* Аспирант по специальности <a href="http://www.altstu.ru/media/f/051318_OOP_ispr.pdf">05.13.18</a> «Математическое моделирование, численные методы и комплексы программ». Диссертация <a href="http://www.sscc.ru/Diss_sov/akinshin-synopsis.pdf">«Математическое и численное моделирование искусственных регуляторных контуров генных сетей»</a> (защита в <a href="http://www.sscc.ru/">ИВМиМГ СО РАН</a>, <a href="http://www.sscc.ru/Diss_sov/D02_2013.12.17.html">декабрь 2013</a>).
</section>

<hr />
<section>
  <h3 id="certificates">Сертификаты</h3>

  **Свидетельства о регистрации программ для ЭВМ**
  * ![](/img/icons/ministry.png)
    Phase Portrait Analyzer
    (Свидетельство о государственной регистрации программы для ЭВМ [№2013660415](http://www1.fips.ru/fips_servl/fips_servlet?DB=EVM&rn=673&DocNumber=2013660415&TypeFile=html))<br />
    *Программа предназначена для выполнения анализа нелинейных систем дифференциальных уравнений специального вида.*
  * ![](/img/icons/ministry.png)
    Neuro Biomarker Analyzer
    (Свидетельство о государственной регистрации программы для ЭВМ [№2015612396](http://www1.fips.ru/Archive/EVM/2015/2015.03.20/DOC/RUNW/000/002/015/612/396/document.pdf))<br />
    *Программа позволяет оценить диагностическую и прогностическую значимость биохимических параметров (концентраций) биомаркеров сыворотки периферической крови для дифференциальной диагностики неврологических синдромов поясничного остеохондроза.*
  <br /><br />

  **Microsoft**
  * <a href="https://www.microsoft.com/learning/en-us/microsoft-certified-professional.aspx">Microsoft Certified Professional (MCP)</a>: <a href="/data/certificates/mcp.pdf">сертификат</a>
  * <a href="https://www.microsoft.com/learning/en-us/exam-70-483.aspx">Programming in C# Specialist (70-483)</a>: <a href="/data/certificates/ms-70-483.pdf">сертификат</a>
  <br /><br />
  
  <b><a href="https://www.coursera.org/specialization/jhudatascience/1">Coursera: The Data Science Specialization</a></b>: <a href="https://www.coursera.org/account/accomplishments/specialization/44Y2uInkEe">сертификат (верифицируемый)</a><br />
  1. <a href="https://www.coursera.org/course/datascitoolbox">The Data Scientist’s Toolbox</a>: <a href="https://www.coursera.org/records/DjNvsvmPV9xCbVp8">сертификат (верифицируемый)</a>
  2. <a href="https://www.coursera.org/course/rprog">R Programming</a>: <a href="https://www.coursera.org/records/HYm8MNbAKs4VF2n6">сертификат (верифицируемый)</a>
  3. <a href="https://www.coursera.org/course/getdata">Getting and Cleaning Data</a>: <a href="https://www.coursera.org/records/mdbQY6K5KGT2YLnu">сертификат (верифицируемый)</a>
  4. <a href="https://www.coursera.org/course/exdata">Exploratory Data Analysis</a>: <a href="https://www.coursera.org/records/wbRpVCv3cbGA366h">сертификат (верифицируемый)</a>
  5. <a href="https://www.coursera.org/course/repdata">Reproducible Research</a>: <a href="https://www.coursera.org/records/9Dn88n69GSBgdqRq">сертификат (верифицируемый)</a>
  6. <a href="https://www.coursera.org/course/statinference">Statistical Inference</a>: <a href="https://www.coursera.org/records/SrwJ9BzYnJvCqFhf">сертификат (верифицируемый)</a>
  7. <a href="https://www.coursera.org/course/regmods">Regression Models</a>: <a href="https://www.coursera.org/records/VCYRT4KkCtg6RvDb">сертификат (верифицируемый)</a>
  8. <a href="https://www.coursera.org/course/predmachlearn">Practical Machine Learning</a>: <a href="https://www.coursera.org/records/MSqb7c4BNBNsh2r6">сертификат (верифицируемый)</a>
  9. <a href="https://www.coursera.org/course/devdataprod">Developing Data Products</a>: <a href="https://www.coursera.org/records/sGb9a2xXgvKTX7J7">сертификат (верифицируемый)</a>
  10. <a href="https://www.coursera.org/course/dsscapstone">Data Science Capstone</a>: <a href="https://www.coursera.org/account/accomplishments/records/6GSQ7S36nRUQ7YDn">сертификат (верифицируемый)</a>

  **Coursera**
  * <a href="https://www.coursera.org/course/usablesec">Usable Security</a>: <a href="https://www.coursera.org/account/accomplishments/records/HercA2dcqGaEpKsm">сертификат (верифицируемый)</a>
  * <a href="https://www.coursera.org/course/softwaresec">Software Security</a>: <a href="https://www.coursera.org/account/accomplishments/records/CESXRmrpvMM4kbsd">сертификат (верифицируемый)</a>
  * <a href="https://www.coursera.org/learn/cryptography">Cryptography</a>: <a href="https://www.coursera.org/account/accomplishments/records/KYELW2LJ54AL">сертификат (верифицируемый)</a>
  * <a href="https://www.coursera.org/learn/hardware-security/">Hardware Security</a>: <a href="https://www.coursera.org/account/accomplishments/records/NRVPDVRLFTJA">сертификат (верифицируемый)</a>
  * <a href="https://www.coursera.org/course/dsp">Digital Signal Processing</a>: <a href="https://www.coursera.org/account/accomplishments/records/SjLYjhw5dwvz3fFR">сертификат (верифицируемый)</a>
  * <a href="https://www.coursera.org/course/sysbio">Introduction to Systems Biology</a>: <a href="https://www.coursera.org/records/vfkb32TKmLapxqJN">сертификат (верифицируемый)</a>
  * <a href="https://www.coursera.org/course/latex">Документы и презентации в LaTeX</a>: <a href="https://www.coursera.org/records/t8gYgHqbtKs3pygc">сертификат (верифицируемый)</a>
</section>


<hr />
</div>
