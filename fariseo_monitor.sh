#!/bin/bash

PING_ATTEMPTS=3
HOST_STATUSES_COUNTER=0

JSON_EVENT_TEMPLATE='{"local_host_ip":"%s","remote_endpoint":"%s","host_name":"%s","status":"%s"}'

##LOCAL_HOST_IP
LOCAL_HOST_IP=$(hostname -I )



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

validate_endpoint()
{
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

  HOST_ENDPOINT=$( echo ${line} | awk -F "|" '{print $1}' )
  HOST_ENDPOINT_NAME=$( echo ${line} | awk -F "|" '{print $2}' )

  validate_endpoint $HOST_ENDPOINT

  if [[ ! $? -eq 0 ]]
  then
  	HOST_STATUS=$(printf "$JSON_EVENT_TEMPLATE" "$LOCAL_HOST_IP" "$HOST_ENDPOINT" "$HOST_ENDPOINT_NAME" "NO_REACHABLE")
  else
    HOST_STATUS=$(printf "$JSON_EVENT_TEMPLATE" "$LOCAL_HOST_IP" "$HOST_ENDPOINT" "$HOST_ENDPOINT_NAME" "REACHABLE")  
  fi

  CURRENT_HOST_STATUSES_ARRAY[HOST_STATUSES_COUNTER]=${HOST_STATUS}
  HOST_STATUSES_COUNTER=`expr $HOST_STATUSES_COUNTER + 1`
  
done < "$endpoint_list"

#If there is any unreachable host then fariseo takes action
if [ ${#CURRENT_HOST_STATUSES_ARRAY[@]} -ge 1 ]
then
	echo ${CURRENT_HOST_STATUSES_ARRAY[@]} | tr ' ' '\n'
fi
