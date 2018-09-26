---
layout: post
title: "Perfect code and real projects"
date: "2013-08-28"
lang: en
type: post
tags:
- PerfectCode
redirect_from:
- /en/blog/dev/perfect-code-and-real-projects/
- /blog/post/perfect-code-and-real-projects/
---

I’ve got a problem. I am a perfectionist. I like perfect code. This is not only the correct way to develop applications but also the real proficiency. I enjoy reading a good listing not less than reading a good book. Developing architecture of a big project is no simpler than designing architecture of a big building. In case the work is good the result is no less beautiful. I am sometimes fascinated by how elegantly the patterns are entwined in the perfect software system. I am delighted by the attention to details when every method is so simple and understandable that can be a classic sample of the perfect code.
 

But, unfortunately, this splendor is ruined by stern reality and real projects. If we talk about production project, users don’t care how beautiful your code is and how wonderful your architecture is, they care to have a properly working project. But I still think that in any case you need to strive for writing good code, but without getting stuck on this idea. After reading various holy-war discussions related to correct approaches to writing code I noticed a trend: everyone tries to apply the mentioned approaches not to programming in general, but to personal development experience, to their own projects. Many developers don’t understand that good practice is not an absolute rule that should be followed in 100% of scenarios. It’s just an advice on what to do in most cases. You can get a dozen of scenarios where the practice won’t work at all. But it doesn’t mean that the approach is not that good, it’s just used in the wrong environment.
 
There is another problem: some developers are not that good as they think. I often see the following situation: such developer got some idea (without getting deep into details) in the big article about the perfect code and he started to use it everywhere and the developer’s code became even worse. And then I have to listen to: “they read articles about these approaches and then start writing code in this way”. And what if this is not about the articles? If some programmers use good practices inappropriately it doesn’t mean that good development practices shouldn’t be discussed. Willingness to write correct code is good, but it’s necessary to estimate development skills soberly. There are a lot of maneuvers of stunt flying described for pilots. But it doesn’t mean that every newbie pilot should try to do them all in the very first flight. The same thing is for junior programmers: he doesn’t need to use tens of patterns he got to know after reading the book of GoF in his next project.
 
But let’s get back to the discussion of the perfect code. Approach to the correct programming depends on many factors: on purpose, terms, team, etc. I’d like to review several types of projects that have absolutely different purposes. Let’s think to what extent the code should be clear and to what extent the architecture should be elaborated in each case. We will see patterns used in some projects that are inappropriate in other projects. Next time when you got outraged by some advice in a development related article, you should first think what purpose an author had. Maybe this is not advice that is bad, and just your project differs from the author’s one. So, let’s start.
 
## Project size
 
### Small projects

For example, there is one man who develops the project for several days. It is some simple utility that solves a small separate task. Most likely it won’t be actively developed and transformed into something big. You can keep in mind all system elements (and even variables) in such projects. You don’t need sophisticated architecture in this project: if you get a task that can be resolved with a two code lines patch, you better do it. Of course, you can spend two days to develop a complicated architecture that will be convenient to use when new simple tasks arise. But there is a nuance: these simple tasks will hardly appear in such a small project while time has been already spent. In this situation, you don’t need to think about writing the perfect code. You shouldn’t write explicitly bad code as well, just do it right.
 
### Medium size projects

Assume we’ve got a team of 5-6 developers and the project for several months. You can’t dabble here; it’s necessary to think over the system and structure the complete code. It’s better to control the amount of workarounds. Developers can spend some time for initial research, analysis and design, but not too much. It’s good if you manage to create an ideal plan for development of the ideal system by the deadline, but it’s even much better to develop not a very ideal but working system. At worst, if everything goes wrong, it’s not that difficult to re-design the whole architecture by all team members (I had to do it for several times, it’s not that horrible). If this is a custom development project, a customer will pay not for the wonderful code, but for working features implemented in time. Don’t forget about it.
 
### Big projects

And now we have dozens of developers and the project will be developed for several years. And here it’s better to think over the architecture carefully from the very beginning. If there is a need for a workaround then maybe it’s better to re-design the architecture on early stages in the way that new features fit into it seamlessly. Every improper line of code written now will turn into great sufferings in a year or two. Read books about clear coding and correct architecture; they contain much advice that will come in handy. You just need to use it correctly, not everywhere. I like a story from the Martin Fowler’s book: Fowler did some consulting for a company that developed quite a big project. The project code was terrible and Fowler insisted on a slight refactoring. In a couple of days, they managed to get rid of half code without any damage to the system functionality. Programmers were very glad, but executives were not that happy since this work didn’t result in new features. The old code worked and its optimization didn’t seem economically viable. That is why further consulting recommendations were not followed by the executives. They forced sooner development of new features without any additional work on the code. In half a year the project was closed as the code became too complicated to maintain.
 
## Project maintenance
 
### Projects without maintenance

Activity that is well known by various freelancers and outsourcers. After the project is delivered you will never remember all this horror hidden under the car hood. Deep in your mind, you hope that they will just use the project and no one will ever review the source code. And this is an acceptable approach, since we are required to provide a working application, but not the perfect code. In the very beginning of the project you can afford designing architecture, writing correct code. But when there is just two days till the deadline and only half of features are implemented, it’s not about lofty matters. It’s allowed to add any workarounds, infringe all imaginable approaches to good code. And this is ok in this case. I don’t say this is good and don’t guide to make it in this way. But this is normal. Here we talk about programming not as about art, here we talk about the project that should be delivered in time and that won’t be maintained. If you start writing everything ideally, you get a risk to exceed the time frame. You will quit on the customer, won’t get money, loose your time and code won’t be demanded by anyone. You should always remember about the purposes.
 
### Maintained projects

And here I would write the good code, get right architecture and clear code. This is such a wonderful feeling when a customer asks you to add some sophisticated feature and you cope with this task in an hour. And this is because new code can be easily added to the project since it is ideally laid on the existing architecture. It’s so easy to work with the existing code base; the code is understandable and easy-to-orientate. And there is another feeling when a customer asks to add some minor feature (the customer is just absolutely sure this is a minor feature and easy to add) and you look at the classes cacophony, try to estimate how many days you would spend on this minor functionality, but for some reason you don’t even want to touch the keyboard. You can’t even look at this code.
 
## Project publicity
 
### In-house projects

You create a project for you or your team and won’t make it public. In this case you are allowed a lot of things. No one makes you digress from your ideals in software development, but if you want to, you can – there is nothing improper. There is no need to create detailed documentation, you can write comments in your native language (if everyone engaged in the project understands it), and some complicated architectural solutions can be explained to your team members orally. I don’t say that you should certainly do it in this way. But if you are in a hurry some good practices can be ignored.
 
### Public projects

Here is an absolutely different situation. Here you need to document your project properly, so that you don’t get hundreds of questions from your customers every day. And you better write comments in English to make it easy for everyone to understand them. If you have an API, you better think over it; don’t add some interface which will allow you to get all necessary data only if you really need to. Remember that the project belongs not only to you, but also to third party developers. Respect those developers who will work with your code. Write code in the way that won’t make others want to stop you in the dark backstreet and hurt you.
 
## Specific projects
 
### Highload projects
 
Highload is a separate matter. In practice, you have to sacrifice a lot of things including good architecture and understandable code for high productivity. Sometimes you may want to cry when you look at what your cozy project turned to after optimization. But what can you do? Instead, program execution time reduced twice. Sometimes you don’t have a choice.
 
### Projects using third-party libraries
 
When I talk about third-party libraries some my associates start looking at me understandingly. I see in their faces – they suffered in the same way. In real conditions of the big project you will hardly develop absolutely all functionality. There are usually quite common tasks that have been already solved by someone. In this situation it’s reasonable to use a ready-made solution than to reinvent the wheel. This is it, but sometimes it appears that authors of this ready solution are not good programmers. Their project solves its main task, but it’s developed…not really professionally. And integrating it into your project is… not really easy. This circumstance makes you add terrible kludges spoiling your fine architecture. But this is an operational need since it’s not cost-effective to implement this functionality on your own. (I will tell you in secret, several times I couldn’t bear it and developed my own library instead of using the third-party one. But this is an exception, not a rule.)
 
### Project of newbie developers
 
You can often hear that an average developer should know this and that. It’s assumed that a developer knows some programming language (if we talk about OOP-language, he should at least know polymorphism and inheritance), he can understand complex syntax constructions, basic platform mechanisms, he knows common patterns (when he sees a class named Visitor, he will immediately understand the definite system part), he easily reads comments in English and can do much more things. But before becoming an average developer everyone was a newbie developer. And nowadays there are a lot of people who begin to study this science. And this is ok that they don’t know and can’t do a lot of things. This is a usual situation when some novice developers form a team and start developing a project. They learn many new tricks while developing the project. Of course they will do a lot of things in improper way. And you shouldn’t expect the opposite. It would be good if senior colleagues help with different issues: how to re-write code in a better way, what books to read, etc. But you shouldn’t specify the same requirements as to senior staff. Junior developers’ project may have lots of deviation from “how it should be” as they are just studying. Advice and recommendations are good while the requirement to write an ideal architecture from the first time is not that good.
 
## Non-production projects
 
### Demo projects
 
Sometimes I have to create demo projects to show some great features to my associates. It can be language, engine, library or something else they haven’t seen before. As a rule, the project should be detailed and simple with lots of comments. In some cases there are tens of lines of comments for a single line of code and this is ok. You don’t write the perfect code, you just use the code as illustration. At the same time the code can be very bad and execute for too long. It doesn’t matter as we have a different purpose to demonstrate some technology to the public.
 
### Research projects
 
In this project, we don’t show anything to anyone. We want to understand some new interesting feature by ourselves. Let’s say we examine some algorithm. It’s ok to write 10 versions of the algorithm side by side. Probably, versions will be in different languages. It will be ok not to care about the agreement on names (that is good to follow when creating a real project) and to name the same things in the same way – by names set in the book. It doesn’t matter what’s the common practice in this or that language. We examine the algorithm; we don’t care about such things right now. If you are going to show the result to someone else you should work over the code, but this is another story. And while you are on the research stage your main purpose is the research, not the perfect code. Of course, you can combine these things, but this is not obligatory. The main thing is not to substitute the academic purpose with the perfect code purpose.
 
### Local projects
 
Many developers can say that it is necessary to get used to write good code everywhere. But local code has some specific, you don’t need to show it to anyone, you don’t need to report to anyone, you can be guided by your own ideas in development. There can appear a lot of bad intermediate code in the workflow. You can play with the platform, make some experiments. You can develop in the way convenient for you. You can create some data dump regardless of the general architecture and just save it to a local file from the most unacceptable place. It’s possible to write any amount of comments in any language, if this is more convenient for you.
 
But remember that the situation changes when the creative process ends and you need to show the results to others (send local developments to the central repository). You need to clear the code in this case. All the experiments, kludges and excessive comments should be removed. Respect developers who will have to understand your writings.
 
### Prototype projects
 
The main purpose of such projects is to quickly create some features to get the idea how they will look like. This is a reasonable approach. Let’s say we have 5 different implementations: we will chuck together a common concept of each variant. After that you will be able to examine all approaches on live samples and choose the one that will be used in the main project. It’s important to understand prototyping tasks. You don’t need to clear this code, you don’t need to write it ideally. I am always impressed by people who criticize a prototype with the following statements: “this variable could be named in a more understandable manner” or “it would be good to move this interface button 1 pixel to the left”. Does it matter how the variable is named? This is a prototype, back off. Such discussion is reasonable for a finished project, but it has no sense for a prototype.
 
### Entertainment projects
 
I remember that once I and my friends decided to make a birthday present to a good man. We created a Java project which represented in OOP his life, friends and other interesting things he interacts with. The program really worked, it was possible to execute some funny commands from the console. As to the source code, absolutely all names (classes, methods, variables, etc.) were written in Russian (Java allows such tricks). Javadoc was also written in Russian and didn’t contain any useful information. Logic was implemented in the simplest way. We used the simplest algorithms instead of the complicated ones. Architecture wasn’t too pretty; we even didn’t try to think over it.
 
And the present worked out, though we haven’t used any good practice of writing the perfect code. And the matter is in absolutely different purposes of the project.
 
## Summary
 
Once again I would like to draw your attention to main ideas. If you want to become a good programmer, you should develop, learn to write better code, work to improve yourself. You should try to write as clear and good code as possible. But you need to understand that your code will never be ideal in a big project. You shouldn’t admit bad code; write it in the way that you won’t be ashamed of. At the same time don’t forget about the project purpose since in most cases the perfect code is not the purpose, but means to reach it. It’s not necessary to intentionally write bad code, but show no fanaticism about the perfect code as well. Remember about your purposes and situation. It’s not that easy to write good code. Compare your effort spent for code improvement and the result it will get. If you read a good article about the good code, don’t extract separate pieces of advice that you will use everywhere without a second thought. Pay attention to the context of the given advice. Think of the situation described in the article. Think when it’s appropriate to use known patterns and when it’s not. And in general, think more, it’s very useful in programming. And everything will be ok for you.

## Cross-posts

* [blogs.perpetuumsoft.com, Part 1](http://blogs.perpetuumsoft.com/dotnet/perfect-code-and-real-projects-part-1/)
* [blogs.perpetuumsoft.com, Part 2](http://blogs.perpetuumsoft.com/dotnet/perfect-code-and-real-projects-part-2/)