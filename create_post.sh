#! /usr/bin/zsh


cat > _posts/$(date --rfc-3339=date)-$2.md <<EOF
---
layout: post
title:  "$1"
date:  $(date --rfc-3339=seconds)
categories: 
comments: false
---
EOF
