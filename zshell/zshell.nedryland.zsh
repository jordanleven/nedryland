#!/bin/zsh

nedryland_current_directory=$(dirname "$0")

nedryland_should_animate() {
  [[ -o interactive ]] && [[ "${NEDRYLAND_ANIMATE:-1}" = "1" ]]
}

nedryland_message_get() {
  printf "%s" "$(<"$nedryland_current_directory/../assets/$1")"
}

nedryland_message_show() {
  printf "%b\n\n" "$(nedryland_message_get "$1")"
}

nedryland_terminal_size_get() {
  local terminal_columns="${COLUMNS:-0}"
  local terminal_lines="${LINES:-0}"
  local stty_size=""
  local -a size_parts

  if command -v stty > /dev/null && [[ -t 1 ]]
  then
    stty_size="$(stty size <&1 2>/dev/null || true)"
    if [[ "$stty_size" = <->" "<-> ]]
    then
      size_parts=(${=stty_size})
      terminal_lines="${size_parts[1]}"
      terminal_columns="${size_parts[2]}"
    fi
  fi

  if (( terminal_columns <= 0 || terminal_lines <= 0 )) && command -v tput > /dev/null
  then
    terminal_columns="$(tput cols 2>/dev/null || echo 0)"
    terminal_lines="$(tput lines 2>/dev/null || echo 0)"
  fi

  printf "%s %s" "$terminal_columns" "$terminal_lines"
}

nedryland_message_asset_auto() {
  local forced_asset="${NEDRYLAND_FORCE_LOGO_ASSET:-}"
  local terminal_size
  local -a terminal_size_parts
  local terminal_columns=0
  local terminal_lines=0
  local large_min_columns="${NEDRYLAND_LARGE_MIN_COLUMNS:-100}"
  local large_min_lines="${NEDRYLAND_LARGE_MIN_LINES:-14}"
  local horizontal_padding="${NEDRYLAND_LOGO_HORIZONTAL_PADDING:-2}"
  local vertical_padding="${NEDRYLAND_LOGO_VERTICAL_PADDING:-1}"

  if [[ -n "$forced_asset" ]]
  then
    printf "%s" "$forced_asset"
    return
  fi

  terminal_size="$(nedryland_terminal_size_get)"
  terminal_size_parts=(${=terminal_size})
  terminal_columns="${terminal_size_parts[1]:-0}"
  terminal_lines="${terminal_size_parts[2]:-0}"

  if (( terminal_columns >= large_min_columns + horizontal_padding && terminal_lines >= large_min_lines + vertical_padding ))
  then
    printf "nedryland_large.txt"
  else
    printf "nedryland_small.txt"
  fi
}

nedryland_message_show_large() {
  nedryland_message_show "nedryland_large.txt"
}

nedryland_message_show_small() {
  nedryland_message_show "nedryland_small.txt"
}

nedryland_message_show_auto() {
  nedryland_message_show "$(nedryland_message_asset_auto)"
}

nedryland_random_pick_messages() {
  local pick_count="${1:-3}"
  local pool_text="$2"
  local seed_source
  local -a pool_messages
  local -a shuffled_messages
  local total_messages
  local i
  local j
  local temp_message

  pool_messages=("${(@f)pool_text}")
  total_messages="${#pool_messages[@]}"
  if (( total_messages == 0 ))
  then
    return
  fi

  seed_source="$(date +%s%N 2>/dev/null || date +%s)"
  RANDOM=$(( (seed_source + $$ + RANDOM) % 32768 ))

  if (( pick_count > total_messages ))
  then
    pick_count="$total_messages"
  fi

  shuffled_messages=("${pool_messages[@]}")
  for (( i = total_messages; i > 1; i-- ))
  do
    j=$(( RANDOM % i + 1 ))
    temp_message="${shuffled_messages[$i]}"
    shuffled_messages[$i]="${shuffled_messages[$j]}"
    shuffled_messages[$j]="$temp_message"
  done

  printf "%s\n" "${(@)shuffled_messages[1,$pick_count]}"
}

nedryland_new_window_intro_show() {
  local intro_delay="${NEDRYLAND_INTRO_DELAY:-0.1}"
  local -a intro_pool=(
    "> Perimeter fences: ONLINE"
    "> Tour vehicles: TRACK LOCK CONFIRMED"
    "> Park systems: READY FOR VISITORS"
    "> Park command network synchronized"
    "> Visitor center systems calibrated"
    "> Electric fence telemetry nominal"
    "> Tour route tracking active"
    "> Emergency shutdown relays armed"
    "> Animal containment monitors stable"
    "> Access control checkpoints responding"
    "> Biometric scanners: INITIALIZED"
    "> Raptor paddock sensors: ACTIVE"
    "> Helicopter pad beacon: TRANSMITTING"
    "> Genetics lab environment controls nominal"
    "> Hammond observation deck: CLEAR"
  )
  local -a intro_lines
  local intro_line
  local rendered=0

  intro_lines=("${(@f)$(nedryland_random_pick_messages 6 "${(F)intro_pool}")}")

  printf "\033[1;32m"
  for intro_line in "${intro_lines[@]}"
  do
    if (( rendered ))
    then
      printf "\033[1A\033[2K"
    fi
    printf "%s\n" "$intro_line"
    rendered=1
    sleep "$intro_delay"
  done
  printf "\033[0m"
}

nedryland_reboot_intro_show() {
  local intro_delay="${NEDRYLAND_INTRO_DELAY:-0.1}"
  local -a reboot_pool=(
    "> Security systems reboot in progress"
    "> Door locks and containment controls re-engaging"
    "> Containment power grid cycling"
    "> Sector lock matrix restoring"
    "> Command authorization table reloading"
    "> Peripheral gate controllers reconnecting"
    "> Visitor perimeter checkpoints restarting"
    "> Operations uplink restoring handshake"
    "> Alarm routing map rebuilding"
    "> Core security services reinitialized"
    "> Motion sensor network rebooting"
    "> Backup generator handoff complete"
    "> Emergency broadcast system restarting"
    "> Containment protocol stack reloading"
    "> Velociraptor enclosure locks cycling"
  )
  local -a intro_lines
  local -a intro_colors=(
    "\033[1;31m"
    "\033[1;31m"
    "\033[1;31m"
    "\033[1;31m"
    "\033[1;31m"
    "\033[1;32m"
  )
  local intro_line
  local intro_index=1
  local rendered=0

  intro_lines=("${(@f)$(nedryland_random_pick_messages 6 "${(F)reboot_pool}")}")

  for intro_line in "${intro_lines[@]}"
  do
    if (( rendered ))
    then
      printf "\033[1A\033[2K"
    fi
    printf "%b%s%b\n" "${intro_colors[$intro_index]}" "$intro_line" "\033[0m"
    rendered=1
    (( intro_index++ ))
    sleep "$intro_delay"
  done
}

nedryland_logo_frame_show_type_on() {
  local frame_text="$1"
  local reveal_column="$2"
  local color_code="$3"
  local max_width="$4"
  local preserve_hashes="$5"
  local -a frame_lines
  local line_number
  local line_text
  local display_line
  local column_number
  local character

  frame_lines=("${(@f)frame_text}")
  for (( line_number = 1; line_number <= ${#frame_lines[@]}; line_number++ ))
  do
    line_text="${frame_lines[$line_number]}"
    display_line=""

    for (( column_number = 1; column_number <= max_width; column_number++ ))
    do
      character="${line_text:$(( column_number - 1 )):1}"
      if [[ -z "$character" ]]
      then
        character=" "
      fi

      if [[ "$character" = " " ]]
      then
        display_line+="$character"
        continue
      fi

      if [[ "$character" = "#" ]] && (( preserve_hashes ))
      then
        display_line+="$character"
        continue
      fi

      if (( column_number <= reveal_column ))
      then
        display_line+="$character"
      else
        display_line+=" "
      fi
    done

    printf "%b%s%b\n" "$color_code" "$display_line" "\033[0m"
  done
  printf "\n"
}

nedryland_logo_animate() {
  local logo_asset="$1"
  local plain_logo
  local reveal_delay="${NEDRYLAND_REVEAL_DELAY:-0.002}"
  local -a logo_lines
  local line_count
  local line_text
  local max_width=0
  local column_number
  local reveal_step
  local preserve_hashes=0

  plain_logo="$(nedryland_message_get "$logo_asset" | sed -E 's/\\033\[[0-9;]*m//g')"
  logo_lines=("${(@f)plain_logo}")
  line_count=${#logo_lines[@]}
  if [[ "$logo_asset" = "nedryland_small.txt" ]] || [[ "$logo_asset" = "nedryland_large.txt" ]]
  then
    preserve_hashes=1
  fi

  for line_text in "${logo_lines[@]}"
  do
    if (( ${#line_text} > max_width ))
    then
      max_width=${#line_text}
    fi
  done

  if (( max_width == 0 ))
  then
    nedryland_message_show "$logo_asset"
    return
  fi

  printf "\033[?25l"

  for (( reveal_step = 0; reveal_step <= max_width; reveal_step++ ))
  do
    if (( reveal_step > 0 ))
    then
      printf "\033[%sA" "$(( line_count + 1 ))"
    fi
    nedryland_logo_frame_show_type_on "$plain_logo" "$reveal_step" "\033[1;31m" "$max_width" "$preserve_hashes"
    sleep "$reveal_delay"
  done

  printf "\033[%sA" "$(( line_count + 1 ))"
  nedryland_message_show "$logo_asset"
  printf "\033[?25h"
}

nedryland_show_with_intro_and_logo() {
  local intro_function="$1"
  local logo_asset="$2"

  if nedryland_should_animate && [[ -n "$intro_function" ]]
  then
    "$intro_function"
    nedryland_logo_animate "$logo_asset"
  else
    nedryland_message_show "$logo_asset"
  fi
}

nedryland_new_window_show() {
  local logo_asset

  logo_asset="$(nedryland_message_asset_auto)"
  nedryland_show_with_intro_and_logo "nedryland_new_window_intro_show" "$logo_asset"
}

nedryland_loaded_show() {
  nedryland_new_window_show
}

nedryland_reload_show() {
  local logo_asset="${NEDRYLAND_RELOAD_LOGO_ASSET:-}"

  if [[ -z "$logo_asset" ]]
  then
    logo_asset="$(nedryland_message_asset_auto)"
  fi

  nedryland_show_with_intro_and_logo "nedryland_reboot_intro_show" "$logo_asset"
}

nedryland_show_manual() {
  nedryland_reload_show
}
