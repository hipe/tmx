module Skylab::GitViz
  class Api::HistTree < Api::Action
    def invoke
      emit :info, "i have a runtime: #{api.runtime.class}"
      Struct.new(:one, :two).new('alpha', 'beta')
    end
  end
end

