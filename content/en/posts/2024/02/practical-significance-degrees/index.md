---
title: Degrees of practical significance
date: 2024-02-06
tags:
- mathematics
- statistics
- research
- thoughts
features:
- math
---

Let's say we have two data samples, and we want to check if there is a difference between them.
If we are talking about any kind of difference, the answer is most probably yes.
It's highly unlikely that two random samples are identical.
Even if they are, there are still chances that we observe such a situation by accident,
  and there is a difference in the underlying distributions.
Therefore, the discussion about the existence of any kind of difference is not meaningful.

To make more meaningful insights, researchers often talk about statistical significance.
The approach can also be misleading.
If the sample size is large enough, we are almost always able to detect even a neglectable difference
  and obtain a statistically significant result for any pair of distributions.
On the other hand, a huge difference can be declared insignificant if the sample size is small.
While the concept is interesting and well-researched, it rarely matches the actual research goal.
I strongly believe that we should *not* test for the nil hypothesis (checking if the true difference is *exactly* zero).

Here, we can switch from statistical significance to practical significance.
We are supposed to define a threshold (e.g., in terms of minimum effect size)
  for the difference that is meaningful for the research.
This approach has more chances to be aligned with the research goals.
However, it is also not always satisfying enough.
We should keep in mind that hypothesis testing often arises in the context of decision-making problems.
In some cases, we can do exploration research in which we just want to have a better understanding of the world.
However, in most cases, we do not perform calculations just because we are curious;
  we often want to make a decision based on the results.
And this is the most crucial moment.
It should always be the starting point in any research project.
First of all, we should clearly describe the possible decisions and their preconditions.
When we start doing that, we can discover that not all the practically significant outcomes are equally significant.
If different practically significant results may lead to different decisions,
  we should define the proper classification in advance during the research design stage.
The dichotomy of "practically significant" vs. "not practically significant"
  may conceal important problem aspects and lead to a wrong decision.

In this post, I would like to discuss the degrees of practical significance and
  show an example of how important it is for some problems.

<!--more-->

My primary research field is the software performance measurements.
Let us say we develop an application, and one of its crucial features is performance.
The customers pay for the application mainly because it's blazingly fast.
If we deteriorate the performance, the customers will be dissatisfied and may go away to our competitors.
Therefore, we care about performance,
  and we set up performance testing that automatically detects performance degradation.
A reliable performance testing system is extremely tricky to implement,
  but we should keep in mind that it is only half of the job.
Let us say we have confidently detected a performance degradation, what should we do next?

First of all, we should understand the reference baseline.
Let us say that the current version of the application takes ≈1.0..1.5 seconds to start.
Now, a developer has implemented a new cool feature,
  and the performance tests were able to detect an actual 3ms startup time degradation.
What should we do about it?
We may say that 3ms is a negligible degradation and we can silently ignore it.
Yeah, such small degradations may sum up and lead to a noticeable performance drop in the long run,
  but it is better to handle such problems with another workflow.
For example, we can introduce a systematic monthly check of the overall performance
  and start an optimization campaign if we observe an unacceptable performance drop.
But if we block any 3ms degradation, we can significantly slow down the development process.
Developers write new code, this code takes time, and we should expect occasional performance erosion.

Now, let us say that the degradation is about 50ms.
In this case, it's much more noticeable for the given ≈1.0..1.5 seconds baseline.
Still, it can be OK to merge such a change, but we may want to be aware of such a change.
Therefore, we can automatically accept the change, but we should notify the developer about the performance degradation.
Yes, we slow down the application, but at least we are aware of it, and we make a conscious decision.

Now, let us say that the degradation is about 2 seconds.
In this case, it's a huge degradation.
It feels reasonable to not just send an alert about it but also to automatically block the merge,
  so that it's physically impossible to accidentally introduce such a regression.
To make things more interesting, let us say that it is a security patch for a zero-day vulnerability.
If we treat security seriously, we may want to accept the patch despite the performance degradation.
This leads us to the idea that we need a way to work around the merge block and explicitly say
  "Yes, we are aware of the degradation, but we consciously accept it."

Now, let us say that the degradation is about 5 hours.
Such a change in startup time (from 1 second to 5 hours) makes the application unusable.
It's irrelevant how important the patch is; the majority of the customers will not wait for 5 hours.
We must find other ways to handle the underlying issue; the degradation of such magnitude is unacceptable.

All the above threshold values are arbitrary, and they are presented for the sake of the example.
However, it gives the idea of various possible decisions based on the degradation magnitude:

* Allow merge; silent ignore
* Allow merge; send an alert
* Block merge; provide an option to bypass it
* Block merge; no way to bypass it

While all of the above degradation may be both statistically and practically significant,
  we should consider different decision-making strategies for different situations.

In other problems, we may consider another classification of degrees of practical significance.
My main idea is that we should first focus on what we are going to do with the research outcome.
We should design a proper research protocol in advance,
  and only after that we can discuss possible approaches for statistical analysis.
Without a clear understanding of the goals,
  we don't have a validation procedure that helps evaluate possible analysis approaches.
If you observe a long discussion on topics like
  "Should we use the Bayesian or frequentist approach?",
  "Should we use the significance level of 0.05 or 0.01?",
  or "Should we calculate the confidence interval with confidence level of 95% or 99%?",
  it is most likely a sign of the absence of clear research goals.
When the goals are properly defined, all of these disputes can often be easily resolved:
  we should just check which approach is more aligned with the goals.
Ideally, it should be a mechanical procedure that does not require a subjective opinion.
If one experiences troubles with such a decision, one should probably take another look at the goals.

Sometimes, it can be quite challenging to define the goals properly.
Reflecting on degrees of practical significance can help to adjust the focus of attention
  and find places for possible improvements.
