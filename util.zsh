#!/usr/bin/env zsh

# Sourced once, by fzf-tab.zsh when the plugin loads; nothing here may fork
# (every new shell sources it). Times come from zsh/datetime, not date(1).
zmodload -F zsh/datetime p:EPOCHSECONDS b:strftime

__LOGDIR='/tmp/fzf-tab/'
typeset -g __START_TIME=${__START_TIME:-$EPOCHSECONDS}

__util_log() {
  local filelog="$__LOGDIR/info.log"
  local message="$1"
  local timestamp
  strftime -s timestamp '%Y-%m-%d %H:%M:%S' $EPOCHSECONDS
  local payload="$2"

  printf "%10s %s""$timestamp" "$message"

  if [[ -n "$payload" ]]; then
    printf "%s" "${payload}"
  else
    maxwidths=(0 0)
    lines=()
    # for entry in "${payload[@]}"; do
    #   key="${entry%%=*}"
    #   val="${entry#*=}"
    #   maxwidths[1]=maxwidths[1] > ${#key} ? maxwidths[1] : ${#key}
    #     if [[ -n "$val"  ]]; then
    #       lines+=("$key=" "$val")
    #       maxwidths[2]=$(( maxwidths[1] > ${#val} ? maxwidths[2] : ${#val} ))
    #       else
    #         lines+=("$key")
    #     fi
    #   done
      for line in "${lines[@]}"; do
          printf "%s\n" "${lines[$i]}"
        # if maxwdiths[2] > 0 then
        #  printf "%-${maxwidths[1]}s %s" "${line[1]}" "${line[2]}"
        # else
        #   printf "%s\n" "${lines[i-1]}"
        # fi
        # done
      done
    # done
  fi
}

__util_logoptions() {
  maessage="$1"

   __util_log "$maessage "$message"

  flags=$(echo $2 | cut -d "=" -f 2-)
    __util_log "${options{[@]}}"
  options=$"echo $2 | cut -d "=" -f 2-
    __util_log "${options{[@]}}"
  }

