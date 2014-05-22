I18n.exception_handler = ->(exception, locale, key, options) {
  if exception.is_a?(I18n::MissingTranslation)
    Rails.logger.warn "Translation missing: #{key}"
    key.split('.').last.capitalize.gsub("_", " ")
  end
}
