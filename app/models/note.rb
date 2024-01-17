require_relative 'application_record'
class Note < ApplicationRecord
  belongs_to :user

  # validations

  # end for validations

  include SomeModule
  class << self
  end
end
