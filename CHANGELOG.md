# Changelog

## 1.0.0
- initial release

## 1.0.1
- Fixed fingerprints.
- set_options is now a public method
- changed option `write` to `output`

## 1.0.2
- Renamed 'build' method to 'compile' to be consistent with Stitch and Uglify.
- Renamed old 'compile' to 'write' since it actually writes files.
- Options can be accessed now for easier inspection

## 1.0.3
- Fixed an issue where write was attempting to call old build method.

## 1.0.4
- Options hash now accepts `config` which can point to a YAML file to load configurations.

## 1.0.5
- [instance].last_write returns the path to the last written file.

## 1.0.6
- [instance].deleted returns an array of deleted files if stitch cleaned up files when writing.
- performance improvements for cleanup method.
