# MemoryLocker

[![Gem Version](https://badge.fury.io/rb/memory_locker.svg)](https://badge.fury.io/rb/memory_locker)

Lock memory containing sensitive data (such as passwords or cryptographic keys) to prevent it from being swapped
by the kernel, which allows the attacker with access to swap space to recover secrets.

## How it works

Ruby doesn't allow granular memory management, therefore the approach is to lock the entire memory of a current
process using [mlockall()](https://linux.die.net/man/2/mlockall).

The memory will stay locked until the process terminates. Although unlocking memory is technically possible,
the gem doesn't allow it. The reason is Ruby doesn't support reliable removal of secrets from memory,
therefore it is safer to just keep memory locked.

Warning: if your app leaks memory, it won't be swapped and at some point may be killed by the kernel.

Subprocesses don't inherit memory locking. Make sure to lock memory in each one of them if they handle sensitive data.

## Requirements

OS support for [mlockall()](https://linux.die.net/man/2/mlockall) is required.
Will work on most Unixes except macOS. Windows is not supported.

## Installation

    gem install memory_locker

## Usage

To lock the memory of your process, add the following code early in the app lifetime:

    require 'memory_locker'
    MemoryLocker.call     # short syntax
    MemoryLocker.new.call # if you prefer to use instance explicitly

## Exceptions

If your OS is unsupported or there is a locking error, you will get an exception descending from `MemoryLocker::Error`.

## Testing

Locking the memory of your app when testing is not needed, and if you use an unsupported OS will break your app.

As only the `#call` method is being used, you can easily replace `MemoryLocker` class or instance with an empty
lambda `->{}` in your tests.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/phantom-node/memory_locker>.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct](https://github.com/phantom-node/memory_locker/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MemoryLocker project's codebases, issue trackers, chat rooms, and mailing lists is
expected to follow the [code of conduct](https://github.com/phantom-node/memory_locker/blob/master/CODE_OF_CONDUCT.md).
