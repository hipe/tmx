module Skylab::GitViz

  class API::Actions__::Ping < API::Action_

    attribute :go_the_distance, argument_arity: :zero, writer: false, reader: false
    attribute :how_far, default: '80 feet'
    attribute :how_wide, default: '90 feet'
    attribute :on_channel, argument_arity: :one, writer: false

    def initialize
      @go_the_distance = @on_channel = nil
      super
      @y = build_yielder_for :info, :line
    end

    def execute
      if @go_the_distance
        go_the_distance
      else
        exec_normally
      end
    end
  private
    def exec_normally
      msg = "hello from git viz.".freeze
      if @on_channel
        @listener.maybe_receive_event @on_channel, :line, msg
      else
        @y << msg
      end
      :hello_from_git_viz
    end
  private
    def go_the_distance
      @y << "(#{ @how_wide } x #{ @how_far })"
      :_the_distance_
    end
  end
end
