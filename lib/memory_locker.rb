# frozen_string_literal: true

require_relative 'memory_locker/version'
require 'ffi'

# Lock process memory, so it won't be swapped by the kernel.
# It is implemented as a one-way operation: there is no unlock.
# That's because it's hard to properly clean memory in Ruby.
class MemoryLocker
  Error             = Class.new StandardError
  UnsupportedError  = Class.new Error
  LibcNotFoundError = Class.new Error
  LockingError      = Class.new Error

  def call
    result, errno = libc.mlockall
    raise LockingError, "Locking of memory failed with errno #{errno}" unless result.zero?
  end

  private

  attr_reader :libc

  def initialize(libc_loader: -> { require_relative 'memory_locker/libc' },
                 libc_fetcher: -> { Libc },
                 unsupported_error: FFI::NotFoundError,
                 libc_not_found_error: LoadError)
    libc_loader.call
    @libc = libc_fetcher.call
  rescue unsupported_error => e
    raise UnsupportedError, 'System does not support mlockall()', cause: e
  rescue libc_not_found_error => e
    raise LibcNotFoundError, 'Failed to find C library', cause: e
  end
end
