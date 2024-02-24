---
title: "A story about slow NuGet package browsing"
date: "2018-05-08"
tags:
- programming
- NuGet
- Rider
---

In [Rider](https://www.jetbrains.com/rider/), we have integration tests which interact with [api.nuget.org](https://api.nuget.org/).
Also, we have an internal service which monitors the performance of these tests.
Two days ago, I noticed that some of these tests sometimes are running for too long.
For example, `nuget_NuGetTest_shouldUpgradeVersionForDotNetCore` usually takes around `10 sec`.
However, in some cases, it takes around `110 sec`, `210 sec`, or `310 sec`:

{{< img perf-chart >}}

It looks very suspicious and increases the whole test suite duration.
Also, our dashboard with performance degradations contains only such tests
  and some real degradations (which are introduced by the changes in our codebase) can go unnoticed.
So, my colleagues and I decided to investigate it.

<!--more-->

First of all, we decided to look at the logs:

```txt
Information   GET https://api-v2v3search-0.nuget.org/query?q=&skip=0&take=10&prerelease=false&semVerLevel=2.0.0
Information An error was encountered when fetching
  'GET https://api-v2v3search-0.nuget.org/query?q=&skip=0&take=10&prerelease=false&semVerLevel=2.0.0'. The request will now be retried.
The HTTP request to 'GET https://api-v2v3search-0.nuget.org/query?q=&skip=0&take=10&prerelease=false&semVerLevel=2.0.0'
  has timed out after 100000ms.
Information   GET https://api-v2v3search-0.nuget.org/query?q=&skip=0&take=10&prerelease=false&semVerLevel=2.0.0
Information   OK https://api-v2v3search-0.nuget.org/query?q=&skip=0&take=10&prerelease=false&semVerLevel=2.0.0 1090ms
```

In this test, we are trying to get TOP 10 NuGet packages from nuget.org.
The code calls [NuGet.Client API](https://github.com/NuGet/NuGet.Client)
  which [constructs](https://github.com/NuGet/NuGet.Client/blob/release-4.5.0-rtm/src/NuGet.Core/NuGet.Protocol/Resources/RawSearchResourceV3.cs#L40)
  the `https://api-v2v3search-0.nuget.org/query?q=&skip=0&take=10&prerelease=false&semVerLevel=2.0.0` url
  and send a HTTP request.
The server doesn't respond in `100'000ms`, NuGet terminates this request by timeout
  and [retries](https://github.com/NuGet/NuGet.Client/blob/release-4.5.0-rtm/src/NuGet.Core/NuGet.Protocol/HttpSource/HttpRetryHandler.cs#L38) it.

We decided to write a simple small repro based on `HttpClient` which reproduces the issue:

```cs
for (int i = 0; i < 100; i++)
{
    using (var client = new HttpClient { Timeout = TimeSpan.FromSeconds(10000) })
    {
        Console.Write("Request #" + (i + 1).ToString("000") + ": ");
        var sw = Stopwatch.StartNew();
        try
        {
            var r = await client.GetAsync(
                "https://api-v2v3search-0.nuget.org:443/query?q=&skip=0&take=10&prerelease=false&semVerLevel=2.0.0");
            Console.Write("OK");
        }
        catch (Exception e)
        {
            Console.Write("FAIL                 .");
            Console.WriteLine(e);
        }
        sw.Stop();
        Console.WriteLine($" Time: {sw.Elapsed.TotalSeconds:0.000} sec");
    }
}
```

Surprisingly, with `Timeout = TimeSpan.FromSeconds(10000)` almost all of the request are successful.
On Windows, it produces the following distribution:

{{< img stat >}}

It's very important to create a new instance of `HttpClient` for the each iteration: otherwise, the connection will be reused, and we will not get such a picture.

In the picture, we have a multimodal distribution with following levels:

* `~1sec`:
  * `HttpClient` sends a request;
  * request is finished without any problems;
  * we get the list of packages
* `~125sec`:
  * `HttpClient` sends a request;
  * the server terminates the request after 2 minutes;
  * `HttpClient` retries the request;
  * we get the list of packages
* `~250sec`:
  * `HttpClient` sends a request;
  * the server terminates the request after 2 minutes;
  * `HttpClient` retries the request;
  * the server terminates the second request after 2 minutes;
  * `HttpClient` retries the request again;
  * we get the list of packages
* `~375sec`:
  * `HttpClient` sends a request;
  * the server terminates the request after 2 minutes;
  * `HttpClient` retries the request;
  * the server terminates the second request after 2 minutes;
  * `HttpClient` retries the request again;
  * the server terminates the third request after 2 minutes;
  * we **don't** get the list of packages (we get `System.Net.Http.WinHttpException: The connection with the server was terminated abnormally`)

A remark: on my machine, the first attempt uses `TLSv1.2`, the second attempt uses `TLSv1.1`, the third attempt uses `TLSv1`.
A screenshot from [Wireshark](https://www.wireshark.org/) for the `~250sec` case:

{{< img wireshark >}}

We tried it on our local machines and double checked it on an Azure VM:

{{< img azure >}}

This problem affects (sometimes) different IDEs with NuGet Package Manager: it may take up to several minutes before it displays the search results.
That's how it looks in Visual Studio:

{{< img vs >}}

That's how it looks in Visual Studio for Mac:

{{< img vs-for-mac >}}

It's hard to reproduce this issue in [Rider](https://www.jetbrains.com/rider/) because we are [using a persistent local cache of search results](https://aakinshin.net/blog/post/rider-nuget-search/):

{{< img rider >}}

Currently, the problem is reproduced on `api-v2v3search-0.nuget.org` (`52.162.253.198`) and `api-v2v3search-1.nuget.org` (`13.84.46.37`).

Since it's a server-side problem and we can't fix it locally, we created an issue on GitHub: [NuGet/Home#6921](https://github.com/NuGet/Home/issues/6921) (moved to [NuGet/NuGetGallery#5899](https://github.com/NuGet/NuGetGallery/issues/5899)).

**Update.**
A remark about the code snippet.
In the first version of the repro, I used a single `HttpClient` instance for all requests.
In this case, the first request fails in ~30% cases,
  other requests are successful because the connection is already established.
From the practical point of view, it means that user can get hanged NuGet Package Manager in VS only once after startup.
However, in this case, it's hard to investigate the problem because it's very unstable.
Thus, the code snippet creates a new HttpClient instance each time on purpose.
So, it's very easy to reproduce the problem.

**Update 2018-05-11.**
The issue is [fixed](https://github.com/NuGet/NuGetGallery/issues/5899#issuecomment-388222254).
