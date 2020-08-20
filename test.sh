#!/usr/bin/env bash

full_tag="1.1.2"
state=0

check() {
  if [ $? -ne 0 ]; then
    echo "Check image failed"
  fi
}

output=$(echo "1.1.2")
[[ $state -eq 0 ]]
check
[[ "$output" == "$full_tag" ]]
check
