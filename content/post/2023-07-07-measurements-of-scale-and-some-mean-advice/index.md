---
title: Distributions and Some "Mean" Advice
author: Chionesu George
date: '2023-07-15'
slug: distributions-and-some-mean-advice
categories:
  - Theory
tags:
  - central tendency
  - distributions
  - statistics
  - data
output: html_document
---

**Focal Thoughts:**
   1. Simply reporting a measure of central tendency presents an incomplete picture of the data under study
   2. Choosing the wrong "mean" can mean trouble
   3. The values in a dataset should not be interpreted apart from the real-world elements they encode

# Average Value: Is it Informative? 

Inevitably, in reading anything involving reported statistics, the average value of some measurement will be reported. What exactly is being reported?  Simply put, the "center" of observed values.  That, however, is simply a description of the metric.  A more important question to ask is, _"Is this value informative or helpful in a decision-support context?"_:

   1. If all that is needed is a _"ballpark"_ estimate, the chance that the average value will be informative increases. _"We need to provide some performance measures for the quarterly newsletter: about how many families do we serve each month?"_ is an example of such a need.
   
   2. If the _range_ of likely values to be observed is of interest, the chance of the average value being informative often decreases.  _"We're trying to determine if we have enough analysts supporting to Family Services department: what is the average turnaround time for dashboard development?"_  The average value provides no information regarding how typical or a typical the measure is.  Hiring staff is time-consuming and expensive, so a more complete picture of what to expect is needed. 

In the second example, what is needed to properly satisfy the request is the _distribution_ of values from which the average value can be calculated as well as measures of the way the values are distributed.

# Central Tendency: _"Mean"ingful measures_

Truth be told, there is a logical fallacy contained in the preceding scenarios: [_"question-begging"_](https://www.merriam-webster.com/dictionary/question-begging), to be specific.  The question being begged is, _"Is the average the appropriate central-tendency measure to use?"_ By _"average"_, I specifically refer to the arithmetic mean.  Central tendency (CT) can be expressed in statistical and non-statistical terms, but the idea of values being _distributed around a centralized reference point_ remains. There are certain principles that guide the choice of CT measure, but for now, a brief word on _why_ knowing various CT measures matters:

# Why This Matters

- As a data practitioner, it is crucial to keep in mind that in using CT measures, you are not just executing mathematical operations on data detached from the real world the data encodes &mdash; you are making statements (explicitly or implicitly) about some quantifiable aspect of the real world, which includes the distribution and specific characteristics of the data values.
- The addage _"If all you have is a hammer, everything looks like a nail"_ applies: the choice of CT measure is not trivial &mdash; you are not always dealing with "nails" and undisciplined use of the arithmetic mean can result in invalid analysis and incorrect inferences as a result
- Knowing various CT measures allows you to be more deliberate regarding design decisions which is faster than having to "trial-and-error" your way to a solution. An added benefit is being in a better position to detect potential sources of errors in logic when evaluating business requests.

<hr style="width:100%">
Congratulations!  You made it =)  Thanks for allowing me to share a few nuggets of knowledge that I have personally found useful. Until we meet again, I wish you much success in your journey as a data practitioner!

{{< footer-include "content/footer.html" >}}
