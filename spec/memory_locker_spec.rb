# frozen_string_literal: true

require "English"

RSpec.describe MemoryLocker do
  subject(:locker) do
    described_class.new(libc_loader: libc_loader,
      libc_fetcher: -> { libc },
      unsupported_error: unsupported_error,
      libc_not_found_error: libc_not_found_error)
  end

  let(:libc_loader) { spy }
  let :libc do
    double("Libc").tap do |obj|
      allow(obj).to receive(:mlockall).and_return(mlockall_result)
    end
  end
  let(:unsupported_error) { Class.new StandardError }
  let(:libc_not_found_error) { Class.new StandardError }

  it "has a version number" do
    expect(described_class::VERSION).not_to be_nil
  end

  it "returns nil when called without doubles" do
    # Do not lock rspec process memory
    fork { exit described_class.new.call.nil? ? 0 : 1 }
    Process.wait
    expect($CHILD_STATUS.exitstatus).to eq(0)
  end

  context "when everything is ok" do
    let(:mlockall_result) { [0, 2] }

    it "returns nil" do
      expect(locker.call).to be_nil
    end

    it "loads libc" do
      locker.call
      expect(libc_loader).to have_received(:call)
    end
  end

  context "when libc failed to load" do
    let :libc_loader do
      -> { raise libc_not_found_error }
    end

    it "raises exception" do
      expect { locker }.to raise_error(described_class::LibcNotFoundError)
    end
  end

  context "when libc does not support mlockall" do
    let :mlockall_result do
      raise unsupported_error
    end

    it "raises exception" do
      expect { locker }.to raise_error(described_class::UnsupportedError)
    end
  end

  context "when locking failed" do
    let(:mlockall_result) { [1, 2] }

    it "raises exception" do
      expect do
        locker.call
      end.to raise_error(described_class::LockingError)
    end
  end
end
