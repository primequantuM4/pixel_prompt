# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## 0.1.4-wip

* Remove unneeded dependency.

## [0.1.3](https://github.com/primequantuM4/pixel_prompt/compare/v0.1.2...v0.1.3) 2025-09-01
### Features
* **Full screen mode:** Introduced API for devs to access alternate screen buffer

## [0.1.2](https://github.com/primequantuM4/pixel_prompt/compare/v0.0.2...v0.1.2) 2025-08-20
### Features

* **components:** introduce stateful components with lifecycle and state management API  
* **input:** improved input manager with focus handling and keyboard/mouse interactivity  
* **examples:** add Snake game demo showcasing interactive components  

### Bug Fixes

* focus now retains position after screen redraw with `setState`  
* optimized rendering to avoid unnecessary conditionals and fragments from previous buffer  
* fixed button and textfield initialization issues  
* improved quit behavior (graceful exit on ctrl-c)  

### Chore / Docs

* reorganized golden files and common directories  
* added documentation across `lib/core`, `lib/events`, `lib/layout_engine`, `lib/terminal`, etc.  
* removed unused methods and stale functions  

### [0.0.3](https://github.com/primequantuM4/pixel_prompt/compare/v0.0.2...v0.0.3) (2025-06-12)


### Features

* **layout:** implement layout engine with row and column support ([299a651](https://github.com/primequantuM4/pixel_prompt/commit/299a6516b1df8609c415fe2ba52262b9bd70cbf4))

### [0.0.2](https://github.com/primequantuM4/pixel_prompt/compare/v0.0.1...v0.0.2) (2025-06-12)


### Features

* **rendering:** implement core rendering pipeline and text components ([2e32c8d](https://github.com/primequantuM4/pixel_prompt/commit/2e32c8d94d7cba73b327fa233802ec496a47e6aa))


### Bug Fixes

* margin and size rename ([4dae080](https://github.com/primequantuM4/pixel_prompt/commit/4dae0809da0717d00292808d491422879090da07))

## 0.0.1

- Initial version.
