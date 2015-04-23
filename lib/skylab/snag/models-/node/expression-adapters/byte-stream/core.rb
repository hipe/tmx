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
              BS_::Sessions_::Delineate[ d, y, expag, node ]
            else
              BS_::Sessions_::Delineate.new_with( d, y, expag, node ).execute_agnostic
            end
          else
            body.express_N_units_into_under_ d, y, expag
          end
        end
      end  # >>

      Actors_ = ::Module.new

      the_language_extension_for_structures = nil

      Actors_::Flyweighted_object_stream_via_substring = -> do

        # to leverage (rather than be penalized by) the flyweighting that the
        # upstream provides (see), we must re-use the same stream object over
        # all of the upstream lines.

        p = -> sstr do  # the first time it its called ..

          fly = Snag_::Models::Hashtag::Stream.new

          fly.initialize_string_scanner_ sstr.begin, sstr.end, sstr.s

          fly.receive_hashtag_class_(
            Snag_::Models_::Tag::Expression_Adapters::Byte_Stream::Models_::Tag
          )

          fly.init

          fly.become_name_value_scanner

          fly_ = the_language_extension_for_structures[ fly ]

          p = -> sstr_ do  # subsequent times ..

            fly.reinitialize_string_scanner_ sstr_.begin, sstr_.end, sstr_.s

            fly_.upstream.__reinitialize

            fly_
          end

          fly_
        end

        -> sstr do
          p[ sstr ]
        end
      end.call

      # ~ begin experimental language extension

      the_language_extension_for_structures = -> do

        open_paren_byte = '('.getbyte 0
        space_byte = SPACE_.getbyte 0

        -> st do

          money = nil
          p = main_p = -> do

            # look for pieces that are strings ending in open parenthesis

            pc = st.gets
            if pc && :string == pc.category_symbol

              scn = st.string_scanner
              s = scn.string
              last = pc._begin
              d = last + pc._length - 1

              # going backwards, skip over zero or more space (32) characters
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

              if stay && open_paren_byte == s.getbyte( d )

                pc_ = st.gets  # lookahead
                if pc_
                  if :tag == pc_.category_symbol && pc_.value_is_known_is_known
                    pc = money[ d, pc_, pc ]
                  else
                    p = -> do  # "put it back'
                      p = main_p
                      pc_
                    end
                  end
                end
              end
            end
            pc
          end

          close_paren = /[^)]*\)/
          open_double_quote = /[^)"]*"/

          money = -> open_d, deep_pc, string_pc do

            scn = st.string_scanner

            d = scn.skip open_double_quote
            if d
              self._HAVE_FUN_PARSING_QUOTES
            end

            d = scn.skip close_paren
            if ! d
              self._HAVE_FUN_PARSING_MULTI_LINE_DOO_HAS
            end

            # the received string piece is what would have gone out if we
            # didn't engage this extension. mutate the string piece so
            # it does not include the open paren:

            string_pc._length = open_d - string_pc._begin

            # mutate the "deep piece" so that it begins with the open paren

            deep_pc._begin = open_d

            # (note the deep piece's name string range stays the same)

            # extend the deep piece's length so it ends with the close paren

            deep_pc._length = scn.pos - open_d

            # change the deep piece's value range to have everything from
            # after the open colon to before the close paren

            deep_pc._value_r = deep_pc._name_r.end + 1 ... scn.pos - 1

            if string_pc._length.zero?

              # in cases where the mutated string piece ends up with no
              # content of its own, skip over it and produce deep pc now

              self._COVER_ME
              deep_pc
            else

              # otherwise, result in this mutated string piece now and the
              # deep piece next

              p = -> do  # "push it back"
                p = main_p
                deep_pc
              end

              string_pc
            end
          end  # end money

          _reinitializer = Reinitializer___.new do
            p = main_p
            NIL_
          end

          Callback_::Stream.new _reinitializer do
            p[]
          end
        end
      end.call

      class Reinitializer___ < ::Proc
        alias_method :__reinitialize, :call
      end


      # ~ end

      BS_ = self
    end
  end
end
