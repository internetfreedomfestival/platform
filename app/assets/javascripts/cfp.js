$( document ).ready(function() {
  var element = document.getElementById("dif_form");
    if( $("#travel").attr("checked")) {
      $(element).show()
    }
  $("#travel").on("click", function(){
    var x = document.getElementById("dif_form");
      $(element).toggle()
    })
  });
