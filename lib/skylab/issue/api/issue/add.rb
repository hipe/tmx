require File.expand_path('../action', __FILE__)

module Skylab::Issue
  class Api::Add < Api::Action
    extend ::Skylab::Slake::Muxer
    emits :all, :error => :all, :info => :all, :payload => :all
    def execute
      emit :info, "sure we have this: #{@params[:message]}"
      emit :payload, "this is out"
    end
  end
end

