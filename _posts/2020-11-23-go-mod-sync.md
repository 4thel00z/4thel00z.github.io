---
layout: post
title:  "go mod -sync"
date:  2020-11-23 16:52:41+01:00
categories: 
comments: false
---

## Silent deprecation
In case you ask yourself why:

`
go mod -sync
`

doesnt't work anymore, it is because it was deprecated in favor of:

`
go mod tidy
`
