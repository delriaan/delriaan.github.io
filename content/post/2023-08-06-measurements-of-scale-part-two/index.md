---
title: Measurements of Scale, Part Two
author: Chionesu George
date: '2023-08-06'
slug: measurements-of-scale-part-two
series:
  - Measurements of Scale
categories:
  - Theory
tags:
  - central tendency
  - distributions
  - statistics
  - data
---

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<script src="{{< blogdown/postref >}}index_files/plotly-binding/plotly.js"></script>
<script src="{{< blogdown/postref >}}index_files/mathjax/cdn.js"></script>
<script src="{{< blogdown/postref >}}index_files/typedarray/typedarray.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/crosstalk/js/crosstalk.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/plotly-htmlwidgets-css/plotly-htmlwidgets.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/plotly-main/plotly-latest.min.js"></script>

<span style="font-size:smaller; text-decoration:italic; color:#999999; ">Updated 2023-10-23 21:36:26</span>

<script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
<style>.warning {background-color:#DFDFDFEE; border-top: solid 2px #AA0000; border-bottom: solid 2px #AA0000}</style>

**References**

- [Nominal, Ordinal, Interval, and Ratio Scales](https://statisticsbyjim.com/basics/nominal-ordinal-interval-ratio-scales/) (Statistics by Jim)

- [Scales of Measurement](https://byjus.com/maths/scales-of-measurement/) (Byju’s Learning)

- [Level of Measurement](https://en.wikipedia.org/wiki/Level_of_measurement#) (Wikipedia)

- [Levels of Measurement](https://www.scribbr.com/statistics/levels-of-measurement/) (Scribbr)

And we’re back!

Be sure to check out Measurements of Scale part one, [here](https://delriaan.github.io/2023/07/27/measurements-of-scale-part-one/). Now, we’ll tackle *interval* and *ratio* measurements.

<p class="warning">
<span style="color:#AA0000; font-weight:bold">Warning</span>: This entry is considerably longer than Part One. If you suffer from <code>TL;DR</code>, please use the “back” button to return to safety.
</p>

## Interval Scale: It’s all about distance

In the previous article, it was stated that an ordinal scale does not indicate *“\[d\]istance between positions”* or *“intrinsic value at each position”*. An interval scale, however, possesses the qualities of an ordinal scale **and** includes information about the *distance* between positions.

As a data practitioner, keep in mind that distance is not a strictly geo-spatial term. For example, consider the words in the sentence *“I tried to climb the hill but was too tired.”*:

- The **position** of appearance of words the words are on an *ordinal* scale

- The **distances** between word positions are also on an *interval* scale:

<table style="margin-left:50px; font-size:smaller; ">
<tr>
<th style="text-align: right; padding-right:10px; ; color: black"></th>
<th style="text-align: center; color: black">I</th>
<th style="text-align: center; color: black">tried</th>
<th style="text-align: center; color: black">to</th>
<th style="text-align: center; color: black">climb</th>
<th style="text-align: center; color: black">the</th>
<th style="text-align: center; color: black">hill</th>
<th style="text-align: center; color: black">but</th>
<th style="text-align: center; color: black">was</th>
<th style="text-align: center; color: black">too</th>
<th style="text-align: center; color: black">tired</th>
</tr>
<tr>
<td style="font-weight:bold; text-align: right; color: black">I</td>
<td style="text-align: center; color: black">0</td>
<td style="text-align: center; color: red">-1</td>
<td style="text-align: center; color: red">-2</td>
<td style="text-align: center; color: red">-3</td>
<td style="text-align: center; color: red">-4</td>
<td style="text-align: center; color: red">-5</td>
<td style="text-align: center; color: red">-6</td>
<td style="text-align: center; color: red">-7</td>
<td style="text-align: center; color: red">-8</td>
<td style="text-align: center; color: red">-9</td>
</tr>
<tr>
<td style="font-weight:bold; text-align: right; color: black">tried</td>
<td style="text-align: center; color: black">1</td>
<td style="text-align: center; color: black"> 0</td>
<td style="text-align: center; color: red">-1</td>
<td style="text-align: center; color: red">-2</td>
<td style="text-align: center; color: red">-3</td>
<td style="text-align: center; color: red">-4</td>
<td style="text-align: center; color: red">-5</td>
<td style="text-align: center; color: red">-6</td>
<td style="text-align: center; color: red">-7</td>
<td style="text-align: center; color: red">-8</td>
</tr>
<tr>
<td style="font-weight:bold; text-align: right; color: black">to</td>
<td style="text-align: center; color: black">2</td>
<td style="text-align: center; color: black"> 1</td>
<td style="text-align: center; color: black"> 0</td>
<td style="text-align: center; color: red">-1</td>
<td style="text-align: center; color: red">-2</td>
<td style="text-align: center; color: red">-3</td>
<td style="text-align: center; color: red">-4</td>
<td style="text-align: center; color: red">-5</td>
<td style="text-align: center; color: red">-6</td>
<td style="text-align: center; color: red">-7</td>
</tr>
<tr>
<td style="font-weight:bold; text-align: right; color: black">climb</td>
<td style="text-align: center; color: black">3</td>
<td style="text-align: center; color: black"> 2</td>
<td style="text-align: center; color: black"> 1</td>
<td style="text-align: center; color: black"> 0</td>
<td style="text-align: center; color: red">-1</td>
<td style="text-align: center; color: red">-2</td>
<td style="text-align: center; color: red">-3</td>
<td style="text-align: center; color: red">-4</td>
<td style="text-align: center; color: red">-5</td>
<td style="text-align: center; color: red">-6</td>
</tr>
<tr>
<td style="font-weight:bold; text-align: right; color: black">the</td>
<td style="text-align: center; color: black">4</td>
<td style="text-align: center; color: black"> 3</td>
<td style="text-align: center; color: black"> 2</td>
<td style="text-align: center; color: black"> 1</td>
<td style="text-align: center; color: black"> 0</td>
<td style="text-align: center; color: red">-1</td>
<td style="text-align: center; color: red">-2</td>
<td style="text-align: center; color: red">-3</td>
<td style="text-align: center; color: red">-4</td>
<td style="text-align: center; color: red">-5</td>
</tr>
<tr>
<td style="font-weight:bold; text-align: right; color: black">hill</td>
<td style="text-align: center; color: black">5</td>
<td style="text-align: center; color: black"> 4</td>
<td style="text-align: center; color: black"> 3</td>
<td style="text-align: center; color: black"> 2</td>
<td style="text-align: center; color: black"> 1</td>
<td style="text-align: center; color: black"> 0</td>
<td style="text-align: center; color: red">-1</td>
<td style="text-align: center; color: red">-2</td>
<td style="text-align: center; color: red">-3</td>
<td style="text-align: center; color: red">-4</td>
</tr>
<tr>
<td style="font-weight:bold; text-align: right; color: black">but</td>
<td style="text-align: center; color: black">6</td>
<td style="text-align: center; color: black"> 5</td>
<td style="text-align: center; color: black"> 4</td>
<td style="text-align: center; color: black"> 3</td>
<td style="text-align: center; color: black"> 2</td>
<td style="text-align: center; color: black"> 1</td>
<td style="text-align: center; color: black"> 0</td>
<td style="text-align: center; color: red">-1</td>
<td style="text-align: center; color: red">-2</td>
<td style="text-align: center; color: red">-3</td>
</tr>
<tr>
<td style="font-weight:bold; text-align: right; color: black">was</td>
<td style="text-align: center; color: black">7</td>
<td style="text-align: center; color: black"> 6</td>
<td style="text-align: center; color: black"> 5</td>
<td style="text-align: center; color: black"> 4</td>
<td style="text-align: center; color: black"> 3</td>
<td style="text-align: center; color: black"> 2</td>
<td style="text-align: center; color: black"> 1</td>
<td style="text-align: center; color: black"> 0</td>
<td style="text-align: center; color: red">-1</td>
<td style="text-align: center; color: red">-2</td>
</tr>
<tr>
<td style="font-weight:bold; text-align: right; color: black">too</td>
<td style="text-align: center; color: black">8</td>
<td style="text-align: center; color: black"> 7</td>
<td style="text-align: center; color: black"> 6</td>
<td style="text-align: center; color: black"> 5</td>
<td style="text-align: center; color: black"> 4</td>
<td style="text-align: center; color: black"> 3</td>
<td style="text-align: center; color: black"> 2</td>
<td style="text-align: center; color: black"> 1</td>
<td style="text-align: center; color: black"> 0</td>
<td style="text-align: center; color: red">-1</td>
</tr>
<tr>
<td style="font-weight:bold; text-align: right; color: black">tired</td>
<td style="text-align: center; color: black">9</td>
<td style="text-align: center; color: black"> 8</td>
<td style="text-align: center; color: black"> 7</td>
<td style="text-align: center; color: black"> 6</td>
<td style="text-align: center; color: black"> 5</td>
<td style="text-align: center; color: black"> 4</td>
<td style="text-align: center; color: black"> 3</td>
<td style="text-align: center; color: black"> 2</td>
<td style="text-align: center; color: black"> 1</td>
<td style="text-align: center; color: black"> 0</td>
</tr>
</table>

In addition, interval scales have an infinite domain and no **true** zero point:

- Latitude and longitude are on an interval scale. The “zero” location on the globe (<span style="font-family: Georgia; ">0 ° long., 0 ° lat.</span>) is arbitrary, only having value for the purpose of providing a reference point from which distance is measured.

- Temporal demarcations (e.g., dates, timestamps, etc.) are also on an interval scale <sup style="color:red">\*</sup>. “Nine o’clock” is not three times as “big” as “three o’clock”. Also, there would be no reason one should consider a clock divided into 27 partitions as invalid as long as the partitions are equal.

<span style="font-size:smaller"><sup style="color:red">\*</sup> Yes, one could point to [cosmological theories](https://plato.stanford.edu/entries/cosmological-argument/) of the origin of the universe as a rebuttal, so I ask for your indulgence.</span>

By way of example:

- `\(X:\)` *a vector of data* <br> <span>[92, 51, 63, 87, 12, 95, 67, 31, 100, 72]</span>

- **Ordinal:** positions of each value in `\(X\)`<br> <span>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]</span>

- **Interval:** distances from the mean `\((X - \bar{X})\)`<br> <span>[25, -16, -4, 20, -55, 28, 0, -36, 33, 5]</span><br>

Division and multiplication are not allowed on an interval scale: fortunately, we have our final measurement scale — the *ratio* scale.

## Ratio

<span style="font-family: Georgia; font-size: 14pt;">“Alas, poor Yorick! I knew him, Ho</span><span style="font-style: italic; font-weight:bold; ">ratio</span>”</span>

Not only does the ratio scale contain the winning personality of an interval scale, it possesses the distinguishing feature of having an absolute zero point beyond which nothing exists. Physical measurements such as *weight* and *height* are examples. Returning to our example sentence, we have the concept of *string similarity* which is also on a ratio scale (*Jaro-Winkler* string similarity values generated with the R package [stringdist](https://github.com/markvanderloo/stringdist)):

<table style="margin-left:25px; font-size:smaller; "> <tr> <th style="font-weight:bold; width:100px; text-align: right"></th> <th style="text-align: center">I</th> <th style="text-align: center">tried</th> <th style="text-align: center">to</th> <th style="text-align: center">climb</th> <th style="text-align: center">the</th> <th style="text-align: center">hill</th> <th style="text-align: center">but</th> <th style="text-align: center">was</th> <th style="text-align: center">too</th> <th style="text-align: center">tired</th> </tr> <tr> <td style="font-weight:bold; width:100px; text-align: right; color: black">I</td> <td style="text-align: center; color: #001400">1</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> </tr> <tr> <td style="font-weight:bold; width:100px; text-align: right; color: black">tried</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #001400">1.0000</td> <td style="text-align: center; color: #6E4E6E">0.5667</td> <td style="text-align: center; color: #885E88">0.4667</td> <td style="text-align: center; color: #4F3C4F">0.6889</td> <td style="text-align: center; color: #845C84">0.4833</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #7D577D">0.5111</td> <td style="text-align: center; color: #111C11">0.9333</td> </tr> <tr> <td style="font-weight:bold; width:100px; text-align: right; color: black">to</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #6E4E6E">0.5667</td> <td style="text-align: center; color: #001400">1.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #634763">0.6111</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #1C211C">0.8889</td> <td style="text-align: center; color: #6E4E6E">0.5667</td> </tr> <tr> <td style="font-weight:bold; width:100px; text-align: right; color: black">climb</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #885E88">0.4667</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #001400">1.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #885E88">0.4667</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #885E88">0.4667</td> </tr> <tr> <td style="font-weight:bold; width:100px; text-align: right; color: black">the</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #4F3C4F">0.6889</td> <td style="text-align: center; color: #634763">0.6111</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #001400">1.0000</td> <td style="text-align: center; color: #785478">0.5278</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #715071">0.5556</td> <td style="text-align: center; color: #4F3C4F">0.6889</td> </tr> <tr> <td style="font-weight:bold; width:100px; text-align: right; color: black">hill</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #845C84">0.4833</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #885E88">0.4667</td> <td style="text-align: center; color: #785478">0.5278</td> <td style="text-align: center; color: #001400">1.0000</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #845C84">0.4833</td> </tr> <tr> <td style="font-weight:bold; width:100px; text-align: right; color: black">but</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #001400">1</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> </tr> <tr> <td style="font-weight:bold; width:100px; text-align: right; color: black">was</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #001400">1</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> </tr> <tr> <td style="font-weight:bold; width:100px; text-align: right; color: black">too</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #7D577D">0.5111</td> <td style="text-align: center; color: #1C211C">0.8889</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #715071">0.5556</td> <td style="text-align: center; color: #BFBFBF">0.0000</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #001400">1.0000</td> <td style="text-align: center; color: #7D577D">0.5111</td> </tr> <tr> <td style="font-weight:bold; width:100px; text-align: right; color: black">tired</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #111C11">0.9333</td> <td style="text-align: center; color: #6E4E6E">0.5667</td> <td style="text-align: center; color: #885E88">0.4667</td> <td style="text-align: center; color: #4F3C4F">0.6889</td> <td style="text-align: center; color: #845C84">0.4833</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #BFBFBF">0</td> <td style="text-align: center; color: #7D577D">0.5111</td> <td style="text-align: center; color: #001400">1.0000</td> </tr> </table>

**The Importance of Absolute Zero**

What makes a ratio scale so great is that it provides an objective, uniform way to communicate information about the values at each location as well as the distances between values. Count data is a great example of this. For example, consider a set of counts of unique people entering or leaving an auditorium (for the first time) though one of four entrances:

<table style="margin-left:50px; font-size:smaller; ">
<tr>
<th style="width:80px; ">Entrance</th>
<th style="width:80px; ">Entered</th>
<th style="width:80px; ">Exited</th>
</tr>
<tr>
<td style="text-align:center">A</td>
<td style="text-align:center">12</td>
<td style="text-align:center">1</td>
</tr>
<tr>
<td style="text-align:center">B</td>
<td style="text-align:center">6</td>
<td style="text-align:center">0</td>
</tr>
<tr>
<td style="text-align:center">C</td>
<td style="text-align:center">0</td>
<td style="text-align:center">4</td>
</tr>
<tr>
<td style="text-align:center">D</td>
<td style="text-align:center">1</td>
<td style="text-align:center">6</td>
</tr>
</table>

Having an absolute zero point allows us to objectively state that nobody entered through **Entrance C** or exited through **Door B** for the first time during the measurement period. Another example is a sequence of notes played at certain volumes (measured in *decibels*):

<table style="margin-left:50px; font-size:smaller; ">
<tr>
<th style="width:90px; ">Note</th>
<th style="width:90px; ">Freq (Hz)</th>
<th style="width:90px; ">Distance<br>from C</th>
<th style="width:90px; ">dB</th>
</tr>
<tr>
<td style="text-align:center">A</td>
<td style="text-align:center">220</td>
<td style="text-align:center">-1.5</td>
<td style="text-align:center">26</td>
</tr>
<tr>
<td style="text-align:center">A#</td>
<td style="text-align:center">233.08</td>
<td style="text-align:center">-1</td>
<td style="text-align:center">-16.93</td>
</tr>
<tr>
<td style="text-align:center">B</td>
<td style="text-align:center">246.94</td>
<td style="text-align:center">-0.5</td>
<td style="text-align:center">-54.61</td>
</tr>
<tr>
<td style="text-align:center">C (middle)</td>
<td style="text-align:center">261.63</td>
<td style="text-align:center">0</td>
<td style="text-align:center">33.77</td>
</tr>
<tr>
<td style="text-align:center">C#</td>
<td style="text-align:center">277.18</td>
<td style="text-align:center">0.5</td>
<td style="text-align:center">89.56</td>
</tr>
<tr>
<td style="text-align:center">D</td>
<td style="text-align:center">293.66</td>
<td style="text-align:center">1</td>
<td style="text-align:center">24.38</td>
</tr>
<tr>
<td style="text-align:center">D#</td>
<td style="text-align:center">311.13</td>
<td style="text-align:center">1.5</td>
<td style="text-align:center">-9.03</td>
</tr>
<tr>
<td style="text-align:center">E</td>
<td style="text-align:center">329.63</td>
<td style="text-align:center">2</td>
<td style="text-align:center">-31.82</td>
</tr>
</table>

- With an interval scale, one can correctly state that the `E` is two steps (distance) from the `C`, but it would be incorrect to state that `E` is twice as “high” as `D`.

- With a ratio scale, once correctly state that Hz separates `E` and `C` and that `E` has 1.3 times as high a frequency as `C`.

- A final … note (*sorry*): column “dB” is on a ratio scale, but it isn’t obvious. There doesn’t appear to be an absolute zero given the negative values, so what gives? Decibels (dB) are [logarithmic.](https://www.mathsisfun.com/algebra/logarithms.html) Negative logarithms result in smaller values. To illustrate, consider taking a piece of paper, cutting it in half, and then repeating this process many times: `\(\frac{1}{2^0}, \frac{1}{2^1}, \frac{1}{2^2}, \cdots, \frac{1}{2^x}\equiv 2^{-x}: x\in [0, \infty)\)`. With each iteration, the halves become smaller and smaller. At some point, there would be *virtually* nothing left to cut:
  <div id="htmlwidget-1" style="width:720px;height:550px;" class="plotly html-widget "></div> <script type="application/json" data-for="htmlwidget-1">{"x":{"visdat":{"152058cd12f2":["function () ","plotlyVisDat"]},"cur_data":"152058cd12f2","attrs":{"152058cd12f2":{"x":{},"y":{},"hoverinfo":"text+info","hovertext":{},"mode":"markers","name":"The half of it","color":{},"stroke":["#000000"],"size":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter"}},"layout":{"width":720,"height":550,"margin":{"b":-11,"l":60,"t":-11,"r":10},"xaxis":{"domain":[0,1],"automargin":true,"title":"$x\\text{ (# of halves)}$","gridcolor":"#CCCCCC"},"yaxis":{"domain":[0,1],"automargin":true,"title":"$f(x)$","gridcolor":"#CCCCCC"},"hovermode":"closest","showlegend":false,"legend":{"yanchor":"top","y":0.5},"title":"Cutting Into Halves<br><span style='font-size:smaller; font-family: Georgia; ' >(How 1,000 papercuts happen)<\/span>","plot_bgcolor":"#EFEFEF"},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20],"y":[0.5,0.25,0.125,0.0625,0.03125,0.015625,0.0078125,0.00390625,0.001953125,0.0009765625,0.00048828125,0.000244140625,0.0001220703125,6.103515625e-05,3.0517578125e-05,1.52587890625e-05,7.62939453125e-06,3.814697265625e-06,1.9073486328125e-06,9.5367431640625e-07],"hoverinfo":["text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info","text+info"],"hovertext":["Piece size: 0.5","Piece size: 0.25","Piece size: 0.125","Piece size: Smaller","Piece size: Smaller","Piece size: Smaller","Piece size: Really small","Piece size: Really small","Piece size: Really small","Piece size: Get a microscope!","Piece size: Get a microscope!","Piece size: Get a microscope!","Piece size: Get a microscope!","Piece size: Approaching zero!!!","Piece size: Approaching zero!!!","Piece size: Approaching zero!!!","Piece size: Approaching zero!!!","Piece size: Approaching zero!!!","Piece size: Approaching zero!!!","Piece size: Approaching zero!!!"],"mode":"markers","name":"The half of it","type":"scatter","marker":{"colorbar":{"title":"y","ticklen":2},"cmin":9.5367431640625e-07,"cmax":0.5,"colorscale":[["0","rgba(68,1,84,1)"],["0.0416666666666667","rgba(70,19,97,1)"],["0.0833333333333333","rgba(72,32,111,1)"],["0.125","rgba(71,45,122,1)"],["0.166666666666667","rgba(68,58,128,1)"],["0.208333333333333","rgba(64,70,135,1)"],["0.25","rgba(60,82,138,1)"],["0.291666666666667","rgba(56,93,140,1)"],["0.333333333333333","rgba(49,104,142,1)"],["0.375","rgba(46,114,142,1)"],["0.416666666666667","rgba(42,123,142,1)"],["0.458333333333333","rgba(38,133,141,1)"],["0.5","rgba(37,144,140,1)"],["0.541666666666667","rgba(33,154,138,1)"],["0.583333333333333","rgba(39,164,133,1)"],["0.625","rgba(47,174,127,1)"],["0.666666666666667","rgba(53,183,121,1)"],["0.708333333333333","rgba(79,191,110,1)"],["0.75","rgba(98,199,98,1)"],["0.791666666666667","rgba(119,207,85,1)"],["0.833333333333333","rgba(147,214,70,1)"],["0.875","rgba(172,220,52,1)"],["0.916666666666667","rgba(199,225,42,1)"],["0.958333333333333","rgba(226,228,40,1)"],["1","rgba(253,231,37,1)"]],"showscale":false,"color":[0.5,0.25,0.125,0.0625,0.03125,0.015625,0.0078125,0.00390625,0.001953125,0.0009765625,0.00048828125,0.000244140625,0.0001220703125,6.103515625e-05,3.0517578125e-05,1.52587890625e-05,7.62939453125e-06,3.814697265625e-06,1.9073486328125e-06,9.5367431640625e-07],"size":[100,54.9999141691478,32.4998712537217,21.2498497960087,15.6248390671522,12.8123337027239,11.4060810205098,10.7029546794027,10.3513915088492,10.1756099235724,10.087719130934,10.0437737346148,10.0218010364552,10.0108146873754,10.0053215128355,10.0025749255656,10.0012016319306,10.0005149851131,10.0001716617044,10],"sizemode":"area","line":{"color":"rgba(0,0,0,1)","width":1}},"textfont":{"size":[100,54.9999141691478,32.4998712537217,21.2498497960087,15.6248390671522,12.8123337027239,11.4060810205098,10.7029546794027,10.3513915088492,10.1756099235724,10.087719130934,10.0437737346148,10.0218010364552,10.0108146873754,10.0053215128355,10.0025749255656,10.0012016319306,10.0005149851131,10.0001716617044,10]},"error_y":{"thickness":1,"width":[]},"error_x":{"thickness":1,"width":[]},"xaxis":"x","yaxis":"y","frame":null},{"x":[1,20],"y":[9.5367431640625e-07,0.5],"type":"scatter","mode":"markers","opacity":0,"hoverinfo":"none","showlegend":false,"marker":{"colorbar":{"title":{"text":"<span style='font-family: Georgia'>f(x) = 2<sup>-x<\/sup><\/span>"},"ticklen":2,"len":0.5,"lenmode":"fraction","y":1,"yanchor":"top"},"cmin":9.5367431640625e-07,"cmax":0.5,"colorscale":[["0","rgba(68,1,84,1)"],["0.0416666666666667","rgba(70,19,97,1)"],["0.0833333333333333","rgba(72,32,111,1)"],["0.125","rgba(71,45,122,1)"],["0.166666666666667","rgba(68,58,128,1)"],["0.208333333333333","rgba(64,70,135,1)"],["0.25","rgba(60,82,138,1)"],["0.291666666666667","rgba(56,93,140,1)"],["0.333333333333333","rgba(49,104,142,1)"],["0.375","rgba(46,114,142,1)"],["0.416666666666667","rgba(42,123,142,1)"],["0.458333333333333","rgba(38,133,141,1)"],["0.5","rgba(37,144,140,1)"],["0.541666666666667","rgba(33,154,138,1)"],["0.583333333333333","rgba(39,164,133,1)"],["0.625","rgba(47,174,127,1)"],["0.666666666666667","rgba(53,183,121,1)"],["0.708333333333333","rgba(79,191,110,1)"],["0.75","rgba(98,199,98,1)"],["0.791666666666667","rgba(119,207,85,1)"],["0.833333333333333","rgba(147,214,70,1)"],["0.875","rgba(172,220,52,1)"],["0.916666666666667","rgba(199,225,42,1)"],["0.958333333333333","rgba(226,228,40,1)"],["1","rgba(253,231,37,1)"]],"showscale":true,"color":[9.5367431640625e-07,0.5],"line":{"color":"rgba(255,127,14,1)"}},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>

  <hr width = "100%">

  Congratulations — you made it! Thanks for taking this brief journey into measurements of scale. In a future post, I’ll relate measurements of scale and central-tendency to satisfying analytic requests, but before that, I’ll address the *deconstruction* of analytic requests after I complete my research. Until we meet again, I wish you much success in your journey as a data practitioner!

``` r
ifelse(Sys.getenv('GIT_REPOS') == '', Sys.getenv('GIT_Imperial'), Sys.getenv('GIT_REPOS')) |>
  dir(pattern = "blog", recursive = TRUE, full.names = TRUE) |> 
  purrr::walk(source);

get_footer()
```

<p style="border-top: solid 2px black; border-bottom: solid 2px black; background-color: #EFEFEF; font-size:smaller; ">
<span style="font-family:Georgia; font-variant:italic; ">Life is data, but data is not life: analyze responsibly!</span>
</p>