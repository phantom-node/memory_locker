# frozen_string_literal: true

require 'English'

RSpec.describe MemoryLocker do
  subject(:locker) { described_class.new(:glibc) }

  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  context 'with glibc backend' do
    let(:lock_failed) { 10 }
    let(:lock_unchanged) { 20 }
    let(:lock_success) { 0 }

    def lock
      locker.lock!
    rescue described_class::LockingError
      exit lock_failed
    end

    def locked
      File.readlines('/proc/self/status').grep(/^VmLck/)
          .first.split("\t").last.strip
    end

    def locked_changed?
      before = locked
      yield
      locked != before
    end

    def fork_status(&block)
      fork(&block)
      Process.wait
      $CHILD_STATUS.exitstatus
    end

    it 'locks memory' do
      status = fork_status do
        changed = locked_changed? { lock }
        exit lock_unchanged unless changed
      end
      expect(status).to eq(lock_success)
    end

    it 'raises exception if failed to lock memory' do
      status = fork_status do
        Process.setrlimit(:MEMLOCK, 0)
        lock
      end
      expect(status).to eq(lock_failed)
    end
  end
end
