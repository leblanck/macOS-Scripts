#!/bin/bash
machineUptime=$( uptime | cut -d',' -f1 | cut -d' ' -f2- )
echo "<result>$machineUptime</result>"
