require 'open3' # popen3
require 'shellwords' # shellescape

module Skylab::MyTree

  module API::Actions::Tree::Find
  end


  class API::Actions::Tree::Find::Command < ::Struct.new :paths, :pattern
    # one day this might subsume 2 others [#sl-118]
    # but it's a ways away from that now.  trying to make it universally
    # reusable might make it really abstract and ugly (also would probably
    # be lots of fun..)

    extend Headless::Parameter::Definer
    include Headless::Parameter::Controller::InstanceMethods

    param :paths, required: true, accessor: true
    param :pattern

    def each
      valid? or return false
      verbose and verbose[:find_command] and info string
      dry_run and return nil # it's such a bleeding non-feature, just for dbg
      e = ::Enumerator.new do |y|
        ::Open3.popen3 string do |_, sout, serr|
          e = serr.read
          if '' == e
            sout.each_line do |line|
              y << line.chomp
            end
          else
            e.split("\n").each do |line|
              error line.chomp
            end
          end
        end
      end
      if block_given?
        e.each { |x| yield x }
      end
      e
    end

    attr_accessor :dry_run

    def string
      a = [ "find #{ paths.map { |p| p.to_s.shellescape }.join ' ' }" ]
      type and a.push "-type #{ type }"
      pattern and a.push "-name #{ pattern.shellescape }"
      a.join ' '
    end

    def valid
      @valid or return # don't re-emit same errors
      # path.exist? or return error "path not found: #{ path }"
      # path.directory? or return error "is not directory: #{ path }"
      true
    end

    alias_method :valid?, :valid

    attr_accessor :verbose

  protected

    def initialize request_client, paths, pattern=nil
      self.type = :file
      _headless_sub_client_init request_client
      @valid = set! paths: paths, pattern: pattern
    end

    def error msg
      @valid = false
      request_client.error "-->#{ msg }<--"
    end

    attr_accessor :type # yeah etc. you could have lots of fun with this

  end
end
