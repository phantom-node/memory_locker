# frozen_string_literal: true

class MemoryLocker
  # Low level interface to libc
  module Libc
    # Those values should remain the same on all POSIX systems
    MCL_CURRENT = 1
    MCL_FUTURE = 2

    extend FFI::Library
    # Try to load already loaded libc from the current process, use system libc as a fallback
    ffi_lib [FFI::CURRENT_PROCESS, FFI::Library::LIBC], FFI::Library::LIBC
    attach_function :real_mlockall, :mlockall, [:int], :int

    def self.mlockall
      result = real_mlockall(MCL_CURRENT | MCL_FUTURE)
      [result, FFI.errno]
    end
  end

  private_constant :Libc
end
