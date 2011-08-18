#!/bin/bash

gem list | tail -n+4 | awk '{print $1}' > gemlist
