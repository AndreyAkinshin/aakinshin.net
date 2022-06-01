---
title: Beeping Busy Beavers and twin prime conjecture
date: 2022-06-01
tags:
- Mathematics
- BusyBeaverology
features:
- math
---

In this post, I use Beeping Busy Beavers to show that twin prime conjecture could be proven or disproven.

<!--more-->

### Busy Beavers

Let's consider a Turing machine $T(n)$ with a two-symbols alphabet, a 2-way infinite tape, and $n$ states.
There are two types of such machines: machines that halt after a finite number of steps
  and machines that never halts (assuming all machines start on all-0 input tape).
Among all $T(n)$ that halts, let's select the one that runs the longest.
Such a machine is known as a *Busy Beaver* (introduced by Tibor Radó in 1962).
The number of steps that the Busy Beaver performs before halting is known as the *Busy Beaver number*
  and it's typically denoted as $\operatorname{BB}(n)$.
This function grows astronomically fast and it could be proven to be uncomputable.
However, we have some manually gathered information about several first Busy Beaver numbers:

| n |                               BB(n) |
|--:|------------------------------------:|
| 1 |                                   1 |
| 2 |                                   6 |
| 3 |                                  21 |
| 4 |                                 107 |
| 5 |                 $\geq 47\,176\,870$ |
| 6 |           $>7.4 \cdot 10^{36\,534}$ |
| 7 | $>10^{10^{10^{10^{18\,705\,352}}}}$ |

*A remark: in May 2022, a set of new estimations for $BB(6)$ was discovered,
  see [Busy Beaver Discuss](https://groups.google.com/g/busy-beaver-discuss) for details.*

Busy Beavers have interesting applications.
For example, let's consider [Goldbach’s Conjecture](https://en.wikipedia.org/wiki/Goldbach%27s_conjecture):
  "Every even natural number greater than two is the sum of two prime numbers"
  (e.g., 8=5+3).
This conjecture was introduced in 1742, and it's still unresolved.
Dozens of famous mathematicians tried to solve it without success.
If we recall
  the [Gödel's incompleteness theorems](https://en.wikipedia.org/wiki/G%C3%B6del%27s_incompleteness_theorems),
  we may think that there is a chance that Goldbach’s Conjecture couldn't be proven or disproven.
This though could be quite disturbing.
Fortunately, Busy Beavers rush to the rescue.
Let's build such a Turing machine that enumerates all the even numbers greater than two,
  check if an enumerated number is a sum of two primes,
  and halts if a counterexample for Goldbach’s Conjecture is found.
There is [such a machine that uses only 27 states](https://gist.github.com/anonymous/a64213f391339236c2fe31f8749a0df6).
Now let's run this machine awhile and see if it halts.
If the number of performed steps exceeds $\operatorname{BB}(27)$,
  it would mean that Goldbach’s Conjecture is true
  (because if it's false, the machine would have halted earlier).
If it halts within less than $\operatorname{BB}(27)$ steps,
  it discovers a counterexample for Goldbach’s Conjecture.
Although this approach is highly impractical ($\operatorname{BB}(27)$ is astronomically large),
  it allows us to prove that it's possible to prove to disprove Goldbach’s Conjecture.
This approach could be applied to other conjectures like
  consistency of [Zermelo–Fraenkel set theory](https://en.wikipedia.org/wiki/Zermelo%E2%80%93Fraenkel_set_theory)
  ([here](https://github.com/sorear/metamath-turing-machines/blob/master/zf2.nql) a 748-state machine is proposed) or
  the [Riemann Hypothesis](https://en.wikipedia.org/wiki/Riemann_hypothesis)
  ([here](https://github.com/sorear/metamath-turing-machines/blob/master/riemann-matiyasevich-aaronson.nql)
  a 744-state machine is proposed).

If you want to learn more about Busy Beavers, I highly recommend the following resources:

* [The Busy Beaver Frontier](https://www.scottaaronson.com/papers/bb.pdf) by Scott Aaronson (2020)
* [Historical survey of Busy Beavers](https://webusers.imj-prg.fr/~pascal.michel/ha.html) by Pascal Michel
* [The Busy Beaver Competitions](https://webusers.imj-prg.fr/~pascal.michel/bbc.html) by Pascal Michel
* [Busy Beaver Discussions on Google Groups](https://groups.google.com/g/busy-beaver-discuss)
* [The Busy Beaver Challenge](https://bbchallenge.org/)

### Beeping Busy Beavers

In [The Busy Beaver Frontier](https://www.scottaaronson.com/papers/bb.pdf),
  Scott Aaronson introduced a concept of a Beeping Busy Beaver.
He suggested that we can denote one of the Turing machine states as a "beeping state"
  (whenever a machine reaches this state, it beeps without halting).
Among all the machines $T(n)$ that beep a finite number of times,
  let's choose the one that runs the longest until the final beep is reached.
Such a machine is known as a *Beeping Busy Beaver*.
The number of steps that should be taken until the final beep happens is known as a
  *Beeping Busy Beaver number* as denoted as $\operatorname{BBB}(n)$.
$\operatorname{BBB}(n)$ is more uncomputable than $\operatorname{BB}(n)$
  and it grows much faster.
Here are estimations for several first values:

| n |                   BB(n) |
|--:|------------------------:|
| 1 |                       1 |
| 2 |                       6 |
| 3 |               $\geq 55$ |
| 4 |     $\geq 32\,779\,478$ |
| 5 | $\geq 10^{10^{286\,574}}$ |

If you want to learn more about Beeping Busy Beavers, I highly recommend the following resources:

* [Nick Drozd's blog](https://nickdrozd.github.io/)
* [Shawn Ligocki's blog](https://www.sligocki.com/)
* [Busy Beaver Discussions on Google Groups](https://groups.google.com/g/busy-beaver-discuss)

### Beeping Busy Beavers and the twin prime conjecture

The classic Busy Beavers works great for conjectures
  that could be disproved using a counterexample among a countable number of objects
  like Goldbach’s Conjecture.
For such conjectures, we can always build a Turing machine that enumerates all the objects
  and halts once a counterexample is found.
It provides a way to show that a conjecture could be proven or disproven.
However, this approach doesn't work for conjectures that state
  that there is an infinite number of objects with a given computable property among a countable set.

A classic example of such a conjecture is the twin prime conjecture.
It states that there are infinitely many twin primes
  which are pairs of prime numbers with a difference between them that equals two
  (e.g., $(5, 7)$ or $(11, 13)$).
Recently, I came up with an idea of how to apply Beeping Busy Beavers for such problems.

Let's consider a Turing machine that enumerates all the natural numbers $x$
  and check if $(x, x+2)$ is a twin prime pair.
Once such a pair is found, the machine beeps.
It never halts: it runs forever and enumerates all possible natural numbers.
Obviously, such a machine could be easily built.
Let's denote it as $T_1$.
We also denote the number of $T_1$ states as $n_1$.

Now let's start this machine, make a cup of tea, and wait until $T_1$ is performed $\operatorname{BBB}(n_1)$ steps.
We assume that at this moment, we enumerated $m_1$ natural numbers.
If the twin prime conjecture is false, $T_1$ should beep a finite number of times;
  the last beep should happen before the step number $\operatorname{BBB}(n_1)$ is reached.
If we continue executing this machine after $\operatorname{BBB}(n_1)$ steps and observe at least one beep,
  it would mean that it beeps forever and the twin prime conjecture is true.
Thus, we showed that if there is a single twin prime pair greater than $m_1$,
  there is an infinite number of twin prime pairs.
Again, this approach is quite impractical because the universe would probably collapse
  before we perform $\operatorname{BBB}(n_1)$ steps,
  but it gives us an idea of the upper bound for the largest twin prime pair assuming
  that twin prime conjecture is false.

Next, we build another Turing machine $T_2$ with $n_2$ states
  that enumerates all the natural numbers $x$ starting from $m_1$
  and halts if $(x, x+2)$ is a twin prime pair.
Let's make another cup of tea, run $T_2$ and wait for $\operatorname{BB}(n_2)$ steps.
If $T_2$ halts at some moment, it would mean that we discovered a twin prime pair that is greater than $m_1$
  and twin prime conjecture is true.
If $T_2$ doesn't halt within $\operatorname{BB}(n_2)$ steps, it would mean that it never halts.
In other words, there are no twin prime pairs greater than $m_1$ and
  the twin prime conjecture is false.

Thus, we showed that there is a way to prove or disprove twin prime conjecture using Beeping Busy Beavers
  and $\operatorname{BBB}(n_1)+\operatorname{BB}(n_2)$ simulation steps.
Although, I really hope that there is a faster way to do it.

### Discussion

I'm not sure that the presented result is novel, but I failed to find it anywhere on the Internet.
If you know of any papers that describe a similar idea, please let me know.
Any feedback is welcome!

The described approach could be also applied to any conjecture that states that
  there is an infinite number of objects with a given computable property among a countable set.
