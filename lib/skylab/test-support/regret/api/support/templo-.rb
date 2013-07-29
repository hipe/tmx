module Skylab::TestSupport::Regret::API

  class Support::Templo_

    # it's a goofy name but i wanted it to be short, unique and semantic.
    # a "templo" holds all the ugly, hard-to read, and one-offy logic we
    # need to write partly because our templates are truly logic-less and
    # partly because what we're doing is so cool we need ad-hoc classes for
    # it. Sure call it a view controller but eew.

    EXT_ = '.tmpl'.freeze

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
        self.class.dir_pathname.join( "#{ i }#{ EXT_ }" ).read
      )
    end

    def get_templates *a
      a.map { |i| get_template i }
    end

    # ~ option support ~

  public

    def set_options option_a  # mutates
      res = true ; avail_a = available_option_a
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

    def available_option_a
      self.class::OPTION_A_
    end

    def show_option_help
      @snitch.puts "available template options:"
      build_section_yielder = -> y, name_i do
        first = true
        ::Enumerator::Yielder.new do |line|
          if first
            y << [ name_i.to_s, line ]
            first = false
          else
            y << [ '', line ]
          end
        end
      end
      ea = ::Enumerator.new do |y|
        available_option_a.each do | name_i, _, _, p|
          p[ build_section_yielder[ y, name_i ] ]
        end
      end
      Face::CLI::Table[
        :field, :id, :name,
        :field, :id, :desc, :left,
        :show_header, false,
        :left, '| ', :sep, '    ',
        :write_lines_to, @snitch.method( :puts ),
        :read_rows_from, ea ]
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
