module Skylab::Snag

  # (below line kept for #posterity, is is the twinkle in the eye of the
  # [#sl-123] convention)
  # Todo = Api::Todo # yeah, this sad problem.  or is it a pattern!?

  class API::Actions::ToDo::Report < API::Action
    emits :all, error: :all, info: :all, payload: :all,
           number_found: :all

    attribute :names, required: true, default: ['*.rb']
    attribute :paths, required: true
    attribute :pattern, required: true, default: Snag::Models::Pattern.default
    attribute :show_command_only
    attribute :verbose

  protected

    def execute
      res = nil
      begin
        enum = Snag::Models::ToDo::Enumerator.new paths, names, pattern
        if show_command_only
          emit :payload, enum.command
          break( res = true )
        end
        if verbose
          emit :info, enum.command
        end
        enum.on_stderr_line { |e| emit :info, e }
        enum.each do |todo|
          emit :payload, todo
        end
        emit :number_found, count: enum.seen_count
        res = true
      end while nil
      res
    end
  end
end
