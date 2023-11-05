---
title: 'Dataset Design: Temporal Concurrency - Who & When'
author: "Chionesu George"
date: 2023-10-31
slug: who-and-when
series: 
  - Dataset Design and Temporal Concurrency
categories:
  - Data Engineering
  - Theory
tags:
  - analytics
  - engineering
  - time
  - data
  - semantics
toc:
  toc_depth: 3
  toc_float: true
---

{{% blogdown/jquery %}}

    ## dataset-design-and-temporal-concurrency

<link rel="stylesheet" href="/markdown.css"/>
<script src="/markdown.js"></script>
<span style="font-size:smaller; text-decoration:italic; color:#999999; ">Updated 2023-11-04 22:33:22</span>

Welcome back!

Before getting started, let’s revisit out problem statement from the introduction:

<span class="speech" style="font-size: 0.9em; ">"I want to know trends related to total cost of care; Inpatient average lengths of stay; lapses in medication adherence; and member counts for the period between January first of 2019 and the end of 2020. Med lapses should show monthly totals and cumulative monthly totals. Pull members between 30 and 50 years old and have had at least two Inpatient visits within a six-week period. I need to see results by month; all services received and corresponding facilities; and member demographics."</span>

The conventions I’ll use are also defined in the introduction <a href="../introduction#definitions--conventions" target="_blank">here</a>.

## When

Identifying the global temporal window ( `\(W\)` ) is important as defines the frame of reference within which temporal relations are queried and transformed. It is the absolute governor of detecting *when* things take place. In this case, the window is defined as all records having temporal columns or derived temporal measurements with at least *one* value falling within the period *2019-01-01* to *2020-12-31*:

<span class="mathblock">`\(\forall W, D^λ \Rightarrow D^\lambda_\Omega:= \Bigg\{\matrix{ W_\text{start} \le \delta^T \le W_\text{end},\enspace\enspace\#\delta^T= 1\\ \\ W_\text{start} \le \delta^T_\text{end} \wedge W_\text{end} \ge \delta^T_\text{start},\enspace\enspace\#\delta^T= 2 }\Bigg\}\)`</span>

, where `\(D^\lambda\)` is the data source for context `\(\lambda\)` (i.e., *demographics*, *claims*, *prescriptions*) and `\(W\)` the lower and upper dates of the global window. The first form of `\(D^\lambda\)` above reflects the case of a *single* time column in `\(D\)` and the second form when there are two.

<span role="toggle" context="posthoc" toggleGroup="0" class="">
Regarding the second form: 
<hint toggleGroup="0">(show)</hint>
</span>

- It allows for a much more compact dataset. I recommend giving serious consideration to transforming the single-date form into the dual-date form, especially when most of `\(\delta^I\)` is duplicative along `\(\delta^T\)` (more on this in a future article)
- It allows for `\(\delta^T\)` to extend outside of the bounds of `\(W\)` while preserving the ability to detect temporal concurrency relative to `\(W\)`
- ***Do not*** use the following logic to detect concurrency of the dual-date form with `\(W\)` (or any other dual-date range):<br><span class="mathblock">`\((W_\text{start} \le \delta_\text{start} \le W_\text{end} ) \wedge (W_\text{start} \le \delta_\text{end} \le W_\text{end})\)`</span> This logical statement **will** fail to capture cases where `\(\delta^T\)` extends outside of `\(W\)`:<br><br><img src="/post/dataset-design-and-temporal-concurrency/1_who_and_when_files/figure-html/unnamed-chunk-2-1.png" width="442" />

## Who

The “Who” aspect of the problem statement consists of two detectable conditions (as indicated by the conjunction *“and”*) and a possible, third:

- <span class="bigMath">`\(\omega_1\)`</span>: <span id="omega-1-def" class="speech">“… members between 30 and 50 years old”</span>
- <span class="bigMath">`\(\omega_2\)`</span>: <span id="omega-2-def" class="speech">“… have had at least two Inpatient visits within a six-week period”</span>
- <span class="bigMath">`\(\omega_3\)`</span>: `\(f(\omega_1, \omega_2)\)` — <span id="omega-3-def" class="speech">hierarchical concurrency</span>

### <span id="omega-1">Age vs. Report Window</span> (<span class="medMath" omega_id="1">`\(\omega_1\)`</span>)

<span class="medMath" omega_id="1">`\(\omega_1\)`</span> is the first opportunity to greatly trim down your data pull.

<span role="toggle" context="posthoc" toggleGroup="1" class="">
It also presents a great case-in-point as to why carefully reading over a request <i>before</i> thrashing away at the keyboard is important: 
<hint toggleGroup="1">(show)</hint>
</span>

- <span class="medMath" omega_id="1">`\(\omega_1\)`</span> must qualified relative to <span class="medMath">`\(W\)`</span> and not <span class="speech">“as of today”</span>. Granted: this is not *explicitly* stated, but think about it: <span class="speech">“… for the period between January first of 2019 and the end of 2020”</span> is your cue. Of course, when in doubt, check with the requester just to be sure.
- <span class="medMath">`\(W\)`</span> covers *two* years which will result in *two* ages for each member not filtered out. **Question**: Which age should be returned at this point? My preference would be *neither* and instead return the dates of birth. *Age* is a derived measure and is only needed to qualify records at this point; *dates of birth* are the temporal attributes (<span class="medMath">`\(\delta^T\)`</span>) which should carried forward (I’ll demonstrate this shortly).

<span class="bigMath" style="color:#330033; ">✨</span> At this stage, we’ve defined the first portion of <span class="speech">“Who”</span> is related to the problem statement. An advantage of starting in this manner is that a maximally large cohort has been defined and can be stored in a table to which subsequent data can more efficiently be joined.

For the sake of demonstration, assume the existence of a member demographics table `\((M)\)`. Satisfying <span class="medMath" omega_id="1">`\(\omega_1\)`</span> results in our first dataset: `\(D^M:=\sigma_{\omega_1}(M)\)`
, where <span class="medMath">`\(\sigma\)`</span> represents a <a href="https://en.wikipedia.org/wiki/Selection_(relational_algebra)" class="speech" target="_blank" title="Selection (Relational Algebra)"><em>selection</em></a> operation.

<p>
<hr style="border-bottom: solid 5px #555555; width:100%; "/>
<span style="font-size:4em;" class="speech">
<img src="/hourglass.png" caption="Take a Break!" style="height:3em; vertical-align:middle; top:-5px; float:left"/>
Take a Break!
</span>
<hr style="border-top: solid 5px #555555; width:100%; "/>
</p>

### <span id="omega-2">Events vs. Report Window</span> (<span class="medMath" omega_id="2">`\(\omega_2\)`</span>)

Now, we move on to defining (<span class="medMath" omega_id="2">`\(\omega_2\)`</span>). Assume a claims dataset `\((L)\)` containing multiple service types `\((\delta^G: \text{Inpt}\in G)\)`. To satisfy this requirement, *three* conditionals need to be addressed:

<span role="toggle" context="posthoc" toggleGroup="1" class="">
<b>c<sub>1</sub></b> &mdash; Has inpatient visits within <span style='font-family:Georgia;'>W</span>: 
<hint toggleGroup="1">(show)</hint>
</span>

<span class="mathblock" toggleGroup="1" context="posthoc">`\(c_1:= W_\text{start} \le \dot{\delta^T} \le{W}_\text{end}; \enspace\dot{\delta^T}\equiv\text{service date}\)`</span>

<br>

<span role="toggle" context="posthoc" toggleGroup="2" class="">
<b>c<sub>2</sub></b> &mdash; Number of inpatient visits greater than one: 
<hint toggleGroup="2">(show)</hint>
</span>

<span toggleGroup="2" context="posthoc" style="right:20px; ">If dataset `\(L\)` has well-defined indicators for admissions (and discharges), detecting distinct events is easy. For the sake of this scenario, I will assume this to be the case <span class="speech">\[scenarios where the beginning and ending of a series are not well-defined will be covered in a separate article — eventually\]</span>:
<span class="mathblock">`\(c_2:=\#\big(\dot{\delta^T|}c_1\big) > 1;\enspace\dot{\delta^T}\equiv\text{admission date}\)`</span></span>

<br>

<span role="toggle" context="posthoc" toggleGroup="3" class="">
<b>c<sub>3</sub></b> &mdash; Time between inpatient admissions less than or equal to six weeks: 
<hint toggleGroup="3">(show)</hint>
</span>

<span toggleGroup="3" context="posthoc"><span class="mathblock">`\(c_3:=\big({\Delta\\^n}\dot{\delta^T}|{c_2}\big)\ge\text{42 days}\)`</span>
<span class="mathblock">`\({\Delta\\^n}\dot{\delta^T}:={\dot{\delta^T}}_{i+1}-{\dot{\delta^T}}_i\Big|_{i=1}^{n-1},\enspace\text{ the time between successive admissions}\)`</span></span>

<p>
</p>
<span role="toggle" context="posthoc" toggleGroup="4" class="">
Before moving on, I want to point out that for performance considerations, the order in which the conditionals are resolved can become very important.  Normally, I would first try the following: 
<hint toggleGroup="4">(show)</hint>
</span>

<span toggleGroup="4" context="posthoc" style="display:block">   **1<sup>st</sup> `\(c_1\)`:** This is the most restrictive and is easily accomplished with a join operation over datasets `\(M\)` and `\(S\)`: `\(M \bowtie_{\theta \rightarrow \delta^I}{S}, \enspace\delta^I\equiv\text{member identifier}\)`<br>
   **2<sup>nd</sup> `\(c_3\)`:** Resolving `\(c_3\)` gives you `\(c_2\)` for free (I’ll leave that as *“thought homework”* for you to ponder)<br>
   **3<sup>rd</sup> `\(c_2\)`:** This is easily resolved by counting over `\(c_3\)` and qualifying based on the prescribed threshold<br>
<span class="speech">The second and third steps can easily be flipped depending on the number of `TRUE` cases at each step. Use your domain knowledge (or someone else’s) in these cases or, if all else fails, use multple trial-and-error runs on sampled data (sampling at the member level, in this case) to get a sense of which order will have the best performance on the full set of observations.</span></span>

<img src="/decorative_line.png" class="decorative-line" />

### <span id="omega-3">Temporal Hierarchy vs. Independence</span> (<span class="medMath" omega_id="3">`\(\omega_3\)`</span>)

{{% blogdown/footer %}}
