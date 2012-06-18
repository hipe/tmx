require_relative '../../skylab'

module Skylab::Treemap

  module API
    extend Skylab::Autoloader
  end

  class API::Client
    def action *names
      klass = names.reduce(API::Actions) do |m, n|
        m.const_get n.to_s.gsub(/(?:^|_)([a-z])/){ $1.upcase }
      end
      klass.new
    end
  end
end

