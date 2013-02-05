module Skylab::Treemap

  module CLI::Option::Ridiculous

    # `Ridiculous` is the high-level entrypoint into this ridiculous library.
    # Extend your Headless-powered CLI::Action sublass with Ridiculous.

    def self.extended mod
      mod.extend CLI::Option::Ridiculous::ModuleMethods
      mod.send :include, CLI::Option::Ridiculous::InstanceMethods
    end
  end

  CLI::Option::Ridiculous::DSL = MetaHell::Proxy::Functional.new :more
      # the DSL proxy is just for getting the `more` hook for now.

  CLI::Option::Ridiculous::Dispatch = MetaHell::Proxy::Nice.new :'nil?',
    :add_definition_block, :options, :'parse!'


  module CLI::Option::Ridiculous::ModuleMethods
     include Headless::CLI::Action::ModuleMethods

    def option_parser             # just for resulting in a DSL for the `more`
      if block_given?
        super
      else
        @option_parser_hookback ||= CLI::Option::Ridiculous::DSL.new(
          more: method( :option_parser_more )
        )
      end
    end

    attr_reader :option_parser_blocks          # publicize it

    attr_reader :option_parser_extension_blocks

    def option_parser_more *a, &b              # (hookback for dsl)
      @option_parser_extension_blocks ||= [ ]
      option_parser_extension_blocks.push -> op do
        op.write_more(* a, &b )
      end
      nil
    end

  protected

  end

  module CLI::Option::Ridiculous::InstanceMethods
    include Headless::CLI::Action::InstanceMethods
      # (taps you into the whole critical f.w of h.l, for e.g `invoke`)

    def option_parser &b          # so think about this for a minute..
      if block_given?
        op = super(   )
        op.add_definition_block b
        op
      else
        super(   )
      end
    end

  protected

    #         ~ host initialization (hooked into elsewhere) ~

    def _option_parser_ridiculous_host_init
      _option_parser_ridiculous_host_is_initted and fail 'init mutex'
      @param_h ||= { }
      @_option_parser_ridiculous_host_is_initted = true
      @had_help = nil
      @option_documenter ||= nil
      @parsing_option_parser ||= nil
      @option_parser_blocks ||= nil
      @option_parser_extension_blocks ||= nil

      # what gets stored in @option_parser will dispatch requests to the
      # above two.  #todo might be overcomplicated in lieu of what h.l does
    end

    attr_reader :_option_parser_ridiculous_host_is_initted


    #         ~ compat & hook into headless ~

    def build_option_parser
      _option_parser_ridiculous_host_is_initted and fail 'sanity'
      _option_parser_ridiculous_host_init
      CLI::Option::Ridiculous::Dispatch.new(
        :add_definition_block => method( :dispatch_definition_block ),
        :nil?                 => -> { false },
        :options              => -> { option_documenter.options },
        :parse!            => ->( *a ) { parsing_option_parser.parse!( *a ) }
      )
    end

    def dispatch_definition_block block
      option_parser_blocks
      @option_parser_blocks.push block
      if @parsing_option_parser
        instance_exec @parsing_option_parser, & block
      else
        @parsing_option_parser = nil
      end
      if @option_documenter
        @option_documenter.absorb_unseen_definition_blocks(
          @option_parser_blocks, nil )
      else
        @option_documenter = nil
      end
      nil
    end

    def option_documenter
      if @option_documenter.nil?
        a, b = option_parser_blocks, option_parser_extension_blocks
        if a || b
          od = @option_documenter = CLI::Option::Documenter.new( self )
          # (note it is very important that you set the ivar right away.
          # the documenter runs the blocks and the blocks use the stylus
          # and the stylus checks for options and the options are in the
          # documenter WAHOO)
          parsing_option_parser  # kick @had_help
          od.absorb_unseen_definition_blocks a, b  # (will change at etc.)
          if false == @had_help
            od.on '-h', '--help', 'this ridiculous screen.'
          end
        end
      end
      @option_documenter
    end

    [ :option_parser_blocks, :option_parser_extension_blocks ].each do |m|
      ivar = "@#{ m }".intern
      define_method m do
        a = instance_variable_get ivar
        if ! a                    # (this is the last chance for the class to
          a0 = self.class.send m  # have any blocks we will see. we maintain our
          a = a0 ? a0.dup : [ ]   # own copies from here bc we may add to them.
          instance_variable_set ivar, a  # it is important for other logic
                                  # that this these ar objs are persistent)
        end
        a if a.length.nonzero?    # to the outside, nil when empty - important,
      end                         # tracked by [#tm-009], change with caution
    end

    def parsing_option_parser
      if @parsing_option_parser.nil?
        a = option_parser_blocks
        if a
          op = @parsing_option_parser = ::OptionParser.new  # see note above
          a.each { |b| instance_exec op, &b } # (will change at etc.)
          @had_help = op.top.list.detect do |x|
            x.respond_to? :short and '-h' == x.short.first
          end
          @had_help ||= false  # catch logic errors through unob. failure
          if ! @had_help
            op.on '-h', '--help', 'never see.' do
              enqueue [ :help ]  # traditional h.l way, we wait for
            end                            # hooks back in thru proxy.
          end
        end
      end
      @parsing_option_parser
    end

    #         ~ the `more` facility (mocking the interface is required) ~

    empty_a = [ ].freeze

    define_method :more do |sym|
      empty_a
    end

    #         ~ rendering help ~

    public
                                  # decorate a a default value to be used as
                                  # a substitution for {{default}}

    def render_option_default opt
      val opt.default_value
    end
  end
end
