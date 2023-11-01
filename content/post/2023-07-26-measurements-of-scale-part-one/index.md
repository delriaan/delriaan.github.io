---
title: 'Measurements of Scale, Part One'
author: 'Chionesu George'
date: '2023-07-27'
slug: 'measurements-of-scale-part-one'
series: 'Measurements of Scale'
categories: 'Theory'
tags: ['central tendency', 'distributions', 'statistics', 'data']
---

<span style="font-size:smaller; text-decoration:italic; color:#999999; ">Updated 2023-10-31 22:20:46</span>

{{% blogdown/style %}}

**References**

- [Nominal, Ordinal, Interval, and Ratio Scales (Statistics by Jim)](https://statisticsbyjim.com/basics/nominal-ordinal-interval-ratio-scales/)

- [Scales of Measurement (Byju’s Learning)](https://byjus.com/maths/scales-of-measurement/)

- [Level of Measurement (Wikipedia)](https://en.wikipedia.org/wiki/Level_of_measurement#)

A good understanding of measurements of scale (MoS) is essential in both metric design as well as conducting analytics in order to avoid misapplying mathematical operations to the wrong input type leading to misleading or incorrect inferences. References are provided above, so I leave the reader to … well, *read*.
What I’d like to focus on are some specific characteristics about these scales.

I briefly discussed central tendency and statistical dispersion (distribution) [here](https://delriaan.github.io/2023/07/15/distributions-and-some-mean-advice/). The referenced material mentions appripriate measures of central tendency and dispersion. One way to appreciate why there is a need to pay attention to such prescription is to approach the treatment of MoS from an interpretive perspective: especially as it pertains to what is and isn’t said about a particular measurement type.

To begin, we’ll first consider *nominal* and *ordinal* measurements:

<table style="border:outset 2px; ">
<tr>
<th style="background-color:#555555; color:#DEDADF; padding:5px; " width="10%">Type</th>
<th style="background-color:#555555; color:#DEDADF; padding:5px; " width="45%">Indicates</th>
<th style="background-color:#555555; color:#DEDADF; padding:5px; " width="45%">Doesn't Indicate</th>
</tr>
<tr>
<td style="padding:5px" width="10%">Nominal</td>
<td style="padding:5px" width="45%">What is and is not</td>
<td style="padding:5px" width="45%">Intrinsic value, uniqueness</td>
</tr>
<tr>
<td style="padding:5px" width="10%">Ordinal</td>
<td style="padding:5px" width="45%">Order, relative position</td>
<td style="padding:5px" width="45%">Distance between positions; intrinsic value at each position</td>
</tr>
</table>

In both contexts, one should separate *syntax* from *semantics*; that is to say, the *symbolic representation* of a word (letters, symbols, etc.) as differentiated from the *meaning* behind the words. What does this differentiation look like? One example can be found with *numerals*. Numerals are not numbers but are used to represent the meaning of what a number is.

- With a nominal scale, the set of symbols `\(\{1, 2, 3, 9, 10\}\)` should be treated as no more than names or labels attached to something that has non-numeric meaning. The sentence, *“I named my cats 1, 3, and 10”* is an example of such a use case. Quantitatively, you can execute frequency counts as a first-order operation (by which I mean operating on the raw values directly).

- With an ordinal scale, the set of symbols `\(\{1, 2, 3, 4, 5\}\)` indicate order, but it would be invalid to attempt the first-order operation `\(2 + 10\)` under this context. One could easily replace the symbolic set with `\(\{\text{first}, \text{second}, \text{third}, \text{fourth}, \text{fifth}\}\)`. It should be obvious that attemping `\(\text{second} + \text{fifth}\)` would be absurd.

- Another thing to note is that ordinal scales map nominal elements to positions. In the table provided earlier, the labels “Nominal” and “Ordinal” are *nominal*. The order of appearance of “Nominal” and “Ordinal” is *ordinal*.

For nominal and (especially) ordinal scales, there is often antecedent background information that implicitly governs how values in the real world are mapped to measurements on a scale. For example, consider the qualifying decisions that are first made in determining how movies in a series are mapped to the ordinal scale `\(\{\text{awful}, \text{meh}, \text{awesome}\}\)`. Ordinal scales provide *no prima facie information* about such decisions.

<hr style="width:100%">

More can (and will) be said regarding the semantics of data, but for now, I’ll end things here and address *interval* and *ratio* MoS in a subsequent post.

<span style="font-family: Georgia; color: #444444; font-size: smaller; ">
<img src="3 cats.jpg" width="512" height="350.4"/>
<br/>
10, 1, and 3 in order of increasing age
</span>

{{% blogdown/footer %}}
