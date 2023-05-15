#!/bin/bash

# Check if the ENV variable for a new Log Folder is set and replace it, otherwise use default.
logout_folder=${LOG_FOLDER:-"/config"}

# Check and create new log folder if necessary. 
if [ ! -d "$logout_folder" ]; then
  echo "Directory $logout_folder does not exist, creating it .."
  mkdir -p $logout_folder
fi
