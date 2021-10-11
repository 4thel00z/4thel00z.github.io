----
title:  "templatectl"
date:  "2021-10-12"
categories: "coding, golang, templating, power-user, cookiecutter"
comments: false
layout: layouts/post.njk
----

Because of my python background I sometimes miss the powerful project boilerplating tool called [cookiecutter](https://github.com/cookiecutter/cookiecutter).
While I find it convenient I also found it annoying that it was not lightweight, had a clunky API and needed a Python interpreter to run.
Why noone built sth. like cookiecutter in go? :(
Then I came across [boilr](https://github.com/tmrts/boilr). While it looked promising at first, it was an abandonware.
So I thought it might be a good idea to build something on top of it called [templatectl](https://github.com/4thel00z/templatectl).

Current enhancements include a self upgrade mechanism and some filters for ease of use.
Also I have created two new templates which play well with my other projects:

- [blog-post-template](https://github.com/4thel00z/blog-post-template) - This is for generating posts for this blogging plattform
- [service_templated module](https://github.com/4thel00z/service-templated-module) - This is for generating modules for [service_templated](https://github.com/4thel00z/service_templated)

If you like the idea give it a spin, peace.
