class PhoneNumberValidator < ActiveModel::EachValidator
  PHONE_NUMBER_REGEX = %r{\A[+]?\d+(?>[- .]\d+)*\z}

  def validate_each(record, attribute, value)
    unless PHONE_NUMBER_REGEX.match value
      record.errors.add(attribute, "#{value} is not a valid phone number")
    end
  end
end
