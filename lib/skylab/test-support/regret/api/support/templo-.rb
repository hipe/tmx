module Skylab::TestSupport::Regret::API

  class Support::Templo_

    # it's a goofy name but i wanted it to be short, unique and semantic.
    # a "templo" holds all the ugly, hard-to read, and one-offy logic we
    # need to write partly because our templates are truly logic-less and
    # partly because what we're doing is so cool we need ad-hoc classes for
    # it. Sure call it a view controller but eew.

    EXT = '.tmpl'

    class << self
      alias_method :begin, :new
      # for now. `begin` means "set these (positional) parameters",
      # and "i might want to do more stuff - i.e hold on to the templo"
    end

    def render_to x ; @render_to[ x ] ; end

  private

    # ~ template support ~

    def get_template i
      Face::Services::Basic::String::Template.from_string(
        self.class.dir_pathname.join( "#{ i }#{ EXT }" ).read
      )
    end

    def get_templates *a
      a.map { |i| get_template i }
    end

    # ~ option support ~

  public

    def set_options option_a  # mutates
      res = true ; avail_a = available_options
      avail_a.each do |i, not_provided, provided|
        if option_a and (( idx = option_a.index i.to_s ))
          option_a[ idx ] = nil
          ( res = instance_exec( & provided ) ).nil? and break
        else
          instance_exec( & not_provided )
        end
      end
      if true == res && option_a
        option_a.compact!
        if option_a.length.nonzero?
          @snitch.say :notice, -> { "invalid template option(s) #{
            }#{ option_a.map( & :inspect ) * ', ' } - valid option(s): #{
            }(#{ avail_a.map( & :first ) * ', ' })" }
          res = false
        end
      end
      res
    end

  private

    def available_options
      self.class::OPTION_A_
    end

    def show_option_help
      @snitch.puts "available template options:"
      Face::CLI::Table::FUN.___tablify[
        [ 'option', 'desc' ], ::Enumerator.new do |y|
          available_options.each do |i, _, _, p|
            first = true
            p[ ::Enumerator::Yielder.new do |line|
              if first
                y << [ i.to_s, line ]
                first = false
              else
                y << [ '', line ]
              end
            end ]
          end
        end, @snitch.method( :puts ), false  # don't show header
      ]
      nil
    end

    # ~ fun ~

    fun = { }

    fun[ :descify ] = -> do
      rx = /:\z/
      -> str do
        no_colon = str.gsub rx, ''
        no_colon.inspect
      end
    end.call

    FUN = ::Struct.new( * fun.keys ).new( * fun.values )
  end
end
