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

  $("#iff_before_checkboxes input[type=checkbox]").on("click", function(){
    if ($(this).attr("id") == "event_iff_before_not_yet") {
      $("#event_iff_before_2015").attr('checked',null)
      $("#event_iff_before_2016").attr('checked',null)
      $("#event_iff_before_2017").attr('checked',null)
      $("#event_iff_before_2018").attr('checked',null)
    }
    else{
      $("#event_iff_before_not_yet").attr('checked',null)
    }
  })


  $("#past_travel_assistance_checkboxes input[type=checkbox]").on("click", function(){
    if ($(this).attr("id") == "event_past_travel_assistance_no") {
      $("#event_past_travel_assistance_2017").attr('checked',null)
      $("#event_past_travel_assistance_2018").attr('checked',null)
    }
    else{
      $("#event_past_travel_assistance_no").attr('checked',null)
    }
  })
});
