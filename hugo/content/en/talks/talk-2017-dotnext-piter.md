---
title: "Let's Talk about Memory"
year: 2017
date: 2017-05-19
urls:
- "http://2017.dotnext-piter.ru/en/"
- "http://2017.dotnext-piter.ru/en/talks/lets-talk-about-memory/"
- "https://www.youtube.com/watch?v=XGtieBVI1lk"
- "http://assets.contentful.com/9n3x4rtjlya6/1hZm9cOhysmSOMSkwym64g/b9c20f34548822ac6e907a5c26a4f658/Andrey-Akinshin_Lets-talk-about-memory.pdf"
- "https://www.slideshare.net/AndreyAkinshin/ss-76401745"
- "https://vk.com/album-65845767_244367987"
- "https://jugru.org/"
tags:
- YouTube
date2: 2017-05-20
event: DotNext 2017 Piter
event_hint: Independent .NET conference
event_hint_ru: Конференция .NET-разработчиков
title_ru: Поговорим про память
location: St. Petersburg, Russia
location_ru: г. Санкт-Петербург
language: ru
youtube: XGtieBVI1lk
hasNotes: true
---

The bottleneck of many modern applications is the main memory. In this case, it's very hard to measure the performance and write correct benchmarks: there are too many things which affect the execution time. In this session, we will talk about how it happens. We will discuss low-level hardware stuff (CPU cache and its associativity, alignment, store forwarding, 4K aliasing, prefetching, cache/page splits, cache bank conflicts, and so on) and .NET specific problems (pinned objects, the large object heap, how does the heap works in the full .NET Framework and Mono).
