class NoteContentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      record.errors.add(attribute, I18n.t('errors.messages.blank'))
    elsif prohibited_language?(value)
      record.errors.add(attribute, I18n.t('errors.messages.prohibited_language'))
    elsif value.length > 5000
      record.errors.add(attribute, I18n.t('errors.messages.too_long', count: 5000))
    end
  end

  private

  def prohibited_language?(content)
    # Assuming there is a method to check for prohibited language
    # This is a placeholder for the actual implementation
    false
  end
end
