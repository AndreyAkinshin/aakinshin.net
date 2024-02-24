---
title: "Hunter: Using Change Point Detection to Hunt for Performance Regressions"
year: 2023
doi: 10.1145/3578244.3583719
arxiv: 2301.03034
urls:
- "http://dx.doi.org/10.1145/3578244.3583719"
authors:
- Matt Fleming
- Piotr Kolaczkowski
- Ishita Kumar
- Shaunak Das
- Sean McCarthy
- Pushkala Pattabhiraman
- Henrik Ingo
tags:
- Change Point Detection
hasNotes: true
---

The authors present an open-source framework {{< link github-hunter >}} for automatic change point detection.

Notes:

* {{< rating 2 >}} Assumes normality + Student’s t-test
  * Haven't performed own experiments yet, but expect poor accuracy and alpha in multimodal cases
  * Presented data samples in Figure 2 do not have any unpleasant deviations
  * In {{< link a4192cbd-ee25-4d65-a58c-b300885d098a >}}, the authors admit issues on untuned hardware
* Comparison only with PELT and DYNP, no mentions of ED-PELT (see {{< link "haynes2016" >}})


## Reference

> <i>Matt Fleming, Piotr Kolaczkowski, Ishita Kumar, Shaunak Das, Sean McCarthy, Pushkala Pattabhiraman, Henrik Ingo</i> “Hunter: Using Change Point Detection to Hunt for Performance Regressions” (2023) // Proceedings of the 2023 ACM/SPEC International Conference on Performance Engineering. Publisher: ACM. DOI:&nbsp;<a href='https://doi.org/10.1145/3578244.3583719'>10.1145/3578244.3583719</a>

## Abstract

> Change point detection has recently gained popularity as a method of detecting performance changes in software due to its ability to cope with noisy data. In this paper we present Hunter, an open source tool that automatically detects performance regressions and improvements in time-series data. Hunter uses a modified E-divisive means algorithm to identify statistically significant changes in normally-distributed performance metrics. We describe the changes we made to the E-divisive means algorithm along with their motivation. The main change we adopted was to replace the significance test using randomized permutations with a Student's t-test, as we discovered that the randomized approach did not produce deterministic results, at least not with a reasonable number of iterations. In addition we've made tweaks that allow us to find change points the original algorithm would not, such as two nearby changes. For evaluation, we developed a method to generate real timeseries, but with artificially injected changes in latency. We used these data sets to compare Hunter against two other well known algorithms, PELT and DYNP. Finally, we conclude with lessons we've learned supporting Hunter across teams with individual responsibility for the performance of their project.

## Bib

```bib
@Inproceedings{fleming2023,
  series = {ICPE ’23},
  title = {Hunter: Using Change Point Detection to Hunt for Performance Regressions},
  abstract = {Change point detection has recently gained popularity as a method of detecting performance changes in software due to its ability to cope with noisy data. In this paper we present Hunter, an open source tool that automatically detects performance regressions and improvements in time-series data. Hunter uses a modified E-divisive means algorithm to identify statistically significant changes in normally-distributed performance metrics. We describe the changes we made to the E-divisive means algorithm along with their motivation. The main change we adopted was to replace the significance test using randomized permutations with a Student's t-test, as we discovered that the randomized approach did not produce deterministic results, at least not with a reasonable number of iterations. In addition we've made tweaks that allow us to find change points the original algorithm would not, such as two nearby changes. For evaluation, we developed a method to generate real timeseries, but with artificially injected changes in latency. We used these data sets to compare Hunter against two other well known algorithms, PELT and DYNP. Finally, we conclude with lessons we've learned supporting Hunter across teams with individual responsibility for the performance of their project.},
  url = {http://dx.doi.org/10.1145/3578244.3583719},
  doi = {10.1145/3578244.3583719},
  booktitle = {Proceedings of the 2023 ACM/SPEC International Conference on Performance Engineering},
  publisher = {ACM},
  author = {Fleming, Matt and Kolaczkowski, Piotr and Kumar, Ishita and Das, Shaunak and McCarthy, Sean and Pattabhiraman, Pushkala and Ingo, Henrik},
  year = {2023},
  month = {apr},
  collection = {ICPE ’23},
  arxiv = {2301.03034}
}
```
