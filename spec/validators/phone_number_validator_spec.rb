require 'spec_helper'

describe PhoneNumberValidator, '#validate_each' do
  it 'does not add errors with a valid phone number' do
    record = build_record('+22111222333')

    PhoneNumberValidator.new(attributes: :phone).validate(record)

    expect(record.errors).to be_empty
  end

  it 'adds errors with an invalid phone number' do
    record = build_record('+48111invalid')

    PhoneNumberValidator.new(attributes: :phone).validate(record)

    expect(record.errors.full_messages).to \
      eq ['Phone +48111invalid is not a valid phone number']
  end

  def build_record(phone)
    test_class.new.tap do |object|
      object.phone = phone
    end
  end

  def test_class
    Class.new do
      include ActiveModel::Validations
      attr_accessor :phone

      def self.name
        'TestClass'
      end
    end
  end
end
