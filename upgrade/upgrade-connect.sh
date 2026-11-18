#!/bin/sh
sudo apt-mark unhold rstudio-connect
sudo apt update
sudo apt upgrade rstudio-connect
sudo apt-mark hold rstudio-connect

