require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI microservice toolkit - help screen integration" do

    TS_[ self ]
    use :CLI_microservice_toolkit

    context "basic help screen" do

      shared_subject :state_ do

        # this hits [#105]-inline-spot-1 - the tree is "jagged", not regular
        # (because of the option parser options) so we need to use "lax"
        # parsing, which is fine because these trees never go deep anyway.

        immutable_lax_helpscreen_state_via_invoke_ 'wammo', '--hel'
      end

      it "works" do
        expect( state_.exitstatus ).to be_zero
      end

      it "usage lines are formatted as `tight`" do

        _exp = <<-HERE.unindent
          usage: zeepo wammo
                 zeepo wammo -h

        HERE

        expect( state_.lookup( 'usage' ).to_string :unstyled ).to eql _exp
      end

      it "options section header is *plural* (option*s*) and looks right" do

        _t = state_.lookup 'options'

        cx = _t.children
        expect( cx.length ).to eql 2

        # ok so for "fun" and as an exercise we spike out a lot of silliness
        # here to assert that things line up as they should without asserting
        # a byte-per-byte equality, which is too fragile considering we may
        # change the default formatting (has happened before).
        #
        # so the "only" reasonable way to do this is to assert that the lines
        # line up with each other, which is tricky here because one line has
        # a short option in the "short option cel" and the other item has
        # no short option. so we parse the lines using their common
        # denominator (here): each line has one long switch, and each line
        # has a description:

        rx = /\A
          (?<before_long_switch>(?:(?!--).)+)
          (?<long_switch>[^ ]+)
          (?<long_space>[ ]+)
          (?=[^ ])  # some description
        /mx

        summary = ::Struct.new :col2_index, :col3_index

        summarize = -> idx do

          md = rx.match cx.fetch( idx ).x.string

          d = md[ :before_long_switch ].length

          _ = d + md[ :long_switch ].length + md[ :long_space ].length

          summary[ d, _ ]
        end

        smry1 = summarize[ 0 ]
        smry2 = summarize[ 1 ]

        #  col 1 |          col 2             |     col 3
        #
        #         --flim[=foo]                 flam.
        #     -h, --help                       this screen

        expect( smry1.col2_index ).to eql smry2.col2_index
        expect( smry1.col3_index ).to eql smry2.col3_index
      end

      shared_subject :client_class_ do

        class CLI_IMC_06 < subject_class_

          option_parser do | op |

            op.on '--flim[=foo]', 'flam.' do |x|
              @_par_x_a_.push :flim, x ; nil
            end
          end

          def wammo
          end
          self
        end
      end
    end
  end
end
