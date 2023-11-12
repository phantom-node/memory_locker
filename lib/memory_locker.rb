# frozen_string_literal: true

require_relative "memory_locker/version"
require "fiddle"

# Lock process memory, so it won't be swapped by the kernel.
# It is implemented as a one-way operation: there is no unlock.
# That's because it's hard to properly clean memory in Ruby.
class MemoryLocker
  Error = Class.new StandardError
  LockingError = Class.new Error
  UnsupportedError = Class.new Error

  # Those values should remain the same on all POSIX systems
  MCL_CURRENT = 1
  MCL_FUTURE = 2
  private_constant :MCL_CURRENT, :MCL_FUTURE

  def call
    raise LockingError, "Locking of memory failed" unless function.call(MCL_CURRENT | MCL_FUTURE).zero?
  end

  def self.call
    new.send :call
  end

  private

  def function
    lazy_function.call
  rescue unsupported_error => e
    raise UnsupportedError, "Memory locking not supported: #{e.message}", cause: e
  end

  attr_reader :lazy_function, :unsupported_error

  def initialize(
    libc_path: nil,
    function_name: "mlockall",
    lazy_handle: -> { Fiddle.dlopen(libc_path)[function_name] },
    lazy_function: -> { Fiddle::Function.new(lazy_handle.call, [Fiddle::TYPE_INT], Fiddle::TYPE_INT) },
    unsupported_error: Fiddle::DLError
  )

    @lazy_function = lazy_function
    @unsupported_error = unsupported_error
  end
end
