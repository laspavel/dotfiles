#!/bin/bash

subscription-manager remove --all
subscription-manager unregister
subscription-manager clean
subscription-manager register
subscription-manager attach --auto
subscription-manager list

# https://unix.stackexchange.com/questions/692749/what-this-error-message-mean-please-ignoring-request-to-auto-attach-it-is-disa
