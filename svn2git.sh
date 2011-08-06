#!/bin/bash
#
#     convert_svn_to_git.sh - easily convert your svn to git
#
#     Copyright (C) 2009  Stefano Mosconi <stefano.mosconi@gmail.com>
# 
#     Based on the initial recipe found at 
#     http://frank.thomas-alfeld.de/wp/2008/08/30/converting-git-svn-tag-branches\
#     -to-real-tags/
#     and other hints found there.
#     
#     License:
#
#     This program is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
#     This script provides an easy way to convert svn to git repositories.
#     I tried to make it the most automatic possible from cloning to converting the
#     tags.
# 
#     Since it's very much automatic it's not failproof that you will get what you
#     need.
#     It supports 2 kind of SVN layouts:
# 
#     The so called (by git folks) standard layout (used by default):
# 
#     ./project/
#     ./project/trunk
#     ./project/tags
#     ./project/branches
# 
#     And another layout (that I nicknamed multi) that is the layout that I saw most
#     commonly used when it happens that you have multiple projects under the same
#     svn tree:
# 
#     ./trunk/project1
#     ./tags/project1
#     ./branches/project1
#     ./trunk/project2
#     ./tags/project2
#     ./branches/project2

# http://stezz.blogspot.com/2009/04/really-convert-your-svn-to-git-with-one.html


print_help()
{
echo -n "$0\nAn easier way to convert your svn repo into a git one.\n
usage: $0 -r <path/to/svn/repo> -a <path/to/authorsfile>\n
Additional options:\n  
   -s use standard layout of SVN (default)\n
   -m use different layout of SVN (read the docs)\n
   -u SVN username\n"
}

options="std"

while getopts "r:sma:u:" flag; do
    case $flag in
    r)
        url="$OPTARG"
        ;;
    s)
        options="std"
        ;;
    m)
        options="multi"
        ;;
    a)
        authorsfile="$OPTARG"
        ;;
    u)
        username="$OPTARG"
        ;;
    *)
        print_help; exit 1
        ;;
    esac
done

if [ "$options" = "multi" ]; then
    url=`echo $url | grep trunk`
    reponame=`basename $url`
    baseurl=`dirname $url | sed -e 's/\/trunk//'`
    urlopt="-T $url -t ${baseurl}/tags/$reponame -b ${baseurl}/branches/$reponame"
elif [ "$options" = "std" ]; then
    urlopt="--stdlayout"
    if [ ! X"$url" = X"" ]; then
        reponame=`basename $url`
    fi
fi

if [ X"$url" = X"" ]; then
    tput bold
    echo -n "===\nE: Please enter the URL (it should have trunk in the address if you have -m option)\n===\n"
    tput sgr0
    print_help
    exit 1
fi

if [ X"$authorsfile" = X"" ]; then
    tpur bold
    echo -n "===\nE: Please set authorsfile (and maybe also username if required)\n===\n"
    tput sgr0
    print_help
    exit 1
fi

PWD=`pwd`
GITK=`which gitk`

git-svn clone $urlopt --authors-file $authorsfile --no-metadata ${username:+--username $username} --prefix=svn-import/ $url $reponame
ret=$?
if [ "$ret" = "0" ]; then
    cd $reponame
    for branch in `git branch -r`; do
        echo "processing $branch"
        if [ `echo $branch | egrep "svn-import/tags/.+$"` ]; then
            version=`basename $branch`
            subject=`git log -1 --pretty=format:"%s" $branch`
            GIT_COMMITTER_DATE=`git log -1 --pretty=format:"%ci" $branch`
            export GIT_COMMITTER_DATE

            git tag -f -m "$subject" "debian/$version" "$branch^"
            git branch -d -r $branch
        fi
    done
    echo "Syncing master --> remote/svn-import/trunk"
    git reset --hard remotes/svn-import/trunk
    ret=$?
    if [ "$ret" = "0" ]; then
        git branch -r -d svn-import/trunk
    fi
    branches=`git branch -r`
    if [ ! X"$branches" = X"" ]; then
        tput bold
        echo "You still have some remote tracking branches!"
        tput sgr0
        echo "I would do..."
        for i in $branches; do
            echo "git checkout -b $i $i"
            echo "git branch -d -r $i"
        done
    fi
    if [ ! X"$GITK" = X"" ]; then
        echo "Do you want to see your repo with gitk? [Y/n]"
        read yesno
        if [ -z $yesno ] || [ $yesno = "Y" ] || [ $yesno = "y" ]; then
            $GITK --all
        fi
    else
        echo "I would have liked to run gitk to show how nice is your git repo... but you don't have it installed... sorry"
    fi
    cd $PWD
else
    echo "git-svn clone seems to have failed... removing dir $reponame"
    rm -rf $reponame
fi
