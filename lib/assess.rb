require 'ruby-debug'
require 'assess/commands'
require 'assess/version'
require 'assess/controller'

module Hipe
  module Assess
    RootDir = File.expand_path('../../', __FILE__)
    class UserFail < RuntimeError; end
    class AppFail  < RuntimeError; end

    class << self
      attr_reader :ui
    end
    @ui = UI.new $stdout

  end
end
