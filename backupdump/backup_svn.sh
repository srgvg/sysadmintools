#!/bin/bash
for repo in $(find  /var/lib/svn/ -mindepth 1 -maxdepth 1 -type d )
        do svnadmin hotcopy $repo ./$(basename $repo)
        done

