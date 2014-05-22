class RoleDecorator < Draper::Decorator
  delegate_all

  def label
    h.content_tag :span, name, class: "label label-default", style: "background-color: #{color}"
  end
end
