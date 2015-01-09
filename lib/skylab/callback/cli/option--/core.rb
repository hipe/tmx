module Skylab::Callback

  # **NOTE** this is not part of the normal day-to-day [cb] digraph distribution,
  # rather it is part of a s super experimental high-tech precision debugging
  # tool..

  class CLI

    module Option__

      class << self

        def parser
          Parser__
        end
      end

      module Parser__

        class << self
          def fire
            Fire__
          end
        end

        class Fire__ < Lib_::Stdlib_option_parser[]

    # do our hacky custom parse yay
    def parse! argv, &setback
      argv_rest = Stop__.parse! argv
      res = super argv, & nil  # result is always..
      if argv_rest
        ok = true ; errmsg = nil
        opendata = Open__.parse argv_rest, -> e do
          ok = false
          errmsg = e
        end
        if ! ok then
          raise ::OptionParser::ParseError, "while parsing opendata, #{errmsg}"
        else
          setback[ -> { @opendata = opendata } ]
        end
      end
      res
    end
        end

        module Open__

    # experiment in parsing
    def self.parse argv, err
      scn = Option__::Scanner.new argv, err
      if scn.eos? then nil
      elsif scn.last? and scn.looks_like_arg?
        [ :string, scn.current ]
      else
        box = Callback_::Box.new
        valid = nil
        begin
          valid = false
          opt = scn.expect_long or break
          arg = scn.expect_arg or break
          box.algorithms.if_has_name opt.normalized_parameter_name, -> k do
            err[ "can't take multiple values for #{opt.as_parameter_signifier}"]
            false
          end, -> bx, k do
            bx.add k, arg
            valid = true
            true
          end or break
        end while ! scn.eos?
        if ! valid then valid else
          [ :box, box ]
        end
      end
    end
        end

        module Stop__

    # iff `argv` has any first '--' occuring in it (alone as a token) then
    # mutate argv: parse-out the '--' and any tokens that follow it
    # including any subsequent '--'), and the result is this array
    # (not including the leading '--').
    # result is nil iff '--' did not occur in the argv. result is the
    # empty array iff '--' occured with nothing after it. when result is
    # non-nil argv will be mutated to have the '--' and anything after it
    # (that which was the result) removed.

    def self.parse! argv
      idx = argv.index '--'
      if idx
        argv_rest = argv[ idx + 1  .. -1 ]
        argv[ idx .. -1 ] = []
      end
      argv_rest
    end

        end
      end
    end
  end
end
