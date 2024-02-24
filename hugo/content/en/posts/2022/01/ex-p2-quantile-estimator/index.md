---
title: Extended P² quantile estimator
date: 2022-01-18
tags:
- mathematics
- statistics
- research
- research-p2qe
features:
- math
---

I already covered *the P² quantile estimator* and its possible implementation improvements
  in [several blog posts]({{< ref research-p2qe >}}).
This sequential estimator uses $O(1)$ memory and allows estimating a single predefined quantile.
Now it's time to discuss *the extended P² quantile estimator* that allows estimating multiple predefined quantiles.
This extended version was suggested in the paper
  ["Simultaneous estimation of several percentiles"](https://doi.org/10.1177/003754978704900405).
In this post, we briefly discuss the approach from this paper and how we can improve its implementation.

<!--more-->

### The extended P² quantile estimator

The [P² quantile estimator]({{< ref p2-quantile-estimator >}}) (see {{< link jain1985 >}})
  that estimates the $p^\textrm{th}$ quantile suggest maintaining a list of five markers:

* $q_0$: The minimum
* $q_1$: The (p/2)-quantile
* $q_2$: The p-quantile
* $q_3$: The ((1+p)/2)-quantile
* $q_4$: The maximum

The $q_i$ values are known as the marker heights.

Also, we have to maintain the marker positions $\{ n_0, n_1, n_2, n_3, n_4 \}$.
These integer values describe actual marker indexes across obtained observations at the moment.

Next, we have to define the marker desired positions $\{ n'_0, n'_1, n'_2, n'_3, n'_4 \}$.
For the first $n$ observations, these real values are defined as follows:

* $n'_0 = 0$
* $n'_1 = (n - 1) p / 2$
* $n'_2 = (n - 1) p$
* $n'_3 = (n - 1) (1 + p) / 2$
* $n'_4 = (n - 1)$

The paper suggests simple logic that invalidates all of these values on each new observation.

Now let's consider the extended P² quantile estimator (see {{< link raatikainen1987 >}})
  that estimates $m$ quantile values $p_0, p_1, \ldots, p_{m-1}$.
In order to do it, we need $2m+3$ markers: $m+2$ principle markers and $m+1$ middle markers.
These markers are defined as follows:

* $q_0$: The minimum *(principle marker)*
* $q_1$: The $(p_0/2)$-quantile *(middle marker)*
* $q_2$: The $(p_0)$-quantile *(principle marker)*
* $q_3$: The $((p_0+p_1)/2)$-quantile *(middle marker)*
* $\ldots$
* $q_{2m-1}$: The $((p_{n-2}+p_{n-1})/2)$-quantile *(middle marker)*
* $q_{2m}$: The $(p_{n-1})$-quantile *(principle marker)*
* $q_{2m+1}$: The $((p_{n-1}+1)/2)$-quantile *(middle marker)*
* $q_{2m+2}$: The maximum *(principle marker)*

The marker desired locations are defined correspondingly.

The marker invalidation logic matches the
  [original scheme of the P² quantile estimator]({{< ref p2-quantile-estimator >}}).

### Initialization strategy

Now let's discuss the initialization strategy.
The paper {{< link raatikainen1987 >}} has the following paragraph:

> The initialization of the algorithm requires $2m+3$ observations.
> These observations are sorted and used as the initial heights of the markers, $q_i=x_{(i)}$.
> The actual positions initialize to $n_i=i$.
> This initialization is the simplest one.
> More sophisticated initializations are possible, but not used in this study.
> For example, the first $n'$ observations are generated and sorted.
> The actual positions initialize to $n_i=[d_i]$, where $d_i$ is the desired position of the marker $i$.
> Then it must be checked that the actual positions are strictly increasing.
> If not, some adjustments must be made.
> The heights then initialize to $q_i=x(n_i)$.

I already [covered]({{< ref p2-quantile-estimator-initialization >}}) the initialization strategy importance.
My approach matches the $n_i=[d_i]$ strategy suggested in the second part of the above quote.
Numerical simulations show that it works much better than the simplest one with $n_i=i$
  (especially on small streams and extreme quantiles).

### Marker adjustments

The marker adjustment order also affects the estimator accuracy.
I have already shown it in the [previous blog post]({{< ref p2-quantile-estimator-adjusting-order >}}).
The suggested approach could be easily generalized for the extended P² quantile estimator.

In the adjustment stage, we should update markers $q_1, q_2, \ldots, q_{2m+1}$ (assuming zero-based indexing).
The desired marker locations $n'_1, n'_2, \ldots, n'_{2m+1}$ are known.
On each step, we consider a list of markers $q_l, \ldots, q_r$ that are not adjusted yet
  (for the first step, $l=1$, $r=2m+1$).
In order to choose the next mark to update, we should compare $|n'_l/n-0.5|$ and $|n'_r/n-0.5|$.
If the first expression is less than or equal to the right expression, we should adjust $q_l$.
Otherwise, we should adjust $q_r$.
For details, see the reference implementation.

### Reference implementation

```cs
public class ExtendedP2QuantileEstimator
{
    private readonly double[] probabilities;
    private readonly int m, markerCount;
    private readonly int[] n;
    private readonly double[] ns;
    private readonly double[] q;

    public int Count { get; private set; }

    public ExtendedP2QuantileEstimator(params double[] probabilities)
    {
        this.probabilities = probabilities;
        m = probabilities.Length;
        markerCount = 2 * m + 3;
        n = new int[markerCount];
        ns = new double[markerCount];
        q = new double[markerCount];
    }

    private void UpdateNs(int maxIndex)
    {
        // Principal markers
        ns[0] = 0;
        for (int i = 0; i < m; i++)
            ns[i * 2 + 2] = maxIndex * probabilities[i];
        ns[markerCount - 1] = maxIndex;

        // Middle markers
        ns[1] = maxIndex * probabilities[0] / 2;
        for (int i = 1; i < m; i++)
            ns[2 * i + 1] = maxIndex * (probabilities[i - 1] + probabilities[i]) / 2;
        ns[markerCount - 2] = maxIndex * (1 + probabilities[m - 1]) / 2;
    }

    public void Add(double value)
    {
        if (Count < markerCount)
        {
            q[Count++] = value;
            if (Count == markerCount)
            {
                Array.Sort(q);

                UpdateNs(markerCount - 1);
                for (int i = 0; i < markerCount; i++)
                    n[i] = (int)Math.Round(ns[i]);

                Array.Copy(q, ns, markerCount);
                for (int i = 0; i < markerCount; i++)
                    q[i] = ns[n[i]];
                UpdateNs(markerCount - 1);
            }

            return;
        }

        int k = -1;
        if (value < q[0])
        {
            q[0] = value;
            k = 0;
        }
        else
        {
            for (int i = 1; i < markerCount; i++)
                if (value < q[i])
                {
                    k = i - 1;
                    break;
                }

            if (k == -1)
            {
                q[markerCount - 1] = value;
                k = markerCount - 2;
            }
        }

        for (int i = k + 1; i < markerCount; i++)
            n[i]++;
        UpdateNs(Count);

        int leftI = 1, rightI = markerCount - 2;
        while (leftI <= rightI)
        {
            int i;
            if (Math.Abs(ns[leftI] / Count - 0.5) <= Math.Abs(ns[rightI] / Count - 0.5))
                i = leftI++;
            else
                i = rightI--;
            Adjust(i);
        }

        Count++;
    }

    private void Adjust(int i)
    {
        double d = ns[i] - n[i];
        if (d >= 1 && n[i + 1] - n[i] > 1 || d <= -1 && n[i - 1] - n[i] < -1)
        {
            int dInt = Math.Sign(d);
            double qs = Parabolic(i, dInt);
            if (q[i - 1] < qs && qs < q[i + 1])
                q[i] = qs;
            else
                q[i] = Linear(i, dInt);
            n[i] += dInt;
        }
    }

    private double Parabolic(int i, double d)
    {
        return q[i] + d / (n[i + 1] - n[i - 1]) * (
            (n[i] - n[i - 1] + d) * (q[i + 1] - q[i]) / (n[i + 1] - n[i]) +
            (n[i + 1] - n[i] - d) * (q[i] - q[i - 1]) / (n[i] - n[i - 1])
        );
    }

    private double Linear(int i, int d)
    {
        return q[i] + d * (q[i + d] - q[i]) / (n[i + d] - n[i]);
    }

    public double GetQuantile(double p)
    {
        if (Count == 0)
            throw new InvalidOperationException("Sequence contains no elements");
        if (Count <= markerCount)
        {
            Array.Sort(q, 0, Count);
            int index = (int)Math.Round((Count - 1) * p);
            return q[index];
        }

        for (int i = 0; i < m; i++)
            if (probabilities[i] == p)
                return q[2 * i + 2];

        throw new InvalidOperationException($"Target quantile ({p}) wasn't requested in the constructor");
    }

    public void Clear()
    {
        Count = 0;
    }
}
```

### References

* <b id="Jain1985">[Jain1985]</b>  
  Jain, Raj, and Imrich Chlamtac.
  "The P² algorithm for dynamic calculation of quantiles and histograms without storing observations."
  Communications of the ACM 28, no. 10 (1985): 1076-1085.  
  https://doi.org/10.1145/4372.4378
* <b id="Raatikainen1987">[Raatikainen1987]</b>  
  Raatikainen, Kimmo EE. "Simultaneous estimation of several percentiles."
  Simulation 49, no. 4 (1987): 159-163.  
  https://doi.org/10.1177/003754978704900405