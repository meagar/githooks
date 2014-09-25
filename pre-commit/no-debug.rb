#!/usr/bin/env ruby

#
# This is a Git pre-commit hook.
#
# Reject commits that contain any of the following strings:
# # NO COMMIT | // NO COMMIT | #NOCOMMIT | //NOCOMMIT | etc
# debugger
# binding.pry
# console.log | console.dir | console.warn | etc
#
# If you attempt to commit any of these strings, you will get a pretty error telling you
# where the offence occured, and that you can use `git commit -n` to skip this check, in
# the case that you want to forcibly add (for example) a console.log
#
# INSTALL:
#  - Save this file as <project_path>/.git/hooks/pre-commit
#  - Make sure you have Ruby installed
#
# USAGE:
#  Forget this script exists until you accidentally stage a "bidning.pry" and are
#  prevented from committing your changes by it
#


TESTS = [
  /(#|\/\/) ?NO ?COMMIT/,
  /\bdebugger\b/,
  /\bbinding\.pry\b/,
  /\bconsole\.(log|dir|debug|warn|error|count|profile|profileEnd|trace)\b/,
]

# Mapping of file names to 0 or more violations
files = {}

lines = `git diff --cached`.split("\n")

# `lines` is series of lines of output from `git diff --cached`
#
# Each group of output is separated by a line like this:
# --- a/app/models/user.rb
# +++ b/app/models/user.rb
# When we hit a `+++ b`, we open a new file context
#
# After a `+++ b`, there are one or more introduced changes
# Each line will start with a `-` or a `+`, we're interested in the `+` which denote added lines.

current_file = "" # the last encountered +++ b
lines.each do |line|
  # Check for the beginning of a new file context
  if line[/^(\+\+\+) b\//]
    current_file = line.gsub('+++ b', '')
    files[current_file] = []
    next
  end

  # Not a +++ b, so it's a line of change

  # Skip the line unless it is a line of *added* change
  next unless line[/^\+/]

  TESTS.each do |test|
    if (match = line[test])
      # Record the file, line and test which failed
      files[current_file] << [line, test]
    end
  end
end

files_with_errors = files.select { |k,v| v.any? }

exit(0) unless files_with_errors.any?

# Output pass
files_with_errors.each do |file, errors|
  puts "\n#{file}"
  errors.each do |line, test|
    # Output the line with the offending bit highlighted
    puts "\t#{line.gsub(test, "\e[0;37;41m\\0\e[0m")}"
  end
end

# Output error summary

num_errors = files_with_errors.map(&:last).flatten(1).length

puts "\n#{num_errors} violations found in #{files_with_errors.length} of #{files.length} files"
puts
puts "Use \e[1;37m git commit -n \e[0m to bypass this pre-commit hook"
exit 1
