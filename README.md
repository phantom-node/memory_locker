# MemoryLocker

Lock memory containing sensitive data (such as passwords or cryptographic keys) to prevent it from being swapped
by the kernel, which allows the attacker with access to swap space to recover secrets.

Ruby doesn't allow granular memory management, therefore the approach is to lock the entire memory of a program.

## Requirements

This gem requires `ffi` gem, which needs to be built on install.
In case of build-related issues, make sure you have the compiler installed.

In Debian-based Linux distributions, you can install it by executing:

    $ sudo apt install --no-install-recommends build-essential

Refer to [ffi gem documentation](https://github.com/ffi/ffi) for requirements on other systems.

## Installation

Install the gem and add it to the application's Gemfile by executing:

    $ bundle add memory_locker

If the bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install memory_locker

## Usage

To lock the memory of the current process use the following once, whenever you want,
but before sensitive data processing:

    MemoryLocker.new(:glibc).lock!

The above example uses the `glibc` backend which should work on most Linux distributions.
Currently, only this backend is implemented, however, it is trivial to add support for other c-libraries.

The memory will stay locked until the process terminates. There is no way to unlock memory.
The reason is Ruby doesn't support reliable removal of secrets from memory, therefore it is safer to just
keep memory locked.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To implement the backend for a different c-library, use existing one as a template.
Copy `lib/memory_locker/glibc.rb` to `lib/memory_locker/my_backend.rb`, and change it.
Later use `:my_backend` as an argument to `MemoryLocker` initializer.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/phantom-node/memory_locker.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct](https://github.com/phantom-node/memory_locker/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MemoryLocker project's codebases, issue trackers, chat rooms, and mailing lists
is expected to follow the [code of conduct](https://github.com/phantom-node/memory_locker/blob/master/CODE_OF_CONDUCT.md).
