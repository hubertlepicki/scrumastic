# encoding: UTF-8

module ApplicationHelper
  def loader_icon(prefix, visible = false)
    image_tag "ajax-loader.gif", id: "#{prefix}_loader", style: "#{'display: none' unless visible}", class: "ajax-loader"
  end

  def thumb_of(project)
    link_to image_tag(project.logo.thumb.url, class: "logo_thumb"), project
  end

  def icon_tag name
    content_tag :span, {}, {class: "ui-icon ui-icon-#{name}"}
  end

  def story_text(user_story_or_nil)
    return I18n.t("item_removed") unless user_story_or_nil

    link_to(
      "#{t("as_a")} #{user_story_or_nil.who} #{t("I_want_to")} #{user_story_or_nil.what} " +
      "#{"#{t("so_that")} #{user_story_or_nil.reason}" unless user_story_or_nil.reason.blank?}",
      project_user_story_path(user_story_or_nil.project, user_story_or_nil)
    )
  end

  def sum_time_log_entries(time_log_entries)
    TimeFormatter::format time_log_entries.collect{|entry| entry.number_of_seconds}
  end

end
