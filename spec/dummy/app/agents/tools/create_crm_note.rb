# frozen_string_literal: true

class CreateCrmNote < RailsAgents::Tool
  description "Create a note on a CRM contact"
  param :email, :string
  param :body, :string

  def call(email:, body:)
    note = {email: email, body: body, created_at: Time.current.iso8601}
    CrmNoteStore.notes << note
    note
  end
end
