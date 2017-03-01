module Skylab::Fields

  class Attributes

    module AssociationIndex_

      Normalize_using_defaults_and_requireds = -> sess do
        Here_::Normalization::Normalize_via_Session_with_StaticAttributes[ sess ]
      end

      class Index_of_Definition___

        def initialize unparsed_h, ma_cls, atr_cls

          o = Build_Index_of_Definition___.new ma_cls, atr_cls

          h = {}
          unparsed_h.each_pair do |k, x|

            h[ k ] = o.__build_and_index_attribute k, x
          end

          @_custom_index = o.__release_thing_ding_one
          @static_index_ = o.__release_thing_ding_two

          @_h = h
        end

        def begin_parse_and_normalize_for__ sess, & x_p
          Parse_and_or_Normalize.new sess, self, & x_p
        end

        def begin_normalization_ & x_p

          _ = Here_::Normalization.define do |o|  # :#spot-1-3
            # -

          sidx = static_index_
          o.effectively_defaultants = sidx.effectively_defaultants
          o.lookup = read_association_by_
          o.requireds = sidx.requireds

            # -
            o.listener = x_p
          end
          _  # hi.
        end

        # --

        def define_methods__ mod

          st = @static_index_.method_definers.to_key_stream
          begin
            k = st.gets
            k or break
            @_h.fetch( k ).deffers_.each do |p|
              p[ mod ]
            end
            redo
          end while nil
          NIL_
        end

        def is_X__ meta_k  # read-only
          ci = @_custom_index
          if ci
            bx = ci[ meta_k ]
            if bx
              bx.h_
            end
          end
        end

        def lookup_particular__ meta_k  # assumes some. read-only
          @_custom_index.fetch( meta_k ).a_
        end

        def to_defined_attribute_stream__

          ea = @_h.each_value
          Common_.stream do
            begin
              ea.next
            rescue ::StopIteration
            end
          end
        end

        def read_association_ k
          @_h.fetch k
        end

        def read_association_by_
          @_h.method :fetch
        end

        # --

        attr_reader(
          :_custom_index,
          :_h,
          :static_index_,
        )
      end

      Process_argument_scanner_passively_ = -> st, sess, formals, meths, & x_p do  # 1x

        sess.instance_variable_set ARGUMENT_SCANNER_IVAR_, st  # as we do

        if formals
          _idx = formals.index_
        end

        o = Parse_and_or_Normalize.new sess, _idx, & x_p

        o.argument_scanner = st

        o.__push_formal_reader_by do |k|

          m = meths[ k ]
          if m
            MethodBased_Attribute___.new m
          end
        end

        o.at_extra_token = :at_extra_stop_parsing

        kp = o.execute

        sess.remove_instance_variable ARGUMENT_SCANNER_IVAR_

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

      class Parse_and_or_Normalize  # this lib only

        def initialize sess, index=nil, & oes_p

          @argument_scanner = nil
          @_formal_reader_stack = []
          @index = index  # can be nil
          @_oes_p = oes_p  # can be nil
          @session = sess
        end

        def __push_formal_reader_by & p
          @_formal_reader_stack.push p ; nil
        end

        def sexp= sx
          @argument_scanner = Common_::Scanner.via_array sx ; sx
        end

        attr_writer(
          :argument_scanner,
        )

        attr_accessor(
          :at_extra_token,
        )

        def execute_as_init_

          _ok = execute
          _ok && @session
        end

        def execute

          __given_any_static_indexes_push_to_formal_reader_stack

          if @_do_normalize  # for now..
            normalize_m = :__do_normalize
          end

          if @argument_scanner
            kp = ___process_argument_stream
          else
            kp = KEEP_PARSING_
          end

          if kp && normalize_m
            kp = send normalize_m
          end

          kp
        end

        def ___process_argument_stream

          kp = KEEP_PARSING_

          oes_p = @_oes_p   # can be nil

          read = __formal_attribute_reader

          st = @argument_scanner

          until st.no_unparsed_exists

            @_attribute = read[]
            if @_attribute
              st.advance_one
              kp = @_attribute._interpret self, & oes_p  # result is "keep parsing"
              kp and next
              break
            end
            kp = ___at_extra
            break
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

        def __at_extra_then_raise_an_exception  # mimic #spot-1-1
          _ev = Home_::Events::Extra.via_strange @argument_scanner.head_as_is
          raise _ev.to_exception
        end

        def __given_any_static_indexes_push_to_formal_reader_stack

          idx = @index
          if idx

            sidx = idx.static_index_
            if sidx.effectively_defaultants  # [#012.B]
              yes = true
            end

            atr_h = idx._h
            @_formal_reader_stack.push( -> k do
              # (hi.)
              atr_h[ k ]
            end )
          end

          @_do_normalize = yes
          NIL_
        end

        def __do_normalize

          o = @index.begin_normalization_( & @_oes_p )
          o.ivar_store = @session
          o.execute
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
            p[ @argument_scanner.head_as_is ]
          end
        end

        def __formal_attribute_reader_when_many stack

          top_d = stack.length - 1
          st = @argument_scanner

          -> do

            d = top_d
            k = st.head_as_is

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
          :argument_scanner,
          :index,
          :session,
        )
      end

      class Build_Index_of_Definition___

        def initialize ma_cls, atr_cls

          @_p = -> kk, xx do

            n_meta_prototype = Here_::N_Meta_Attribute::Build.new ma_cls, atr_cls

            n_meta_prototype.attribute_services = self

            n_meta_prototype.build_N_plus_one_interpreter =
              Here_::N_Meta_Attribute::Common_build_N_plus_one_interpreter

            n_meta_prototype.finish_attribute = Finish_attribute___

            @_p = -> k, x do
              n_meta_prototype.__build_and_process_attribute k, x
            end

            @_p[ kk, xx ]
          end

          @_custom_index = nil
          @_static_index = StaticIndex___.new
        end

        def __build_and_index_attribute k, x
          @_p[ k, x ]
        end

        # -- exposures

        def add_to_the_custom_index_ k, meta_k

          _idx = ( @_custom_index ||= {} )
          _bx = _idx[ meta_k ] ||= Common_::Box.new
          _bx.add k, true  # so we can h[k] with a transparent h
        end

        def add_to_the_static_index_ k, meta_k
          @_static_index.add_ k, meta_k
        end

        SI_OP_H__ = {
          effectively_defaultants: :_push_to_array,
          method_definers: :__add_to_box,
          requireds: :_push_to_array,
        }

        StaticIndex___ = ::Struct.new( * SI_OP_H__.keys ) do

          def add_ k, meta_k
            send SI_OP_H__.fetch( meta_k ), k, meta_k
          end

          def __add_to_box k, meta_k

            ( self[ meta_k ] ||= Common_::Box.new ).add k, nil
            NIL_
          end

          def _push_to_array k, meta_k

            ( self[ meta_k ] ||= [] ).push k
            NIL_
          end
        end

        # -- for client

        def __release_thing_ding_one
          remove_instance_variable :@_custom_index
        end

        def __release_thing_ding_two
          remove_instance_variable :@_static_index
        end
      end

      # --

      Finish_attribute___ = -> build do

        if ! build.current_attribute.parameter_arity
          build.add_to_static_index_ :requireds
        end

        NIL_
      end

      # ==

      class MethodBased_Attribute___

        # (we don't subclass simplified name because we are one-off
        #  so we don't bother caching things lazily nor freezing.)

        # #open [#020] do we want to memoize these?

        def initialize m
          @__m = m
        end

        def _interpret parse, & x_p
          parse.session.send @__m, & x_p
        end
      end
    end
  end
end
# #tombstone: `edit_actor_class`