
class NoteContentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if attribute.to_sym == :title
      validate_title(record, value)
    else
      validate_content(record, attribute, value)
    end
  end

  private

  def validate_title(record, value)
    if value.blank?
      record.errors.add(:title, I18n.t('errors.messages.blank'))
    elsif value.length > 255
      record.errors.add(:title, I18n.t('errors.messages.too_long', count: 255))
    end
  end

  def validate_content(record, attribute, value)
    if value.blank?
      record.errors.add(attribute, I18n.t('errors.messages.blank'))
    elsif prohibited_language?(value)
      record.errors.add(attribute, I18n.t('errors.messages.prohibited_language'))
    elsif value.length > 5000
      record.errors.add(attribute, I18n.t('errors.messages.too_long', count: 5000))
    end
  end

  def prohibited_language?(content)
    # Assuming there is a method to check for prohibited language
    # This is a placeholder for the actual implementation
    false
  end
end
