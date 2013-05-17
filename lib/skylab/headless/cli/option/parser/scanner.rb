module Skylab::Headless

  CLI::Option::Parser::Scanner = MetaHell::Function::Class.new :gets
  class CLI::Option::Parser::Scanner  # for quick ::OptionParser hacks
                                  # (emigrated in from ancient tr, aged well)
                                  # this class and idea is tracked by [#053])

    -> do # `fetch`

      reduce_a = nil

      define_method :fetch do |query_x, *a, &b|
        query = if query_x.respond_to? :call then query_x else
          -> param do query_x == param.normalized_parameter_name end
        end
        otherwise = reduce_a.fetch( ( b ? ( a << b ) : a ).length ).call a
        while x = gets
          break( found = x ) if query[ x ]
        end
        if found then found else
          otherwise ||= -> { raise ::KeyError, 'item matching query not found.'}
          otherwise[]
        end
      end
      reduce_a = [ -> _ { }, -> a { a[0] } ].freeze # distills 1 item from args
    end.call

  protected

    def initialize enum
      ea = if enum.respond_to?( :each ) then enum else
        CLI::Option::Enumerator.new enum
      end
      fly = CLI::Option.new_flyweight
      @gets = -> do
        begin
          sw = ea.next
          fly.replace_with_switch sw
          fly
        rescue ::StopIteration
          @gets = -> { }
          nil
        end
      end
    end

    FUN = -> do

      long_rx, short_rx = CLI::Option::FUN.at :long_rx, :short_rx

      # (used elsewhere, here as courtesy and for proper semantic taxonomy)

      ::Struct.new( :weak_identifier_for_switch )[
        -> sw, otherwise=nil do
          stem = if sw.long.length.nonzero?
            md = long_rx.match sw.long.first
            md && "--#{ md[:long_stem] }"
          else
            md = short_rx.match sw.short.first
            md && "-#{ md[:short_stem] }"
          end
          if stem then stem
          elsif otherwise then otherwise[ ] else
            raise ::RuntimeError, "can't infer weak identifier from switch"
          end
        end
      ].freeze
    end.call
  end
end
