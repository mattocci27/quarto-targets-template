#!/bin/bash

scripts/setup_dev_container.sh
scripts/make_renviron.sh

# Define the path to the radian.sif file
sif_file="radian.sif"

# Check conditions and build radian.sif from radian.def if applicable
if [ ! -f "/.dockerenv" ] && [ ! -f "$sif_file" ] && which apptainer > /dev/null; then
    echo "Building radian.sif from radian.def..."
    sudo apptainer build radian.sif radian.def
else
    echo "Conditions not met for building radian.sif."
fi
