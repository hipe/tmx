module Skylab::Brazen

  class Collection_Adapters::Directory_as_Collection

    class << self
      def is_actionable
        false
      end
    end  # >>

    def initialize k

      @directory_is_assumed_to_exist = true
      @filename_pattern = nil
      @_kernel = k

      if block_given?
        yield self
      end
    end

    attr_writer(
      :directory_is_assumed_to_exist,
      :directory_path,
      :filesystem,
      :filename_pattern,  # respond to `=~`
      :flyweight_class
    )

    def to_entity_stream_via_model _cls_, & x_p  # #UAO
      to_entity_stream( & x_p )
    end

    # ~ c.r.u.d

    # ~~ create (by way of ACS)

    def __add__object_for_mutation_session o, & x_p

      ok = __resolve_entry_name o, & x_p
      ok &&= __resolve_destination_directory( & x_p )
      ok && __finish_add( o, & x_p )
    end

    def __resolve_entry_name o, & x_p

      if @filename_pattern
        ok = @filename_pattern =~ o.natural_key_string
        if ok
          ok
        else
          x_p.call :error, :expression, :invalid_name do | y |
            y << "invalid name #{ ick o.natural_key_string }"
          end
          UNABLE_
        end
      else
        ACHIEVED_
      end
    end

    def __resolve_destination_directory & x_p

      if @filesystem.directory? @directory_path
        ACHIEVED_
      elsif @directory_is_assumed_to_exist
        x_p.call :error, :expression, :noent do | y |
          y < "no. (hl-xyzzy)"
        end
        UNABLE_
      else

        # we can make 2. meh

        path = ::File.dirname @directory_path
        ok = if @filesystem.directory? path
          ACHIEVED_
        else
          @filesystem.mkdir path  # -p meh
        end
        if ok
          if path == @directory_path
            ok
          else
            @filesystem.mkdir @directory_path
          end
        else
          ok
        end
      end
    end

    def __finish_add o, & x_p

      o.express_into_under self, @filesystem, & x_p
    end

    attr_reader :directory_path

    # ~~ delete (by way of ACS)

    def __remove__object_for_mutation_session o, & x_p

      # per ACS, assume that last we checked, item is present in collection

      succ = Brazen_.lib_.basic::String.succ.with(

        :beginning_width, 2,
        :first_item_does_not_use_number,

        :template, '{{ sep if ID }}{{ ID }}{{ tail }}',

        :sep, '.',
        :tail, '.previous',
      )

      entry_s  = o.natural_key_string

      src = ::File.join @directory_path, entry_s

      begin

        candidate_s = ::File.join @directory_path, "#{ entry_s }#{ succ[] }"

        if @filesystem.file? candidate_s
          redo
        end

        ok = @filesystem.mv src, candidate_s, & x_p
        break
      end while nil

      ok && o
    end

    def has_equivalent_item_for_mutation_session item

      s = item.natural_key_string

      _x = to_entity_stream.detect do | item_ |

        s == item_.natural_key_string
      end

      _x ? true : false
    end

    # ~~ retrieve

    def to_entity_stream & x_p

      p = -> do

        path_a = __produce_path_a
        if path_a
          p = __proc_via_path_a path_a, & x_p
          p[]
        else
          path_a
        end
      end

      Callback_.stream do
        p[]
      end
    end

    def __produce_path_a

      path = @directory_path
      if path  # otherwise nasty

        glob = -> do
          @filesystem.glob ::File.join( path, '*' )
        end

        if @directory_is_assumed_to_exist
          glob[]
        else
          if @filesystem.directory? path
            glob[]
          else
            EMPTY_A_
          end
        end
      else
        UNABLE_
      end
    end

    def __proc_via_path_a path_a, & x_p

      fly = @flyweight_class.new_flyweight @_kernel, & x_p

      pass = __produce_pass_proc

      st = Callback_::Stream.via_nonsparse_array(
        path_a
      ).map_reduce_by do | path_ |

        _yes = pass[ path_ ]
        if _yes

          fly.reinitialize_via_path_for_directory_as_collection path_
          fly
        end
      end

      -> do
        st.gets
      end
    end

    def __produce_pass_proc

      if @filename_pattern
        rx_ish = @filename_pattern
        -> path do
          rx_ish =~ ::File.basename( path )
        end
      else
        MONADIC_TRUTH_
      end
    end

    # ~~ support

    def edit * x_a, & x_p

      Brazen_::Mutation_Session.edit x_a, self, & x_p
    end

    def mutable_body_for_mutation_session
      self
    end

    def receive_changed_during_mutation_session & x_p

      ACHIEVED_
    end

    # :+#hook-out: `description_under`

    # ~

    MONADIC_TRUTH_ = -> _ { true }
  end
end
