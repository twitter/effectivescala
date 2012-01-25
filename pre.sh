#!/bin/bash

sed '
s;^\.< \(.*\)$;<p class="unind">\1</p>;g
'
