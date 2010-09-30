$("input[type=submit], button").livequery(function() {
    $(this).button();
});

$("input[type=text], input[type=password]").livequery(function() {
    $(this).addClass("ui-corner-all");
});

$(".errorExplanation ul").livequery(function() {
    $(this).addClass("ui-widget");
    $("li", $(this)).addClass("ui-state-error");
    $("li", $(this)).addClass("ui-corner-all");
    $("li", $(this)).prepend("<span class='ui-icon ui-icon-alert' style='float: left; margin-right: 5px'></span>");
});

var UserProjectRolesForm = function() {
   var self = this;
   $('.person-draggable').draggable({
            revert: 'invalid',
            containment: 'document',
            helper: 'clone',
            cursor: 'move'
    });

    $("#available_people").droppable({
      accept: '.person-draggable',
      drop: function(ev, ui) {
        $item = ui.draggable;
        $item.appendTo($('#available_people'));
      }
    });

    $("#team_members_droppable").droppable({
      accept: '.person-draggable',
      drop: function(ev, ui) {
        $item = ui.draggable;
        $item.appendTo($("#team_members_droppable"));
      }
    });

    $("#stakeholders_droppable").droppable({
      accept: '.person-draggable',
      drop: function(ev, ui) {
        $item = ui.draggable;
        $item.appendTo($("#stakeholders_droppable"));
      }
    });

    $("#scrum_master_droppable").droppable({
      accept: '.person-draggable',
      drop: function(ev, ui) {
        $item = ui.draggable;
        $('.person-draggable', $("#scrum_master_droppable")).appendTo($("#available_people"));
        $item.appendTo($("#scrum_master_droppable"));
      }
    });

    $("#product_owner_droppable").droppable({
      accept: '.person-draggable',
      drop: function(ev, ui) {
        $item = ui.draggable;
        $('.person-draggable', $("#product_owner_droppable")).appendTo($("#available_people"));
        $item.appendTo($("#product_owner_droppable"));
      }
    });

    self.updateHiddenFields = function() {
      if ($("#scrum_master_droppable .person-draggable").size() > 0)
          $("#project_scrum_master_id").val($("#scrum_master_droppable .person-draggable").attr("userId"));
      else
          $("#project_scrum_master_id").val("");

      if ($("#product_owner_droppable .person-draggable").size() > 0)
          $("#project_product_owner_id").val($("#product_owner_droppable .person-draggable").attr("userId"));
      else
          $("#project_product_owner_id").val("");

      if ($("#stakeholders_droppable .person-draggable").size() > 0) {
          $("#stakeholders_droppable .person-draggable").each(function(k,e) {
              $("#project_form").append(
                "<input type='hidden' name='project[stakeholder_ids][]' value='" +
                $(e).attr("userId") + "'/>"
              );
          });
      }
      
      $("input[name='team_member_ids[]']").remove();
      if ($("#team_members_droppable .person-draggable").size() > 0) {
          $("#team_members_droppable .person-draggable").each(function(k,e) {
              $("#project_form").append(
                "<input type='hidden' name='project[team_member_ids][]' value='" +
                $(e).attr("userId") + "'/>"
              );
          });
      }
    };

    self.involvedPeopleIds = function() {
      var ids=[];
      $("#scrum_master_droppable .person-draggable, #product_owner_droppable .person-draggable," +
        "#stakeholders_droppable .person-draggable, #team_members_droppable .person-draggable"
       ).each(function(index, value) {
         ids.push($(value).attr("userId"));
       });
       return(ids);
    };

    self.searchPeople = function() {
      $("#people_search_loader").show();

      $.ajax({
          url: "/user_searches.js",
          dataType: "script",
          type: "POST",
          data: {
              q: $("#search_people_text").val(),
              exclude_ids: self.involvedPeopleIds()
          }
      });
    };
}

$("#project_form").livequery(function() {
    var user_project_roles_form = new UserProjectRolesForm();
    $("#project_form").submit(function(event) {
      user_project_roles_form.updateHiddenFields();
    });

    $("#search_people_text").observe_field(1, function() {
      user_project_roles_form.searchPeople();
    });
    user_project_roles_form.searchPeople();
});

$(".nosubmit").livequery("keypress", function(event) {
    return !(event.keyCode == 13);
});

$("#project_buttons").livequery(function(event) {
    $(this).buttonset();
});

$("#project_buttons input").livequery("change", function(event) {
    $("#"+$(this).attr("id").replace("_visible", "")).toggle();
    count = $("#sprints:visible, #product_backlog:visible, #user_stories_incubator:visible").size();
    
    if (count == 1) {
        $("#sprints, #product_backlog, #user_stories_incubator").css("width", "940px");
    } else if (count == 2) {
        $("#sprints, #product_backlog, #user_stories_incubator").css("width", "460px");
    } else if (count == 3) {
        $("#sprints, #product_backlog, #user_stories_incubator").css("width", "300px");
    }

});


$("#sprints_accordion").livequery(function(event) {
    $(this).accordion({autoHeight: false, collapsible: true, active: $(".current-sprint")});
});

var load_html_into = function(event) {
    var target = $(this);
    $.get($(this).attr("data-populate-with"), function(data) {
       $(target).html(data);
    });
}

$("*[data-populate-with]").livequery(load_html_into);
$("*[data-populate-with]").livequery("reload", load_html_into);

$("a[data-toggle]").livequery("click", function(event) {
    event.preventDefault();
    $($(this).attr("data-toggle")).toggle("blind");
    if ($(this).attr("data-collapse")) {
        $(this).hide();
    }
});

$(".date-picker").livequery(function(event) {
    $(this).datepicker({dateFormat: "dd/mm/yy"})
});

$(".new_sprint, .edit-sprint form, .new_user_story").livequery("ajax:loading", function(event) {
  $(".ajax-loader", this).show();
});

$(".user-stories-sortable").livequery(function(event) {
    $(this).sortable({connectWith: ".user-stories-sortable", placeholder: 'ui-state-highlight'});
});

var updateSortable = function(prefix, dropped) {
  if (dropped) {
      $.post("/projects/"+$(dropped).attr("data-project-id")+"/user_stories/"+$(dropped).attr("data-id")+"/move_to_"+prefix, {ignore: "me"});
  }

  var stories = [];
  $("#"+prefix+"_stories .user-story").each(function(i, el) {
     stories.push($(el).attr("data-id"));
  });

  if (stories.length > 0) {
    $.post("/projects/"+$("#"+prefix+"_stories .user-story").attr("data-project-id")+"/user_stories/sort", {items: stories});
  }
};

var updateSprintSortable = function(sprint_id, dropped) {
  if (dropped) {
      $.post("/projects/"+$(dropped).attr("data-project-id")+"/user_stories/"+$(dropped).attr("data-id")+"/move_to_sprint", {sprint_id: sprint_id});
  }

  var stories = [];
  $(".sprint-sortable[data-sprint-id='"+sprint_id+"'] .user-story").each(function(i, el) {
     stories.push($(el).attr("data-id"));
  });

  if (stories.length > 0) {
    $.post("/projects/"+$(".sprint-sortable[data-sprint-id='"+sprint_id+"'] .user-story").attr("data-project-id")+"/user_stories/sort", {items: stories});
  }
};

$("#backlog_stories").livequery("sortreceive", function(event, ui) {
  updateSortable("backlog", ui.item);
});

$("#backlog_stories").livequery("sortstop", function(event, ui) {
  updateSortable("backlog");
});

$("#incubator_stories").livequery("sortreceive", function(event, ui) {
  updateSortable("incubator", ui.item);
});

$("#incubator_stories").livequery("sortstop", function(event, ui) {
  updateSortable("incubator");
});

$(".sprint-sortable").livequery("sortreceive", function(event, ui) {
  updateSprintSortable($(this).attr("data-sprint-id"), ui.item);
});

$(".sprint-sortable").livequery("sortstop", function(event, ui) {
  updateSprintSortable($(this).attr("data-sprint-id"));
});

var BurnDown = function(canvas) {
    var self = this;
    var ctx = canvas.getContext("2d");
    ctx.lineWidth = 1;

    ctx.clearRect(0, 0, 600, 350);

    var width = $(canvas).width();
    var height = $(canvas).height();
    var total_points = 0;
    
    self.drawLine = function(x1, y1, x2, y2, color) {
        ctx.lineWidth = 2.0;
        ctx.beginPath();
        ctx.strokeStyle = color;
        ctx.moveTo(x1,y1);
        ctx.lineTo(x2,y2);
        ctx.stroke();
    };

    self.drawLabel = function(x, y, color, text) {
        ctx.font = "15px Arial";
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.rect(x, y, 10, 10);
        ctx.closePath();
        ctx.fill();
        ctx.fillStyle = "black";
        ctx.fillText(text, x+15, y+10);
    }

    self.drawRegressionLine = function(data) {
        var x_ = 0;
        var y_ = total_points;

        for (var i=0; i<data.sprint_log_entries.length; i++) {
            x_ += i+1;
            y_ += data.sprint_log_entries[i].remaining_points;
        }
        x_ = x_ / (data.sprint_log_entries.length + 1);
        y_ = y_ / (data.sprint_log_entries.length + 1);

        var a; var b;
        var a_top=(-x_)*total_points;
        var a_bottom=(-x_)*(-x_);
        for (var i=1; i<=data.sprint_log_entries.length; i++) {
            a_top += (i - x_)*data.sprint_log_entries[i-1].remaining_points;
            a_bottom += (i - x_)*(i - x_);
        }

        a = a_top / a_bottom;
        b = y_ - x_ * a;

        self.drawLine( 10,
                       height-10-(a*0+b)*(height-20)/total_points,
                       width-10,
                       height-10-(a*days+b)*(height-20)/total_points,
                       "#ffaaaa" );
    };

    // load data with json
    $.getJSON($(canvas).attr("data-url"), function(data) {
    //$.getJSON("/fake_data.json", function(data) {
        if ( data.sprint_log_entries.length == 0 ||
             (data.sprint_log_entries.length == 1) && data.sprint_log_entries[0].total_points == 0.0
           ) {
            ctx.font = "24px Arial";
            ctx.fillText("Cannot draw chart - no data yet!", 10, 30);
            return;
        }

        // draw axis
        self.drawLine(10, 10, 10, height-10, "black");
        self.drawLine(10, height-10, width-10, height-10, "black");
        start_date = new Date(data.start_date.substr(0, 10))
        end_date = new Date(data.end_date.substr(0, 10))
        total_days = (end_date - start_date) / (1000*60*60*24) + 1;

        total_points = 0;

        $(data.sprint_log_entries).each(function(i, e) {
          if(e.total_points > total_points)
            total_points = e.total_points;
        });

        step = ((height-20) / total_points) * total_points / 10;
        days = total_days;
        for (var sum = step; sum<height-20; sum += step) {
            self.drawLine(10, height-10-sum, width-10, height-10-sum, '#ddddff');
        }

        for (var i=1; i<days; i++) {
            self.drawLine(i*(width-20)/days + 10, 10, i*(width-20)/days  + 10, height-10, '#ddddff');
        }

        // draw ideal sprint line
        self.drawLine(10, 10, width-10, height-10, "#55ff55");

        var prev_x = 10;
        var prev_y = 10;
        self.drawRegressionLine(data);
        for (var i=0; i<data.sprint_log_entries.length; i++) {
            cur_y = height - 10 - (data.sprint_log_entries[i].remaining_points * (height-20) / total_points);
            cur_x = 10 + (i+1)*(width-20)/days;
            self.drawLine(prev_x, prev_y, cur_x, cur_y, "blue");
            prev_x = cur_x;
            prev_y = cur_y;

            ctx.beginPath();
            ctx.arc(cur_x, cur_y, 5, 0, Math.PI*2, true);
            ctx.closePath();
            ctx.stroke();
            ctx.font = "12px Arial";
            ctx.fillText(data.sprint_log_entries[i].remaining_points + " story points", cur_x+5, cur_y-5);
        }

        // add labels
        ctx.font = "10px Arial";
        ctx.fillText(total_points + " story points", 1, 8);
        ctx.fillText(data.start_date.substr(0, 10), 40, height-1);
        ctx.fillText(data.end_date.substr(0, 10), width-90, height-1);

        self.drawLabel(width-165, 10, "red", "actual velocity");
        self.drawLabel(width-165, 30, "green", "ideal velocity");
        self.drawLabel(width-165, 50, "blue", "remaining story points");
    });
}

$(".pop-up").live("click", function(event) {
    event.preventDefault();
    dialog_el = $($(this).attr("href"));
    opts = { modal: true, title: dialog_el.attr("data-title"),
             position: ["center", "center"],
             width: 600 + 40,
             height: 350 + 60 };
    
    dialog_el.dialog("destroy");
    dialog_el.dialog(opts);
});

$(".burn-down-canvas:visible").livequery(function() {
   new BurnDown(this);
});

$("input[name='user_story[who]']:visible").livequery(function() {
  var self = this;
  setTimeout(function() { $(self).focus(); }, 1000);
});

$(".autoresize").livequery(function() {
  $(this).autoResize({
    onResize : function() {
      $(this).css({opacity:0.8});
    },
    animateCallback : function() {
      $(this).css({opacity:1});
    },
    animateDuration : 300,
    extraSpace : 0
 });
});
 
$(".shouts").livequery(function() {
  $(".shouts").attr("scrollTop", $(".shouts").attr("scrollHeight"));
});

$("#toggle_shoutbox").live("click", function(event) {
  if ($(".shouts").css("height") == "60px")
    $(".shouts").animate({height: 400}, 200);
  else
    $(".shouts").animate({height: 60}, 200);
});

$("input[name='user_story[who]']").livequery(function() {
    if ($(this).attr("data-suggestions")) {
      var suggestions = $(this).attr("data-suggestions").split("|");
      $(this).autocomplete({ source: suggestions });
    }
});

var Canvas = new function() {
  var self = this;

  self.drawLine = function(canvas, x1, y1, x2, y2, color) {
    ctx = $(canvas)[0].getContext("2d");
    console.debug("pff");
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    ctx.strokeStyle = color;
    ctx.moveTo(x1,y1);
    ctx.lineTo(x2,y2);
    ctx.stroke();
  }
}

function prepareReportsCanvas() {
    days = ($("#reports select[name='to']").val() - $("#reports select[name='from']").val()) / (24 * 3600);
    $("#timeline").attr("width", 20*days);
    if (days < 43) {
      $("#timeline").css("width", days * 20 + "px");
    } else {
      $("#timeline").css("width", "960px");
    }

    ppd = $("#timeline").width() / days;

    $("#timeline").attr("height", 200);
    $("#timeline").css("height", 20 * ppd + "px");
    for (var x=0; x<days; x++) {
      Canvas.drawLine("#timeline", 20*x, 0, 20*x, 200, "#cccccc");
    }
    for (var y=0; y<200; y+=20) {
      Canvas.drawLine("#timeline", 0, y, 20*days, y, "#cccccc");
    }
}

$(function() {
  if ($("#reports #from").size() > 0) {
    prepareReportsCanvas();
  }

  $("#reports #from, #reports #to").change(function(event) {
    prepareReportsCanvas();
  });

  $("#reports button").click(function(event) {
  
  });
});
