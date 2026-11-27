#!/bin/zsh -f

emulate zsh

# Run all specified tests, keeping count of which succeeded.
# The reason for this extra layer above the test script is to
# protect from catastrophic failure of an individual test.
# We could probably do that with subshells instead.

# With the C module built, each file runs twice: the pure-zsh path
# (FZF_TAB_NO_MODULE=1), then the module's; without it, once. FZF_TAB_NO_MODULE
# set by the caller picks one pass.
local -a passes=(0) built=(../modules/Src/aloxaf/fzftab.(so|bundle)(N))
if [[ -z $FZF_TAB_NO_MODULE ]] && (( $#built )); then
  passes=(1 0)
fi

integer success failure skipped retval
local pass
for file in ${@:1}; do
  for pass in $passes; do
    if [[ -n $FZF_TAB_NO_MODULE ]]; then
      zsh +Z -f ./ztst.zsh $file
    else
      (( $#passes > 1 )) && print -r -- "$file: ${${pass:#0}:+without}${${pass:#1}:+with} the C module"
      FZF_TAB_NO_MODULE=$pass zsh +Z -f ./ztst.zsh $file
    fi
    retval=$?
    if (( $retval == 2 )); then
      (( skipped++ ))
    elif (( $retval )); then
      (( failure++ ))
    else
      (( success++ ))
    fi
  done
done
print "**************************************
$success successful test script${${success:#1}:+s}, \
$failure failure${${failure:#1}:+s}, \
$skipped skipped
**************************************"
return $(( failure ? 1 : 0 ))
