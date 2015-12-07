module Skylab::Brazen

  class CLI::Isomorphic_Methods_Client

    class Models_::Help_Screen  # see [#106]

      class << self

        def write_to_array_sections_from_line_stream a, st

          Parse_sections___[ a, st ]
        end
      end  # >>

      Models = ::Module.new
      Models_ = ::Module.new

      class Models::Description

        class << self

          def of_instance inst

            if inst.class.const_defined? :DESCRIPTION_BLOCK_
              new inst
            else
              THE_EMPTY_DESCRIPTION___
            end
          end
          private :new
        end  # >>

        def initialize inst
          @__description_proc = inst.class.const_get :DESCRIPTION_BLOCK_
        end

        def instance_description_proc
          @__description_proc  # (hi.)
        end
      end

      THE_EMPTY_DESCRIPTION___ = class Models_::The_Empty_Description____

        def instance_description_proc
          NIL_
        end

        self
      end.new

      class Models_::Section

        attr_reader(
          :header,
          :lines,
        )

        attr_writer(
          :header,
        )

        def initialize header, lines

          @header = header
          @lines = lines
        end

        def any_nonzero_length_line_a
          if @lines.length.nonzero?
            @lines
          end
        end
      end

      # <-

    state_h = { }  # das state machine

    state = ::Struct.new :rx, :to

    #         name               regex         which can be followed by..

    state_h[ :initial ] = state[ nil,          [ :section, :desc ] ]
    state_h[ :desc    ] = state[ //,           [ :section, :normal ] ]
    state_h[ :normal  ] = state[ //,           [ :section, :normal ] ]
    state_h[ :section ] = state[ /\A[^:]+:\z/, [ :item, :normal ] ]
    state_h[ :item    ] = state[
                       /\A(?<ind> +)(?<hdr>((?!  ).)+)(?: {2,}(?<bdy>.+))?\z/,
                                      [ :subitem, :item, :section, :normal ] ]
    state_h[ :subitem ] = state[ nil, # (<- guess what will happen here)
                                      [ :subitem, :item, :section, :normal ] ]

    item_rx_h = ::Hash.new { |h, k| h[k] = /\A {#{ k },}(.+)\z/ }  # cache rx

    Parse_sections___ = -> sections, lines do
      stat = state_h[ :initial ]  # (var meaning change!!)
      section = line = nil
      push = -> { sections << ( section = Models_::Section.new nil, [] )  }
      trigger_h = {
        desc:    -> { push[] ; section.lines << [ :line, line ] },
        section: -> { push[] ; section.header = line },
        normal:  -> {          section.lines << [ :line, line ] },
        item:    -> {          section.lines << [ :item, * $~.captures[1..-1]]
                               state_h[:subitem].rx =  # *NOTE* not #idempotent
                                 item_rx_h[ $~[:ind].length + 1 ] },
        subitem: -> {          section.lines << [ :item, nil, $~[1] ] }
      }
      while (( line = lines.gets ))
        line.chomp!
        name_i = stat.to.detect do |i|
          state_h[ i ].rx =~ line
        end
        trigger_h.fetch( name_i ).call
        stat = state_h.fetch name_i
      end ; nil
    end

    # ~ end legacy

  # ->
    end
  end
end
