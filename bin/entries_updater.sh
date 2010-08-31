#!/bin/bash

echo "This script is helpful for development only. On production, prease use cron!"

while true; do
  rake sprint_log_entries:update_now; sleep 30;
done
