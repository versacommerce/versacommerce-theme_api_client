# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2025-10-30

### Fixed
- SSL context configuration now correctly uses HTTP gem 5.x API
- Fixed `with_ssl_context` implementation to work with HTTP::Options and HTTP::Client

## [1.0.2] - 2025-10-30

### Added
- SSL verification configuration option (`ssl_verify` attribute)
- Support for custom base URL configuration
- Comprehensive configuration documentation in README

### Changed
- Default SSL verification is enabled (secure by default)
- Fetcher now respects `ssl_verify` setting when making HTTP requests

## [1.0.1] - Previous Release

### Changed
- Updated to Ruby 3.1+
- Loosened gem dependencies
