# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
 - Ability to distribute via package managers
 - Support for `completion-at-point-functions` and `company` via `company-capf`

### Changed
 - `M-<tab>` or `C-M-i` is no longer bound to `sclang-complete-symbol`
   to make builtin completion work as expected.
 - `sclang-mode` is now derived from `prog-mode`.
