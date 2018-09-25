$( document ).ready(function() {
  $("#travel").on("click", function(){
    var x = document.getElementById("dif_form");
      if(x.style.display === "block"){
        x.style.display = "none";
      } else {
        x.style.display = "block";
      }
    })
  });
