---
layout: post
title:  "Python Tipp 3: Contextmanagers in action: writing a rename context manager"
date:   2018-05-26 19:10:00 +0100
categories: python-tipp python contextmanager context manager threading hacks locks snippets
comments: true
---

### Problem

Sometimes we find ourselves having trouble with variables of great verbosity.
It feels unelegant and unpythonic to do something like the following code snippet to declare 
temp variables which we would get rid of the next second:

```python
a = a_variable_with_a_very_long_name
b= another_variable_with_a_very_long_name

result = (a + do_some_calc(b)) - ((1 / do_some_calc(a) )-b)
del a
del b 
```

### Idea

What if we could do something like this:


```python

with rename(a= a_variable_with_a_very_long_name,b=another_variable_with_a_very_long_name):
    result = (a + do_some_calc(b)) - ((1 / do_some_calc(a) )-b)
```

### Implementation 

How would we go about implementing such a contextmanager ?
The code might look very similiar to this:
```python

import threading


class rename:
    _lock = threading.Lock()

    def __init__(self, **kwargs):
        self.abbrs = kwargs
        self.store = {}

    def __enter__(self):
        rename._lock.acquire()

        for key, value in self.abbrs.items():
            try:
                self.store[key] = globals()[key]
            except KeyError:
                pass
            globals()[key] = value

    def __exit__(self, *args, **kwargs):
        for key in self.abbrs:
            try:
                globals()[key] = self.store[key]
            except KeyError:
                del globals()[key]
        rename._lock.release()

```

### Discussion

You might ask yourself why we added the threading.Lock.
Given that we change the globals dir and it actually gives us the python-interpreter-agnostic
possibility (unlike locals)<sup>1</sup> to alter all visible and declared variables we can run into trouble
doing so in a multi threaded fashion.
Hence we implemented a thread-safe - but mind you **while-in-the-context-manager-scope-blocking**,
way of renaming our variables.

### Proving that it works

And as we can see here, it works brilliantly well:

```python

a = 2
b = 5

with rename(test=a):
    print(test)

_err = None
try:
    test
except NameError as err:
    _err = err

assert _err


```



### Footnotes:

1 - There is a note in the locals implementation that states: "updates to this dictionary will affect name lookups in
    the local scope and vice-versa is *implementation dependent*":

```python
def locals(*args, **kwargs): # real signature unknown
    """
    Return a dictionary containing the current scope's local variables.
    
    NOTE: Whether or not updates to this dictionary will affect name lookups in
    the local scope and vice-versa is *implementation dependent* and not
    covered by any backwards compatibility guarantees.
    """
    pass
```
