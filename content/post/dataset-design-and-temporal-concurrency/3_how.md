---
title: 'Dataset Design: Temporal Concurrency - How'
author: "Chionesu George"
date: 2024-01-23
date-modified: last-modified
slug: how
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
<span style="display: none;" id="msg_h1">Results by month</span>
<span style="display: none;" id="msg_h2">All services received and corresponding facilities</span>
<span style="display: none;" id="msg_h3">Member demographics</span>
<span style="display: none;" id="msg_g1">Average length of stay</span>
<span style="display: none;" id="msg_g2">Counts of lapses in medication adherence</span>
<span style="display: none;" id="msg_g3">Cumulative count of lapses in medication adherence</span>
<span style="display: none;" id="msg_g4">Number of unique members</span>
<span style="display: none;" id="msg_g5">Total expenditures</span>

<span class="decorativeText">Welcome back!</span>

In <a href="../what" target="blank">Part 2</a>, we discussed the quantitative building blocks of the problem statement we’ve been working with. In this final article, I’ll cover the *how* of the problem statement, focusing on considerations of both design and implementation of the deliverable.

First, let’s review the key criteria governing how to display or interact with results:

- <span class="bigMath">`\(h_1\)`</span>: <span id="msg_h1">Results by month</span>

- <span class="bigMath">`\(h_2\)`</span>: <span id="msg_h2">Services and facilities</span>

- <span class="bigMath">`\(h_3\)`</span>: <span id="msg_h3">Member demographics</span>

The relevant part of the problem statement is as follows:

> `\(H\)`: <span class="quote">“… I need to see results by month; all services received and corresponding facilities; and member demographics.”</span>.

In keeping with the theme of temporal concurrency, the focus will be to explore the effect of our **how** criteria in expressing `\(\Big\langle\)`
<span msg_id="g1">`\(\gamma_1\)`</span>,
<span msg_id="g2">`\(\gamma_2\)`</span>,
<span msg_id="g3">`\(\gamma_3\)`</span>,
<span msg_id="g4">`\(\gamma_4\)`</span>,
<span msg_id="g5">`\(\gamma_5\)`</span>
`\(\Big\rangle\)` and `\(\Big\langle\)`
<span msg_id="W">`\(W\)`</span>,
<span msg_id="o1">`\(\omega_1\)`</span>,
<span msg_id="o2">`\(\omega_2\)`</span>,
<span msg_id="o3">`\(\omega_3\)`</span>
`\(\Big\rangle\)`:

`\(h_i\)` are interdependent and concurrent:

$$
`\begin{align*}
\pmatrix{
h_{11}^* & h_{12} & h_{13} \\
h_{21} & h_{22}^* & h_{23} \\
h_{31} & h_{32} & h_{33}^* \\
}
\end{align*}`
$$

<img src="/decorative_line.png" class="decorative-line" />

{{% blogdown/footer %}}
