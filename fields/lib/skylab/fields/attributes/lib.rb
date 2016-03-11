module Skylab::Fields

  class Attributes

    module Lib

      Polymorphic_Processing_Instance_Methods = Here_::Actor::InstanceMethods

      class Index_of_Definition___

        def initialize unparsed_h, ma_cls, atr_cls

          ab = Build_Index_of_Definition___.new ma_cls, atr_cls

          h = {}
          unparsed_h.each_pair do |k, x|

            h[ k ] = ab.__build_attribute k, x
          end

          @_custom_index = ab.__release_thing_ding_one
          @_static_index = ab.__release_thing_ding_two

          @_h = h
        end

        def init__ sess, x_a
          o = Parse__.new sess, self
          o.sexp = x_a
          o.__execute_as_init
        end

        # --

        def optionals_hash__
          si = @_static_index
          if si
            si.optionals
          end
        end

        def define_methods__ mod

          st = @_static_index.method_definers.to_name_stream
          begin
            k = st.gets
            k or break
            atr = @_h.fetch k
            atr._deffers.each do |p|
              p[ mod, atr ]
            end
          end while nil
          NIL_
        end

        def lookup_particular__ meta_k
          @_custom_index.fetch meta_k
        end

        def to_defined_attribute_stream__

          ea = @_h.each_value
          Callback_.stream do
            begin
              ea.next
            rescue ::StopIteration
            end
          end
        end

        def _lookup_attribute k
          @_h.fetch k
        end


        # --

        attr_reader(
          :_custom_index,
          :_h,
          :_static_index,
        )
      end

      Process_polymorphic_stream_passively_ = -> st, sess, formals, meths, & x_p do

        sess.instance_variable_set ARG_STREAM_IVAR_, st  # as we do

        if formals
          _idx = formals.index_
        end

        o = Parse__.new sess, _idx

        o.argument_stream = st

        o.__push_formal_reader_by do |k|

          m = meths[ k ]
          if m
            MethodBased_Attribute___.new m
          end
        end

        o.at_extra_token = :at_extra_stop_parsing

        kp = o.execute

        sess.remove_instance_variable ARG_STREAM_IVAR_

        kp
      end

      Writer_method_reader___ = -> cls do

        -> name_symbol do

          m = Classic_writer_method_[ name_symbol ]

          if cls.private_method_defined? m
            m
          end
        end
      end

      class Parse__

        def initialize sess, index
          @index = index  # can be nil
          @session = sess
          @_formal_reader_stack = []
        end

        def __push_formal_reader_by & p
          @_formal_reader_stack.push p ; nil
        end

        def sexp= sx
          @argument_stream = Callback_::Polymorphic_Stream.via_array sx ; sx
        end

        attr_writer(
          :argument_stream,
        )

        attr_accessor(
          :at_extra_token,
        )

        def __execute_as_init

          _ok = execute
          _ok && @session
        end

        def execute

          __given_any_definitions_index_push_to_stack_and_see_optionals

          __init_the_normalize_and_see_formal_attribute_procs

          kp = KEEP_PARSING_
          read = __formal_attribute_reader
          see_formal_attr = remove_instance_variable :@_see_formal_attribute
          st = @argument_stream

          until st.no_unparsed_exists

            @_attribute = read[]
            if @_attribute
              see_formal_attr[]
              kp = @_attribute._interpret self  # result is "keep parsing"
              kp and next
              break
            end
            kp = ___at_extra
            break
          end

          if kp && @_normalize
            instance_exec( & @_normalize )
          end

          kp
        end

        def ___at_extra
          m = self.at_extra_token
          m ||= :__at_extra_then_raise_an_exception
          send m
        end

        def at_extra_stop_parsing
          # NOTE: the "stop parsing" signal is *NOT* issued in these cases
          KEEP_PARSING_
        end

        def __at_extra_then_raise_an_exception  # mimic #spot-1
          _ev = Home_::Events::Extra.via_strange @argument_stream.current_token
          raise _ev.to_exception
        end

        def __given_any_definitions_index_push_to_stack_and_see_optionals

          idx = @index
          if idx

            idxs = idx._static_index
            if idxs
              opts = idxs.optionals
            end

            atr_h = idx._h
            @_formal_reader_stack.push( -> k do
              # (hi.)
              atr_h[ k ]
            end )
          end

          @_optionals = opts
          NIL_
        end

        def __init_the_normalize_and_see_formal_attribute_procs

          opts = remove_instance_variable :@_optionals
          if opts
            ___init_the_etc_when_opts opts
          else
            @_normalize = nil
            @_see_formal_attribute = @argument_stream.method :advance_one
          end
          NIL_
        end

        def ___init_the_etc_when_opts opts

          # we nilify IFF you had optionals AND we're in `fully` mode..

          pool = opts.dup
          st = @argument_stream

          @_normalize = Nilify___[ pool ]

          @_see_formal_attribute = -> do
            pool.delete @_attribute.name_symbol
            st.advance_one
            NIL_
          end

          NIL_
        end

        def __formal_attribute_reader

          stack = remove_instance_variable :@_formal_reader_stack
          send OP_H___.fetch( 1 <=> stack.length ), stack
        end

        OP_H___ = {
          0 => :__formal_attribute_reader_when_one,
          -1 => :__formal_attribute_reader_when_many,
        }

        def __formal_attribute_reader_when_one stack

          p = stack.fetch 0
          -> do
            p[ @argument_stream.current_token ]
          end
        end

        def __formal_attribute_reader_when_many stack

          top_d = stack.length - 1
          st = @argument_stream

          -> do

            d = top_d
            k = st.current_token

            begin
              atr = stack.fetch( d ).call k
              if atr
                break
              end
              if d.zero?
                break
              end
              d -= 1
              redo
            end while nil
            atr
          end
        end

        attr_reader(  # (all here)
          :argument_stream,
          :index,
          :session,
        )
      end

      Nilify___ = -> pool do
        -> do
          pool.keys.each do |k|
            ivar = @index._lookup_attribute( k ).as_ivar
            if ! @session.instance_variable_defined? ivar
              @session.instance_variable_set ivar, nil
            end
          end
          KEEP_PARSING_
        end
      end

      class Build_Index_of_Definition___

        def initialize ma_cls, atr_cls

          @_attribute_class = atr_cls
          @_custom_index = nil
          @_static_index = nil
          @_meta_attributes_class = ma_cls
          @_process_meta_attribute = __process_meta_attribute
        end

        def __build_attribute k, x

          @_attribute_class.new k do |atr|
            x and ___edit_attribute atr, x, k
            NIL_
          end
        end

        def ___edit_attribute atr, x, k

          @_current_attribute = atr
          @_current_attribute_name_symbol = k

          _a = ::Array.try_convert( x ) || [ x ]
          st = Callback_::Polymorphic_Stream.via_array _a

          @_sexp_stream_for_current_attribute = st

          p = @_process_meta_attribute
          begin
            p[ st.gets_one ]
          end until st.no_unparsed_exists

          NIL_
        end

        def __process_meta_attribute

          ma_cls = @_meta_attributes_class

          ma = -> do
            x = ma_cls.new self
            ma = -> { x }
            x
          end

          -> k do
            if ma_cls.method_defined? k
              ma[].__send__ k
              NIL_
            else
              SANITY_RX___ =~ k or self._SANITY
              ___add_to_custom_index k
              NIL_
            end
          end
        end
        SANITY_RX___ = /\A_/  # for now - catch typos & API mismatches

        # --

        def ___add_to_custom_index meta_k

          _idx = ( @_custom_index ||= {} )
          _a = _idx[ meta_k ] ||= []
          _a.push @_current_attribute_name_symbol ; nil
        end

        def touchpush_to_static_index__ meta_k

          _idx = _static_index
          _bx = _idx[ meta_k ] ||= Callback_::Box.new
          _bx.touch @_current_attribute_name_symbol do NOTHING_ end ; nil
        end

        def add_to_static_index__ meta_k

          _idx = _static_index
          _h = ( _idx[ meta_k ] ||= {} )
          _h[ @_current_attribute_name_symbol ] = true ; nil
        end

        def _static_index
          @_static_index ||= Static_Index___.new
        end

        Static_Index___ = ::Struct.new :method_definers, :optionals

        def _gets_one
          @_sexp_stream_for_current_attribute.gets_one
        end

        def current_attribute
          @_current_attribute
        end

        # --

        def __release_thing_ding_one
          remove_instance_variable :@_custom_index
        end

        def __release_thing_ding_two
          remove_instance_variable :@_static_index
        end
      end

      # ==

      class MethodBased_Attribute___

        # (we don't subclass simplified name because we are one-off
        #  so we don't bother caching things lazily nor freezing.)

        # #open [#020] do we want to memoize these?

        def initialize m
          @__m = m
        end

        def _interpret parse
          parse.session.send @__m
        end
      end

      # ==

      class DefinedAttribute < SimplifiedName

        def initialize k, & edit_p

          @_read_m = :__receive_first_read_proc
          @_RW_m = :__receive_first_read_and_write_proc
          @_write_m = :__receive_first_write_proc
          @_read_p_kn = nil
          @_RW_p_kn = nil
          @_write_p_kn = nil

          super k do |me|
            edit_p[ me ]
          end
        end

        def freeze

          remove_instance_variable :@_read_m
          remove_instance_variable :@_RW_m
          remove_instance_variable :@_write_m

          r_kn = remove_instance_variable :@_read_p_kn
          rw_kn = remove_instance_variable :@_RW_p_kn
          w_kn = remove_instance_variable :@_write_p_kn

          if rw_kn
            # then our state machine "ensures" that the others were not
            @__rw = rw_kn.value_x
            @_interpret_m = :__custom_interpret
          else
            @_read = r_kn ? r_kn.value_x : Read___
            @_write = w_kn ? w_kn.value_x : Write___
            @_interpret_m = :__common_interpret
          end

          super
        end

        def define_methods_by & p
          ( @_deffers ||= [] ).push p ; nil
        end

        attr_reader :_deffers

        def read_by & p
          send @_read_m, p
        end

        def __receive_first_read_proc p
          @_read_m = :_locked
          @_RW_m = :_locked
          @_read_p_kn = Callback_::Known_Known[ p ] ; nil
        end

        def _interpret parse
          _args = Interpretation_Arguments___.new self, parse
          _read_and_write _args
        end

        def read_and_write_by & p
          send @_RW_m, p
        end

        def __receive_first_read_and_write_proc p
          @_read_m = :_locked
          @_RW_m = :_locked
          @_write_m = :_locked
          @_RW_p_kn = Callback_::Known_Known[ p ] ; nil
        end

        def write_by & p
          send @_write_m, p
        end

        def __receive_first_write_proc p
          @_write_m = :_locked
          @_RW_m = :_locked
          @_write_p_kn = Callback_::Known_Known[ p ] ; nil
        end

        def _read_and_write args  # at least 2x here
          send @_interpret_m, args
        end

        def __common_interpret args

          _x = args.calculate( & @_read )
          args.calculate _x, & @_write  # result is k.p
        end

        def __custom_interpret args

          args.calculate( & @__rw )  # result is k.p
        end
      end

      Read___ = -> do
        argument_stream.gets_one
      end

      Write___ = -> x do
        session.instance_variable_set formal_attribute.as_ivar, x
        KEEP_PARSING_
      end

      # ==

      class Interpretation_Arguments___

        def initialize attr, parse
          @_arg_st = nil
          @_formal_attribute = attr
          @_parse = parse
          # for now, don't freeze only because #this
        end

        def _mutate_for_redirect x, atr  # :#this is why we didn't freeze
          @_arg_st = Argument_stream_via_value[ x ]
          @_formal_attribute = atr ; nil
        end

        alias_method :calculate, :instance_exec

        def argument_stream
          @_arg_st || @_parse.argument_stream
        end

        def formal_attribute
          @_formal_attribute
        end

        def index
          @_parse.index
        end

        def session
          @_parse.session
        end
      end

      # ==
    end
  end
end
# #tombstone: `edit_actor_class`
