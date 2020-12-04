---
layout: post
title:  "lfs: go module checksum mismatch"
date:  2020-12-04 14:40:12+01:00
categories: 
comments: false
---

## Weird go module checksum mismatches

The other day I was troubleshooting weird go module checksum mismatches for my [lambda](https://github.com/4thel00z/lambda) module..
It was driving me nuts why the go module checksum was mismatching.
I was assuming that this was relating to me ammending my tags and force pushing it (and I can confirm that this breaks the checksum too but is somewhat expected :D).
However even after pushing a new tag it was still broken.
I found the solution when I read this post:

```
https://github.com/golang/go/issues/39720
```

go module checksum mechanism does not support git extension like git-lfs yet, which I happened to use for my project to host the image (which was complete nonesense, since the image is just a couple of kbytes..).

After removing git-lfs and creating a new tag I could finally use my library :).
