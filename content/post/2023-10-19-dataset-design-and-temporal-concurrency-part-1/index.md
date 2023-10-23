---
title: "Dataset Design and Temporal Concurrency, Prologue"
author: "Chionesu George"
date: "2023-10-21"
slug: "dataset-design-and-temporal-concurrency-prologue"
series: Dataset Design and Temporal Concurrency
categories:
- Data Engineering
- Methodology
- Theory
tags:
- analytics
- data
- engineering
- semantics
- time

---

<span style="font-size:smaller; text-decoration:italic; color:#999999; ">Updated 2023-10-22 23:47:56</span>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script src="markdown.js"></script>
<style>
.warning {background-color:#DFDFDFEE; border-top: solid 2px #AA0000; border-bottom: solid 2px #AA0000}
#problemStatement { color: #666666; font-family:Georgia; font-size:14pt; }
.def_sym {font-weight:bold; color:#5555DD; } 
.speech {color: #444444; font-family:Georgia; font-style: italic;font-size:16pt;  }
hint {font-size: 14pt; font-family: Georgia; font-variant: small-caps italic;  text-decoration: underline;}
hint:hover {cursor: pointer; font-weight: bold; }
[id^='Math'] {font-size;10pt; }
</style>

## Introduction

Numerous articles have been published centered on data engineering and using data to satisfy a business inquiries. Best practices, techniques, and technology are inescapable concepts one will encounter. What I’d like to present are some design concepts drawn from my own experience specifically dealing with the time-centric aspects of data engineering in the context of deconstructing analytic problem statements.

This article serves as the introduction to a short series articles drawing from my experiences as a data practitioner, specifically focusing on lessons I’ve learned in dealing with temporal co-occurrence. Two overarching goals that guide my design thinking in general, but especially when dealing with resolving temporal concurrency are as follows:

1.  Reduce trial-and-error data engineering iterations by using a methodological treatment of the *ontology* (*temporal* ontology for this article series) of the relevant data sources and the *semantic relationships* between data source and the problem statement at hand
2.  Increase the likelihood of creating a minimal number of datasets that both satisfies the immediate task at hand as well as allows for some ability to address related inquiries not yet posed.

Moving forward, the base unit of time will be days, mainly due to not having had to deal with more frequent units of time but also because it’s just easier to think and converse in terms of days.

## Definitions & Conventions

- <span class="def_sym">`\(D_{i,j}\)`</span>: a tabular dataset of `\(i\)` rows and `\(j\)` columns

- <span class="def_sym">`\(Ω_k\)`</span>: Row-based dataset qualifiers — specifically, a set of `\(k\)` rules/criteria `\((ω_1, \omega_2, \omega_3, \cdots, \omega_k)\)` given as predicate statements, that qualify the rows of dataset `\(D\)` such that `\(D_\Omega\subset D\)`.

- <span class="def_sym">`\(Y|X\)`</span>: Condition, read as *“Y given X”* or *“Y conditioned on X”* — an existential constraint that subsets the left-hand side to those cases where the right-hand side exists or is true. For example, `\(\text{Cost}_\text{item}|\big\{\text{Id}_\text{item}=90210\big\}\)` is interpreted as *“Item cost where item ID equals 90210”*.

- <span class="def_sym">`\(∧, ∨\)`</span>: Logical *“and”* and *“or”*, respectively

<p>
<b>Column (&delta;) Taxonomy </b>
<span role="toggle" context="definition" toggleGroup="0" class="">
&#10;<hint toggleGroup="0">(show)</hint>
</span>
</p>
<p>
<ul toggleGroup="0" context="definition">
<li>
<span class="def_sym">&delta;<sup>I</sup></span>
: Information-carrying columns
</li>
<li>
<span class="def_sym">&delta;<sup>G</sup></span>
: Grouping columns (categorical, descriptive)
</li>
<li>
<span class="def_sym">&delta;<sup>Y</sup></span>
: Measurements (e.g., purchase price, height, product ratings)
</li>
<li>
<span class="def_sym">&delta;<sup>T</sup></span>
: Temporal columns to include dates and temporal hierarchies
</li>
<li>
<span class="def_sym">&delta;<sup>E</sup></span>
: Record life-cycle tracking columns (for example, effective dates in slowly changing dimension parlance)
</li>
</ul>
</p>
<hr style="width:100%; "/>

## A Motivating Example

Consider a business request submitted 2023-10-22 and stated as follows \[*demonstration purposes only, so cut me some slack* 😏\]:

<blockquote id="problemStatement" class="speech">"I want to know trends related to total cost of care; Inpatient average lengths of stay; lapses in medication adherence; and member counts for the period between January first of 2019 and the end of 2020. Med lapses should show monthly totals and cumulative monthly totals. Pull members between 30 and 50 years old and have had at least two Inpatient visits within a six-week period. I need to see results by month; all services received and corresponding facilities; and member demographics."</blockquote>

### Problem Restatement

I mentioned consideration of <span class="speech">“the *semantic relationships* between data source and the problem statement”</span> in my introductory remarks. Two principles I always be kept in mind when working with data are as follows:

<blockquote class="speech" style="border-left: solid 3px #6666CC; padding-left: 10px; margin-left: 0px; ">
<span role="toggle" context="problemStatement" toggleGroup="1" class="">
Life is data, but data is not life  
<hint toggleGroup="1">(show)</hint>
</span>
</blockquote>
<p style="margin-left:30px; " context="problemStatement" toggleGroup="1">Life <i>produces</i> information and data <i>encodes</i> it &mdash; <i>always</i> with a loss of information. In the reverse direction, data must be interpreted back to the real-world in order to be considered information precisely because it ties back to the real-world. This semantic map should always be kept in mind.</p>
<blockquote class="speech" style="border-left: solid 3px #6666CC; padding-left: 10px; margin-left: 0px; ">
<span role="toggle" context="problemStatement" toggleGroup="2" class="">
The language of data follows the language of people  
<hint toggleGroup="2">(show)</hint>
</span>
</blockquote>
<p style="margin-left:30px; " context="problemStatement" toggleGroup="2">A basic framework for interpreting and communicating information is <i>language</i>. Language involves syntax and structure to make distinctions among information and provide meaning on the basis of those distinctions.  Since data encodes information, it loosely follows the semantics and syntax of human language.</p>

With that in mind, the business request can be restated in terms of the following:

<table>
<tr>
<td style="background-color:#FFFFFF; width:20px; height:20px; border:outset #999999 2px; "></td>
<td style="width:100px; padding-left:5px; align:right">Who?</td>
<td style="background-color:#FFFFFF; width:20px; height:20px; border:outset #999999 2px; "></td>
<td style="width:100px; padding-left:5px; align:right">When?</td>
<td style="background-color:#FFFFFF; width:20px; height:20px; border:outset #999999 2px; "></td>
<td style="width:100px; padding-left:5px; align:right">What?</td>
<td style="background-color:#FFFFFF; width:20px; height:20px; border:outset #999999 2px; "></td>
<td style="width:100px; padding-left:5px; align:right">How?</td>
</tr>
</table>

These will be addressed subsequent posts:

- *Part 1* will cover <span class="speech">Who?</span> and <span class="speech">When?</span>
- *Part 2* will address <span class="speech">What?</span>
- *Part 3* will cover <span class="speech">How?</span> as well as provide some concluding thoughts

I look forward to seeing you in Part 1. Until then, I wish you much success in your journey as a data practitioner!

<p><p style="border-top: solid 2px black; border-bottom: solid 2px black; background-color: #EFEFEF; font-size:smaller; "><span style="font-family:Georgia; font-variant:italic; ">Life is data, but data is not life: analyze responsibly!</span></p></p>
