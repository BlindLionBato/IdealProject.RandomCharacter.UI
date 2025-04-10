#!/bin/bash
if systemctl is-active --quiet httpd; then
  echo "Apache server running!"
  exit 0
else
  echo "Apache failed to start!"
  exit 1
fi