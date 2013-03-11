module Skylab::MyTree

  MyTree::Services::Shellwords || nil

  class Services::Find  # [#sl-118] - unify find cmds mebbem

    def string                    # didactic
      if is_valid
        y = [ "find #{ @path_a.map { |p| p.to_s.shellescape } * ' ' }" ]
        if @type
          y << "-type #{ @type }"
        end
        if @pattern
          y << "-name #{ pattern.shellescape }"
        end
        y.join ' '
      end
    end

    #         ~ setters for you, and their getters ~

    #         ~ ~ path ~ ~

    def add_path path_s
      @path_a.push path_s
      nil
    end

    def concat_paths path_a
      @path_a.concat path_a
      nil
    end

    def path_a
      @path_a.dup
    end

    #         ~ ~ pattern ~ ~

    def pattern= x
      if @pattern
        error "pattern already set"
      else
        @pattern = x
      end
      x
    end

    attr_reader :pattern

    # `each` - make an enumerator out of the result of the `find` command,
    # one line per line written to stdout.

    def each  # result is nil if invalid or block given, else enumerator
      if is_valid
        ea = ::Enumerator.new do |y|
          MyTree::Services::Open3.popen3 string do |_, sout, serr|
            err = serr.read
            if '' == err
              sout.each_line do |line|
                y << line.chomp
              end
            else
              err.split( "\n" ).each do |line|
                error line.chomp
              end
            end
          end
          nil
        end
        block_given? ? ea.each { |x| yield x } : ea
      end
    end

    def is_valid
      if @is_valid.nil?  # one way street..
        if @path_a.length.zero?
          error "find command has no paths"
        end
        if @is_valid.nil?
          @is_valid = true
        end
      end
      @is_valid
    end

  protected

    def initialize error
      @error = error
      @is_valid = nil
      @path_a = [ ]
      @pattern = nil
      @type = :file  # meh for now
      nil
    end

    def error text
      @is_valid = false
      @error[ text ]
      false
    end
  end
end
