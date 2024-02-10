---
title: 'Dataset Design: Temporal Concurrency - What'
slug: what
date: 2023-12-31
date-modified: last-modified
author: Chionesu George
params:
  - dateForm = Jan 2020
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
editor_options: 
  chunk_output_type: console
---

{{% blogdown/jquery %}}

    ## dataset-design-and-temporal-concurrency

<link rel="stylesheet" href="/markdown.css"/>
<script src="/markdown.js"></script>
<span style="display: none;">
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
<span style="display: none;" id="msg_W">Report Window</span>
<span style="display: none;" id="msg_o1">... members between 30 and 50 years old</span>
<span style="display: none;" id="msg_o2">... have had at least two inpatient visits within a six-week period</span>
<span style="display: none;" id="msg_o3">Dependence vs. Independence</span>

<span class="decorativeText">Welcome back!</span>

In <a href="../who-and-when" target="blank">Part 1</a>, we discussed the importance of giving proper treatment to understanding the *who* and *when* of a problem statement which provide the context within which a solution will be crafted. In this article, we’ll discuss the quantitative building blocks of the problem statement itself.

<span role="toggle" context="posthoc" toggleGroup="1" class="">
First, let's define the key measures and related metrics listed in the problem statement: 
<hint toggleGroup="1">(show)</hint>
</span>

- <span class="bigMath">`\(\gamma_1\)`</span>: <span id="msg_g1">Average length of stay</span> `\(\\\enspace\enspace\enspace\enspace\gamma(x)=\bar{x};\enspace x := \big(t_{i+1}-t_{i}\big)\)`

- <span class="bigMath">`\(\gamma_2\)`</span>: <span id="msg_g2">Counts of lapses in medication adherence</span> `\(\\\enspace\enspace\enspace\enspace f(x)=\sum{x};\enspace x:=\Big\{\matrix{0, \text{No lapse}\\1, \text{Lapse}}\)` (there’s more to this operation which will be covered in Part 3)

- <span class="bigMath">`\(\gamma_3\)`</span>: <span id="msg_g3">Cumulative count of lapses in medication adherence</span> `\(\\\enspace\enspace\enspace\enspace f(\gamma_2, j)=\sum_{i=1}^{j}{\gamma_2|j\le{i}}\)` (yes, I have not defined `\(j\)`: that will be covered in Part 3)

- <span class="bigMath">`\(\gamma_{4}\)`</span>: <span id="msg_g4">Number of unique members</span> `\(\\\enspace\enspace\enspace\enspace f(x)=\#x;\enspace x:=\text{the set of unduplicated member identifiers}\)`

- <span class="bigMath">`\(\gamma_5\)`</span>: <span id="msg_g5">Total expenditures</span> `\(\\\enspace\enspace\enspace\enspace f(x)=\sum{x};\enspace x:=\text{cost}\)`

Note that for each of metrics, a *metric* and a *measure* were defined. The measure is the content of the metric, while the metric operates on the measure.

> For example, <span msg_id="1">`\(\gamma_1\)`</span>’s measure is *days between dates* and the metric is *mean of {measure}*.

<img src="/decorative_line.png" class="decorative-line" />

Next, recall that the dimensions of the problem statement are the *who* and *when* of the problem statement. These were discussed in <a href="../who-and-when" target="_blank">Part 1</a>, so we won’t go into them here. Instead, I want to prepare you for the next article in this series that addresses the *how* of the problem statement.

Recall the relationship between *metrics* and *measures*, the latter being content that is operated on by the former. What they often have in common is being able to be functionally expressed.

Using *“Average length of stay”* as an example, <span msg_id="g1">`\(\gamma_1\)`</span> can be written as follows:

**The measure:**

> `\(f(t_{i+1}, t_i) := t_{i+1}-t_i \Rightarrow \mathbb{F}\)`

**The metric `\((\gamma_1)\)`:**

> `\(g(\mathbb{F}, k) := k^{-1}{\sum_{j=1}^{k}{\mathbb{F}_j}}\\ \enspace\enspace \equiv k^{-1}{\sum_{j=1}^{k}{\big(t_{i+1}-t_{i}\big)_j}}\)`

, where `\(k\)` indexes the number of observations.

Parameters <span class="bigMath">`\(t\)`</span> and <span class="bigMath">`\(k\)`</span> are influenced by *Who* and *When*. While the metrics define *What* to do the final item to address is *How* to apply the metrics to the inputs given *Who* is involved and *When*:

> `\(\Big\langle\)`
> <span msg_id="g1">`\(\gamma_1\)`</span>,
> <span msg_id="g2">`\(\gamma_2\)`</span>,
> <span msg_id="g3">`\(\gamma_3\)`</span>,
> <span msg_id="g4">`\(\gamma_4\)`</span>,
> <span msg_id="g5">`\(\gamma_5\)`</span>
> `\(\Big\rangle\)`
> in the context of
> `\(\Big\langle\)`
> <span msg_id="W">`\(W\)`</span>,
> <span msg_id="o1">`\(\omega_1\)`</span>,
> <span msg_id="o2">`\(\omega_2\)`</span>,
> <span msg_id="o3">`\(\omega_3\)`</span>
> `\(\Big\rangle\)` expressed `\(\text{How}\)`?

In <a href="../how" target="_blank">Part 3</a>, we’ll do just that <span style="font-size:larger;">🙂</span>. See you in ’24!

<img src="/decorative_line.png" class="decorative-line" />
{{% blogdown/footer %}}
