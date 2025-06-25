# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **MAJOR FEATURE**: Automatic file tracking system
- **MAJOR FIX**: Resolved duplicate Claude terminal creation issue
- Real-time file monitoring and auto-reload functionality
- Enhanced terminal singleton detection and management
- New file tracking commands (`:ClaudeFileStatus`, `:ClaudeFileToggle`, etc.)
- New keybindings for file tracking operations (`<leader>cf*`)
- Configurable file pattern detection for Claude output parsing
- Auto-open files mentioned by Claude in main editor window
- File watcher system using `vim.uv.new_fs_event()`
- Enhanced window management with proper focus handling

### Fixed
- **CRITICAL**: Duplicate Claude terminal instances no longer created
- Terminal detection now properly validates running processes
- Improved process cleanup when Claude exits
- Better window focus management (main editor stays focused)
- Enhanced singleton behavior with global registry system

### Changed
- Complete rewrite of terminal creation logic
- Enhanced configuration with `file_tracking` options
- Improved terminal output monitoring for file detection
- Better error handling and debug logging
- More robust buffer and window validation

### Technical Improvements
- Added comprehensive file tracking infrastructure
- Implemented `vim.uv.new_fs_event()` for file monitoring
- Enhanced terminal output parsing with configurable patterns
- Added global Claude instance registry
- Improved async handling and cleanup procedures
- Better separation of concerns between terminal and file management

---

## [1.0.0] - Previous Release

### Added
- Initial release of claude.vim
- Direct Claude Code CLI integration into Neovim
- Terminal mode for interactive Claude sessions
- Floating window mode for quick responses
- Smart window management with singleton behavior
- Comprehensive command set (ClaudeChat, ClaudeStatus, ClaudeToggle, etc.)
- Visual mode code explanation functionality
- File review capabilities
- Highly configurable terminal and floating window behavior
- Animation support for floating windows
- LazyVim compatibility and integration
- Debug logging system
- Status line integration support

### Features
- **Terminal Integration**: Interactive Claude terminal with proper window management
- **Floating Windows**: Beautiful floating windows with animations and customizable borders
- **Smart Singleton**: Prevents duplicate Claude instances, reuses existing terminals
- **Focus Management**: Keep focus in main editor while Claude runs in background
- **Comprehensive Commands**: Full command set for all Claude operations
- **Visual Mode Support**: Explain selected code directly
- **File Analysis**: Review entire files for improvements
- **Configurable**: Extensive configuration options for all aspects
- **Plugin Manager Support**: Works with lazy.nvim, packer.nvim, and vim-plug
- **LazyVim Ready**: Pre-configured for LazyVim users

### Technical Implementation
- Singleton terminal detection and reuse
- Process validation using jobwait
- Proper cleanup on terminal exit
- Async command execution with vim.system
- Fallback support for older Neovim versions
- Comprehensive error handling and user feedback
- Debug logging for troubleshooting

## [1.0.0] - 2024-12-23

### Added
- Initial stable release
- Core functionality complete and tested
- Documentation and examples provided
- Ready for community use

---

## Development Notes

### Upcoming Features
- [ ] Enhanced status line integration
- [ ] More terminal positioning options
- [ ] Custom command templates
- [ ] Integration with other AI services
- [ ] Plugin API for extensions

### Known Issues
- None currently reported

### Contributing
See [README.md](README.md) for contribution guidelines.