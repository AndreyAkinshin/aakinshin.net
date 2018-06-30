---
layout: default
title: Andrey Akinshin
permalink: /about/
redirect_from:
- /en/about/
---
@model Pretzel.Logic.Templating.Context.PageContext

<h1>Andrey Akinshin</h1>
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

Andrey Akinshin is a senior developer at [JetBrains](https://www.jetbrains.com/),
  where he works on [Rider](https://www.jetbrains.com/rider/)
  (a cross-platform .NET IDE based on the [IntelliJ](https://www.jetbrains.com/idea/) platform and [ReSharper](https://www.jetbrains.com/resharper/)).
His favorite topics are performance and micro-optimizations,
  and he is the maintainer of [BenchmarkDotNet](https://github.com/dotnet/BenchmarkDotNet)
  (a powerful .NET library for benchmarking supported by the [.NET Foundation](https://dotnetfoundation.org/)).
Andrey is a frequent [speaker](#talks) at various events for developers, and
  he is the program director of the [DotNext](https://dotnext.ru/en/) conference.
Andrey is also
  a PhD in computer science,
  a Microsoft .NET [MVP](https://mvp.microsoft.com/en-us/PublicProfile/5001348?fullName=Andrey%20%20Akinshin),
  a silver medalist of [ACM ICPC](https://en.wikipedia.org/wiki/ACM_International_Collegiate_Programming_Contest).
In his free time, he likes to study science
  (his primary research interests are mathematical biology and bifurcation theory).
Previously, he worked
  as a postdoctoral research fellow in the [Weizmann Institute of Science](http://www.weizmann.ac.il/) and
  as a research scientist in the [Sobolev Institute of Mathematics SB RAS](http://math.nsc.ru/english.html).

<div id="about">

<hr />
<section>
  <h3>Content</h3>

  Activities:
  [Public talks (@Raw(Model.GeneratedFile("talks-count.txt")))](#talks) **|**
  [Publications (@Raw(Model.GeneratedFile("publications-count.txt")))](#publications) **|**
  [Posts (@Model.Site.RuPosts.Count())](#posts) **|**
  [Open source](#open-source) <br />
  Experience:
  [Enterprise programming](#enterprise) **|**
  [Science](#science) **|**
  [Competitive programming](#competitive) **|**
  [Teaching](#teaching) <br />
  Background:
  [Education](#education) **|**
  [Certificates](#certificates)

</sections>

<hr />
<section>
  <h3 id="talks">Public talks</h3>

  @Raw(Model.GeneratedFile("talks.html"))
</section>

<hr />
<section>
  <h3 id="publications">Selected publications</h3>

  @Raw(Model.GeneratedFile("publications.html"))
</section>

<hr />
<section>
  <h3 id="posts">Posts</h3>
    @foreach(var year in Model.Site.EnPosts.Select(p => p.Date.Year).Distinct().OrderByDescending(y => y))
    {
        var posts = Model.Site.EnPosts.Where(p => p.Date.Year == year).OrderByDescending(p => p.Date).ToList();
        if (posts.Count() > 0)
        {
            <h3 id="@year">@year</h3>
            <ul>
            @foreach(var post in posts)
            {
                <li><a href='@post.Url.Replace("index.html", "")'>@post.Title</a> <i>(@post.Date.ToString("MMMM dd", new System.Globalization.CultureInfo("en-US")))</i></li>
            }
            </ul>
        }
    }
  <br />
  <p style="font-size:150%"><a href="/ru/blog/content/">More posts in Russian</a></p>
</section>

<hr />
<section>
  <h3 id="open-source">Open source</h3>

  <i class="fab fa-github" title="GitHub"></i>
  **GitHub:**
  [github.com/AndreyAkinshin](https://github.com/AndreyAkinshin/)
  <br /><br />

  @Raw(Model.GeneratedFile("opensource.html"))
</section>

<hr />
<section>
  <h3 id="enterprise">Enterprise programming</h3>

  **Current:** *Software Developer at JetBrains, [Microsoft .NET MVP (2015–2018)](https://mvp.microsoft.com/en-us/PublicProfile/5001348?fullName=Andrey%20%20Akinshin)*<br />
  **Main skills:** .NET/C\#, R, Kotlin, Performance, Benchmarking, Algorithms, Mathematics
  <br /><br />

  ![](/img/icons/jetbrains.png)
  [JetBrains](https://www.jetbrains.com/)

  * *10/2015–Present:* Software Developer

  **Projects**
  * ![](/img/icons/rider.png)
    [Rider](https://www.jetbrains.com/rider/):
    A cross-platform .NET IDE based on the IntelliJ platform and ReSharper
  <br /><br />

  ![](/img/icons/perpetuum.png)
  [Perpetuum Software LLC](http://www.perpetuumsoft.com/)
  /
  ![](/img/icons/enterra.png)
  [Enterra, Inc](http://www.enterra-inc.com/)
  /
  ![](/img/icons/notariat.png)
  [Adaptive technologies](http://notariatsoft.ru/)
  
  * *09/2010–08/2011:* Junior Software Developer<br />
  * *09/2011–01/2013:* Software Developer<br />
  * *02/2013–09/2016:* Lead Software Developer

  **Projects**
  * ![](/img/icons/pv.png)
    [PassportVision](http://passportvision.ru/):
    Image recognition software based on OpenCV, Tesseract<br />
    *Team Lead (architecture design, recognition algorithms)*
  * ![](/img/icons/grapholite.png)
    [Grapholite](http://grapholite.com/):
    Diagram editor for
      [<img src="/img/icons/windows8.png" alt="Windows 8" title="Windows 8/10" />](http://apps.microsoft.com/windows/app/grapholite-diagrams-pro/99164828-b985-44ad-af71-58827d8d8a13)
      [<img src="/img/icons/winphone.png" alt="Windows Phone" title="Windows Phone" />](http://www.windowsphone.com/en-us/store/app/grapholite-diagrams-phone-edition/4e89fe82-db21-45c5-a284-8de9a443fb70)
      [<img src="/img/icons/wpf.png" alt="WPF" title="WPF" />](https://grapholite.com/Download/Grapholite.msi)
      [<img src="/img/icons/silverlight.png" alt="Silverlight" title="Silverlight" />](https://grapholite.com/Designer)
      [<img src="/img/icons/ios.png" alt="iPad" title="iPad" />](https://itunes.apple.com/us/app/grapholite-diagrams-flow-charts/id954302708?ls=1&mt=8)
      [<img src="/img/icons/android.png" alt="Android" title="Android" />](https://play.google.com/store/apps/details?id=com.grapholite.diagramsdemo)
    (an analogue of MS Visio).<br />
    *Developer (algorithm development, mathematics, architecture design)*
  * ![](/img/icons/knockout-mvc.png)
    [Knockout MVC](http://knockoutmvc.com/):
    ASP.NET MVC wrapper for knockout.js<br />
    *Main developer (architecture design, API, client/server logic, official site, documentation, etc.)*
  * ![](/img/icons/ui-controls.png)
    [UI Controls for Windows 8](http://www.perpetuumsoft.com/Windows8-UI-Controls.aspx):
    A set of UI controls that will help develop true Windows Store application faster<br />
    *Main developer (architecture design, API, XAML-layout, demo project, documentation, etc.)*
</section>

<hr />
<section>
  <h3 id="science">Science</h3>

  **Current:** *PhD in Mathematics and Computer Science*
  <br /><br />

  ![](/img/icons/math-nsc.png)
  [Sobolev Institute of Mathematics SB RAS](http://math.nsc.ru/english.html), [Laboratory of Inverse Problems of Mathematical Physics](http://a-server.math.nsc.ru/IM/lbrt.asp?CodLB=59) (Novosibirsk, Russia)<br />

  * *08/2012–06/2014:* Engineer
  * *07/2014–12/2016:* [Research scientist](http://a-server.math.nsc.ru/IM/sotrudl.asp?CodID=1573)

  **Areas of expertise:** mathematical biology, gene networks, differential equations with delayed argument, bifurcation theory.<br />
  **Selected scholarships and grants**
  * *01/2012–12/2014:* The grant [RFBR 12-01-00074](http://www.rfbr.ru/rffi/portal/project_search/o_387745) “Direct and inverse problems of gene networks mathematical modeling”<br />
  * *07/2012–07/2014:* The scholarships [SP-561.2012.5](https://grants.extech.ru/grants/res/winners.php?OZ=5&TZ=U&year=2012) of the President of Russian Federation, direction: “Strategic information technology, including the creation of supercomputers and software development” (“Numerical methods for modeling and analyzing of gene networks”)<br />
  * *01/2015–12/2017:* The grant [RFBR 15-01-00745 A](http://www.rfbr.ru/rffi/portal/project_search/o_1999519) “Dynamic characteristics of gene networks models”
  * *01/2018-12/2020:* The grant **RFBR 18-01-00057 A** “Ring structures in gene network models”
  <br /><br />

  ![](/img/icons/weizmann.png)
  [Weizmann Institute of Science](http://www.weizmann.ac.il/), [Faculty of Mathematics and Computer Science](http://wws.weizmann.ac.il/math/) (Rehovot, Israel)

  * *10/2014–09/2016:* Postdoctoral Research Fellow

  **Areas of expertise:** digital signal processing, Fourier transform, Gibbs phenomenon, Prony systems.
</section>

<hr />
<section>
  <h3 id="competitive">Competitive programming</h3>

  **Selected contests (2002-2009)**
  * *04/2006:*
    ![](/img/icons/acm-icpc.png)
    Gold medal at 
    Final of Russian Olympiad in Informatics [ROI 2006](http://neerc.ifmo.ru/school/archive/2005-2006/ru-olymp-roi-2006-standings.html) (Kislovodsk)<br />
  * *04/2008:*
    ![](/img/icons/acm-icpc.png)
    Certified participant at
    [ACM International Collegiate Programming Contest 2008](http://icpc.baylor.edu/community/results-2008) (Canada)<br />
  * *04/2009:*
    ![](/img/icons/acm-icpc.png)
    Silver medal at
    [ACM International Collegiate Programming Contest 2009](http://icpc.baylor.edu/community/results-2009) (Sweden)<br />
</section>

<hr />
<section>
  <h3 id="teaching">Teaching</h3>

  * *09/2006–05/2012:*
    ![](/img/icons/s42.png)
    Coach of competitive programming and mathematics teams in Barnaul <a href="http://gymnasium42.ru/">Gymnasium&nbsp;№42</a>.
  * *09/2009–09/2016:*
    ![](/img/icons/aeli.png)
    Senior lecturer of computer science and mathematics in Altai Economics and Law Institute, Department of general mathematical and scientific disciplines.
  * *09/2011–11/2011:*
    ![](/img/icons/ministry.png)
    Lecturer under the Russian federal program F-263 №4 “Specialized training and retraining of specialists at the centers of education and development in information technology”.
</section>

<hr />
<section>
  <h3 id="education">Education</h3>

  ![](/img/icons/astu.png)
  <a href="http://www.en.altstu.ru/">I.I. Polzunov Altai state technical university</a>, <a href="http://www.altstu.ru/structure/faculty/fit/">Faculty of Information Technologies</a> (Barnaul, Russia)<br />
  
  * *09/2006–06/2011:* Student, specialty <a href="http://www.altstu.ru/entrant/speciality/0026/">230105</a> “Software for Computers and Automated System”.<br />
  Honours degree, 5.0 GPA, AltSTU student of the year 2009, head of the group.
  * *08/2011–12/2013:* PhD student, specialty: <a href="http://www.altstu.ru/media/f/051318_OOP_ispr.pdf">05.13.18</a> “Mathematical modeling, numeric methods, and software systems”.<br />
  PhD thesis <a href="http://www.sscc.ru/Diss_sov/akinshin-synopsis.pdf">“Mathematical and numerical modeling of gene networks artificial regulatory circuits”</a><br />
  (defended in <a href="http://www.sscc.ru/index_e.html">Institute of Computational Mathematics and Mathematical Geophysics SB RAS</a>, <a href="http://www.sscc.ru/Diss_sov/D02_2013.12.17.html">December 2013</a>).
</section>

<hr />
<section>
  <h3 id="certificates">Certificates</h3>

  **Russian state registration certificates of Computer Programs**
  * ![](/img/icons/ministry.png)
    Phase Portrait Analyzer
    (Russian state registration certificate of Computer Programs [№2013660415](http://www1.fips.ru/fips_servl/fips_servlet?DB=EVM&rn=673&DocNumber=2013660415&TypeFile=html))<br />
    *Software for analyzing of some nonlinear differential equation system*
  * ![](/img/icons/ministry.png)
    Neuro Biomarker Analyzer
    (Russian state registration certificate of Computer Programs [№2015612396](http://www1.fips.ru/Archive/EVM/2015/2015.03.20/DOC/RUNW/000/002/015/612/396/document.pdf))<br />
    *Software for the diagnostic and prognostic values evaluation of biochemical parameters of serum biomarkers in peripheral blood for the differential diagnosis of neurological syndromes of lumbar degenerative disc disease*
  <br /><br />

  **Microsoft**
  * <a href="https://www.microsoft.com/learning/en-us/microsoft-certified-professional.aspx">Microsoft Certified Professional (MCP)</a>: <a href="/data/certificates/mcp.pdf">certificate</a>
  * <a href="https://www.microsoft.com/learning/en-us/exam-70-483.aspx">Programming in C# Specialist (70-483)</a>: <a href="/data/certificates/ms-70-483.pdf">certificate</a>
  <br /><br />
  
  <b><a href="https://www.coursera.org/specialization/jhudatascience/1">Coursera: The Data Science Specialization</a></b>: <a href="https://www.coursera.org/account/accomplishments/specialization/44Y2uInkEe">certificate (verifiable)</a><br />
  1. <a href="https://www.coursera.org/course/datascitoolbox">The Data Scientist’s Toolbox</a>: <a href="https://www.coursera.org/records/DjNvsvmPV9xCbVp8">certificate (verifiable)</a>
  2. <a href="https://www.coursera.org/course/rprog">R Programming</a>: <a href="https://www.coursera.org/records/HYm8MNbAKs4VF2n6">certificate (verifiable)</a>
  3. <a href="https://www.coursera.org/course/getdata">Getting and Cleaning Data</a>: <a href="https://www.coursera.org/records/mdbQY6K5KGT2YLnu">certificate (verifiable)</a>
  4. <a href="https://www.coursera.org/course/exdata">Exploratory Data Analysis</a>: <a href="https://www.coursera.org/records/wbRpVCv3cbGA366h">certificate (verifiable)</a>
  5. <a href="https://www.coursera.org/course/repdata">Reproducible Research</a>: <a href="https://www.coursera.org/records/9Dn88n69GSBgdqRq">certificate (verifiable)</a>
  6. <a href="https://www.coursera.org/course/statinference">Statistical Inference</a>: <a href="https://www.coursera.org/records/SrwJ9BzYnJvCqFhf">certificate (verifiable)</a>
  7. <a href="https://www.coursera.org/course/regmods">Regression Models</a>: <a href="https://www.coursera.org/records/VCYRT4KkCtg6RvDb">certificate (verifiable)</a>
  8. <a href="https://www.coursera.org/course/predmachlearn">Practical Machine Learning</a>: <a href="https://www.coursera.org/records/MSqb7c4BNBNsh2r6">certificate (verifiable)</a>
  9. <a href="https://www.coursera.org/course/devdataprod">Developing Data Products</a>: <a href="https://www.coursera.org/records/sGb9a2xXgvKTX7J7">certificate (verifiable)</a>
  10. <a href="https://www.coursera.org/course/dsscapstone">Data Science Capstone</a>: <a href="https://www.coursera.org/account/accomplishments/records/6GSQ7S36nRUQ7YDn">certificate (verifiable)</a>

  **Coursera**
  * <a href="https://www.coursera.org/course/usablesec">Usable Security</a>: <a href="https://www.coursera.org/account/accomplishments/records/HercA2dcqGaEpKsm">certificate (verifiable)</a>
  * <a href="https://www.coursera.org/course/softwaresec">Software Security</a>: <a href="https://www.coursera.org/account/accomplishments/records/CESXRmrpvMM4kbsd">certificate (verifiable)</a>
  * <a href="https://www.coursera.org/learn/cryptography">Cryptography</a>: <a href="https://www.coursera.org/account/accomplishments/records/KYELW2LJ54AL">certificate (verifiable)</a>
  * <a href="https://www.coursera.org/learn/hardware-security/">Hardware Security</a>: <a href="https://www.coursera.org/account/accomplishments/records/NRVPDVRLFTJA">certificate (verifiable)</a>
  * <a href="https://www.coursera.org/course/dsp">Digital Signal Processing</a>: <a href="https://www.coursera.org/account/accomplishments/records/SjLYjhw5dwvz3fFR">certificate (verifiable)</a>
  * <a href="https://www.coursera.org/course/sysbio">Introduction to Systems Biology</a>: <a href="https://www.coursera.org/records/vfkb32TKmLapxqJN">certificate (verifiable)</a>
  * <a href="https://www.coursera.org/course/latex">Introduction to LaTeX</a>: <a href="https://www.coursera.org/records/t8gYgHqbtKs3pygc">certificate (verifiable)</a>
</section>


<hr />
</div>
