module Skylab::TanMan
  module Api::Actions::Remote
  end
  class Api::Actions::Remote::Rm < Api::Action
    attribute :remote_name, required: true
    def execute
      config? or return
      unless remote = config.remotes.detect { |r| remote_name == r.name }
        a = config.remotes.map { |r| "#{pre r.name}" }
        b = error "couldn't find a remote named #{remote_name.inspect}"
        emit :info, "#{s a, :no}known remote#{s a} #{s a, :is} #{oxford_comma(a, ' and ')}".strip << '.'
        return b
      end
      !! config.remotes.remove(remote)
    end
  end
end

