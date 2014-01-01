module Skylab::GitViz
  class CLI::Actions::HistTree < CLI::Action
    def invoke req
      tree = api.invoke(req) or return tree
      tree.text do |row|
        emit :payload, row.to_s
      end
      true
    end
  end
end

