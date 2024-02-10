#!/usr/bin/env bash
set -e

menu() {
	echo "1) tar_make() on local"
	echo "2) tar_make() on Apptainer"
	echo "3) Enter in the Apptainer container"
	read -rp "Enter number：" menu_num
  case $menu_num in
  1)
    Rscript run.R
    ;;
  2)
 		apptainer exec radian.sif Rscript run.R
    ;;
  3)
 		apptainer shell radian.sif bash
    ;;
	*)
    echo "Type 1-3"
    ;;
  esac
}

menu "$@"
