# frozen_string_literal: true

class MemoryLocker
  # Low level interface to glibc
  module Backend
    extend FFI::Library
    ffi_lib 'libc.so.6'

    MCL_CURRENT = 1
    MCL_FUTURE = 2

    attach_function :mlockall, [:int], :int

    def self.lock!
      mlockall(MCL_CURRENT | MCL_FUTURE).zero?
    end
  end
end
