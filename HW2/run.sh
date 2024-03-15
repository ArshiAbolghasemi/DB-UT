#!/bin/bash

docker run --name ut_bd_hw2 -e MYSQL_ROOT_PASSWORD=root -e MYSQL_ROOT_USERNAME=root -p 3306:3306 -d mysql

