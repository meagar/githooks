
Githooks I find useful for developing Rails apps

## Installation

Clone the project to your home directory as `.githooks`, and then symlink
specific hooks to your project.

The specific hooks (ie pre-commit/no-debug.rb) are invoked by the top-level hook
pre-commit.rb.

```
cd ~
git clone https://github.com/meagar/githooks .githooks

cd /path/to/my/project

ln -s ~/.githooks/pre-commit.rb .git/hooks/pre-commit
```


## Hooks

### pre-commit/no-debug.rb

Stops you from accidentally introducing debugger/binding.pry/console.log, etc.

Example:

![pre-commit/no-debug.rb screenshot](https://raw.githubusercontent.com/meagar/githooks/master/assets/pre-commit-nodebug-ex1.png)
