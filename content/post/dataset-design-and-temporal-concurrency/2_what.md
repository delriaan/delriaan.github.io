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

<span class="decorativeText">Welcome back!</span> In [Part 1](../who-and-when), we discussed the importance of giving proper treatment to understanding the *who* and *when* of a problem statement which provide the context within which a solution will be crafted. In this article, we’ll discuss the core of the problem statement itself.

## Metrics & Dimensions

First, let’s define the key measures and related metrics listed in the problem statement:

- <span class="bigMath">`\(\gamma_1 \Rightarrow \gamma(x)=\bar{x} \\ x := \big(t_{i+1}-t_{i}\big)\\\)`</span>: <span id="msg_1">Length of stay</span>
- <span class="bigMath">`\(\gamma_2 \Rightarrow f(x, m)=\sum_{i=1}^{m}{x_m}\\x:=\Big\{\matrix{0, \text{No lapse}\\1, \text{Lapse}}; \enspace m:= \text{month index}\)`</span>: <span id="msg_2">Monthly counts of lapses in medication adherence</span>
- <span class="bigMath">`\(\gamma_3 \Rightarrow f(\gamma_2, m)=\sum_{i=1}^{m}{\gamma_2|i\le{m}}\)`</span>: <span id="msg_3">Cumulative count of lapses in medication adherence</span>
- <span class="bigMath">`\(\gamma_4 \Rightarrow f(x)=\#x \\ x:=\text{unduplicated member identifiers}\)`</span>: <span id="msg_3">Counts of unduplicated members</span>
- <span class="bigMath">`\(\gamma_5 \Rightarrow f(x)=\sum{x}\\x:=\text{cost}\)`</span>: <span id="msg_5">Total expenditures</span>

{{% blogdown/footer %}}
