module Skylab::Fields

  module CommonMetaAssociations::Boolean

      # the conceptual logic ("DNA") predates the earliest code in this file
      # by about four years. this is for ancient "DSL-controllers".
      #
      # as an exercise, in this latest rewrite we are playing with this
      # would-be "method definer" pattern..

    Parse = -> ai do  # argument interpreter

      scn = ai.meta_argument_scanner_

      defs = MethodsDefiner___.new

      begin
        scn.no_unparsed_exists and break
        p = MODIFIERS___[ scn.head_as_is ]
        p or break
        scn.advance_one
        p[ defs, scn ]
        redo
      end while nil

      defs.finish

      ai.entity_class_enhancer_by_ do |asc|

        a = defs.stream_for( asc ).to_a

        -> mod do
          mod.module_exec do
            st = Common_::Stream.via_nonsparse_array a
            begin
              defn = st.gets
              defn or break
              define_method defn.name_x, & defn.value_x
              redo
            end while nil
          end
        end
      end
    end

    # ->

      MODIFIERS___ = {

        negative_stem: -> defs, scn do

          sym = scn.gets_one
          defs.neg_read = :"#{ sym }?"
          defs.neg_write = :"#{ sym }!" ; nil
        end,

        positive_stem: -> defs, scn do

          sym = scn.gets_one
          defs.pos_read = :"#{ sym }?"
          defs.pos_write = :"#{ sym }!" ; nil
        end,

        # (etc)
      }

      class MethodsDefiner___

        def initialize
          @_neg_write = nil
          @_neg_read = nil
          @_pos_write = nil
          @_pos_read = nil
        end

        def neg_write= m
          _set :@_neg_write, m
        end

        def neg_read= m
          _set :@_neg_read, m
        end

        def pos_write= m
          _set :@_pos_write, m
        end

        def pos_read= m
          _set :@_pos_read, m
        end

        def _set ivar, x
          instance_variable_set ivar, Common_::Known_Known[ x ] ; x
        end

        def finish
          @_a = []
          _maybe :@_neg_write, :__add_negative_writer
          _maybe :@_neg_read, :__add_negative_reader
          _maybe :@_pos_write, :__add_positive_writer
          _maybe :@_pos_read, :__add_positive_reader
          NIL_
        end

        def _maybe ivar, then_m
          kn = remove_instance_variable ivar
          if kn
            m = kn.value_x
            if m
              send then_m, m
            end
          else
            send then_m
          end
          NIL_
        end

        def __add_negative_writer m=nil

          _will_define do |atr|

            write = _writer_for atr

            _define m || :"not_#{ atr.name_symbol }!" do
              write[ self, false ]
            end
          end
        end

        def __add_negative_reader m=nil

          _will_define do |atr|

            soft_read = _soft_reader_for atr

            _define m || :"not_#{ atr.name_symbol }?" do
              ! soft_read[ self ]
            end
          end
        end

        def __add_positive_writer m=nil

          _will_define do |atr|

            write = _writer_for atr

            _define m || :"#{ atr.name_symbol }!" do
              write[ self, true ]
            end
          end
        end

        def __add_positive_reader m=nil

          _will_define do |atr|

            soft_read = _soft_reader_for atr

            _define m || :"#{ atr.name_symbol }?" do
              soft_read[ self ]
            end
          end
        end

        def _will_define & p

          @_a.push( -> atr do
            p[ atr ]
          end ) ; nil
        end

        def _define m, & p
          Common_::Pair.via_value_and_name p, m
        end

        def _writer_for atr
          ivar = atr.as_ivar
          -> sess, x do
            sess.instance_variable_set ivar, x ; nil
          end
        end

        def _soft_reader_for atr
          ivar = atr.as_ivar
          -> sess do
            if sess.instance_variable_defined? ivar
              sess.instance_variable_get ivar
            end
          end
        end

        def stream_for atr

          Common_::Stream.via_nonsparse_array( @_a ).map_by do |p|
            p[ atr ]
          end
        end
      end
    # -
  end
end
