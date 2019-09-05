#!/bin/bash

PING_ATTEMPTS=3
UNREACHABLE_HOST_COUNTER=0

# Error exit function
error_exit()
{
	echo "Error: $1" 1>&2
}

validate_endpoint()
{
	echo "Ping $1"
	ping -c $PING_ATTEMPTS $1 1>&2
}

# Validating number of arguments
if [ ! $# -eq 1 ] 
then
	error_exit "Wrong number of arguments, no Host file found"
fi

#Assigning the input path to the host file
endpoint_list=$1

# If file exists 
if [ ! -f "$endpoint_list" ]
then
	error_exit "Host file not found"
fi

#Reading each line
while IFS= read -r line
do
  
  # ignore empty lines
  [[ $line == "" ]] && continue

  # ignore all config line starting with '#'
  [[ $line =~ ^#.* ]] && continue

  HOST_ENDPOINT=$( echo ${line} | awk '{print $1}' )

  validate_endpoint $HOST_ENDPOINT

  if [[ ! $? -eq 0 ]]
  then
  	UNREACHABLE_HOST_ARRAY[$UNREACHABLE_HOST_COUNTER]=$line
  	UNREACHABLE_HOST_COUNTER=`expr $UNREACHABLE_HOST_COUNTER + 1`
  	echo error_exit "$line not reachable $UNREACHABLE_HOST_COUNTER"
  else
  	echo "Host reachable $line"
  fi
  
done < "$endpoint_list"

#If there is any unreachable host then fariseo takes action
if [ ${#UNREACHABLE_HOST_ARRAY[@]} -ge 1 ]
then
	echo "Unreachable HOSTs found ${#UNREACHABLE_HOST_ARRAY[@]}"
	echo ${UNREACHABLE_HOST_ARRAY[@]} | tr ' ' '\n'
fi