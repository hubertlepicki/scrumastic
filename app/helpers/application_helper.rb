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
end
