# frozen_string_literal: true

require_relative 'memory_locker/version'
require 'ffi'

# Lock process memory, so it won't be swapped by the kernel.
# It is implemented as a one-way operation: there is no unlock.
# That's because it's hard to properly clean memory in Ruby.
class MemoryLocker
  LockingError = Class.new StandardError

  def lock!
    Backend.lock! || raise(LockingError, "Failed to lock memory, errno #{FFI.errno}")
  end

  private

  attr_reader :backend

  def initialize(backend)
    require_relative "memory_locker/#{backend}"
  end
end
