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

      def writable_temp!
        CodeBuilder.writable_directory!(File.join(RootDir, '/writable-temp'))
      end

    end
    @ui = UI.new $stdout

    module BracketExtender
      def [] item
        item.extend self unless item.kind_of? self
        item
      end
    end

    module RegexpExtra
      extend BracketExtender

      #
      # return the array of captures and alter the original string to remove
      # everything up to the end of the match.
      # returns nil and leaves the string intact if no match.
      #
      # For now the regexp must have captures in it.
      #
      # Suitable for really simple hand-written top-down recursive decent
      # parsers
      #
      # Example:
      #   prefix_re = RegexpExtra[/(Mrs\.|Mr\.|Dr)/]
      #   name_re = RegexpExtra[/ *([^ ]+)]
      #
      #   str = "Dr. Elizabeth Blackwell"
      #   prefix = prefix_re.parse!(str)
      #   first  = name_re.parse!(str)
      #   last   = name_re.parse!(str)
      #
      def parse! str
        if md = match(str)
          caps = md.captures
          str.replace str[md.offset(0)[1]..-1]
          caps
        else
          nil
        end
      end
    end

    module HashExtra
      extend BracketExtender

      def values_at *indices
        indices.map{|key| self[key]}
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
