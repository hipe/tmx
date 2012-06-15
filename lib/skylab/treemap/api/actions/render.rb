require_relative '../../models'

module Skylab::Treemap
  class API::Actions::Render < API::Action
    emits payload: :all, info: :all, error: :all

    attribute :char, required: true, regex: [/^.$/, 'must be a single character']
    attribute :path, path: true, required: true
    attribute :show_tree

    def invoke params
      clear!.update_parameters!(params).validate or return
      (path = self.path).exist? or return error("input file not found: #{path.pretty}")
      @tree = API::Parse::Indentation.invoke(path, char) { |o|
        o.on_parse_error { |e| emit(:error, e) } } or return
      if show_tree
        render_debug
      else
        emit(:payload, "wow, you're great")
      end
    end

    def render_debug
      require 'skylab/porcelain/tree'
      empty = true
      Skylab::Porcelain::Tree.lines(@tree).each do |line|
        emit :info, line # egads!
        empty = false
      end
      empty ? (info("(nothing)") and false) : true
    end
  end
end

