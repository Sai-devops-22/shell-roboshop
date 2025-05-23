#!/bin/bash

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]
then 
    echo "login to root user"
else
    echo "you are a root user"