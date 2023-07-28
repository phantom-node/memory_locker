# frozen_string_literal: true

require 'memory_locker/libc'
require 'English'

MemoryLocker.class_eval <<-RUBY, __FILE__, __LINE__ + 1
  public_constant :Libc
RUBY

RSpec.describe MemoryLocker::Libc do
  subject(:libc) { described_class }

  def lock_and_exit(converter = ->(result) { result[0] })
    exit converter.call(libc.mlockall)
  end

  def lock_and_check_impact
    before = locked
    libc.mlockall
    exit locked == before ? 1 : 0
  end

  def fork_status(&block)
    fork(&block)
    Process.wait
    $CHILD_STATUS.exitstatus
  end

  def limited_fork_status
    fork_status do
      Process.setrlimit(:MEMLOCK, 0)
      yield
    end
  end

  context 'without limits on locking' do
    it 'locks memory' do
      status = fork_status { lock_and_exit }
      expect(status).to eq(0)
    end

    it 'changes amount of locked memory' do
      status = fork_status { lock_and_check_impact }
      expect(status).to eq(0)
    end

    it 'returns 2 element array' do
      array_test = ->(result) { result.is_a?(Array) && result.size == 2 ? 0 : 1 }
      status = fork_status { lock_and_exit(array_test) }
      expect(status).to eq(0)
    end

    it 'returns array of integers' do
      array_test = ->(result) { result.all? { |e| e.is_a?(Integer) } ? 0 : 1 }
      status = fork_status { lock_and_exit(array_test) }
      expect(status).to eq(0)
    end

    it 'returns errno' do
      array_test = ->(result) { result[1] == FFI.errno ? 0 : 1 }
      status = fork_status { lock_and_exit(array_test) }
      expect(status).to eq(0)
    end
  end

  context 'with limits on locking' do
    it 'fails to lock memory' do
      status = limited_fork_status { lock_and_exit }
      expect(status).to eq(255) # exit(-1)
    end

    it 'does not change amount of locked memory' do
      status = limited_fork_status { lock_and_check_impact }
      expect(status).to eq(1)
    end

    it 'returns 2 element array' do
      array_test = ->(result) { result.is_a?(Array) && result.size == 2 ? 0 : 1 }
      status = limited_fork_status { lock_and_exit(array_test) }
      expect(status).to eq(0)
    end

    it 'returns array of integers' do
      array_test = ->(result) { result.all? { |e| e.is_a?(Integer) } ? 0 : 1 }
      status = limited_fork_status { lock_and_exit(array_test) }
      expect(status).to eq(0)
    end

    it 'returns errno' do
      array_test = ->(result) { result[1] == FFI.errno ? 0 : 1 }
      status = limited_fork_status { lock_and_exit(array_test) }
      expect(status).to eq(0)
    end
  end

  private

  def locked
    File.readlines('/proc/self/status').grep(/^VmLck/)
        .first.split("\t").last.strip
  end
end
