#!/bin/bash
sudo apt policy dump
sudo apt -y install dump
sudo apt -y remove dump
sudo apt -y autoremove
sudo apt policy dump