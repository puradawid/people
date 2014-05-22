SimpleForm.setup do |config|
  config.wrappers :bootstrap, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: 'div' do |ba|
      ba.use :input
      ba.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
      ba.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
    end
  end

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

  config.default_wrapper = :bootstrap
  config.boolean_style = :nested
  config.button_class = 'btn btn-default'
  config.error_notification_tag = :div
  config.label_class = 'control-label'
  config.input_class = 'form-control'
  config.browser_validations = false
end
