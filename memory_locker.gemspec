# frozen_string_literal: true

require_relative 'lib/memory_locker/version'

Gem::Specification.new do |spec|
  spec.name = 'memory_locker'
  spec.version = MemoryLocker::VERSION
  spec.authors = ['Paweł Pokrywka']
  spec.email = ['pepawel@users.noreply.github.com']

  spec.summary = 'Lock memory containing sensitive data to prevent it from being swapped by the kernel'
  spec.homepage = 'https://github.com/phantom-node/memory_locker'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/phantom-node/memory_locker/blob/master/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = ['CHANGELOG.md', 'LICENSE.txt', 'README.md']
  spec.files += Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      f.match(%r{\A(?:lib)/})
    end
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'ffi', '>= 1.0.0'
end
