
$(document).ready(function(){
  $("ul[context='definition']").hide();
  $("p[context='problemStatement']").hide();
  $("[role='toggle']").click(
    function(){
      lgrp = $(this).attr("toggleGroup");
      hint = $(this).find("hint").first();
      
      if (hint.text() == "(show)"){ hint.text("<hide>"); }
      else { hint.text("(show)"); }
      
      $("ul[toggleGroup='" + lgrp + "']").fadeToggle(10);
      $("p[toggleGroup='" + lgrp + "']").fadeToggle(10);
    }); 
  $("ul[context='definition']").first().click();
  $("p[context='problemStatement']").first().click();
})