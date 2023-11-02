---
title: 'Dataset Design: Temporal Concurrency - Who & When'
author: Chionesu George
date: '2023-10-31'
slug: who-and-when
series: 'Dataset Design and Temporal Concurrency'
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
  toc_depth: 2
  toc_float: true
---

<span style="font-size:smaller; text-decoration:italic; color:#999999; ">Updated 2023-11-02 17:52:26</span>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<style>
#problemStatement { color: #666666; font-family:Georgia; font-size:14pt; }
.def_sym {font-weight:bold; color:#5555DD; } 
.speech {color: #444444; font-family:Georgia; font-style: italic;font-size:16pt;  }
[id^='Math'] {font-size: 14pt; }
body {background-image: url(multicolored_lights.jpg); background-size: 2048px 300px; background-repeat: no-repeat; }
</style>
<script>
$(document).ready(function(){
  $("ul[context='definition']").hide();
  $("p[context='problemStatement']").hide();
  $("[role='toggle']").click(
    function(){
      lgrp = $(this).attr("toggleGroup");
      hint = $(this).find("hint").first();
      &#10;      if (hint.text() == "(show)"){ hint.text("&lt;hide&gt;"); }
      else { hint.text("(show)"); }
      &#10;      $("ul[toggleGroup='" + lgrp + "']").fadeToggle(10);
      $("p[toggleGroup='" + lgrp + "']").fadeToggle(10);
    }); 
  $("ul[context='definition']").first().click();
  $("p[context='problemStatement']").first().click();
})</script>

{{% blogdown/style %}}
{{% blogdown/markdown_js %}}

Welcome back! Before getting started, let’s revisit out problem statement from the introduction:

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
- ***Do not*** use the following logic to detect concurrency of the dual-date form with `\(W\)` (or any other dual-date range):<br><span class="mathblock">`\((W_\text{start} \le \delta_\text{start} \le W_\text{end} ) \wedge (W_\text{start} \le \delta_\text{end} \le W_\text{end})\)`</span> This logical statement **will** fail to capture cases where `\(\delta^T\)` extends outside of `\(W\)`:<br><br><img src="/post/dataset-design-and-temporal-concurrency/1_who_and_when_files/figure-html/unnamed-chunk-3-1.png" width="442" />

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

### <span id="omega-2">Events vs. Report Window</span> (<span class="medMath" omega_id="2">`\(\omega_2\)`</span>)
