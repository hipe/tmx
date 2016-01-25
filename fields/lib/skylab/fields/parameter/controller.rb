module Skylab::Fields

  class Parameter

    module Controller

      # (this will become `Controller` at next moves commit)

      # this (yet another (but perhaps the first)) :+[#sl-116] common
      # normalization implementation has been modified at this writing
      # to be more straightforward: all concerns are evaluated (rigidly)
      # at each step of one pass, as opposed to doing several passes.
      #
      # in addition to being a parameter container, your client must have:
      #
      #
      #   • the boolean meta-parameter `required`
      #
      #   • `@on_event_selectively` - this is the only means thru which the
      #      client may hook into the behavior from this method.
      #
      # if your client does not have `@formal_parameters` already true-ish,
      # it will get set by "the usual means"

      NORMALIZE_METHOD = -> do

        miss_a = nil

        _foz = ( @formal_parameters ||= self.class.parameters )

        _foz.to_value_stream.each do | prp |

          had = true
          x = fetch prp.name_symbol do
            had = false
            NIL_
          end

          if x.nil? && prp.has_default
            x = prp.default_value
            self[ prp.name_symbol ] = x
          end

          if prp.required? && x.nil?
            ( miss_a ||= [] ).push prp
          end
        end

        if miss_a

          @on_event_selectively.call :error, :missing_required_properties do

            Events___::Missing[ miss_a, self, false ]
          end
        else
          ACHIEVED_
        end
      end

      Events___ = ::Module.new
      Expression___ = Callback_::Event.structured_expressive.method :new

      Events___::Missing = Expression___.call do | parameters, entity, ok |

        a = parameters.map do | prp |
          par prp
        end

        _moniker = if false
          # (#todo probably '.name'
        else
          Actors___::Get_parameter_controller_moniker[ entity ]
        end

        "#{ _moniker } missing the required parameter#{ s a } #{ and_ a }"
      end

      Actors___ = ::Module.new
      Actors___::Get_parameter_controller_moniker = -> ent do  # legacy

        s_a = ent.class.name.split CONST_SEP_

        case 2 <=> s_a.length
        when -1  # long
          s_a = s_a[ -2 .. -1 ]
          has_two = true
        when 0
          has_two = true
        end

        if has_two
          if UNDERSCORE_ == s_a.first[ -1 ]  # assume Actors_::Foo
            s_a.shift
          else
            s_a.reverse!  # assume Noun::Verb -> 'verb noun'
          end
        end

        p = Callback_::Name::Conversion_Functions::Pathify
        s_a.map do | s |
          p[ s ]
        end * SPACE_
      end

      CONST_SEP_ = '::'
      UNDERSCORE_ = '_'
    end
  end
end
