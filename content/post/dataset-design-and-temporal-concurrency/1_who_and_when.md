---
title: 'Dataset Design: Temporal Concurrency - Who & When'
author: "Chionesu George"
date: 2023-10-31
date-modified: last-modified
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
  - depth: 2
  - float: true
---

{{% blogdown/jquery %}}

    ## dataset-design-and-temporal-concurrency

<link rel="stylesheet" href="/markdown.css"/>
<script src="/markdown.js"></script>
<span style="display: hidden;">
<p>
<ul toggleGroup="0" context="definition">
<li id="msg_tax_I">
<span class="def_sym">&delta;<sup>I</sup></span>
: Information-carrying columns
</li>
<li id="msg_tax_G">
<span class="def_sym">&delta;<sup>G</sup></span>
: Grouping columns (categorical, descriptive)
</li>
<li id="msg_tax_Y">
<span class="def_sym">&delta;<sup>Y</sup></span>
: Measurements (e.g., purchase price, height, product ratings)
</li>
<li id="msg_tax_T">
<span class="def_sym">&delta;<sup>T</sup></span>
: Temporal columns to include dates and temporal hierarchies
</li>
<li id="msg_tax_E">
<span class="def_sym">&delta;<sup>E</sup></span>
: Record life-cycle tracking columns (for example, effective dates in slowly changing dimension parlance)
</li>
</ul>
</p>
</span>

<span class="decorativeText">Welcome back!</span>

Before getting started, let’s revisit out problem statement from the introduction:

<blockquote class="speech" style="font-size: 0.9em; " id="msg_problem">"I want to know trends related to total cost of care; inpatient average lengths of stay; lapses in medication adherence; and member counts for the period between January first of 2019 and the end of 2020. Med lapses should show monthly totals and cumulative monthly totals. Pull members between 30 and 50 years old and have had at least two inpatient visits within a six-week period. I need to see results by month; all services received and corresponding facilities; and member demographics."</blockquote>

The conventions I’ll use are also defined in the introduction <a href="../introduction#definitions--conventions" target="_blank">here</a>.

## When

Identifying the global temporal window ( `\(W\)` ) is important as defines the frame of reference within which temporal relations are queried and transformed. It is the absolute governor of detecting *when* things take place. In this case, the window is defined as all records having temporal columns or derived temporal measurements with at least *one* value falling within the period *2019-01-01* to *2020-12-31*:

<span class="mathblock">`\(\forall W, D^λ \Rightarrow D^\lambda_\Omega:= \Bigg\{\matrix{ W_\text{start} \le \delta^T \le W_\text{end},\enspace\enspace\#\delta^T= 1\\ \\ W_\text{start} \le \delta^T_\text{end} \wedge W_\text{end} \ge \delta^T_\text{start},\enspace\enspace\#\delta^T= 2 }\Bigg\}\)`</span>

, where `\(D^\lambda\)` is the data source for context `\(\lambda\)` (i.e., *demographics*, *claims*, *prescriptions*) and `\(W\)` the lower and upper dates of the global window. The first form of `\(D^\lambda\)` above reflects the case of a *single* time column in `\(D\)` and the second form when there are two.

<span role="toggle" context="posthoc" toggleGroup="0" class="">
Regarding the second form: 
<hint toggleGroup="0">(show)</hint>
</span>

- It allows for a much more compact dataset. I recommend giving serious consideration to transforming the single-date form into the dual-date form, especially when most of `\(\delta^I\)` is duplicative along <span class="medMath" msg_id="tax_T">`\(\delta^T\)`</span> (more on this in a future article)

- It allows for `\(\delta^T\)` to extend outside of the bounds of `\(W\)` while preserving the ability to detect temporal concurrency relative to `\(W\)`

- ***Do not*** use the following logic to detect concurrency of the dual-date form with `\(W\)` (or any other dual-date range):<br><span class="mathblock">`\((W_\text{start} \le \delta_\text{start} \le W_\text{end} ) \vee (W_\text{start} \le \delta_\text{end} \le W_\text{end})\)`</span> This logical statement **will** fail to capture cases where `\(\delta^T\)` extends outside of `\(W\)`:<br><br><img src="/post/dataset-design-and-temporal-concurrency/1_who_and_when_files/figure-html/unnamed-chunk-6-1.png" width="442" />

## Who

The “Who” aspect of the problem statement consists of two detectable conditions (as indicated by the conjunction *“and”*) and a possible, third:

- <span class="bigMath">`\(\omega_1\)`</span>: <span id="msg_1" class="speech">“… members between 30 and 50 years old”</span>

- <span class="bigMath">`\(\omega_2\)`</span>: <span id="msg_2" class="speech">“… have had at least two inpatient visits within a six-week period”</span>

- <span class="bigMath">`\(\omega_3\)`</span>: `\(f(\omega_1, \omega_2)\)` — <span id="msg_3" class="speech">dependence vs. independence</span>

### <span id="omega-1">Age vs. Report Window</span> (<span class="medMath" msg_id="1">`\(\omega_1\)`</span>)

<span class="medMath" msg_id="1">`\(\omega_1\)`</span> is the first opportunity to greatly trim down your data pull.

<span role="toggle" context="posthoc" toggleGroup="1" class="">
It also presents a great case-in-point as to why carefully reading over a request <i>before</i> thrashing away at the keyboard is important: 
<hint toggleGroup="1">(show)</hint>
</span>

- <span class="medMath" msg_id="1">`\(\omega_1\)`</span> must qualified relative to <span class="medMath">`\(W\)`</span> and not <span class="speech">“as of today”</span>. Granted: this is not *explicitly* stated, but think about it: <span class="speech">“… for the period between January first of 2019 and the end of 2020”</span> is your cue. Of course, when in doubt, check with the requester just to be sure.
- <span class="medMath">`\(W\)`</span> covers *two* years which will result in *two* ages for each member not filtered out. **Question**: Which age should be returned at this point? My preference would be *neither* and instead return the dates of birth. *Age* is a derived measure and is only needed to qualify records at this point; *dates of birth* are the temporal attributes (<span class="medMath" msg_id="tax_T">`\(\delta^T\)`</span>) which should carried forward (I’ll explain why later).

<span class="bigMath" style="color:#330033; ">✨</span> At this stage, we’ve defined the first portion of <span class="speech">“Who”</span> is related to the problem statement. An advantage of starting in this manner is that a maximally large cohort has been defined and can be stored in a table to which subsequent data can more efficiently be joined.

For the sake of demonstration, assume the existence of a member demographics table `\((M)\)`. Satisfying <span class="medMath" msg_id="1">`\(\omega_1\)`</span> results in our first dataset: `\(D^M:=\sigma_{\omega_1}(M)\)`
, where <span class="medMath">`\(\sigma\)`</span> represents a <a href="https://en.wikipedia.org/wiki/Selection_(relational_algebra)" class="speech" target="_blank" title="Selection (Relational Algebra)"><em>selection</em></a> operation.

<p>
<hr style="border-bottom: solid 5px #555555; width:100%; "/>
<span style="font-size:4em;" class="speech">
<img src="/hourglass.png" caption="Take a Break!" style="height:3em; vertical-align:text-top; margin-top:-50px; float:left"/>
Take a Break!
</span>
<hr style="border-top: solid 5px #555555; width:100%; "/>
</p>

### <span id="omega-2">Events vs. Report Window</span> (<span class="medMath" msg_id="2">`\(\omega_2\)`</span>)

Now, we move on to defining (<span class="medMath" msg_id="2">`\(\omega_2\)`</span>). Assume a claims dataset `\((L)\)` containing multiple service types `\((\delta^G: \text{Inpt}\in G)\)`. To satisfy this requirement, *three* conditionals need to be addressed:

<span role="toggle" context="posthoc" toggleGroup="1" class="">
<b>c<sub>1</sub></b> &mdash; Has inpatient visits within <span style='font-family:Georgia;'>W</span>: 
<hint toggleGroup="1">(show)</hint>
</span>

<span class="mathblock" toggleGroup="1" context="posthoc">`\(c_1:= W_\text{start} \le \dot{\delta^T} \le{W}_\text{end}; \enspace\dot{\delta^T}\equiv\text{service date}\)`</span>

<p></p>
<span role="toggle" context="posthoc" toggleGroup="2" class="">
<b>c<sub>2</sub></b> &mdash; Number of inpatient visits greater than one: 
<hint toggleGroup="2">(show)</hint>
</span>

<span toggleGroup="2" context="posthoc" style="right:20px; ">If dataset `\(L\)` has well-defined indicators for admissions (and discharges), detecting distinct events is easy. For the sake of this scenario, I will assume this to be the case <span class="speech">\[scenarios where the beginning and ending of a series are not well-defined will be covered in a separate article — eventually\]</span>:
<span class="mathblock">`\(c_2:=\#\big(\dot{\delta^T|}c_1\big) > 1;\enspace\dot{\delta^T}\equiv\text{admission date}\)`</span></span>

<p></p>
<span role="toggle" context="posthoc" toggleGroup="3" class="">
<b>c<sub>3</sub></b> &mdash; Time between inpatient admissions less than or equal to six weeks: 
<hint toggleGroup="3">(show)</hint>
</span>

<span toggleGroup="3" context="posthoc"><span class="mathblock">`\(c_3:=\big({\Delta_n}\dot{\delta^T}|{c_2}\big)\ge\text{42 days}\\{\Delta_n}\dot{\delta^T}:={\dot{\delta^T}}_{i+1}-{\dot{\delta^T}}_i\Big|_{i=1}^{n-1},\enspace\text{ the time between successive admissions}\)`</span></span>

<p></p>
<span role="toggle" context="posthoc" toggleGroup="4" class="">
Before moving on, I want to point out that for performance considerations, the order in which the conditionals are resolved can become very important.  Normally, I would first try the following: 
<hint toggleGroup="4">(show)</hint>
</span>

<span toggleGroup="4" context="posthoc" style="display:block">   **1<sup>st</sup> `\(c_1\)`:** This is the most restrictive and is easily accomplished with a [join](https://en.wikipedia.org/wiki/Relational_algebra#Joins_and_join-like_operators "Join (Relational Algebra)") operation over relations `\(M\)` and `\(S\)`: `\(M \bowtie_{\theta \rightarrow \delta^I}{S}, \enspace\delta^I\equiv\text{member identifier}\)`<br>
   **2<sup>nd</sup> `\(c_3\)`:** Resolving `\(c_3\)` gives you `\(c_2\)` for free (I’ll leave that as *“thought homework”* for you to ponder)<br>
   **3<sup>rd</sup> `\(c_2\)`:** This is easily resolved by counting over `\(c_3\)` and qualifying based on the prescribed threshold<br>
<span class="speech">The second and third steps can easily be flipped depending on the number of `TRUE` cases at each step. Use your domain knowledge (or someone else’s) in these cases or, if all else fails, use multple trial-and-error runs on sampled data (sampling at the member level, in this case) to get a sense of which order will have the best performance on the full set of observations.</span></span>

<img src="/decorative_line.png" class="decorative-line" />

### <span id="omega-3">Temporal Dependence vs. Independence</span> (<span class="medMath" msg_id="3">`\(\omega_3\)`</span>)

In this final portion of the article, I want to offer a consideration related to the <span msg_id="problem" style="border-bottom: dashed 2px green;">problem statement</span> that I recommend verifying at the beginning of the data retrieval and wrangling process: *temporal dependence vs. independence.* Conceptually similar to (in)dependence of variables, this is in a *semantic* context often encountered when there is ambiguity regarding the relationships among temporal criteria that cannot simply be inferred.

For example, consider two scenarios in which <span class="medMath" msg_id="1">`\(\omega_{1}\)`</span> and <span class="medMath" msg_id="2">`\(\omega_{2}\)`</span> can be understood:

- **Scenario 1: Independence** ( `\(\forall W:\omega_1 \wedge\omega_2\)`)

  > In this scenario, <span class="medMath" msg_id="1">`\(\omega_1\)`</span> is sufficient, and the age calculated when resolving this criterion can be carried forward.

- **Scenario 2: Dependence** ( `\(\forall W: \big(\omega_1|\omega_2\big)\)`)

  > In this scenario, a determination (made by the requester) must be made as to which qualifying event in <span class="medMath" msg_id="2">`\(\omega_{2}\)`</span> — first or second — serves as the point of reference to evaluate <span class="medMath" msg_id="1">`\(\omega_{1}\)`</span>. Scenarios like this are why I recommended only carrying forward *essential* information (in this case, the member dates of birth) instead of *contingent* information (e.g., member age relative to `\(W\)`).

Problem statements related to workflows with multiple decision points frequently cause the second scenario to arise in analytic initiatives, so it is good to look into the real-world context of a request in addition to the available data.

<img src="/decorative_line.png" class="decorative-line" />

## <span style="font-size:1.5em;">🎉</span><span class="decorativeText">Congratulations!</span>

<span class="sidebar">As an aside, if you are a data practioner and are not familiar with *predicate logic* or *relational algebra*, I *strongly* recommend getting a basic understanding — *especially* if combining heterogeneous data is part of your workflow.</span>

You’ve made it to the end! I’ll summarize our journey so far:

- We saw how a plain-language statement can be decomposed into smaller, logical chunks to be stepped through and interrogated.

- We looked at the <span class="speech">“When”</span> and <span class="speech">“Who”</span> of our problem statement and explored temporally-based considerations such as global windows of time, relative time between events, and relative event sequencing.

- We considered how the order in which criteria are addressed relates to query and processing performance.

- I hope you see that as we work through the full statement, what emerges is a <span class="speech">“design map”</span> of sorts (which also helps with data product documentation).

That’s all for now — I look forward to seeing you in <a href="../what" target="_blank">Part 2</a> where we explore the <span class="speech">“What”</span> of our problem statement.

{{% blogdown/footer %}}
