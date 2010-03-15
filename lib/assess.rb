require 'ruby-debug'
require 'assess/commands'
require 'assess/version'

module Hipe
  module Assess

    class << self
      attr_reader :ui
    end
    @ui = UI.new $stdout

  end
end
