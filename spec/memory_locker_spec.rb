# frozen_string_literal: true

require "English"

RSpec.describe MemoryLocker do
  def lock_and_exit(converter = ->(&block) { block.call })
    exit converter.call { locker.call }
  end

  def lock_and_check_impact
    before = locked
    locker.call
    exit (locked == before) ? 1 : 0
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

  subject(:locker) do
    described_class.new(libc_path: libc_path, function_name: function_name)
  end

  let(:libc_path) { nil }
  let(:function_name) { "mlockall" }

  it "has a version number" do
    expect(described_class::VERSION).not_to be_nil
  end

  context "when libc failed to load" do
    let(:libc_path) { "not/existing/file" }
    it "raises exception" do
      expect { locker.call }.to raise_error(described_class::UnsupportedError)
    end
  end

  context "when libc does not support mlockall" do
    let(:function_name) { "hey_this_function_doesnt_exist_in_any_c_library" }
    it "raises exception" do
      expect { locker.call }.to raise_error(described_class::UnsupportedError)
    end
  end

  context "without limits on locking" do
    it "returns nil" do
      converter = ->(&block) { block.call.nil? ? 123 : 1 }
      status = fork_status { lock_and_exit(converter) }
      expect(status).to eq(123)
    end

    it "changes amount of locked memory" do
      status = fork_status { lock_and_check_impact }
      expect(status).to eq(0)
    end
  end

  context "with limits on locking" do
    let :converter do
      ->(&block) {
        begin
          block.call
        rescue described_class::LockingError
          123
        else
          0
        end
      }
    end

    it "fails to lock memory" do
      status = limited_fork_status { lock_and_exit(converter) }
      expect(status).to eq(123)
    end

    it "does not change amount of locked memory" do
      status = limited_fork_status { lock_and_check_impact }
      expect(status).to eq(1)
    end
  end

  private

  def locked
    File.readlines("/proc/self/status").grep(/^VmLck/)
      .first.split("\t").last.strip
  end
end
