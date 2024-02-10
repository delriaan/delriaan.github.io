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

<script src="/rmarkdown-libs/htmlwidgets/htmlwidgets.js"></script>
<script src="/rmarkdown-libs/plotly-binding/plotly.js"></script>
<script src="/rmarkdown-libs/typedarray/typedarray.min.js"></script>
<script src="/rmarkdown-libs/jquery/jquery.min.js"></script>
<link href="/rmarkdown-libs/crosstalk/css/crosstalk.min.css" rel="stylesheet" />
<script src="/rmarkdown-libs/crosstalk/js/crosstalk.min.js"></script>
<link href="/rmarkdown-libs/plotly-htmlwidgets-css/plotly-htmlwidgets.css" rel="stylesheet" />
<script src="/rmarkdown-libs/plotly-main/plotly-latest.min.js"></script>

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
`\(\Big\rangle\)` by
`\(\Big\langle\)`
<span msg_id="h1">`\(h_1\)`</span>,
<span msg_id="h2">`\(h_2\)`</span>,
<span msg_id="h3">`\(h_3\)`</span>
`\(\Big\rangle\)`:

- `\(f(W, \omega_i)\to \gamma_j;\)`: ***What*** derived from ***who*** and ***when***

- `\(g(\gamma_j, h_k):= R_{\gamma\times h}\)`: The `\(\gamma\)` by `\(h\)` report matrix defining ***how*** the metrics are aggregated.

Now for the fun part: If `\(h\)` were limited to `\(h_2\)` and `\(h_3\)`, the report matrix `\(R\)` would be quite straight-forward to derive, appropriately aggregating `\(\gamma_j\)` by each `\(h\)`.

**That’s not the fun part.** 😏

The fun part is taking into account `\(h_1\)`, a time-based requirement that adds a layer of complexity to the report matrix depending on the metric. For example, consider <span msg_id="g4">`\(\gamma_4\)`</span>, an, easy metric to aggregate across each of `\(h_k\)`. Contrast that with <span msg_id="g1">`\(\gamma_1\)`</span>, which presents a temporal **windowing** problem with respect to <span msg_id="h1">`\(h_1\)`</span> since both involve windows of time:

<div id="htmlwidget-1" style="width:100%;height:720px;" class="plotly html-widget "></div> <script type="application/json" data-for="htmlwidget-1">{"x":{"visdat":{"7d2c40357ff7":["function () ","plotlyVisDat"]},"cur_data":"7d2c40357ff7","attrs":{"7d2c40357ff7":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":5,"y":-5,"xend":5,"yend":30,"type":"scatter","mode":"lines","color":["#000000"],"line":{"width":5},"name":"W (start)","showlegend":false,"inherit":true},"7d2c40357ff7.1":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":90,"y":-5,"xend":90,"yend":30,"type":"scatter","mode":"lines","color":["#000000"],"line":{"width":5},"name":"W (end)","showlegend":false,"inherit":true},"7d2c40357ff7.2":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":0,"y":-50,"xend":0,"yend":50,"type":"scatter","mode":"lines","color":["#555555"],"line":{"dash":"dash"},"name":"","opacity":0.20000000000000001,"showlegend":false,"inherit":true},"7d2c40357ff7.3":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":25,"y":-50,"xend":25,"yend":50,"type":"scatter","mode":"lines","color":["#555555"],"line":{"dash":"dash"},"name":"","opacity":0.20000000000000001,"showlegend":false,"inherit":true},"7d2c40357ff7.4":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":50,"y":-50,"xend":50,"yend":50,"type":"scatter","mode":"lines","color":["#555555"],"line":{"dash":"dash"},"name":"","opacity":0.20000000000000001,"showlegend":false,"inherit":true},"7d2c40357ff7.5":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":75,"y":-50,"xend":75,"yend":50,"type":"scatter","mode":"lines","color":["#555555"],"line":{"dash":"dash"},"name":"","opacity":0.20000000000000001,"showlegend":false,"inherit":true},"7d2c40357ff7.6":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":100,"y":-50,"xend":100,"yend":50,"type":"scatter","mode":"lines","color":["#555555"],"line":{"dash":"dash"},"name":"","opacity":0.20000000000000001,"showlegend":false,"inherit":true},"7d2c40357ff7.7":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":2,"y":0,"xend":13,"yend":0,"type":"scatter","mode":"lines","color":"rgba(224,238,238,1)","hoverinfo":"text","hovertext":"<b>Member A<\/b><br>t<sub>2<\/sub> to t<sub>13<\/sub>","legendgroup":"Member A","marker":{"symbol":"circle","size":15},"name":"Member A","showlegend":true,"stroke":["#333333"],"inherit":true},"7d2c40357ff7.8":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":14,"y":1,"xend":31,"yend":1,"type":"scatter","mode":"lines","color":"rgba(224,238,238,1)","hoverinfo":"text","hovertext":"<b>Member A<\/b><br>t<sub>14<\/sub> to t<sub>31<\/sub>","legendgroup":"Member A","marker":{"symbol":"circle","size":15},"name":2,"showlegend":false,"stroke":["#333333"],"inherit":true},"7d2c40357ff7.9":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":34,"y":2,"xend":34,"yend":2,"type":"scatter","mode":"lines","color":"rgba(224,238,238,1)","hoverinfo":"text","hovertext":"<b>Member A<\/b><br>t<sub>34<\/sub> to t<sub>34<\/sub>","legendgroup":"Member A","marker":{"symbol":"circle","size":15},"name":3,"showlegend":false,"stroke":["#333333"],"inherit":true},"7d2c40357ff7.10":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":12,"y":3,"xend":12,"yend":3,"type":"scatter","mode":"lines","color":"rgba(255,114,86,1)","hoverinfo":"text","hovertext":"<b>Member B<\/b><br>t<sub>12<\/sub> to t<sub>12<\/sub>","legendgroup":"Member B","marker":{"symbol":"diamond","size":15},"name":"Member B","showlegend":true,"stroke":["#333333"],"inherit":true},"7d2c40357ff7.11":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":14,"y":4,"xend":30,"yend":4,"type":"scatter","mode":"lines","color":"rgba(255,114,86,1)","hoverinfo":"text","hovertext":"<b>Member B<\/b><br>t<sub>14<\/sub> to t<sub>30<\/sub>","legendgroup":"Member B","marker":{"symbol":"diamond","size":15},"name":2,"showlegend":false,"stroke":["#333333"],"inherit":true},"7d2c40357ff7.12":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":31,"y":5,"xend":39,"yend":5,"type":"scatter","mode":"lines","color":"rgba(255,114,86,1)","hoverinfo":"text","hovertext":"<b>Member B<\/b><br>t<sub>31<\/sub> to t<sub>39<\/sub>","legendgroup":"Member B","marker":{"symbol":"diamond","size":15},"name":3,"showlegend":false,"stroke":["#333333"],"inherit":true},"7d2c40357ff7.13":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":5,"y":5,"xend":9,"yend":5,"type":"scatter","mode":"lines","color":"rgba(46,46,46,1)","hoverinfo":"text","hovertext":"<b>Member C<\/b><br>t<sub>5<\/sub> to t<sub>9<\/sub>","legendgroup":"Member C","marker":{"symbol":"square","size":15},"name":"Member C","showlegend":true,"stroke":["#333333"],"inherit":true},"7d2c40357ff7.14":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":10,"y":6,"xend":11,"yend":6,"type":"scatter","mode":"lines","color":"rgba(46,46,46,1)","hoverinfo":"text","hovertext":"<b>Member C<\/b><br>t<sub>10<\/sub> to t<sub>11<\/sub>","legendgroup":"Member C","marker":{"symbol":"square","size":15},"name":2,"showlegend":false,"stroke":["#333333"],"inherit":true},"7d2c40357ff7.15":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":12,"y":7,"xend":46,"yend":7,"type":"scatter","mode":"lines","color":"rgba(46,46,46,1)","hoverinfo":"text","hovertext":"<b>Member C<\/b><br>t<sub>12<\/sub> to t<sub>46<\/sub>","legendgroup":"Member C","marker":{"symbol":"square","size":15},"name":3,"showlegend":false,"stroke":["#333333"],"inherit":true},"7d2c40357ff7.16":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":47,"y":8,"xend":48,"yend":8,"type":"scatter","mode":"lines","color":"rgba(46,46,46,1)","hoverinfo":"text","hovertext":"<b>Member C<\/b><br>t<sub>47<\/sub> to t<sub>48<\/sub>","legendgroup":"Member C","marker":{"symbol":"square","size":15},"name":4,"showlegend":false,"stroke":["#333333"],"inherit":true},"7d2c40357ff7.17":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":56,"y":9,"xend":59,"yend":9,"type":"scatter","mode":"lines","color":"rgba(46,46,46,1)","hoverinfo":"text","hovertext":"<b>Member C<\/b><br>t<sub>56<\/sub> to t<sub>59<\/sub>","legendgroup":"Member C","marker":{"symbol":"square","size":15},"name":5,"showlegend":false,"stroke":["#333333"],"inherit":true},"7d2c40357ff7.18":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":13,"y":10,"xend":36,"yend":10,"type":"scatter","mode":"lines","color":"rgba(244,164,96,1)","hoverinfo":"text","hovertext":"<b>Member D<\/b><br>t<sub>13<\/sub> to t<sub>36<\/sub>","legendgroup":"Member D","marker":{"symbol":"hexagon","size":15},"name":"Member D","showlegend":true,"stroke":["#333333"],"inherit":true},"7d2c40357ff7.19":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":19,"y":13,"xend":36,"yend":13,"type":"scatter","mode":"lines","color":"rgba(135,135,135,1)","hoverinfo":"text","hovertext":"<b>Member E<\/b><br>t<sub>19<\/sub> to t<sub>36<\/sub>","legendgroup":"Member E","marker":{"symbol":"triangle-up","size":15},"name":"Member E","showlegend":true,"stroke":["#333333"],"inherit":true}},"layout":{"height":720,"margin":{"b":-5,"l":60,"t":-5,"r":10},"annotations":[{"text":"W<sub>start<\/sub>","x":5,"y":1.05,"xref":"plot","yref":"paper","showarrow":false,"font":{"size":16,"color":"black"}},{"text":"W<sub>start<\/sub>","x":5,"y":1.05,"xref":"plot","yref":"paper","showarrow":false,"font":{"size":16,"color":"black"}},{"text":"W<sub>end<\/sub>","x":90,"y":1.05,"xref":"plot","yref":"paper","showarrow":false,"font":{"size":16,"color":"black"}},{"text":"W<sub>end<\/sub>","x":90,"y":1.05,"xref":"plot","yref":"paper","showarrow":false,"font":{"size":16,"color":"black"}}],"xaxis":{"domain":[0,1],"automargin":true,"title":{"text":"<b>Time<\/b>: Report window (W) and h<sub>1<\/sub>"},"range":[-5,100],"showgrid":false,"zeroline":false,"showline":false,"showticklabels":false},"yaxis":{"domain":[0,1],"automargin":true,"title":{"text":""},"range":[-1,15],"showgrid":false,"zeroline":false,"showline":false,"showticklabels":false},"paper_bgcolor":["#999999"],"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[5,5],"y":[-5,30],"type":"scatter","mode":"lines","line":{"color":"rgba(0,0,0,1)","width":5},"name":"W (start)","showlegend":false,"marker":{"color":"rgba(0,0,0,1)","line":{"color":"rgba(0,0,0,1)"}},"textfont":{"color":"rgba(0,0,0,1)"},"error_y":{"color":"rgba(0,0,0,1)"},"error_x":{"color":"rgba(0,0,0,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[90,90],"y":[-5,30],"type":"scatter","mode":"lines","line":{"color":"rgba(0,0,0,1)","width":5},"name":"W (end)","showlegend":false,"marker":{"color":"rgba(0,0,0,1)","line":{"color":"rgba(0,0,0,1)"}},"textfont":{"color":"rgba(0,0,0,1)"},"error_y":{"color":"rgba(0,0,0,1)"},"error_x":{"color":"rgba(0,0,0,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[0,0],"y":[-50,50],"type":"scatter","mode":"lines","line":{"color":"rgba(85,85,85,1)","dash":"dash"},"name":"","opacity":0.20000000000000001,"showlegend":false,"marker":{"color":"rgba(85,85,85,1)","line":{"color":"rgba(85,85,85,1)"}},"textfont":{"color":"rgba(85,85,85,1)"},"error_y":{"color":"rgba(85,85,85,1)"},"error_x":{"color":"rgba(85,85,85,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[25,25],"y":[-50,50],"type":"scatter","mode":"lines","line":{"color":"rgba(85,85,85,1)","dash":"dash"},"name":"","opacity":0.20000000000000001,"showlegend":false,"marker":{"color":"rgba(85,85,85,1)","line":{"color":"rgba(85,85,85,1)"}},"textfont":{"color":"rgba(85,85,85,1)"},"error_y":{"color":"rgba(85,85,85,1)"},"error_x":{"color":"rgba(85,85,85,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[50,50],"y":[-50,50],"type":"scatter","mode":"lines","line":{"color":"rgba(85,85,85,1)","dash":"dash"},"name":"","opacity":0.20000000000000001,"showlegend":false,"marker":{"color":"rgba(85,85,85,1)","line":{"color":"rgba(85,85,85,1)"}},"textfont":{"color":"rgba(85,85,85,1)"},"error_y":{"color":"rgba(85,85,85,1)"},"error_x":{"color":"rgba(85,85,85,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[75,75],"y":[-50,50],"type":"scatter","mode":"lines","line":{"color":"rgba(85,85,85,1)","dash":"dash"},"name":"","opacity":0.20000000000000001,"showlegend":false,"marker":{"color":"rgba(85,85,85,1)","line":{"color":"rgba(85,85,85,1)"}},"textfont":{"color":"rgba(85,85,85,1)"},"error_y":{"color":"rgba(85,85,85,1)"},"error_x":{"color":"rgba(85,85,85,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[100,100],"y":[-50,50],"type":"scatter","mode":"lines","line":{"color":"rgba(85,85,85,1)","dash":"dash"},"name":"","opacity":0.20000000000000001,"showlegend":false,"marker":{"color":"rgba(85,85,85,1)","line":{"color":"rgba(85,85,85,1)"}},"textfont":{"color":"rgba(85,85,85,1)"},"error_y":{"color":"rgba(85,85,85,1)"},"error_x":{"color":"rgba(85,85,85,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[2,13],"y":[0,0],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member A<\/b><br>t<sub>2<\/sub> to t<sub>13<\/sub>","<b>Member A<\/b><br>t<sub>2<\/sub> to t<sub>13<\/sub>"],"legendgroup":"Member A","marker":{"color":"rgba(252,141,98,1)","symbol":"circle","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":"Member A","showlegend":true,"error_y":{"color":"rgba(252,141,98,1)","thickness":1},"error_x":{"color":"rgba(252,141,98,1)","thickness":1},"textfont":{"color":"rgba(252,141,98,1)"},"line":{"color":"rgba(252,141,98,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[14,31],"y":[1,1],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member A<\/b><br>t<sub>14<\/sub> to t<sub>31<\/sub>","<b>Member A<\/b><br>t<sub>14<\/sub> to t<sub>31<\/sub>"],"legendgroup":"Member A","marker":{"color":"rgba(252,141,98,1)","symbol":"circle","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":2,"showlegend":false,"error_y":{"color":"rgba(252,141,98,1)","thickness":1},"error_x":{"color":"rgba(252,141,98,1)","thickness":1},"textfont":{"color":"rgba(252,141,98,1)"},"line":{"color":"rgba(252,141,98,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[34,34],"y":[2,2],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member A<\/b><br>t<sub>34<\/sub> to t<sub>34<\/sub>","<b>Member A<\/b><br>t<sub>34<\/sub> to t<sub>34<\/sub>"],"legendgroup":"Member A","marker":{"color":"rgba(252,141,98,1)","symbol":"circle","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":3,"showlegend":false,"error_y":{"color":"rgba(252,141,98,1)","thickness":1},"error_x":{"color":"rgba(252,141,98,1)","thickness":1},"textfont":{"color":"rgba(252,141,98,1)"},"line":{"color":"rgba(252,141,98,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[12,12],"y":[3,3],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member B<\/b><br>t<sub>12<\/sub> to t<sub>12<\/sub>","<b>Member B<\/b><br>t<sub>12<\/sub> to t<sub>12<\/sub>"],"legendgroup":"Member B","marker":{"color":"rgba(231,138,195,1)","symbol":"diamond","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":"Member B","showlegend":true,"error_y":{"color":"rgba(231,138,195,1)","thickness":1},"error_x":{"color":"rgba(231,138,195,1)","thickness":1},"textfont":{"color":"rgba(231,138,195,1)"},"line":{"color":"rgba(231,138,195,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[14,30],"y":[4,4],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member B<\/b><br>t<sub>14<\/sub> to t<sub>30<\/sub>","<b>Member B<\/b><br>t<sub>14<\/sub> to t<sub>30<\/sub>"],"legendgroup":"Member B","marker":{"color":"rgba(231,138,195,1)","symbol":"diamond","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":2,"showlegend":false,"error_y":{"color":"rgba(231,138,195,1)","thickness":1},"error_x":{"color":"rgba(231,138,195,1)","thickness":1},"textfont":{"color":"rgba(231,138,195,1)"},"line":{"color":"rgba(231,138,195,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[31,39],"y":[5,5],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member B<\/b><br>t<sub>31<\/sub> to t<sub>39<\/sub>","<b>Member B<\/b><br>t<sub>31<\/sub> to t<sub>39<\/sub>"],"legendgroup":"Member B","marker":{"color":"rgba(231,138,195,1)","symbol":"diamond","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":3,"showlegend":false,"error_y":{"color":"rgba(231,138,195,1)","thickness":1},"error_x":{"color":"rgba(231,138,195,1)","thickness":1},"textfont":{"color":"rgba(231,138,195,1)"},"line":{"color":"rgba(231,138,195,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[5,9],"y":[5,5],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member C<\/b><br>t<sub>5<\/sub> to t<sub>9<\/sub>","<b>Member C<\/b><br>t<sub>5<\/sub> to t<sub>9<\/sub>"],"legendgroup":"Member C","marker":{"color":"rgba(166,216,84,1)","symbol":"square","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":"Member C","showlegend":true,"error_y":{"color":"rgba(166,216,84,1)","thickness":1},"error_x":{"color":"rgba(166,216,84,1)","thickness":1},"textfont":{"color":"rgba(166,216,84,1)"},"line":{"color":"rgba(166,216,84,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[10,11],"y":[6,6],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member C<\/b><br>t<sub>10<\/sub> to t<sub>11<\/sub>","<b>Member C<\/b><br>t<sub>10<\/sub> to t<sub>11<\/sub>"],"legendgroup":"Member C","marker":{"color":"rgba(166,216,84,1)","symbol":"square","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":2,"showlegend":false,"error_y":{"color":"rgba(166,216,84,1)","thickness":1},"error_x":{"color":"rgba(166,216,84,1)","thickness":1},"textfont":{"color":"rgba(166,216,84,1)"},"line":{"color":"rgba(166,216,84,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[12,46],"y":[7,7],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member C<\/b><br>t<sub>12<\/sub> to t<sub>46<\/sub>","<b>Member C<\/b><br>t<sub>12<\/sub> to t<sub>46<\/sub>"],"legendgroup":"Member C","marker":{"color":"rgba(166,216,84,1)","symbol":"square","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":3,"showlegend":false,"error_y":{"color":"rgba(166,216,84,1)","thickness":1},"error_x":{"color":"rgba(166,216,84,1)","thickness":1},"textfont":{"color":"rgba(166,216,84,1)"},"line":{"color":"rgba(166,216,84,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[47,48],"y":[8,8],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member C<\/b><br>t<sub>47<\/sub> to t<sub>48<\/sub>","<b>Member C<\/b><br>t<sub>47<\/sub> to t<sub>48<\/sub>"],"legendgroup":"Member C","marker":{"color":"rgba(166,216,84,1)","symbol":"square","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":4,"showlegend":false,"error_y":{"color":"rgba(166,216,84,1)","thickness":1},"error_x":{"color":"rgba(166,216,84,1)","thickness":1},"textfont":{"color":"rgba(166,216,84,1)"},"line":{"color":"rgba(166,216,84,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[56,59],"y":[9,9],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member C<\/b><br>t<sub>56<\/sub> to t<sub>59<\/sub>","<b>Member C<\/b><br>t<sub>56<\/sub> to t<sub>59<\/sub>"],"legendgroup":"Member C","marker":{"color":"rgba(166,216,84,1)","symbol":"square","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":5,"showlegend":false,"error_y":{"color":"rgba(166,216,84,1)","thickness":1},"error_x":{"color":"rgba(166,216,84,1)","thickness":1},"textfont":{"color":"rgba(166,216,84,1)"},"line":{"color":"rgba(166,216,84,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[13,36],"y":[10,10],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member D<\/b><br>t<sub>13<\/sub> to t<sub>36<\/sub>","<b>Member D<\/b><br>t<sub>13<\/sub> to t<sub>36<\/sub>"],"legendgroup":"Member D","marker":{"color":"rgba(141,160,203,1)","symbol":"hexagon","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":"Member D","showlegend":true,"error_y":{"color":"rgba(141,160,203,1)","thickness":1},"error_x":{"color":"rgba(141,160,203,1)","thickness":1},"textfont":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[19,36],"y":[13,13],"type":"scatter","mode":"lines+markers","hoverinfo":["text","text"],"hovertext":["<b>Member E<\/b><br>t<sub>19<\/sub> to t<sub>36<\/sub>","<b>Member E<\/b><br>t<sub>19<\/sub> to t<sub>36<\/sub>"],"legendgroup":"Member E","marker":{"color":"rgba(102,194,165,1)","symbol":"triangle-up","size":15,"line":{"color":"rgba(51,51,51,1)","width":1}},"name":"Member E","showlegend":true,"error_y":{"color":"rgba(102,194,165,1)","thickness":1},"error_x":{"color":"rgba(102,194,165,1)","thickness":1},"textfont":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>

Multiple members with multiple events spanning multiple segments of time:

- How does one select the appropriate window of time for each member and event?
- By event end or beginning?
- By any event within the window?
- How does one address multiple events for a single member within a single window?
- ***Bonus question***: Is the arithmetic mean the best way to aggregate the data in the first place?

Fortunately, the goal here isn’t to resolve these questions but to illustrate the complexities of temporal concurrency at various levels. It’s been my experience that dealing with the temporal aspects of an analytic use case can be challenging. Fun, right? 😁

<img src="/decorative_line.png" class="decorative-line" />

## <span style="font-size:1.5em;">🎉</span><span class="decorativeText">Congratulations!</span>

Just a few remarks to close out this series:

- I encourage you to get in the habit of framing your problem statements in terms of the ***what***, ***when***, ***who***, and ***how***. It’s a simple way to ensure that you’re considering the right questions at the right time (slight pun intended). Don’t be in a rush to jump from problem statement to code: interrogate the problem statement like an 80’s detective show.

- Always investigate how time affects your problem statement as it relates to **inclusion criteria**, **metrics derivation**, and **reporting**. The way you go about retrieving data or feature engineering can be greatly influenced by the temporal aspects of your problem.

- If possible, during the discovery phase of your analytics project, determine what form the results will take in the final data product. Knowing this can help guide your thought process when considering how much data to wrangle and transform within the data produce vs. within the upstream data pipeline. This is especially important when there are temporal dynamics to the analysis tied to dynamically calculated metrics: an example would be moving averages, cumulative sums, etc. in an interactive dashboard.

{{% blogdown/footer %}}
