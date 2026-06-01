# A/B Test Analysis: Do Ads Actually Drive Conversions?

## Overview
This project analyses a marketing A/B test run across 588,000 users to answer
one core business question: does showing users real ads lead to more conversions
compared to showing them a neutral public service announcement (PSA)? Users were
split into two groups — an `ad` group exposed to the actual marketing campaign,
and a `psa` control group shown a non-commercial placeholder. The dataset
captures each user's group assignment, whether they converted, the total number
of ads they saw, and the day and hour they were most exposed to ads. The entire
analysis was conducted in PostgreSQL using pgAdmin.

---

## Approach
Before looking at any conversion numbers, I first checked the group size split
to understand the data structure. This revealed a significant imbalance — 96% of
users were in the `ad` group and only 4% in the `psa` group — which is an
important caveat that shapes how results should be interpreted.

From there I calculated raw conversion rates per group using conditional
aggregation, then moved into segmentation. I bucketed the ad group by ad
frequency (1–10, 11–50, 51–100, and 100+ ads seen) to test whether more
exposure actually correlates with higher conversion. I then broke down
performance by day of the week and hour of the day to identify the strongest
time windows for ad delivery before drawing any business conclusions.

---

## Findings
- The `ad` group converted at **2.55%** vs **1.79%** for the `psa` group — a
  **43% relative lift**, confirmed as statistically significant via chi-square
  test.
- Conversion rate increases consistently with ad frequency:
  users who saw **100+ ads converted at ~17%**, compared to low single digits
  for lighter exposure.
- **Monday** is the strongest day for conversions at **3.32%**, while Sunday is
  the weakest at **2.13%** — a 1.19 percentage point spread across the week.
- The best-performing hours are **16:00 (3.09%)** and **20:00 (3.03%)**,
  suggesting mid-to-late afternoon and early evening as the optimal delivery
  windows.

---

## Limitations
- The group split is heavily imbalanced (96% ads, 4% PSA). While the chi-square
  test accounts for this mathematically, it makes direct head-to-head comparison
  less clean and means the PSA group has far less statistical power.
- The method of group assignment is unknown. If the assignment was not truly
  random — for example, if high-intent users were systematically shown more ads
  — the results could reflect selection bias rather than a genuine ad effect.
- The strong correlation between ad frequency and conversion rate is
  observational, not causal. Users who are already more likely to convert may
  simply be more engaged and therefore encounter more ads naturally.
- No demographic data is available, so it is not possible to determine whether
  the ad effect is consistent across age groups, geographies, or other segments.

---

## Tools
- PostgreSQL 18 (pgAdmin)
- SQL — aggregation, conditional logic, window functions, percentile functions

## Dataset from Kaggle - Marketing A/B Testing
