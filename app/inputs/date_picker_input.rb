class DatePickerInput < SimpleForm::Inputs::StringInput
  def input_html_options
    value = object.send(attribute_name)
    options = { value: value.nil? ? nil : I18n.localize(value, format: :date_picker) }
    super.merge options
  end
end
