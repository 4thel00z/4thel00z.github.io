#! /usr/bin/zsh


cat > _posts/$(date --rfc-3339=date)-$2 << EOF
----
-layout: post
-title:  "$1"
-date:  $(date --rfc-3339=seconds)
-categories: 
-comments: true
----
EOF 
