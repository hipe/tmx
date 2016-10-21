module Skylab::TMX

  class Operations_::Map

    When_ = ::Module.new
    module EventsScratchSpace___

      # ==

      When_::Contextually_missing = -> dep_sym, primary_sym, listener do

        listener.call :error, :expression, :parse_error, :contextually_missing do |y|

          _prim_name = Common_::Name.via_variegated_symbol primary_sym

          _dep_name = Common_::Name.via_variegated_symbol dep_sym

          y << "cannot use #{ say_primary_ _prim_name } without #{ say_primary_ _dep_name }"
        end

        UNABLE_
      end

      # ==

      When_::Contextually_invalid_primary = -> sym, listener do

        listener.call :error, :expression, :parse_error, :contextually_invalid do |y|

          means = Misc_hard_coded_dependency_reflection__[].fetch sym

          _me = means.say_self_via_symbol sym, self

          _dep = means.say_dependency_under self

          y << "#{ _me } must occur after #{ _dep }."
        end
        UNABLE_
      end

      # ==

      When_::Missing_requireds = -> missing_ivar_a, listener do

        listener.call :error, :expression, :parse_error, :missing_required_arguments do |y|

          h = Misc_hard_coded_dependency_reflection__[]

          missing_ivar_a.each do |ivar|

            means = h.fetch ivar

            _me = means.say_self_via_ivar ivar, self

            _dep = means.say_dependency_under self

            y << "#{ _me } was not resolved. (use #{ _dep }.)"
          end
          y
        end

        UNABLE_
      end

      # ==

      When_::Unrecognized_primary = -> argument_scanner, listener do

        listener.call :error, :expression, :parse_error, :unrecognized_primary do |y|

          _name = argument_scanner.head_as_agnostic

          _name_st = Stream_.call PRIMARIES_.keys do |sym|
            Common_::Name.via_variegated_symbol sym
          end

          y << "unrecognized primary #{ say_primary_ _name }"

          _this_or_this_or_this = say_primary_alternation_ _name_st

          y << "expecting #{ _this_or_this_or_this }"
        end

        UNABLE_
      end

      # ==

      Misc_hard_coded_dependency_reflection__ = Lazy_.call do

        # hypothetically we can generate some of this with [ta] magnetics meh

        o = Home_::Models_::Means
        {
          :result_in_tree => o[ :primary, :order, :primary ],
          :@unparsed_node_stream => o[ :primary, :json_file_stream, :human ],
        }
      end

      # ==
    end
  end
end
# #history: broke out of operation
