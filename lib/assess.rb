require 'ruby-debug'
require 'assess/version'
require 'assess/common-instance-methods'

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

      # for datamapper
      def write(*a)
        @io ? @io.write(*a) : $stdout.write(*a)
      end

      def print *a; @io.print(*a) end

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


    module Openesque
      def self.[] m
        m.extend self
        m
      end
      def def! name, value
        fail("no") if respond_to? name
        meta.send(:define_method, name){value}
        self
      end
    private
      def meta
        class << self; self end
      end
    end

    module HashExtra

      def self.[] item;
        item.extend self
        item
      end

      def values_at *indices
        indices.collect {|key| self[key]}
      end

      def slice *indices
        result = HashExtra[Hash.new]
        indices.each do |key|
          result[key] = self[key] if has_key?(key)
        end
        result
      end
    end
  end
end

#
# this loads plugins that need ui to be set above :/
#
require 'assess/commands'
