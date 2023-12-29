---
title: 'Dataset Design: Temporal Concurrency - What'
author: "Chionesu George"
date: 2023-12-26
date-modified: last-modified
slug: what
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
editor_options: 
  chunk_output_type: console
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

In <a href="../who-and-when" target="blank">Part 1</a>, we discussed the importance of giving proper treatment to understanding the *who* and *when* of a problem statement which provide the context within which a solution will be crafted. In this article, we’ll discuss the quantitative building blocks of the problem statement itself.

## Metrics & Dimensions

<span role="toggle" context="posthoc" toggleGroup="1" class="">
First, let's define the key measures and related metrics listed in the problem statement: 
<hint toggleGroup="1">(show)</hint>
</span>

- <span class="bigMath">`\(\gamma_1\)`</span>: <span id="msg_1">Average length of stay</span> `\(\\\gamma(x)=\bar{x};\enspace x := \big(t_{i+1}-t_{i}\big)\)`

- <span class="bigMath">`\(\gamma_2\)`</span>: <span id="msg_2">Counts of lapses in medication adherence</span> `\(\\f(x)=\sum{x};\enspace x:=\Big\{\matrix{0, \text{No lapse}\\1, \text{Lapse}}\)` (there’s more to this operation which will be covered in Part 3)

- <span class="bigMath">`\(\gamma_3\)`</span>: <span id="msg_3">Cumulative count of lapses in medication adherence</span> `\(\\f(\gamma_2, j)=\sum_{i=1}^{j}{\gamma_2|j\le{i}}\)` (yes, I have not defined `\(j\)`: that will be covered in Part 3)

- <span class="bigMath">`\(\gamma_{4}\)`</span>: <span id="msg_4">Number of unique members</span> `\(\\f(x)=\#x;\enspace x:=\text{the set of unduplicated member identifiers}\)`

- <span class="bigMath">`\(\gamma_5\)`</span>: <span id="msg_5">Total expenditures</span> `\(\\f(x)=\sum{x};\enspace x:=\text{cost}\)`

### Metrics vs. Measures

Note that for each of metrics, a *metric* and a *measure* were defined. The measure is the content of the metric, while the metric operates on the measure.

> For example, <span msg_id="1">`\(\gamma_1\)`</span>’s measure is *days between dates* and the metric is *mean of {measure}*.

### Dimensions

The dimensions of the problem statement are the *who* and *when* of the problem statement. These were discussed in <a href="../who-and-when" target="_blank">Part 1</a>.

{{% blogdown/footer %}}
