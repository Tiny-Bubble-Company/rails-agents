# frozen_string_literal: true

class CrmNoteStore
  class << self
    def notes = @notes ||= []
  end
end
