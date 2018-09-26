---
layout: post
title: "To Add Comments or Not to Add?"
date: "2013-08-28"
lang: en
type: post
tags:
- PerfectCode
redirect_from:
- /en/blog/dev/comments/
- /blog/post/comments
---

*A really good comment is the one you managed to avoid. (c) Uncle Bob*

Lately, I’ve been feeling really tired of hot discussions on if it’s necessary to add comments in the code. As a rule, there are self-confident juniors with the indisputable statement as: “Why not to comment it, it will be unreadable without the comments!” on one side. And experienced seniors are on the other side. They understand that if it’s possible to go without the comments than “You better, damn it, do it in this way!” Probably, many developers got comment cravings since they’ve been students when professors made them comment every code line, “to make the student better understand it”. Real projects shouldn’t contain a lot of comments that only spoil the code. I don’t agitate for avoiding comments at all, but if you managed to write the code that doesn’t need comments, you can consider it your small victory. I would like to refer you to some good books that helped form my position. I like and respect these authors and completely share their opinion.

* [Steven C. McConnell, Code Complete](http://www.amazon.com/Code-Complete-Practical-Handbook-Construction/dp/0735619670)
* [Robert Martin, Clean Code: A Handbook of Agile Software Craftsmanship](http://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
* [Dustin Boswell, Trevor Foucher, The Art of Readable Code (Theory in Practice)](http://www.amazon.com/The-Readable-Code-Theory-Practice/dp/0596802293)

<!--more-->

So, what makes me mad about the comments? Here are some main statements:

* Comments spoil the code itself, make it less readable;
* Comments require time for writing and maintenance;
* Comments lie (starting from the improperly composed comments and ending with the obsolete ones)

Basically, I agree that in some cases the comments are necessary. But the less such cases exist the more beautiful your code is. Besides, writing a good comment is the art as well. Unfortunately, just few developers have that skill, the rest of them write the comments anyhow. The benefit of such commenting is quite doubtful. Isn’t it better not to spend time and effort for writing a good comment but to spend it for re-writing the code in the way it could go without any comments?
 
Let’s discuss some typical scenarios and define to what extent the comment is necessary. I provide C# code, but this is not that critical for this article.
 
## When you can go without the comments
 
### Comments that repeat code
 
Let’s have a look at the following code:

```cs
// This method is responsible for calculating array elements sum
// The method receives elements array at the input
public int CalcSumOfElement(int[] elements)
{
  int result = 0; // Creating a special variable for the result
  int n = elements.Length; // Defining array length, i.e. number of elements
  for (int i = 0; i < n; i++) // Running cycle for all elements
    result += elements[i]; // Adding an element to the result
  return result; // Returning the result
}
```
 
Of course, this sample is fake, but unfortunately, I don’t overdo. I saw such code quite often. In this sample, the comments don’t provide any new information; everything can be understood from code. And reading this code without the comments would be much easier. I don’t even say about maintenance of such code: it’s quite tiresome to support this level of commenting. Most likely, when the code becomes more sophisticated half of code won’t have comments, the rest of code will include obsolete comments.
 
### Comments explaining syntax
 
Here is the sample:
 
```cs
public class Item
{
  private int value; // This is a private field, it’s not available from outside

  // This is a constructor
  public Item(int twoValue)
  {
    value = twoValue >> 1; // Two characters don’t mean bitwise sift to the right
    // so, we divide the value in two
  }
}
```
 
If this is a laboratory research of a fresher, it’s ok. But if this is the production code and your developers need such comments, I’ve got bad news for you. Probably, this article is not for you.
 
### Comments explaining standard classes
 
```cs
HashSet set; // This is data structure called Hash-Set
// It represents a set of elements
// We can easily find out if an element is included in this set
// More information on hash-tables can be found in wikipedia:
// http://ru.wikipedia.org/wiki
// /%D0%A5%D0%B5%D1%88-%D1%82%D0%B0%D0%B1%D0%BB%D0%B8%D1%86%D0%B0
```
 
If a programmer really doesn’t know designation of some standard class or method, he can always use Google search / read documentation / ask an associate. Most good developers already know it. That’s why I strongly doubt usefulness of such comments.
 
### Comments explaining improper names

```cs
// Setting up server connection
public void DoIt()
```
 
I agree that it’s not always possible to name a class/method/property/variable properly. And if the project deadline is yesterday, there is no time to think over good names. Let’s take some arbitrary name and explain what’s happening in the comments. This is much easier and quicker! Or you will spare a minute or two to give an understandable name?
 
### Comments explaining a paragraph
 
I often hear the following phrases: “This method is 300 lines, it does lots of things. You can’t understand it without the comments. I will comment every 10 lines”. If this is the case, you, probably, do something wrong. May be it’s better to divide this big 300-lines method into several smaller methods. And give an understandable name to every small method. In this way you won’t need the comments.
 
### Comments explaining constants
 
```cs
public int GetSeconds(int hours)
{
  return hours * 3600; // 3600 – this is amount of seconds forming an hour
}
```

In this variant, availability of the comment is a more adequate variant that just a figure added to the code and meaning something. But it’s even better to create a named constant which name made everything understandable.

For example, in this way:

```cs
private const int SecondsInHour = 3600;
public int GetSeconds(int hours)
{
  return hours * SecondsInHour;
}
```
 
### Comments not related to programming
 
I like a story from “Code Complete” about how a developer tried to understand the following comment for the whole night:

```asm
MOV AX, 723h ; R. I. P. L. V. В.
```

Some months later he met the author of this code and learnt that the comment meant the following: «Rest in peace, Ludwig van Beethoven» as 723 is a hexadecimal view of the year of Beethoven’s death. Unfortunately, some programmers think that the code is some kind of a forum where they can communicate. Some of them try to be witty (nearly telling funny stories), others tell something about themselves (for example, “It’s 3.00am right now and I am still writing this class as I am fond of programming”). You don’t do it in this way; there are hundreds of other communication means. If the comment is included in the project it should add some value to this project.

### Comments containing thoughts

It happens that a comment contains some smart ideas that are very useful. But very often this is not the case:

```cs
public void Main()
{
  // Well, this is a very useful method
  // It executes main logic of this class.
  // At first I wanted to name it Run.
  // But then I thought that Run means “to go quickly”.
  // And this method doesn’t run, it’s very slow.
  // I was thinking about it when washing the dishes.
  // And when I finished washing the dishes and got back to my computer I renamed the method to Main.
  // This is the main method of this class, let it be Main.
}
```

### Comments containing use cases

Sometimes an author of the method is not sure that everybody will correctly understand how to use his method. And he gives use cases that demonstrate what the method gets with the definite data:

```cs
// Sum(1, 2) == 3
// Sum(2, 1) == 3
// Sum(2, 2) == 4
public int Sum(int a, int b)
```

I think that every task should have its own tool. And unit tests were created for this exact purpose. This is a very smart thing. Necessity of unit tests is a debatable topic as well. But if you need to describe samples of the returned results for the method, why not to do a corresponding unit test?

### Comments containing code history

Luckily, I haven’t seen such comments for quite a long time. But sometimes I have to review the following comments: // 11.06.13: Fixed a bug in the method. Previously it worked in the following way, now it works in this way. // 12.06.13: Oops, that bug wasn’t a bug at all. Got everything back. I will repeat once again: there is a separate tool for every task. Source control systems are able to store change history. You don’t need to overload source code with unnecessary history of how the code was written. If anyone gets interested in it, he can always review it in the repository.

### Comments containing code

Such comments make me especially sad. Let’s say you are reviewing the code of some good class and subbenly you see:

```cs
// int number = GetNumber()
// int number = 4;
// int number = 5;
int number = 4;
// double number = 4.5;
// decimal number = 4.5;
// string number = "This number";
```

What did author want to say in this comment? Some developers want to say: “I am making some experiments changing the code, but I don’t want to lose old versions of this code in case I will need to get back to them”. This phrase reminds us of the idea to use repository for this purpose, since it can store intermediate versions of your code and they won’t get lost. Take pity on the developers who will read your code. And the worst thing is that this code will stay in the project for a long time. The author just forgets to delete bad code version after a number of experiments. His associates are afraid to thoughtlessly delete the code which designation is unclear: “I will delete the thing and then it will occur that it was absolutely necessary.There was a great idea and I spoiled everything”.

### Incomprehensible comments

```cs
bool flagA = true;
bool flagB = false;
bool flagC = true;
if (Condition(flagA, flagB, flagC))
  Foo();
// else checkbox true, turn off server
```

In such cases you can’t guess what an author wanted to say. What checkbox is true? Is it always set to true in the else-branch? Or is it necessary to add some code that will set the checkbox to true? What is the server? Why is it turned off? Will it turn off automatically? Or do we need to do it manually?

Such comments are likely to do more harm, than good. It doesn’t contain any useful information and just confuses the reader. Don’t confuse your readers! Or don’t write anything at all. Or spend a little more time to write a message everyone will understand.

### Comments containing too much text

Some commenters are afraid of being misunderstood. Or to provide too little information. That is why a comment for a three-lines method can take several screens. In this extensive essay, you will read about the used algorithms, their temporary complexity, see pseudo-code of the method, diagram in ASCII graphics, variable names rationale, some general ideas. And everything will be given in so many details to make even a first-grader understand it.

This is a bad approach. It makes a reader spend much time to review your essay. If you decide to insert a comment take care about its laconism (of course, without prejudice to its readability and information value).

### Comments that lie

```
// two figures product
public int Sum(int a, int b)
```

Again, you confuse your reader. What happens here? Probably, sometimes the method got a product and then it was converted to sum and the comment became obsolete. Or vice-versa, the comment was updated, but method name got out of attention. And may be the method got sum from the very beginning and a programmer just made a mistake while inserting a comment. The method can be very complicated and it can take much time to understand which one of the turtles lie.

## When you can insert a comment

### Comments that add abstraction level

Domain scope can be very complicated. It’s not always possible to get simple and clear names for the classes that will immediately indicate the things they correspond to. That is why it’s ok to set some concise term to denote a complicated domain. Main team developers know it by heart. And it is good to insert a laconic comment for new team members that will explain everything.

### Comments that explain unexplainable

It’s a pity, but sometimes you can’t write the code that is understandable as it is. Probably, some sophisticated algorithm is used. Or a coming deadline made you write a quick but not readable code. May be you need to deliver the project yesterday and have no time to put it in order. It doesn’t matter how the unreadable code got in your project. If it becomes more understandable, let the comment be added in the code.

### TODO comments

The issue is disputable as well. Someone can say that there is an Issue Tracker, let’s store all tasks in it. Others can say that there is no need to generate lots of small issues when it’s possible to insert special comments that will attract developers’ attention to the fact that some functionality needs to be added. It’s good that today’s IDE’s can search for TODO comments and output them as a big fine list, so you won’t worry the instructions will be lost. It’s just necessary to agree within a team on what methodology will be used. Many programmers think that TODO comments are very convenient and there is no harm to use them.

### Comments that attract attention

Sometimes there appear some important things in the code which you want your reader to pay attention to. But it’s impossible to do with the code means. For example, you need to warn a reader that the method executes for a long time. Or the class is being developed and refactored by several people, it contains some bad piece of code that needs to be deleted or revised. But you better don’t do it since it’s very important and everything will fail without it. In general, if there are some important but not obvious aspects of your code, you can add a comment, it won’t be excessive.

### Comments that documentation

Many developers generate documentation based on the specific comments (such approach is used in many languages). There are other means to create documentation without the comments. But depending on some circumstances it’s a concept to use the comments for documenting, you can’t do anything with it. Here we talk about a public API, not about a private method in the in-house project. The team should agree on when and where this approach to documenting will be used. Time is priceless; don’t spend it for generating documentation that no one will read.

### Comments containing legal information

Some projects require adding a header-comment with license or copyright information in every file. No discussions in this case.

## Summary
 
I would like to focus on the main idea: though I insist on reduction of the comments number, it doesn’t mean that comments are evil incarnate that shouldn’t appear in the project. If you can justify the availability of a comment in this code snippet, if you really can’t avoid it, if you can compose it correctly and laconically – you’re welcome to insert a comment since it makes the source code more informative. Unfortunately, most comments don’t provide much benefit and just spoil the code. If you are about to write another wonderful comment, give yourself some more time to think if the comment is really wonderful, can’t you go without it?

I also would like to note that, in real life, many things depend on the programming language, on IDE, on team agreements. Probably, in your definite situation it’s necessary to insert a lot of comments (it can be a complicated algorithm, low-level code, sophisticated optimizations, etc.). May be you are writing local code at the moment and comments make it more convenient to work with the code (though nobody makes you commit comments to the repository). It may occur that your project is 100 lines of code and it’s easier to add some comments than to create a complicated extensible architecture. In this article, I offered some general recommendations for a big project in a high-level language. These recommendations can save you and your associates from unnecessary headache. Just don’t consider the suggested practices as the absolute rules. You need to get the situation: is it appropriate to add a comment? Is it necessary here? Or it’s better to go without it? Just try to pay more attention to such things and your project will be better.

## Cross-posts

* [blogs.perpetuumsoft.com, Part 1](http://blogs.perpetuumsoft.com/dotnet/to-add-comments-or-not-to-add/)
* [blogs.perpetuumsoft.com, Part 2](http://blogs.perpetuumsoft.com/dotnet/to-add-comments-or-not-to-add-part-2/)