# frozen_string_literal: true

class PlaygroundController < ApplicationController
  AGENTS = {
    "HelloAgent" => HelloAgent,
    "LeadQualifier" => LeadQualifier,
    "WebResearchAgent" => WebResearchAgent,
    "SheetBuilderAgent" => SheetBuilderAgent
  }.freeze

  class << self
    def notes = CrmNoteStore.notes
  end

  def index
    @agents = AGENTS
    @notes = CrmNoteStore.notes
    @agent_name ||= AGENTS.keys.first
  end

  def create
    @agent_name = params.require(:agent)
    @agent_class = AGENTS.fetch(@agent_name)
    @input = params.require(:input)
    @save_files_to = params[:save_files_to].presence

    @result = if @save_files_to
      @agent_class.run(@input, save_files_to: @save_files_to)
    else
      @agent_class.run(@input)
    end

    @agents = AGENTS
    @notes = CrmNoteStore.notes
    render :index
  end
end
