module Skylab::Snag

  class Models_::Node

    module Expression_Adapters::Byte_Stream

      class << self

        def express_into_under_of_ y, expag, node
          express_N_units_into_under_of_ nil, y, expag, node
        end

        def express_N_units_into_under_of_ d, y, expag, node

          body = node.body

          if body.is_mutable
            if :Byte_Stream == body.modality_const
              Delineate__[][ d, y, expag, node ]
            else
              Delineate__[].new_via( d, y, expag, node ).execute_agnostic
            end
          else
            body.express_N_units_into_under_ d, y, expag
          end
        end
      end  # >>

      Delineate__ = -> do
        Magnetics_::ExpressDelineatedLines_via_Node
      end

      module Magnetics_
        Autoloader_[ self ]
      end

      the_language_extension_for_structures = nil

      Magnetics_::FlyweightedObjectStream_via_Substring = -> do

        # to leverage (rather than be penalized by) the flyweighting that the
        # upstream provides (see), we must re-use the same stream object over
        # all of the upstream lines.

        p = -> sstr, row_st do  # the first time it its called ..

          fly = Home_::Models::Hashtag::Stream.new

          fly.initialize_string_scanner_ sstr.begin, sstr.end, sstr.s

          fly.receive_hashtag_class_(
            Home_::Models_::Tag::Expression_Adapters::Byte_Stream::Models_::Tag
          )

          fly.init

          fly.become_name_value_scanner

          fly_ = the_language_extension_for_structures[ fly, row_st ]

          p = -> sstr_, row_st_ do  # subsequent times ..

            fly.reinitialize_string_scanner_ sstr_.begin, sstr_.end, sstr_.s

            fly_.upstream.__reinitialize row_st_

            fly_
          end

          fly_
        end

        -> sstr, row_st do
          p[ sstr, row_st ]
        end
      end.call

      # ~ begin experimental language extension

      the_language_extension_for_structures = -> do

        open_paren_byte = '('.getbyte 0
        p = nil
        pc = nil
        s = nil
        space_byte = SPACE_.getbyte 0

        -> st, row_st do

          main_p = nil
          nested_parens = -> open_d, deep_pc, string_pc do

            o = Magnetics_::ParseNestedParenthesis_via_Arguments.call(
              open_d, deep_pc, string_pc, st, row_st )

            pc = o.piece
            pc_ = o.next_piece

            # when single line parenthesis need to put its peek token back:

            if pc_
              p = -> do  # "push it back"
                p = main_p
                pc_
              end
            end

            # when multiline parenthesis closes and there is something after:

            x = o.string_scanner
            if x
              st.reinitialize_string_scanner_ x.pos, x.string.length, x.string
            end

            NIL_
          end

          find_last_non_space_index = -> do

            # going backwards, skip over zero or more space (32) characters

            s = st.string_scanner.string
            last = pc._begin
            d = last + pc._length - 1

            stay = true
            begin
              if space_byte == s.getbyte( d )
                if last == d
                  stay = false
                  break
                end
                d -= 1
                redo
              end
              break
            end while nil
            stay && d
          end

          main_p = nil
          at_string_piece = -> do

            # if we have a string piece whose last non-space character
            # is an open parenthesis AND the next piece after that is
            # a tag with a value (i.e a colon), invoke the nesting parse

            d = find_last_non_space_index[]

            if d && open_paren_byte == s.getbyte( d )
              pc_ = st.gets  # lookahead
              if pc_
                if :tag == pc_.category_symbol && pc_.value_is_known_is_known
                  nested_parens[ d, pc_, pc ]
                else
                  p = -> do  # "put it back'
                    p = main_p
                    pc_
                  end
                end
              end
            end
            NIL_
          end

          p = main_p = -> do

            # look for pieces that are strings ending in open parenthesis

            pc = st.gets
            if pc && :string == pc.category_symbol
              at_string_piece[]
            end
            pc
          end

          _reinitializer = Reinitializer___.new do | row_st_ |
            row_st = row_st_
            p = main_p
            NIL_
          end

          Common_::Stream.new _reinitializer do
            p[]
          end
        end
      end.call

      class Reinitializer___ < ::Proc
        alias_method :__reinitialize, :call
      end

      # ~ end

      class Row_Based_Body_ < Common_Body_

        def to_object_stream_

          # this streaming pattern is so weird we don't have a name for
          # it: each item (row) is able to consume items (subsequent rows)
          # from the same stream it itself came from. this is to implement
          # parsing of nested structures like parenthesis (and maybe one
          # day quotes) that can span multiple lines. because some rows are
          # "already parsed" (as mutable objects or whatever), they won't
          # need to be this fancy, which is why we don't push this method
          # up to be higher then at the row level.. :+#experimental

          p = nil

          st = to_business_row_stream_

          upper_mode = -> do

            row = st.gets
            if row
              st_ = row.to_object_stream_ st

              p = -> do
                x = st_.gets
                if x
                  x
                else
                  p = upper_mode
                  p[]
                end
              end

              p[]
            end
          end

          p = upper_mode

          Common_.stream do
            p[]
          end
        end
      end

      Here_ = self
    end
  end
end
