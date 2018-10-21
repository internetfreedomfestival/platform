$(document).ready(function() {
  $("#iff_before_checkboxes input[type=checkbox]").on("click", function(){
    if ($(this).attr("id") == "ticket_iff_before_not_yet") {
      $("#ticket_iff_before_2015").attr('checked',null)
      $("#ticket_iff_before_2016").attr('checked',null)
      $("#ticket_iff_before_2017").attr('checked',null)
      $("#ticket_iff_before_2018").attr('checked',null)
    }
    else{
      $("#ticket_iff_before_not_yet").attr('checked',null)
    }
  })

  $("#iff_days_checkboxes input[type=checkbox]").on("click", function(){
    if ($(this).attr("id") == "ticket_iff_days_full_week") {
      $("#ticket_iff_days_monday_april_1st").attr('checked',null)
      $("#ticket_iff_days_tuesday_april_2nd").attr('checked',null)
      $("#ticket_iff_days_wednesday_april_3rd").attr('checked',null)
      $("#ticket_iff_days_thursday_april_4th").attr('checked',null)
      $("#ticket_iff_days_friday_april_5th").attr('checked',null)
    }
    else{
      $("#ticket_iff_days_full_week").attr('checked',null)
    }
  })

  $("#ticket_option input[type=radio]").on("click", function(){
    var element = document.getElementById("different_amount");
    var element850 = document.getElementById("amount850");
    document.getElementById("custom_amount").value = "";

    if( $("#ticket_ticket_option_free").attr("checked")) {
      $(element).show()
      $(element850).hide()
    }
    else{
      $(element850).show()
      $(element).hide()
    }
  })

  $("#custom_amount").keyup(function(){
    var element = document.getElementById("ticket_amount_amount");
    var custom_value = document.getElementById("custom_amount").value
    element.checked = "checked";
    element.setAttribute("value", custom_value);
  })
});
