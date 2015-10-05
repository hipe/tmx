module Hipe
  module Assess
    RootDir = File.expand_path('../../..', __FILE__)
    module Config
      extend CommonModuleMethods
      const_accessor :max_backup_slots
      MaxBackupSlots = 3
    end
    class AppFail  < RuntimeError; end
    class UserFail < AppFail
      def initialize *args, &block
        @show_help = true
        @msgs = args
        opts = args.last.kind_of?(Hash) ? args.pop : {}
        process_block(block) if block_given? # before below
        super(*@msgs)     # after above
        @msgs = nil
        dont_show_help! if opts.has_key?(:show_help) && ! opts[:show_help]
      end
      def show_help?
        @show_help.nil? ? true : @show_help
      end
      def dont_show_help!
        @show_help = false
        self
      end
      alias_method :no_help!, :dont_show_help!
      def here!
        p = Common.trace_parse(caller[0])
        @msgs.push(nil) if ! @msgs.any?
        @msgs[@msgs.size-1] =
        [@msgs.last, "(#{p[:basename]}:#{p[:line]})"].compact.join(' ')
        self
      end
    private
      def process_block block
        # we allow the instance_eval variant for shorter more readable blocks
        # when all we are doing is calling the getters here (which is what it
        # should be used for anyway)
        return unless block
        block.arity == -1 ? instance_eval(&block) : block.call(self)
      end
    end
    class UI
      def initialize io = nil, verbose = false
        @io = io; @verbose = verbose
        @err = nil
      end

      def puts(*args)
        if args.empty? then out.puts ""
        else args.each { |msg| out.puts(msg) }
        end
        out.flush
        nil
      end

      # for datamapper
      def write(*a)
        out.write(*a)
      end

      def print *a
        out.print(*a)
      end

      # for PP.pp
      alias_method :<<, :print

      def abort(msg); @io && Kernel.abort("#{app}: #{msg}") end

      def vputs(*args); puts(*args) if @verbose end

      def err
        @err || self
      end

      def err= mixed
        @err = mixed
      end

      def out
        @io || $stdout
      end
    end

    class << self
      attr_reader :ui

      ClassBasenameRe = /([^:]+)$/
      def class_basename kls
        ClassBasenameRe.match(kls.to_s)[1]
      end

      def version
        File.read(File.join(RootDir,'VERSION'))
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

      def keys_to_methods! *ks
        (ks.any? ? ks : keys).each do |k|
          getter_unless_defined k, k
        end
        self
      end

      def getter_unless_defined key, meth
        unless respond_to?(meth)
          meta.send(:define_method, meth){self[key]}
        end
      end

      def slice *indices
        result = HashExtra[Hash.new]
        indices.each do |key|
          result[key] = self[key] if has_key?(key)
        end
        result
      end
    private
      def meta
        class << self; self end
      end
    end
  end
end
