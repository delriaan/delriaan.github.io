# You can create a circle with a border and partial transparency in SVG (Scalable Vector Graphics) using the `<circle>` element along with CSS styles for the border and transparency. Here's an example of how you can do it:
library(htmltools)

svg_circle <- \(x = NULL, cx = 50, cy = 50, r = 50, fill = rgb(0.5, 0.5, 0.5, 1), ...){ 
  circle <- htmltools::tags$circle(cx = cx, cy = cy, fill = fill, r = r, ...);
  append(x, list(circle))
}

svg_intersect <- { c(
  tags$g(
    id = "g1"
    , svg_circle(cx = 60, cy = 60, r = 60) %>% 
      svg_circle(cx = 60, cy = 60, r = 60, stroke = "black", stroke_width="2", fill="none")
    )
  , tags$g(
      id = "g2"
      , svg_circle(cx = 120, cy = 60, r = 60, fill = rgb(0, 1, 0, 0.5)) %>% 
        svg_circle(cx = 120, cy = 60, r = 60, stroke = "#000000", stroke_width="2", fill="none")
      )
  , tags$g(
      id = "g3"
      , svg_circle(cx = 90, cy = 120, r = 60, fill = rgb(0, 0, 1, 0.5)) %>% 
        svg_circle(cx = 90, cy = 120, r = 60, stroke = "#000000", stroke_width="2", fill="none")
      )
  ) %>%
  tags$svg(width = 200, height = 200, xmlns="http://www.w3.org/2000/svg") 
}
svg_disjoint <- { c(
  tags$g(
    id = "g1"
    , svg_circle(cx = 60, cy = 60, r = 60) %>% 
      svg_circle(cx = 60, cy = 60, r = 60, stroke = "black", stroke_width="2", fill="none")
    )
  , tags$g(
      id = "g2"
      , svg_circle(cx = 120 + 60, cy = 60, r = 60, fill = rgb(0, 1, 0, 0.5)) %>% 
        svg_circle(cx = 120 + 60, cy = 60, r = 60, stroke = "#000000", stroke_width="2", fill="none")
      )
  , tags$g(
      id = "g3"
      , svg_circle(cx = 90 + 30, cy = 190 * cos(pi * 30/180), r = 60, fill = rgb(0, 0, 1, 0.5)) %>% 
        svg_circle(cx = 90 + 30, cy = 190 * cos(pi * 30/180), r = 60, stroke = "#000000", stroke_width="2", fill="none")
      )
  ) %>%
  tags$svg(width = 240, height = 240, xmlns="http://www.w3.org/2000/svg") 
}

# html_print(svg_intersect)
html_print(list(svg_intersect, svg_disjoint))


# In this example:
# - `<circle>` elements are used to create both the filled circle with partial transparency and the circle border.
# - `cx` and `cy` attributes specify the center coordinates of the circle.
# - `r` attribute specifies the radius of the circle.
# - `fill` attribute is set to `rgba(255, 0, 0, 0.5)` which specifies the color red with 50% transparency.
# - `stroke` attribute sets the color of the border (black in this case).
# - `stroke-width` attribute sets the width of the border.
# - `fill="none"` ensures that the border doesn't have a fill color.
# 
# You can adjust the values of `fill` and `stroke` as needed to achieve the desired appearance.