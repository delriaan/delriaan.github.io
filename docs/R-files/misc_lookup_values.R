# <snippet: get number words> ----
num_words <- c(
	1, "One",	
	2, "Two",	
	3, "Three",	
	4, "Four",	
	5, "Five",	
	6, "Six",	
	7, "Seven",		
	8, "Eight",	
	9, "Nine",	
	10, "Ten",	
	11, "Eleven",
	12, "Twelve",
	13, "Thirteen",
	14, "Fourteen",
	15, "Fifteen",
	16, "Sixteen",
	17, "Seventeen",
	18, "Eighteen",
	19, "Nineteen",
	20, "Twenty"
	) |>
	matrix(ncol = 2, byrow = TRUE, dimnames = list(NULL, c("numeral", "word")))
# </snippet>