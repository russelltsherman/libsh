#!/usr/bin/env bash

function is_empty() {
  local var="$1"
  [ -z "$var" ]
}

function is_not_empty() {
  local var="$1"
  [ -n "$var" ]
}

function is_file() {
  local file="$1"
  [ -f "$file" ]
}

function is_not_file() {
  local file="$1"
  [ ! -f "$file" ]
}

function is_dir() {
  local dir="$1"
  [ -d "$dir" ]
}

function is_not_dir() {
  local dir="$1"
  [ ! -d "$dir" ]
}

function is_number() {
  local value="$1"
  [[ "$value" =~ ^[0-9]+$ ]]
}

function is_not_number() {
  local value="$1"
  [[ ! "$value" =~ ^[0-9]+$ ]]
}

function contains() {
  local list="$1"
  local item="$2"
  [[ $list =~ (^|[[:space:]])"$item"($|[[:space:]]) ]]
}
