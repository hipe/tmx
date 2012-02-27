module Skylab::GitViz
  class Cli::HistTree < Cli::Action
    def invoke req
      o = api.invoke req
      emit :info, "ok this thing make a view of it: #{o}"
    end
  end
end

