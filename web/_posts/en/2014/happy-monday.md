---
layout: post
title: "Happy Monday!"
date: "2014-08-11"
lang: en
type: post
tags:
- Bugs
- ".NET"
- Hate
- PostSharp
redirect_from:
- /en/blog/dotnet/happy-monday/
- /blog/post/happy-monday/
---

Today I tell you a story about one tricky bug. The bug is a tricky one because it doesn't allow me to debug my application on Mondays. I'm serious right now: the debug mode doesn't work every Monday. Furthermore, the bug literally tell me: "Happy Monday!". 

So, the story. It was a wonderful Sunday evening, no signs of trouble. We planned to release a new version of our software (a minor one, but it includes some useful features). Midnight on the clock. Suddenly, I came up with the idea that we have a minor bug that should be fixed. It requires a few lines of code and 10 minutes to do it. And I decided to write needed logic before I go to sleep. I open VisualStudio, lunch build, and wait. But something goes wrong, because I get the following error:

```
Error connecting to the pipe server.
```

Hmm. It is a strange error. <!--more--> Furthermore, it doesn't allow to build my project without any additional information. I don't know neither location nor cause of the error. Maybe some of my local files were spoiled? Let's run `git clean -f -x -d` and build it again! The result:

```
Error connecting to the pipe server.
```

Hmm. Maybe there are some bad changes in the last commit? I checkout to the previous commit, then to the next one, then to the next one. Then I checkout to a super stable commit (I'm 100% sure that it would work). Aaand the result:

```
Error connecting to the pipe server.
```

Hmm. Maybe there are some bad changes in my environment? I reboot my laptop, build the project. The result:

```
Error connecting to the pipe server.
```

Hmm. Maybe there some critical bad changes in my environment? I take another laptop, clone the repository, build the project. The result:

```
Error connecting to the pipe server.
```

4am on the clock. I still can't build my project. I try every idea I have, but nothing helps. Accidentally, I change build configuration from Debug to Release, and a miracle happened: the build is completed successfully. I try to switch to debug and the see familiar error:

```
Error connecting to the pipe server.
```

What the.. The situation makes me angry. I open a console, run MSBuild, and start to read a very big log. And I find some remarkable lines in the middle of the log:

```
Starting the pipe server: "C:\ProgramData\PostSharp\3.1.28\bin.Release\postsharp.srv.4.0-x86.exe /tp "postsharp-S-1-5-21-1801181006-371574121-2664876850-1002-4.0-x86-release-3.1.28-a4c26157a4624bb9" /config "C:\ProgramData\PostSharp\3.1.28\bin.Release\postsharp.srv.4.0-x86.exe.config"".
  : info : Executing PostSharp 3.1 [3.1.28.0, 32 bit, CLR 4.5, Release]
  : message : Happy Monday! As every Monday, you're getting all the features of the PostSharp Ultimate for free.
  : message : PostSharp 3.1 [3.1.28.0, 32 bit, CLR 4.5, Release] complete -- 0 errors, 0 warnings, processed in 102 ms
```

What a twist! [PostSharp](http://www.postsharp.net/) decided to wish my a happy Monday and give an access to all the features of the ultimate edition. But this wish broke my build. We didn't use PostSharp in the Release mode, and bug happens only in the Debug mode.

If you google troubles with PostSharp, you can also find a lot of interesting stories (e.g. [Critical Defect in PostSharp 3.1](http://www.postsharp.net/blog/post/URGENT-ACTION-REQUIRED-Critical-Defect-in-PostSharp-31-process-exits-with-code-199), [«PostSharp bugs that occur only on a Monday? Really? :(»](https://plus.google.com/113181962167438638669/posts/QF5pDB4XY6F). Fortunately, there is no such bug in the latest version of PostSharp. v3.1.48 still with me a happy Monday, but it doesn't broke the "pipe server".

It was a valuable lesson for me, and I hope you also find this story enlightening.