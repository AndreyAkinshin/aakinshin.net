---
title: Debunking the tale about outlier removal and ozone holes
date: 2023-01-31
tags:
- Thoughts
- Outliers
- Science Audit
- History
aliases:
- outliers-climate-change
---

Imagine you work with some data and assume that the underlying distribution is approximately normal.
In such cases, the data analysis typically involves non-robust statistics like the mean and the standard deviation.
While these metrics are highly efficient under normality, they make the analysis procedure fragile:
  a single extreme value can corrupt all the results.
You may not expect any significant outliers, but you can never be 100% sure.
To avoid unexpected surprises and ensure the reliability of the results,
  it may be tempting to automatically exclude all outliers from the collected samples.
While this approach is widely adopted, it conceals an essential part of the obtained data
  and can lead to fallacious conclusions.

Let me recite a classic story about ozone holes from {{< link kandel1990 >}},
  which is typically used to illustrate the danger of blind outlier removal:

<!--more-->

{{< quote 5eb9df1d-003d-4921-9cde-ab8535f111b9 >}}

According to the cited fragment, the research team had enough data to detect the ozone holes,
  but the software automatically discarded this information
  because it recognized unusual values as outliers that should be removed.

However, there is another version of this story
  that claims that there was no automatic outlier removal of the TOMS data.
According to the letter from Dr. Richard McPeters (Head of the Ozone Processing Team at NASA) to
  Dr. Pukelsheim (see {{< link pukelsheim1990 >}}):

{{< quote 3f621733-8cca-4baf-8f19-c9f1a4701dac >}}

In this letter, Dr. Richard McPeters explains that NASA engineers were aware of the anomalous data
  collected by NASA's Nimbus-7 satellite
  (the software did not throw the outliers away, it reported them properly).
In order to investigate untypical values and verify their correctness,
  they compared them with the data from the South Pole Dobson ground station.
Unfortunately, the Dobson values for the relevant period of time were "erroneous and uncorrectable,"
  so it was impossible to verify if the satellite data were anomalous
  due to an instrument error or due to an actual physical phenomenon.

A similar story can be found in {{< link bhartia2009 >}}:

{{< quote 6a109ebe-d385-4150-a1b8-ddc1c81e46b3 >}}

While the original story is supposed to be a myth, there is a reason why it became so popular:
  the automatic removal of outliers is regrettably widespread in data analysis.
This is understandable: it is much easier to discard inconvenient data rather than properly examine it.
However, such a shortcut can lead to unfortunate consequences and wrong conclusions.
A proper data analysis procedure should provide not only a clear definition of outliers but also explain their origin.

If outliers appear in the data, it is a good idea to investigate them manually rather than automatically remove them
  so that the outliers do not interfere with non-robust analysis procedures.
Of course, it can be impractical to involve humans every time when we detect extreme values
  (especially if we have to process a lot of data).
Once the source of outliers is determined,
  we can try to automate the outlier examination process
  by implementing logic that recognizes special types of outliers.
However, if we fail to match the obtained extreme values to one of the known patterns,
  such a situation should be flagged for manual investigation.
Using such an approach, we can iteratively extend our knowledge base and
  support handling different types of exceptional situations.
Remember that outliers are not inconvenient values;
  they are an essential part of the data, which may provide valuable insights.

### Acknowledgments

The author thanks [Paul Velleman](https://www.ilr.cornell.edu/people/paul-velleman) for valuable discussions.

In the scope of this investigation, I also found
  {{< link fddbf9f495c4af222bf3d05b03d59266 >}},
  {{< link ac8577ebe8a8dd3a07821f9091465859 >}},
  {{< link 03e8dcba6523ab8ff5dac91c99083768 >}}.
