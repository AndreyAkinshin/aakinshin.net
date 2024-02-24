---
title: "Introducing perfolizer"
date: "2020-03-04"
tags:
- programming
- performance
- perfolizer
---

Over the last 7 years, I've been maintaining [BenchmarkDotNet](https://github.com/dotnet/BenchmarkDotNet);
  it's a library that helps you to transform methods into benchmarks, track their performance, and share reproducible measurement experiments.
Today, BenchmarkDotNet became the most popular .NET library for benchmarking which was adopted by [3500+](https://github.com/dotnet/BenchmarkDotNet#who-use-benchmarkdotnet) projects including .NET Core.

While it has tons of features for benchmarking that allows getting reliable and accurate measurements,
  it has a limited set of features for performance analysis.
And it's a problem for many developers.
Lately, I started to get a lot of emails when people ask me
  "OK, I benchmarked my application and got tons of numbers. What should I do next?"
It's an excellent question that requires special tools.
So, I decided to start another project that focuses specifically on performance analysis.

Meet [perfolizer](https://github.com/AndreyAkinshin/perfolizer) — a toolkit for performance analysis!
The source code is available on [GitHub](https://github.com/AndreyAkinshin/perfolizer) under the MIT license.

{{< img perfolizer >}}

<!--more-->

### What's available right now?

For the first announcement, I added a few algorithms like
  [Changepoint detection](https://github.com/AndreyAkinshin/perfolizer#changepoint-detection),
  [Multimodal-sensitive histograms](https://github.com/AndreyAkinshin/perfolizer#multimodal-sensitive-histograms),
  [Multimodality detection](https://github.com/AndreyAkinshin/perfolizer#multimodality-detection),
  [Range Quantile Queries](https://github.com/AndreyAkinshin/perfolizer#range-quantile-queries),
  [QuickSelectAdaptive](https://github.com/AndreyAkinshin/perfolizer#quickselectadaptive).
Some of them are ported from BenchmarkDotNet; some of them are new.
For example, it has a new `RqqPelt` algorithm that works much better than [EdPelt](https://aakinshin.net/posts/edpelt/) on cases
  with a huge number of changepoints.

It's only the beginning, a lot of additional algorithms are coming.

### What's in the roadmap?

Here are the most important directions of work:

* A scheme for performance history data format
* Reliable approach for writing performance tests that compares the current revision with previous versions ([BenchmarkDotNet#155](https://github.com/dotnet/BenchmarkDotNet/issues/155))
* Out-of-the-box solution that can be integrated with existing CI infrastructures ([BenchmarkDotNet#54](https://github.com/dotnet/BenchmarkDotNet/issues/54))
* A collection of performance analysis guides (approaches, good practices, recommendations, etc.)
* More awesome algorithms for performance analysis

I already have drafts for some of these features; others will be written from scratch.
So, it will take some time, so be patient.

### Why do we need another NuGet package?

The [BenchmarkDotNet NuGet package](https://www.nuget.org/packages/BenchmarkDotNet/) becomes pretty heavy because of the dependencies that are essential for benchmarking.
If you want to just analyze the results, you don't need all the stuff that is required for benchmarking.

### Why it's not a part of BenchmarkDotNet?

Approaches and algorithms for performance analysis are platform-agnostic.
I want to target a wider audience and make perfolizer available for everyone regardless of platform, runtime, or language.
Currently, it's available only as a NuGet package and as a command-line tool (which can be installed via the .NET Core SDK),
  but I want to provide an easy way to integrate it with other technology stacks.

### Feedback is welcome!

It's only the first step toward a decent toolkit for performance analysis.
I will be happy to hear what kind of features you expect to see in the future versions of perfolizer!
