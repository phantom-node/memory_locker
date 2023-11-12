## [1.0.3] - 2023-11-12

- Use Fiddle (part of Ruby standard library) instead of FFI gem

## [1.0.2] - 2023-07-28

- Don't load libc if already loaded in the current process

## [1.0.1] - 2023-07-28

- Update Changelog

## [1.0.0] - 2023-07-28

- Support for all c-libraries supported by FFI with automatic detection
- Use in-memory loaded c-library if possible
- Use #call on main object/class instead of #lock for easier mocking
- More meaningful exceptions
- Clear separation between high- and low-level things
- Much better tests

## [0.1.0] - 2023-07-27

- Initial release
