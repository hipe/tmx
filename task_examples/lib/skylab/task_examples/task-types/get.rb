
module Skylab::TaskExamples

  class TaskTypes::Get < Common_task_[]

    depends_on_parameters(

      build_dir: :_from_context,
      dry_run: [ :flag, :_from_context, :optional ],
      from: :optional,
      get: nil,
    )

    def execute

      __normalize_from_and_get
      __init_units_of_work
      ___execute_units_of_work
    end

    def ___execute_units_of_work

      if @units_of_work.length.zero?
        self._COVER_ME_nothing_to_do
      else
        ___execute_nonzero_units_of_work
      end
    end

    def ___execute_nonzero_units_of_work

      require 'net/http'
      @_shellescape = Home_::Library_::Shellwords.method :shellescape

      ok = ACHIEVED_
      @units_of_work.each do |unit|
        ok_ = ___execute_unit unit
        if ! ok_
          ok = false
        end
      end
      ok
    end

    def ___execute_unit unit

      url, dest_path = unit.to_a

      @_oes_p_.call :info, :expression, :fake_shell do |y|
        _ = Home_::Library_::Shellwords.shellescape dest_path
        y << "curl -o #{ _ } #{ url }"  # or "wget -O .."
      end

      uri = ::URI.parse url

      resp = ::Net::HTTP.start uri.host, uri.port do |nh|

        _request = ::Net::HTTP::Get.new uri.request_uri
        nh.request _request
      end

      # the *only* distinguishing thing that adsf does in lieu of a 404 is
      # that it does not send a "last-modified" header (and writes a message in the body)

      h = resp.to_hash
      if h.key? THIS_KEY___
        ::File.open dest_path, FLAGS___ do |fh|
          fh.write resp.body
        end
        ACHIEVED_
      else
        ___when_etc h, unit
        UNABLE_
      end
    end

    FLAGS___ = ::File::CREAT | ::File::WRONLY
    THIS_KEY___ = 'last-modified'

    def ___when_etc h, unit
      @_oes_p_.call :error, :expression, :"404" do |y|
        y << "File not found: #{ unit.url }"  # look sort of like adsf
      end
    end

    def __init_units_of_work

      _tail_a = remove_instance_variable :@get
      from = remove_instance_variable :@from
      build_dir = @build_dir

      unit_a = []

      _tail_a.each do |tail|

        _url = ::File.join from, tail
        _destination_path = ::File.join build_dir, tail
        unit = Unit___.new _url, _destination_path

        _ok = ___unit_does_procure unit
        if _ok
          unit_a.push unit
        end
      end

      @units_of_work = unit_a ; nil
    end

    def ___unit_does_procure unit

      begin
        stat = ::File.stat unit.destination_path
      rescue ::Errno::ENOENT
      end

      if stat
        if stat.size.zero?
          __express_zero_length_file unit
          YES_  # overwrite empty files
        else
          ___express_nonzero_length_file unit
          NO_  # don't overwrite a local version
        end
      else
        YES_  # this is "normal" so don't report anything
      end
    end

    def ___express_nonzero_length_file unit
      @_oes_p.call :info, :expression, :wont_overwrite_file do |y|
        y << "assuming already downloaded b/c exists #{
          }(erase/move to re-download) - #{ pth unit.destination_path }"
      end
    end

    def __express_zero_length_file unit
      @_oes_p_.call :info, :expression, :overwriting_empty_file do |y|
        y << "had zero byte file (strange), overwriting - #{
          }#{ pth unit.destination_path }"
      end
    end

    def __normalize_from_and_get
      if @from
        _when_from
      else
        ___when_no_from
      end
    end

    def ___when_no_from
      @from = ::File.dirname @get
      @get = ::File.basename @get
      _when_from
    end

    def _when_from

      if ! ::Array.try_convert @get
        @get = [ @get ]
      end
      NIL_
    end

    attr_reader(
      :units_of_work,
    )

    NO_ = false
    Unit___ = ::Struct.new :url, :destination_path
    YES_ = true
  end
end
