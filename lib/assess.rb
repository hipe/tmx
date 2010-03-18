require 'ruby-debug'
require 'assess/version'
require 'assess/controller'

module Hipe
  module Assess
    RootDir = File.expand_path('../../', __FILE__)
    class UserFail < RuntimeError; end
    class AppFail  < RuntimeError; end

    class UI
      def initialize io = nil, verbose = false
        @io = io; @verbose = verbose
      end

      def puts(*args)
        return unless @io
        if args.empty? then @io.puts ""
        else args.each { |msg| @io.puts(msg) }
        end
        @io.flush
        nil
      end

      def print *a; @io.print a end

      def abort(msg); @io && Kernel.abort("#{app}: #{msg}") end

      def vputs(*args); puts(*args) if @verbose end

    end

    class << self
      attr_reader :ui

      ClassBasenameRe = /([^:]+)$/
      def class_basename kls
        ClassBasenameRe.match(kls.to_s)[1]
      end

    end
    @ui = UI.new $stdout

  end
end

#
# this loads plugins that need ui to be set above :/
#
require 'assess/commands'
