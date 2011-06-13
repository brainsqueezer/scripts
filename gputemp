#!/bin/sh

lgpu=`nvidia-settings -q GPUCoreTemp | grep neonlight`;

tgpu=${lgpu:43:2}

lcpu=`cat /proc/acpi/thermal_zone/THRM/temperature`

tcpu=${lcpu:25:2}

echo ${tgpu}G ${tcpu}C

