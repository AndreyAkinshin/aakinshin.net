---
title: "Case Study: A City Social Survey"
date: 2024-02-20
tags:
- mathematics
- statistics
- research
- thoughts
---

Imagine a city mayor considering a project offering to build parks in several neighborhoods.
It can be a good budget investment since it can potentially increase the happiness level of the citizens.
However, it is just a hypothesis: if parks do not impact happiness,
  it is worth considering other city renovation projects.
It makes sense to perform a pilot experiment before spending the budget on all the parks.
The mayor is thinking about the following plan:
  pick a random neighborhood,
  survey the citizens to measure their happiness,
  build a park,
  survey the citizens again,
  compare the survey results,
  make a decision about the further parks in other neighborhoods.
Someone is needed to design the survey and draw the conclusion.

Let us explore possible approaches to perform such a study.
These artificial examples are not guidelines
  but rather simplified illustrations of possible mindsets presented as lists of thoughts.
In this demonstration, we mainly focus on the attitude to the research process rather than on the technical details.
All the examples are based on real stories.

<!--more-->

We start with a straightforward approach:

1. Design a survey with a single question:
   "Evaluate your happiness level on a scale from 1 to 1000."
2. Select a random sample of 100 citizens from the target neighborhood.
3. Survey them one month before and one month after the park construction.
4. Calculate the arithmetic means of the happiness level in both surveys.
5. Present the results so that the mayor can decide
     if the "after-park" mean is noticeably higher than the "before-park" mean.
6. Get the paycheque for the excellently performed job.

Now let us expore how we can proceed.

### Technical approach

* The initial plan has a problem: Step 5 involves a subjective decision of the mayor, which can biased.
  The mayor can have an intuition-based personal preference for the desired outcome.
  Even if there is no intention to cheat, the mayor's brain has embedded cognitive bias.
  If the mayor enjoys walking in the parks,
    the difference "before-park: 495; after-park: 505" may be considered as important.
  If the mayor recently heard complaints about the lack of hospitals,
    the difference "before-park: 450; after-park: 550" may lead to a conclusion
    "the impact is not large enough; let us build a hospital instead."  
  Once the mayor gets the survey results and starts thinking about the obtained numbers,
    the decision-making process is compromised!
  To prevent this from happening, a *research protocol* is needed!
  Such a protocol should be designed in advance to avoid the cognitive bias effects.  
  Since the goal is obviously trivial,
    the mayor can just choose the minimum value of the "important" difference in advance (e.g., 50).
  The researcher is appreciated for the valuable scientific advice on psychology
    and for creating an actual research protocol.
* The current procedure does not use statistical methods.
  The classic statistical textbooks claim that a null hypothesis significance test is needed.
  Since the distribution of the happiness levels is most likely normal,
    the Student's t-test is a good choice.  
  This test takes two samples of survey results as input and produces a p-value as output.
  The obtained p-value is supposed to be compared with the predefined significance level.
  The value of 0.05 is the most frequently used option,
    which is time-tested, having proven its reliability over many years.
  If the p-value is less than 0.05, the difference is declared statistically significant,
    and the mayor can continue building the parks.  
  Now, the actual scientific statistical tools are used.
* If the normality assumption is not satisfied, the Student's t-test is not applicable.
  This problem can be solved by using nonparametric statistics.
  In this statistical paradigm, the Mann-Whitney U test is the most popular choice.
  It is not trivial to implement the test by hand,
    but there are existing popular open-source statistical frameworks with ready-to-use implementations.
  The implementations obviously do not have bugs because the frameworks are popular and open-source.
  Indeed, if they had bugs, someone would have already found them, reported them, and fixed them.  
  The idea of using nonparametric statistics is absolutely brilliant
    since it gives additional protection against deviations from normality.
* There is no evaluation of the test power.
  The problem of underpowered research is well-known in the statistical community.
  The power of 80% is the common convention and can be safely used by default.  
  Unfortunately, the function to calculate the power does not take power as one of the parameters.
  The power calculation is not an obvious task to perform.
  Fortunately, it is not actually needed for the current research.
  The sample size of 100 is decently large, and the research is obviously not underpowered.  
  Now, the mayor is confident that the research is powerful enough.
* The current plan focuses on statistical significance rather than on practical significance.
  And the problem is quite practical, so the practical significance is actually needed.  
  Indeed, with such a large sample size, even a small difference can be declared as statistically significant!
  Previously, there was a good idea of introducing a threshold for meaningful differences.
  This idea was lost when the statistical testing was introduced.
  It makes sense to check that the "after-park" average happiness level
    is not just statistically larger than the "before-park" average
    but meaningfully larger.
  The threshold parameter of the Mann-Whitney U test should be changed from 0 to 50.
* The p-value should be banned; the Neyman-Pearson paradigm is outdated.
  Likelihood paradigm should be used!
  The new target statistic is the Bayesian factor, which shows how
    "the true difference is more than 50" is more likely than
    "the true difference is less than 50".
  If it is three times more likely, the park project should be continued.
* The likelihoods are not good enough on their own; Bayesian statistics should be used.
  People like parks, so our priors should be biased towards the positive outcomes.
  Acknowledging the priors allows us to improve the accuracy of the research significantly.
* Bayesian statistics are strange and inconvenient.
  Also, it would be nice to have control over the false-positive rate
    since it is hopefully not the last project in the researcher's career.
  The Nayman-Pearson paradigm is that bad and still can be used.  
  Thanks to the researcher's experience, it was possible not to be fooled by the marginal Bayesian statistics,
    which do not even provide false-positive rate control.
* After the wall, it would still be nice to perform the power analysis.
  It is obvious why the Mann-Whitney U test does not have the power parameter.
  There is a fundamental statistical trade-off between
    the false-positive rate,
    the false-negative rate,
    the effect size,
    and the sample size.
  The sample size is 100, the false-positive rate is 0.05,
    and the effect size is expressed as the difference threshold of 50.
  The power actually defines the false-negative rate, which is the last parameter.
  When three other parameters are fixed, the power is also implicitly fixed.
  However, we can adjust the sample size to achieve the desired power of 80% (and the false-positive rate of 0.20).
  The target sample size can be obtained via numerical simulations.
* The difference threshold of 50 is arbitrary; it should be consciously chosen.
* The power of 80% is also arbitrary; we should somehow justify it.
* The alpha level of 0.05 is too large; we should use 0.01, 0.005, or even 0.001.
* The absolute difference is not appropriate since 50 can be small in comparison to dispersion.
  The Cohen's d should be used as a measure of the effect size.
* Cohen's d is not robust and too sensitive to the outliers.
  Robust effect size alternatives should be considered.
* The power should not be evaluated against a single effect size threshold value.
  The whole power curve should be explored.
* If the samples have equal means but different variances,
  the Mann-Whitney U test is not fully applicable.
  Such a case should be handled.
* If all the people in the "after-park" sample report 1000 as the happiness level,
    the dispersion can be zero, and the effect size is not defined.
  Such a case should be handled.
* The focus should be on estimating the most probable difference value.
  The Hodges-Lehmann location estimator should be used as the natural extension of the Mann-Whitney U test.
* The 95% confidence intervals should be calculated for the Hodges-Lehmann location estimations.
* The 95% is an arbitrary value; the confidence level should be consciously chosen.
* Outliers should be detected and filtered out.
* The Mann-Whitney U test is not correctly implemented.
  The Edgeworth expansion should be used to improve the accuracy instead of the normal approximation.
* The Loefller algorithm should be used to improve the calculation speed.
* It is more reliable to introduce various thresholds for the absolute, relative, and effect size scales.
* ...

### Thinking approach

* Why do we care about the happiness level?
  What are the expected practical outcomes of the increase in happiness level?
  Typically, sincere altruism does not cover 100% of the actual goals.
  Maybe the mayor wants to be reelected next year?
  Then, we should focus on the political views of the citizens rather than on the happiness level.
  What are the formal criteria of the actual state of the city we want to achieve?
* What are the other social renovation projects?
  Why is the focus on the parks only?
  If it is only one of the possible options,
    it is more reasonable to compare all the projects instead of a separate park evaluation.
* Are all the neighborhoods the same?
  Can we actually reuse an experience of one neighborhood for others?
* Are we actually interested in the increase of the "average" happiness level across all the citizens?
  Maybe we should ignore people who are already happy enough and focus only on the unhappy ones.
* What are the other factors that can affect the citizens during the pilot experiment?
* We can't perform such a survey only online: a sample of people who participate in the internet surveys is biased.
  The true park fans should be discovered offline and surveyed in person.
  So, we should hire people who would survey the citizens on the streets.
  What is the budget of the survey, and what is the maximum sample size we can afford?
* ...

These and many other questions are supposed to be clarified before we start designing the research procedure.
Properly described business goals with an available method validation procedure
  make the design stage straightforward and mechanical without chasing the tail.
