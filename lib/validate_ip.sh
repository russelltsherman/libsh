#!/usr/bin/env bash
# shellcheck disable=SC1117

# return nonzero unless $1 contains only digits
# leading zeroes not allowed
is_numeric() {
  case "$1" in
    "" | *[![:digit:]]* | 0[[:digit:]]* ) return 1;;
  esac
}

# return nonzero unless $1 contains only hexadecimal digits
is_hex() {
  case "$1" in
    "" | *[![:xdigit:]]* ) return 1;;
  esac
}

# return nonzero unless $1 is a valid IPv4 address
# allows optional trailing subnet mask in the format /<bits>
is_ipv4() {
    # fail if $1 is not set, move it into a variable so we can mangle it
    [ -n "$1" ] || return
    IP4_ADDR="$1"

    # handle subnet mask for any address containing a /
    case "$IP4_ADDR" in
      *"/"* )
        # set $IP4_GROUP to the number of bits (the characters after the last /)
        IP4_GROUP="${IP4_ADDR##*"/"}"

        # return failure unless $IP4_GROUP is a positive integer less than or equal to 32
        is_numeric "$IP4_GROUP" && [ "$IP4_GROUP" -le 32 ] || return

        # remove the subnet mask from the address
        IP4_ADDR="${IP4_ADDR%"/$IP4_GROUP"}";;
    esac

    # backup current $IFS, set $IFS to . as that's what separates digit groups (octets)
    IP4_IFS="$IFS"; IFS="."

    # initialize count
    IP4_COUNT=0

    # loop over digit groups
    for IP4_GROUP in $IP4_ADDR
    do
        # return failure if group is not numeric or if it is greater than 255
        ! is_numeric "$IP4_GROUP" || [ "$IP4_GROUP" -gt 255 ] && IFS="$IP4_IFS" && return 1

        # increment count
        IP4_COUNT=$(( IP4_COUNT + 1 ))

        # the following line will prevent the loop continuing to run for invalid addresses with many occurrences of .
        # this makes no difference to the result, but may improve performance when validating many such invalid strings
        [ "$IP4_COUNT" -le 4 ] || break
    done

    # restore $IFS
    IFS="$IP4_IFS"

    # return success if there are 4 digit groups, otherwise return failure
    [ "$IP4_COUNT" -eq 4 ]
}

# return nonzero unless $1 is a valid IPv6 address with optional trailing subnet mask in the format /<bits>
is_ipv6() {
    # fail if $1 is not set, move it into a variable so we can mangle it
    [ -n "$1" ] || return
    IP6_ADDR="$1"

    # handle subnet mask for any address containing a /
    case "$IP6_ADDR" in
        *"/"* ) # set $IP6_GROUP to the number of bits (the characters after the last /)
                IP6_GROUP="${IP6_ADDR##*"/"}"

                # return failure unless $IP6_GROUP is a positive integer less than or equal to 128
                is_numeric "$IP6_GROUP" && [ "$IP6_GROUP" -le 128 ] || return

                # remove the subnet mask from the address
                IP6_ADDR="${IP6_ADDR%"/$IP6_GROUP"}";;
    esac

    # perform some preliminary tests and check for the presence of ::
    case "$IP6_ADDR" in
        # failure cases
        # *"::"*"::"*  matches multiple occurrences of ::
        # *":::"*      matches three or more consecutive occurrences of :
        # *[^:]":"     matches trailing single :
        # *"."*":"*    matches : after .
        *"::"*"::"* | *":::"* | *[^:]":" | *"."*":"* ) return 1;;

        *"::"* ) # set flag $IP6_EXPANDED to true, to allow for a variable number of digit groups
                 IP6_EXPANDED=0

                 # because :: should not be used for remove a single zero group we start the group count at 1 when :: exists
                 # NOTE This is a strict interpretation of the standard, applications should not generate such IP addresses but (I think)
                 #      they are in fact technically valid. To allow addresses with single zero groups replaced by :: set $IP6_COUNT to
                 #      zero after this case statement instead
                 IP6_COUNT=1;;

        *      ) # set flag $IP6_EXPANDED to false, to forbid a variable number of digit groups
                 IP6_EXPANDED=""

                 # initialize count
                 IP6_COUNT=0;;
    esac
    # backup current $IFS, set $IFS to : to delimit digit groups
    IP6_IFS="$IFS"; IFS=":"

    # loop over digit groups
    for IP6_GROUP in $IP6_ADDR ;do
        # if this is an empty group then increment count and process next group
        [ -z "$IP6_GROUP" ] && IP6_COUNT=$(( IP6_COUNT + 1 )) && continue

        # handle dotted quad notation groups
        case "$IP6_GROUP" in
            *"."* ) # return failure if group is not a valid IPv4 address
                    # NOTE a subnet mask is added to the group to ensure we are matching addresses only, not ranges
                    ! is_ipv4 "$IP6_GROUP/1" && IFS="$IP6_IFS" && return 1

                    # a dotted quad refers to 32 bits, the same as two 16 bit digit groups, so we increment the count by 2
                    IP6_COUNT=$(( IP6_COUNT + 2 ))

                    # we can stop processing groups now as we can be certain this is the last group, : after . was caught as a failure case earlier
                    break;;
        esac

        # if there are more than 4 characters or any character is not a hex digit then return failure
        [ "${#IP6_GROUP}" -gt 4 ] || ! is_hex "$IP6_GROUP" && IFS="$IP6_IFS" && return 1

        # increment count
        IP6_COUNT=$(( IP6_COUNT + 1 ))

        # the following line will prevent the loop continuing to run for invalid addresses with many occurrences of a single :
        # this makes no difference to the result, but may improve performance when validating many such invalid strings
        [ "$IP6_COUNT" -le 8 ] || break
    done

    # restore $IFS
    IFS="$IP6_IFS"

    # if this address contained a :: and it has less than or equal to 8 groups then return success
    [ "$IP6_EXPANDED" = "0" ] && [ "$IP6_COUNT" -le 8 ] && return

    # if this address contained exactly 8 groups then return success, otherwise return failure
    [ "$IP6_COUNT" -eq 8 ]
}

# If this file is invoked directly, run tests.
if [[ "$(basename "$0")" == 'validate_ip.sh' ]]; then
  TEST_PASSES=0
  TEST_FAILURES=0
  for TEST_IP in 0.0.0.0 255.255.255.255 1.2.3.4/1 1.2.3.4/32 12.12.12.12 123.123.123.123 101.201.201.109 ;do
    ! is_ipv4 "$TEST_IP" && printf "IP4 test failed, test case '%s' returned invalid\n" "$TEST_IP" && TEST_FAILURES=$(( TEST_FAILURES + 1 )) || TEST_PASSES=$(( TEST_PASSES + 1 ))
  done
  for TEST_IP in junk . / 0 -1.0.0.0 1.2.c.0 a.0.0.0 " 1.2.3.4" "1.2.3.4 " " " 01.0.0.0 09.0.0.0 0.0.0.01 \
                0.0.0.09 0.09.0.0.0 0.01.0.0 0.0.01.0 0.0.0.a 0.0.0 .0.0.0.0 256.0.0.0 0.0.0.256 "" 0 1 12 \
                123 1.2.3.4/s 1.2.3.4/33 1.2.3.4/1/1 ;do
      is_ipv4 "$TEST_IP" && printf "IP4 test failed, test case '%s' returned valid\n" "$TEST_IP" && TEST_FAILURES=$(( TEST_FAILURES + 1 )) || TEST_PASSES=$(( TEST_PASSES + 1 ))
  done

  printf "ipv4 test complete, %s passes and %s failures\n" "$TEST_PASSES" "$TEST_FAILURES"

  TEST_PASSES=0
  TEST_FAILURES=0
  for TEST_IP in ::1 ::1/128 ::1/0 ::1234 ::bad ::12 1:2:3:4:5:6:7:8 1234:5678:90ab:cdef:1234:5678:90ab:cdef \
            1234:5678:90ab:cdef:1234:5678:90ab:cdef/127 1234:5678:90ab::5678:90ab:cdef/64 f:1234:c:ba:240::1 \
            1:2:3:4:5:6:1.2.3.4 ::1.2.3.4 ::1.2.3.4/0 ::ffff:1.2.3.4 ;do
      ! is_ipv6 "$TEST_IP" && printf "IP6 test failed, test case '%s' returned invalid\n" "$TEST_IP" && TEST_FAILURES=$(( TEST_FAILURES + 1 )) || TEST_PASSES=$(( TEST_PASSES + 1 ))
  done
  for TEST_IP in junk "" : / :1 ::1/ ::1/1/1 :::1 ::1/129 ::12345 ::bog ::1234:345.234.0.0 ::sdf.d ::1g2 \
                1:2:3:44444:5:6:7:8 1:2:3:4:5:6:7 1:2:3:4:5:6:7:8/1c1 1234:5678:90ab:cdef:1234:5678:90ab:cdef:1234/64 \
                1234:5678:90ab:cdef:1234:5678::cdef/64  ::1.2.3.4:1 1.2.3.4:: ::1.2.3.4j ::1.2.3.4/ ::1.2.3.4:junk ::1.2.3.4.junk ;do
      is_ipv6 "$TEST_IP" && printf "IP6 test failed, test case '%s' returned valid\n" "$TEST_IP" && TEST_FAILURES=$(( TEST_FAILURES + 1 )) || TEST_PASSES=$(( TEST_PASSES + 1 ))
  done
  printf "ipv6 test complete, %s passes and %s failures\n" "$TEST_PASSES" "$TEST_FAILURES"
fi
