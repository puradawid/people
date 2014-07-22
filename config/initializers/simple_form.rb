SimpleForm.setup do |config|
  config.wrappers :prepend, tag: 'div', class: "form-group", error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.wrapper tag: 'div', class: 'input-group' do |input|
      input.use :label_input
    end
    b.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
    b.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
  end

  config.wrappers :append, tag: 'div', class: "form-group", error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.wrapper tag: 'div', class: 'input-group' do |input|
      input.use :input
      input.use :label
    end
    b.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
    b.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
  end

  config.wrappers :default, class: :input,
    hint_class: :field_with_hint, error_class: :field_with_errors do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label_input
    b.use :hint,  wrap_with: { tag: :span, class: :hint }
  end

  config.default_wrapper = :default
  config.boolean_style = :nested
  config.button_class = 'btn btn-default'
  config.error_notification_tag = :div
  config.browser_validations = false
  config.error_notification_tag = :div
  config.label_class = 'control-label'
end
