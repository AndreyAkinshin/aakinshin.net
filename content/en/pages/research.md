---
title: "Research projects"
layout: "page"
url: research
---

# Research projects

<div class="flex flex-wrap gap-y-1 mb-5">
<a class="label-link" href="https://scholar.google.com/citations?hl=en&user=rYVl83IAAAAJ&view_op=list_works&sortby=pubdate">
<svg class="fai fai-link"><use xlink:href="/img/fa/all.svg#graduation-cap"></use></svg>
Google Scholar
</a>
<a class="label-link" href="https://orcid.org/0000-0003-3553-9367">
<svg class="fai fai-link"><use xlink:href="/img/fa/all.svg#orcid"></use></svg>
ORCID
</a>
<a class="label-link" href="https://www.researchgate.net/profile/Andrey_Akinshin">
<svg class="fai fai-link"><use xlink:href="/img/fa/all.svg#researchgate"></use></svg>
ResearchGate
</a>
<a class="label-link" href="https://arxiv.org/a/akinshin_a_1.html">
<svg class="fai fai-link"><use xlink:href="/img/fa/all.svg#arxiv"></use></svg>
arXiv
</a>
<a class="label-link" href="https://www.webofscience.com/wos/author/record/2102893">
<svg class="fai fai-link"><use xlink:href="/img/fa/all.svg#wos"></use></svg>
Web of Science
</a>
<a class="label-link" href="https://www.scopus.com/authid/detail.uri?authorId=56826126900">
<svg class="fai fai-link"><use xlink:href="/img/fa/all.svg#scopus"></use></svg>
Scopus
</a>
</div>

This page aggregates results from some of my research projects:

* [Statistical performance analysis](#statistics)
* [Software benchmarking](#benchmarking)
* [Mathematical models of gene networks](#gene-networks)
* [Digital signal processing](#signal-processing)

---

<h2 id="statistics">Statistical performance analysis</h2>

This project aims to develop advanced statistical procedures
  for the automatic analysis of software performance measurements.
This included various
  location estimators,
  dispersion estimators,
  quantile estimators,
  effect size estimators,
  density estimators,
  change point detectors,
  outlier detectors,
  and multimodality detectors.
The goal is to provide a set of non-parametric, robust, and efficient approaches
  that are applicable to software performance distributions.

I regularly share my preliminary research notes in the form of
  [blog posts ({{< tag-count "statistics" >}})]({{< ref statistics >}}).

**Publications:**

{{< research-pub "statistics" >}}

---

<h2 id="benchmarking">Software benchmarking</h2>

This project aims to provide a set of reliable tools and approaches for software benchmarking.

Since 2013, I have been working on developing
  [BenchmarkDotNet](https://github.com/dotnet/BenchmarkDotNet)
  (9K+ [GitHub stars](https://github.com/dotnet/BenchmarkDotNet/stargazers),
   19K+ [dependent GitHub projects](https://github.com/dotnet/BenchmarkDotNet/network/dependents?package_id=UGFja2FnZS0xNTY3MzExMzE%3D),
   24M+ [NuGet downloads](https://www.nuget.org/packages/BenchmarkDotNet/)).
This .NET library helps to transform methods into benchmarks,
  track their performance,
  and share reproducible measurement experiments.
In the context of the [statistical performance analysis project](#statistics),
  I'm working on the next-generation statistical engine for performance measurement analysis.

I also wrote a book [Pro .NET Benchmarking]({{< ref prodotnetbenchmarking >}})
  about good practices of performance measurements.
This book mostly covers
  general benchmarking practices,
  performance measurement analysis approaches,
  and environmental factors that can affect obtained measurements.
It also contains dozens of case studies that demonstrate common benchmarking pitfalls and explain how to avoid them.

**Publications:**

{{< research-pub "benchmarking" >}}

---

<h2 id="gene-networks">Mathematical models of gene networks</h2>

This project aims to describe the mathematical model of various gene networks:
  build systems of differential equations that simulate biological systems;
  analyze corresponding dynamical systems;
  find stationary points, limit cycles, and bifurcations;
  develop software for numerical simulations.
The latest work is dedicated to the central regulatory circuit of the morphogenesis system of D. Melanogaster.

I was working on this project with fellows from
  [Sobolev Institute of Mathematics SB RAS](https://en.wikipedia.org/wiki/Sobolev_Institute_of_Mathematics) and
  [Institute of Cytology and Genetics SB RAS](https://www.icgbio.ru/en/).
It was also the primary research topic of my PhD thesis
  "Mathematical and numerical modeling of gene network artificial regulatory circuits."

**Selected publications:**

{{< research-pub "gene-networks" >}}

---

<h2 id="signal-processing">Digital signal processing</h2>

I was working on this project during my
  postdoctoral research fellowship at the
  [Weizmann Institute of Science](https://www.weizmann.ac.il/).

**Publications:**

{{< research-pub "signal-processing" >}}