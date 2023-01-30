$(document).ready(function(){
 /* ----------------------------------------
 R version 4.1.3 (2022-03-10)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 22621)
2023-01-28 01:28:37
 ---------------------------------------- */

  $("div[context='formalCause']").hide();
  $("blockquote[context='formalCause']").hide();
  $("[role='toggle'][context='formalCause']").first().find("hint").first().text("[explore]");

  $("[role='toggle']").click(
    function(){
      lgrp = $(this).attr("toggleGroup");
      hint = $(this).find("hint").first();

      if (hint.text() === "[explore]"){ hint.text("[hide]"); } else { hint.text("[explore]"); }
      $("div[toggleGroup='" + lgrp + "']").fadeToggle(10);
      $("blockquote[toggleGroup='" + lgrp + "']").fadeToggle(10);
   });
});
