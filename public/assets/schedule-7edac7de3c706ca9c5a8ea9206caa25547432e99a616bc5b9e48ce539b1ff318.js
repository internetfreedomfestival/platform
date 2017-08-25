(function() {
  var add_event_to_slot, make_draggable, update_event_position, update_unscheduled_events;

  update_event_position = function(event) {
    var td;
    td = $(event).data("slot");
    $(event).css("position", "absolute");
    $(event).css("left", td.offset().left);
    $(event).css("top", td.offset().top);
  };

  update_unscheduled_events = function(track_id) {
    if (track_id == null) {
      track_id = "";
    }
    $.ajax({
      url: $("form#update-track").attr("action"),
      data: {
        track_id: track_id
      },
      dataType: "html",
      success: function(data) {
        $("ul#unscheduled-events").html(data);
      }
    });
  };

  add_event_to_slot = function(event, td, update) {
    if (update == null) {
      update = true;
    }
    event = $(event);
    td = $(td);
    event.data("slot", td);
    td.append($(event));
    update_event_position(event);
    if (update) {
      event.data("time", td.data("time"));
      event.data("room", td.data("room"));
      $.ajax({
        url: event.data("update-url"),
        data: {
          "event": {
            "start_time": td.data("time"),
            "room_id": td.parents("table.room").data("room-id")
          }
        },
        type: "PUT",
        dataType: "script",
        success: function() {
          event.effect('highlight');
        }
      });
    }
  };

  make_draggable = function(element) {
    element.draggable({
      revert: "invalid",
      opacity: 0.4,
      cursorAt: {
        left: 5,
        top: 5
      }
    });
    return true;
  };

  $(function() {
    var button, event, i, j, k, len, len1, len2, ref, ref1, ref2, starting_cell, timeslot;
    $("body").delegate("div.event", "mouseenter", function() {
      var event_div, unschedule;
      event_div = $(this);
      if (event_div.find("a.close").length > 0) {
        return;
      }
      unschedule = $("<a href='#'>×</a>");
      unschedule.addClass("close").addClass("small");
      event_div.prepend(unschedule);
      unschedule.click(function(click_event) {
        $.ajax({
          url: event_div.data("update-url"),
          data: {
            "event": {
              "start_time": null,
              "room_id": null
            }
          },
          type: "PUT",
          dataType: "script",
          success: function() {
            event_div.remove();
            update_unscheduled_events();
          }
        });
        click_event.stopPropagation();
        click_event.preventDefault();
        return false;
      });
    });
    $("body").delegate("div.event", "mouseleave", function() {
      $(this).find("a.close").remove();
    });
    $("body").delegate("div.event", "click", function(click_event) {
      click_event.stopPropagation();
      click_event.preventDefault();
      return false;
    });
    ref = $("a.toggle-room");
    for (i = 0, len = ref.length; i < len; i++) {
      button = ref[i];
      $(button).click(function() {
        var current_button, event, j, len1, ref1;
        current_button = $(this);
        $("table[data-room='" + current_button.data('room') + "']").toggle();
        if (current_button.hasClass("success")) {
          current_button.removeClass("success");
        } else {
          current_button.addClass("success");
        }
        ref1 = $("table.room div.event");
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          event = ref1[j];
          update_event_position(event);
          true;
        }
        preventDefault();
        return false;
      });
      true;
    }
    $("a#hide-all-rooms").click(function() {
      $("a.toggle-room").removeClass("success");
      $("table.room").hide();
      return false;
    });
    $("select#track_select").change(function() {
      update_unscheduled_events($(this).val());
      return true;
    });
    ref1 = $("table.room td");
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      timeslot = ref1[j];
      $(timeslot).droppable({
        hoverClass: "event-hover",
        tolerance: "pointer",
        drop: function(event, ui) {
          add_event_to_slot(ui.draggable, this);
          return true;
        }
      });
      true;
    }
    $("#add-event-modal").modal('hide');
    $("body").delegate("table.room td", "click", function(click_event) {
      var td;
      td = $(this);
      $("#add-event-modal #current-time").html(td.data("time"));
      $("ul#unscheduled-events").undelegate("click");
      $("ul#unscheduled-events").delegate("li a", "click", function(click_event) {
        var li, new_event;
        li = $(this).parent();
        new_event = $("<div></div>");
        new_event.html(li.children().first().html());
        new_event.addClass("event");
        new_event.attr("id", li.attr("id"));
        new_event.css("height", li.data("height"));
        new_event.data("update-url", li.data("update-url"));
        $("#event-pane").append(new_event);
        add_event_to_slot(new_event, td);
        make_draggable(new_event);
        li.remove();
        $("#add-event-modal").modal('hide');
        click_event.preventDefault();
        return false;
      });
      $("#add-event-modal").modal('show');
      click_event.stopPropagation();
      return false;
    });
    ref2 = $("div.event");
    for (k = 0, len2 = ref2.length; k < len2; k++) {
      event = ref2[k];
      if ($(event).data("room") && $(event).data("time")) {
        starting_cell = $("table[data-room='" + $(event).data("room") + "']").find("td[data-time='" + $(event).data("time") + "']");
        add_event_to_slot(event, starting_cell, false);
      }
      make_draggable($(event));
      true;
    }
  });

}).call(this);
