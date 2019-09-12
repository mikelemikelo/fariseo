#!/bin/bash

PING_ATTEMPTS=3
HOST_STATUSES_COUNTER=0

BRANCH_NAME=$2

JSON_EVENT_TEMPLATE='{"company":"Rincon_de_los_Morales","branch_name":"%s","local_host_ip":"%s","remote_endpoint_ip":"%s","remote_endpoint_name":"%s","remote_device_type":"%s","current_exec_time_sec":"%s","current_exec_time_date":"%s","status":"%s"}'

JSON_ARRAY_EVENTS_TEMPLATE='{"events":"[%s]"}'

##LOCAL_HOST_IP
LOCAL_HOST_IP=$(hostname -I)


##Get local Host IP address, supports Linux / Mac.
if [[ $? -eq 0 ]]
then
  #Option for Linux
  LOCAL_HOST_IP=$(cat $LOCAL_HOST_IP | awk '{print $1}')
else
  #MAC Option 
  LOCAL_HOST_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
fi

# Error exit function
error_exit()
{
	echo "Error: $1" 1>&2
}

# Method to validate that the endpoing is reachable.
validate_endpoint()
{
	ping -c $PING_ATTEMPTS $1 1>&2
}

# Validating number of arguments
if [ ! $# -eq 2 ] 
then
	error_exit "Wrong number of arguments, no Host file found"
fi

#Assigning the input path to the host file
endpoint_list=$1


## Current Execition time
EXECUTION_TIME_SECONDS=$(date +%s)

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

  ENDPOINT_IP=$( echo ${line} | awk -F "|" '{print $1}' )
  ENDPOINT_NAME=$( echo ${line} | awk -F "|" '{print $2}' )
  ENDPOINT_DEVICE_TYPE=$( echo ${line} | awk -F "|" '{print $3}' )

  validate_endpoint $ENDPOINT_IP

  # Response evaluation
  if [[ ! $? -eq 0 ]]
  then
  	ENDPOINT_STATUS="NOT_REACHABLE"
  else
    ENDPOINT_STATUS="REACHABLE"
  fi

  CURRENT_HOST_STATUSES_ARRAY[HOST_STATUSES_COUNTER]=$(printf "$JSON_EVENT_TEMPLATE" "$BRANCH_NAME" "$LOCAL_HOST_IP" "$ENDPOINT_IP" "$ENDPOINT_NAME" "$ENDPOINT_DEVICE_TYPE" "$EXECUTION_TIME_SECONDS" "$EXECUTION_TIME_SECONDS" "$ENDPOINT_STATUS" )
  HOST_STATUSES_COUNTER=`expr $HOST_STATUSES_COUNTER + 1`
  
done < "$endpoint_list"

#If there is any unreachable host then fariseo takes action
if [ ${#CURRENT_HOST_STATUSES_ARRAY[@]} -ge 1 ]
then
  ARRAY_COUNTER=1
  EVENTS_JSON_STRING='{"events":['

  for iterated_status in "${CURRENT_HOST_STATUSES_ARRAY[@]}"
    do
      EVENTS_JSON_STRING+="${iterated_status}"

      if [ $ARRAY_COUNTER -lt ${#CURRENT_HOST_STATUSES_ARRAY[@]}  ]
      then
        EVENTS_JSON_STRING+=","
      fi 
      ARRAY_COUNTER=`expr $ARRAY_COUNTER + 1`

  done
  EVENTS_JSON_STRING+=']}'

	echo $EVENTS_JSON_STRING >> ./output.json
fi
