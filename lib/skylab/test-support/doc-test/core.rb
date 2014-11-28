module Skylab::TestSupport

  module DocTest  # see [#015]

    Bzn_ = TestSupport_::Lib_::Bzn_[]

    class << self

      def comment_block_stream_via_line_stream_using_single_line_comment_hack x
        DocTest_::Input_Adapters__::
          Comment_block_stream_via_line_stream_using_single_line_comment_hack[ x ]
      end
    end

    module API

      extend Bzn_::API.module_methods

      class << self

        def expression_agent_class
          Bzn_::API.expression_agent_class
        end
      end
    end

    class Kernel_ < Bzn_::Kernel_  # #todo

    end

  if false
  class Specer__  # read [#025] the specer narrative #storypoint-5 intro

    RegretLib_ = ::Skylab::TestSupport::Regret::API::RegretLib_

    Autoloader_ = ::Skylab::Callback::Autoloader

    RegretLib_::Basic_Fields[ :client, self,
      :absorber, :absrb_iambic_fully,
      :field_i_a, %i( core_basename load_file load_module
        outstream path snitch templo_name ) ]

    def initialize * x_a
      absrb_iambic_fully x_a
      @base_mod = nil
      @block_a = []
    end

    def set_template_options option_a  # #storypoint-15
      @templo_opt_a = option_a
      PROCEDE_
    end

    # this is the first line of a comment block, to become a context desc:
    # this second line of the comment block you will not see.
    # this third line will become the desc for this example:
    #
    #     # this comment gets included in the output because it is indented
    #     # with four or more spaces, and its containing "SNIPPET" has the
    #     # magic equals predicate symbol in it somewhere.
    #
    #     THIS_FILE_ = TestSupport_::This_File[ __FILE__ ]
    #     THIS_FILE_.contains( 'this comment gets included' )       # => true
    #
    #     THIS_FILE_.contains( '"this is the first line of a co' )  # => true
    #     THIS_FILE_.contains( "you will #{ }not see" )             # => false
    #     THIS_FILE_.contains( '"this is the first line of a co' )  # => true
    #
    # note that we now strip trailing colons on these lines:
    #
    #     THIS_FILE_.contains( 'iling colons on these lines"' ) # => true

    # `accept( cblock )`

    class State__
      def initialize rx, a
        @a = a ; @rx = rx ; nil
      end
      attr_reader :rx, :a
    end

    class State__::Machine

      class << self

        alias_method :orig_new, :new

        def new h
        ::Class.new( self ).class_exec do
          class << self ; alias_method :new, :orig_new end
          const_set :H_, h
          self
        end
        end
      end

      def initialize
        @h = self.class::H_
        @state_i = :start
        @history_a = [ ]
      end

      def move cl  # comment line. a custom class instance
        state = @h.fetch @state_i
        nxt_i, md = state.a.reduce nil do |_, i|
          d = @h.fetch( i ).rx.match cl.line, cl.col
          d and break i, d
        end
        nxt_i or fail verbose_errmsg( cl )
        change_state_to nxt_i
        Transition_[ nxt_i, md, cl ]
      end

      def unmove
        @history_a.length.zero? and fail "sanity - history buffer is empty."
        @state_i = @history_a.pop
        nil
      end

    private

      def change_state_to nxt_i
        @history_a[ 0 ] = @state_i
        @state_i = nxt_i
        nil
      end

      def verbose_errmsg cl
        "sanity - parse failure - expecting (#{
          }#{ @h.fetch( @state_i ).a * ' or ' }) - #{
          }#{ cl.line[ cl.col .. -1 ].inspect }"
      end
    end

    Transition_ = ::Struct.new :i, :md, :comment_line

    -> do

      o = State__.method :new

      Machine__ = State__::Machine.new(

        start: o[ nil, [ :nbcode, :blank, :other ] ],

        nbcode: o[ /\G[ ][ ][ ][ ](?<content>.+)/,
                       [ :bcode, :nbcode, :other ] ],

        bcode: o[ /\G[ ]{0,4}(?<content>[ ]*)$/,
                       [ :bcode, :nbcode, :other ] ],

        blank: o[ /\G[[:space:]]*$/, [ :nbcode, :blank, :other ] ],

        other: o[ /\G(?:|(?<content>.+))$/, [ :nbcode, :blank, :other ]]
      )
    end.call

    def accept cblock
      machine = Machine__.new
      sblock = Specer__::Block.new @snitch
      comment_lines = RegretLib_::Stream[ cblock.a ]
      cl = comment_lines.gets
      while cl
        sblock.accept machine.move cl
        cl = comment_lines.gets
      end
      sblock.flush
      if sblock.is_not_empty
        accpt_specer_block sblock
      end ; nil
    end
  private
    def accpt_specer_block sblock
      @block_a << sblock
    end
  public

    def flush
      ok = rslv_templo
      ok && flsh_with_templo
    end

  private

    def rslv_templo
      ok = rslv_mods_and_paths
      ok and begn_templo
    end

    def rslv_mods_and_paths
      if @pat
        rslv_mods_and_paths_when_path_is_set
      else
        @corrected_anchored_const_a = nil
        PROCEDE_
      end
    end

    def rslv_mods_and_paths_when_path_is_set
      ok = rslv_base_module_and_load_file_if_necessary
      ok &&= rslv_tail_path
      ok && rslv_corrected_anchored_const_a
    end

    def rslv_base_module_and_load_file_if_necessary
      @base_mod_can_autoload = false
      @base_mod = ::Skylab  # #etc
      if @load_file
        _path = ::File.expand_path @load_file
        require _path  # or load it..
      end
      PROCEDE_
    end

    def rslv_tail_path  # local, normalized path
      pn = ::Pathname.new ::File.expand_path @path
      pns = pn.to_s ; bms = @base_mod.dir_pathname.to_s
      _eql = bms == pns[ 0, bms.length ]
      if _eql
        @tail_path = pns[ bms.length + 1 .. -1 ]
        PROCEDE_
      else
        when_tail_path_was_not_under_expected_head_path
      end
    end

    def when_tail_path_was_not_under_expected_head_path
      p = @path ; bm = @base_module
      @snitch.notice do
        "expecting to find pathname #{ p } #{
          }under base module `dir_pathnname` - #{ bm.dir_pathname }"
      end
      UNABLE_
    end

    def rslv_corrected_anchored_const_a  # #storypoint-165
      @c_a = infr_unloaded_anchored_const_a_from_tail_path
      @c_a and rslv_corrected_anchored_const_a_from_c_a
    end

    def infr_unloaded_anchored_const_a_from_tail_path
      Regret.infer_const :tail_path, @tail_path,
        :notice_p, -> s { @snitch.notice { s } }
    end

    def rslv_corrected_anchored_const_a_from_c_a
      mk_any_name_corrections
      @value = rdc_const_array_down_to_some_trueish_value
      if @value
        @corrected_anchored_const_a = rslv_some_normalized_const_array
        PROCEDE_
      end
    end

    def mk_any_name_corrections
      @load_module and mk_any_name_corrections_via_load_module
    end

    def mk_any_name_corrections_via_load_module
      c_a = @c_a
      c_a_ = get_another_correct_anchored_name_via_the_load_module
      c_a_.length.times do |d|
        ths = c_a[ d ].intern
        otr = c_a_[ d ].intern
        if ths != otr
          c_a[ d ] = otr
        end
      end ; nil
    end

    def get_another_correct_anchored_name_via_the_load_module
      c_a = @load_module.split CONST_SEP_
      top = ::Object.const_get c_a.shift
      name, = Autloader_.const_reduce do |cr|
        cr.from_module top
        cr.path_x c_a
        cr.result_in_name_and_value
      end
      c_a[ -1 ] = name  # any correction to last part only
      c_a
    end

    def rdc_const_array_down_to_some_trueish_value
      @const_reduce_is_ok = true
      @const_reduce_from_mod = @base_mod
      @const_reduce_else_p = -> err do
        @const_reduce_is_ok = false
        @const_reduce_from_mod = explain_no_such_constant err.module, err.name
      end
      if ! @base_mod_can_autoload
        do_rdc_once_with_loading_assistance
      end
      if @const_reduce_is_ok and 1 < @c_a.length
        do_rdc_the_rest
      end
      @const_reduce_from_mod
    end

    def do_rdc_once_with_loading_assistance  # #unfortunate-hack
      x = Autoloader_.const_reduce.with(
        :core_basename, @core_basename,
        :do_assume_is_defined, false,
        :else_p, @const_reduce_else_p,
        :from_module, @const_reduce_from_mod,
        :path_x, @c_a.first )
      @const_reduce_is_ok and @const_reduce_from_mod = x ; IGNORED_
    end

    def do_rdc_the_rest
      CORE_MOD_I__ == @c_a.last and whn_core_is_last
      x = Autoloader_.const_reduce.with(
        :core_basename, @core_basename,
        :do_assume_is_defined, true,
        :else_p, @const_reduce_else_p,
        :from_module, @const_reduce_from_mod,
        :path_x, @c_a[ 1..-1 ] )
      @const_reduce_is_ok and @const_reduce_from_mod = x ; IGNORED_
    end
    CORE_MOD_I__ = :Core

    def whn_core_is_last  # :[#034] exploratory
      c_a = @c_a ; mod = @const_reduce_from_mod
      @snitch.notice do
        "ignoring last (\"core\") element of #{
          }~#{ mod.name }::#{ c_a * CONST_SEP_ }"
      end
      @c_a.pop ; nil
    end

    def explain_no_such_constant m, c
      a = m.constants ; sac = self.say_any_constants a
      @snitch.notice do
        "'#{ m }' does not have '#{ c }' loaded (or loadable?) as #{
          }#{ s a, :one_of }its #{ a.length } constant#{ s }#{ sac }"
      end
      explain_suggestion_for_no_such_const
      UNABLE_
    end

    def explain_suggestion_for_no_such_const
      @snitch.notice do
        "try passing a second #{ par :load_file } argument that loads it."
      end ; nil
    end

    def say_any_constants a
      if A_REASONABLE_LENGTH_FOR_A_FEW_ITEMS__ >= a.length && a.length.nonzero?
        " (#{ a * ' ' })"
      end
    end
    #
    A_REASONABLE_LENGTH_FOR_A_FEW_ITEMS__ = 3

    def rslv_some_normalized_const_array
      if @value.respond_to? :name
        _name = @value.name
        _range = @base_mod.name.length + 2 .. -1
        _a = _name[ _range ].split CONST_SEP_
        _a.map( & :intern )
      else
        when_best_guess_is_necessary
      end
    end

    def when_best_guess_is_necessary
      emit_message_about_how_best_guess_is_necessary
      @c_a
    end

    def emit_message_about_how_best_guess_is_necessary
      c_a = @c_a
      @snitch.notice do
        "had const that was not a class or module #{
          }(~\"#{ c_a.fetch( -1 ) }\"). just taking best guess at its #{
           }name. we could do better.."
      end ; nil
    end

    def begn_templo
      _tmod = Autoloader_.const_reduce do |cr|
        cr.from_module DocTest_::Templos__
        cr.const_path [ @templo_name ]
        cr.assume_is_defined  # we experiment w/ using this instead of boxxy
      end
      @templo = _tmod.begin @snitch, @base_mod,
        @corrected_anchored_const_a, @block_a
      PROCEDE_
    end

    def flsh_with_templo
      es = @templo.any_exit_status_from_set_options @templo_opt_a
      es or exec_any_rendering_with_templo
    end

    def exec_any_rendering_with_templo
      if @path
        @templo.render_to @outstream
      end
    end

    class Event_

      class  << self

        def [] msg
          new -> { msg }
        end
      end

      def initialize mp
        @message_proc = mp
      end

      attr_reader :message_proc

    end

    IGNORED_ = nil
  end
  end

    DocTest_ = self
  end
end
