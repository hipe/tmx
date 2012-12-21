module Skylab::GitViz
  class Cli::Actions::HistTree < Cli::Action
    def invoke req
      tree = api.invoke(req) or return tree
      tree.text do |row|
        emit :payload, row.to_s
      end
      true
    end
  end
end

