---
layout: post
title: "65535 interfaces ought to be enough for anybody"
date: "2017-02-14"
lang: en
type: post
tags:
- .NET
- Rider
- Bugs
- Mono
redirect_from:
- /en/blog/dotnet/mono-and-65535interfaces/
- /blog/post/mono-and-65535interfaces/
---

It was a bright, sunny morning.
There were no signs of trouble.
I came to work, opened Slack, and received many messages from my coworkers about failed tests.

<div class="mx-auto">
  <img class="mx-auto d-block" width="800" src="/img/posts/dotnet/mono-and-65535interfaces/front.png" />
</div>

After a few hours of investigation, the situation became clear:
* I'm responsible for the unit tests subsystem in [Rider](https://www.jetbrains.com/rider/), and only tests from this subsystem were failing.
* I didn't commit anything to the subsystem for a week because I worked with a local branch.
Other developers also didn't touch this code.
* The unit tests subsystem is completely independent.
It's hard to imagine a situation when only the corresponded tests would fail, thousands of other tests pass, and there are no changes in the source code.
* `git blame` helped to find the "bad commit": it didn't include anything suspicious, only a few additional classes in other subsystems.
* Only tests on Linux and MacOS were red.
On Windows, everything was ok.
* Stacktraces in failed tests were completely random.
We had a new stack trace in each test from different subsystems.
There was no connection between these stack traces, unit tests source code, and the changes in the "bad commit."
There was no clue where we should look for a problem.

So, what was special about this "bad commit"? Spoiler: after these changes, we sometimes have more than 65535 interface implementations at runtime.

<!--more-->

### Going back to 2005
Do you remember these days?
It was time of the
  [.NET Framework 1.1](https://en.wikipedia.org/wiki/.NET_Framework_version_history#.NET_Framework_1.1),
  [C# 1.2](https://msdn.microsoft.com/en-us/library/aa289527(v=vs.71).aspx), and
  [Mono 1.1.3](http://www.mono-project.com/docs/about-mono/releases/1.1.3/).
Yes, Mono already existed, but no one ran huge applications on it.
So, it seemed ok [to use](https://github.com/mono/mono/commit/4e68cba74f65110cf894867c43754f9655bac297) 16-bit integer type `guint16` for `interface_id`.
Indeed, who needs more than 65535 interfaces?

<div class="mx-auto">
  <img class="mx-auto d-block" width="800" src="/img/posts/dotnet/mono-and-65535interfaces/commit2005.png" />
</div>

### Present day
Rider uses the [ReSharper](https://www.jetbrains.com/resharper/) codebase which is really big.
Of course, we have many generic classes.
A short fact about .NET: if you have an interface `IFoo<T>`, the runtime generates a separate method table per each `IFoo<int>`, `IFoo<double>`, `IFoo<bool>`, and so on.
A short fact about the unit tests subsystem in ReSharper: it uses *a lot* of generic classes (especially in the tests for unit tests).

On Windows, everything worked fine because Rider uses the full .NET Framework which doesn't have such limitation on the number of interfaces.
On Linux and MacOS, we use Mono as a runtime.
And tests were failing because we have too many interfaces!
It took a week of debugging to find the problem, but we finally did it.

We found a report in the Mono bug tracking system: [bugzilla.xamarin#10784](https://bugzilla.xamarin.com/show_bug.cgi?id=10784) (2013-02-28).
We also found a [pull request](https://github.com/mono/mono/pull/2408) (2016-01-08) which should solve this problem.
Unfortunately, it was unmerged without any progress.
A [friendly reminder](https://github.com/mono/mono/pull/2408#issuecomment-255080892) (2016-10-20) helped, and it was eventually [merged](https://github.com/mono/mono/pull/2408#event-850109553) into master (2016-11-07).

This fix is not a part of the latest stable mono yet.
Fortunately, Rider uses its own Mono fork.
So, we just cherry-picked this commit, and now all of our tests are green again.

### Links
* [bugzilla.xamarin#10784: Too many classes implementing an interface? Assertion at class.c:2586, condition `iid <= 65535' not met](https://bugzilla.xamarin.com/show_bug.cgi?id=10784)
* [mono/mono#2408: Enhance maximum number of supported interfaces from 2^16](https://github.com/mono/mono/pull/2408)
* [mono/mono/4e68cba: class.c, object.c, class-internals.h, marshal.c: rearrange some fields and tweak some types to lower memory usage](https://github.com/mono/mono/commit/4e68cba74f65110cf894867c43754f9655bac297)