module Skylab::Headless

  class CLI::Argument::Syntax

    module DSL  # read [#142] the CLI argument syntax DSL  #storypoint-5

      def self.DSL_notify_with_p p
        (( srs = Series__.new )).p_notify p
        Front__.new srs
      end

      class Front__ < ::Module
        def initialize series
          @series = series
        end

        def each_argument
          block_given? and never
          ::Enumerator.new do |y|
            scn = get_node_scanner ; node = nil
            y << node while (( node = scn.gets ))
            nil
          end
        end

        def get_node_scanner
          @series.get_node_scanner
        end

        def process_args a, &p
          p[ hooks = Hooks__.new ]
          bx = Headless::Library_::Basic::Box.new
          parse = Parse__.new( hooks, bx, a )
          r = @series.parse_notify parse
          if r
            if a.length.nonzero?
              r = parse.trigger_extra CLI::Argument::Extra_[ a ]
            else
              parse.success_notify_with_struct_class result_struct_class
            end
          end
          r
        end
      private
        def result_struct_class
          if const_defined? :Result_Struct__, false
            const_get :Result_Struct__, false
          else
            init_result_struct_class
          end
        end
        def init_result_struct_class
          bx = Headless::Library_::Basic::Box.new
          y = ::Enumerator::Yielder.new do |i|
            bx.has?( i ) or bx.add i, nil
          end
          @series.gather_names y
          bx._a.length.zero? and fail "sanity - no parameters in grammar?"
          const_set :Result_Struct__, ::Struct.new( * bx._a )
        end
      end

      module Collection_Methods__

        def p_notify p
          instance_exec( & p ) ; nil
        end

        def render_under client
          y = [ ]
          @node_a.each do |node|
            (( x = node.render_under client )) and y << x
          end
          client.render_grp_s_a_as_i collection_type_i, y
        end

        def get_node_scanner
          Node_Scanner__.new @node_a
        end

        def gather_names y
          @node_a.each do |node|
            node.gather_names y
          end
          nil
        end

      private

        def add_notify node
          @node_a << node
          nil
        end
      end

      class Series__

        include Collection_Methods__

        def initialize
          @node_a = [ ] ; nil
        end

        def o * x_a
          add_notify Terminal__.new x_a
          nil
        end

        def alternation &p
          (( alt = Alternation__.new )).p_notify p
          add_notify alt
          nil
        end

        def collection_type_i ; :series end

        def get_node_a
          @node_a.dup
        end

        def as_moniker
          @node_a.map( & :as_moniker ) * TERM_SEPARATOR_STRING_
        end

        def length
          @node_a.length
        end

        def parse_notify parse
          r = true ; scn = get_node_scanner
          while (( node = scn.gets ))
            r = node.parse_notify( parse ) or break
          end
          r
        end
      end

      class Terminal__

        class << self
          alias_method :orig_new, :new
          def new a
            reqity_i = OPT_REQ_H__.fetch a.shift
            const_get( FACTORY_H__.fetch( a.shift ), false ).new reqity_i, a
          end
          def inherited cls
            cls.singleton_class.send :alias_method, :new, :orig_new
          end
        end
        #
        OPT_REQ_H__ = { optional: :optional, required: :required }.freeze
        #
        FACTORY_H__ = { literal: :Literal__, value: :Value__ }.freeze

        def initialize reqity_i
          @reqity_i = reqity_i
          nil
        end

        def is_collection ; false end

        def reqity
          REQITY_H__.fetch @reqity_i
        end
        #
        REQITY_H__ = { optional: :opt, required: :req }.freeze

        def parse_notify parse
          any_tok = parse.peek_any_head_token
          did, val = did_match_and_value_for_any_head_token any_tok
          if did
            parse.accept_head_token_notify
            parse.set_result_value as_parameter_key, val
            true
          elsif is_optional
            true
          else
            # #storypoint-105
            any_tok and _any_at_token_set = Headless::Library_::Set[ any_tok ]
            _stx = CLI::Argument::Syntax.new [ self ]
            _ev = CLI::Argument::Missing_[ :vertical, _stx, _any_at_token_set ]
            parse.trigger_missing _ev
          end
        end

        def gather_names y
          y << as_parameter_key
          nil
        end

      private

        def is_optional
          :optional == @reqity_i
        end
      end

      class Terminal__::Literal__ < Terminal__
        def initialize req_i, a
          @literal_label_s = a.shift
          a.length.zero? or fail "no - #{ a[ 0 ] }"
          super req_i
          nil
        end

        def is_atomic_variable ; false end
        def is_literal ; true end

        def render_under _client  # (but maybe one day)
          as_moniker
        end

        def as_moniker
          @literal_label_s
        end

        def as_parameter_key
          @literal_label_s.gsub( '-', '_' ).intern
        end

      private

        def did_match_and_value_for_any_head_token any_s
          if any_s and @literal_label_s == any_s
            [ true, true ]
          end
        end
      end

      class Terminal__::Value__ < Terminal__
        def initialize req_i, a
          @value_name_i = a.shift
          a.length.zero? or fail "no - #{ a[ 0 ] }"
          super req_i
          nil
        end

        def is_atomic_variable ; true end
        def is_literal ; false end

        attr_reader :value_name_i

        def render_under client
          client.render_argument_text self
        end

        def as_moniker
          "<#{ as_slug }>"
        end

        def as_slug
          @value_name_i.to_s.gsub '_', '-'  # #todo
        end

        def as_parameter_key
          @value_name_i
        end

      private

        def did_match_and_value_for_any_head_token any_s
          if any_s
            [ true, any_s ]
          end
        end
      end

      class Node_Scanner__ < ::Proc
        def self.new a
          p = -> do
            d = -1 ; last = a.length - 1
            (( p = -> do
              a[ d += 1 ] if d < last
            end )).call
          end
          super() do p.call end
        end
        alias_method :gets, :call
      end

      include Collection_Methods__

      class Alternation__
        include Collection_Methods__
        def initialize
          @node_a = [ ]
        end
        def is_atomic_variable ; false end
        def is_collection ; true end
        def collection_type_i ; :alternation end
        def reqity
          :req_group
        end

        def moniker_a
          @node_a.map( & :as_moniker )
        end

        def series &p
          (( ser = Series__.new )).p_notify p
          add_notify ser
          nil
        end

        def parse_notify parse
          scn = get_node_scanner ; fail_a = nil
          while (( node = scn.gets ))
            prs = build_parse_recorder parse
            r = node.parse_notify prs
            if r
              break
            else
              ( fail_a ||= [ ] ) << prs
            end
          end
          if r
            parse.sub_success_notify_with_recorder prs
            r
          else
            perform_failure_a_into_parse fail_a, parse
          end
        end

      private

        def build_parse_recorder parse
          Parse_Recorder__.new parse
        end

        def perform_failure_a_into_parse fail_a, parse
          big_a = [ ] ; tok_set = Headless::Library_::Set.new
          fail_a.each do |prs_rec|
            emit_a = prs_rec.emitted_a
            1 == emit_a.length or fail 'test me'
            emit_a.each do |i, e|
              :missing == i or fail 'test me'
              :vertical == e.orientation_i or fail 'test me'
              big_a.concat e.syntax_slice.to_a
              (( ats = e.any_at_token_set )) and tok_set.merge ats
            end
          end
          _stx_slice = CLI::Argument::Syntax.new big_a
          _tok_set = ( tok_set if tok_set.length.nonzero? )
          _ev = CLI::Argument::Missing_[ :horizontal, _stx_slice, _tok_set ]
          parse.trigger_missing _ev
        end
      end

      class Parse__
        def initialize hooks, box, a
          @a = a ; @box = box ; @hooks = hooks ; nil
        end

        def peek_any_head_token
          @a[ 0 ]
        end

        def accept_head_token_notify
          @a.length.zero? and fail 'no' ; @a.shift
          nil
        end

        def set_result_value i, x
          @box.add i, x
          nil
        end

        def trigger_extra x
          @hooks.unexpected_p[ x ]
        end

        def trigger_missing x
          @hooks.missing_p[ x ]
        end

        def duplicate_a
          @a.dup
        end

        def sub_success_notify_with_recorder rcd
          @a.replace rcd._a
          a, h = rcd._box._ivars
          a.each do |i|
            @box.add i, h.fetch( i )
          end
          nil
        end

        def success_notify_with_struct_class cls
          bx = @box ; @box = :box_was_used ; st = cls.new
          bx.each_pair do |i, x|
            st[ i ] = x
          end
          @hooks.result_struct_p[ st ]
          nil
        end
      end

      on_rx = /(?<=\Aon_)/
      Hooks__ = Headless::Event::Hooks.new( *
        CLI::Argument::Syntax::Validate.parameters.names.map do |i|
          on_rx.match( i ).post_match.intern
        end )

      class Parse_Recorder__ < Parse__
        def initialize upstream
          @a = upstream.duplicate_a
          @box = Headless::Library_::Basic::Box.new
          @emitted_a = []
        end

        attr_reader :emitted_a

        def set_result_value i, x
          # special hack - let the `true` for a literal get overwritten
          # with a terminal value of the same name, for iambic-like phrases
          if @box.has? i and true == @box[ i ]
            @box.modify i, -> _ { x }
          else
            @box.add i, x
          end
          nil
        end

        def trigger_missing x
          @emitted_a << [ :missing, x ]
          nil
        end

        def _a
          @a
        end

        def _box
          @box
        end
      end
    end
  end
end
