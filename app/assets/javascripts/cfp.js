$( document ).ready(function() {
  if ($("#event_track_id option:selected").text() != "Workshop"){
    var time_6 = document.getElementById("event_time_slots_6")
    $(time_6).attr('disabled','disabled');
  }
  var element = document.getElementById("dif_form");
    if( $("#travel").attr("checked")) {
      $(element).show()
    }
  $("#travel").on("click", function(){
    var x = document.getElementById("dif_form");
      $(element).toggle()
    })
  $("#event_track_id").on("change", function(){
    var time_6 = document.getElementById("event_time_slots_6")
    if ($("#event_track_id option:selected").text() == "Workshop"){
      $(time_6).removeAttr('disabled');
    }else{
      $(time_6).attr('disabled','disabled');
      $(time_6).attr('checked',null);
    }
  })
});
