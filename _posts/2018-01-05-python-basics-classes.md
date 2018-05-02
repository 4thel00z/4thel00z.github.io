---
layout: post
title:  "Python Basics 1: How to write a class"
date:   2018-05-01 19:19:41 +0100
categories: python-basics python class classes docs fundamentals
comments: true
---

Classes are abstractions over data and functionality.
You can think of a class as a blueprint for an object.
We call the objects of a certain class "instances".
These instances can have attributes to contain either primitive values (int, string, etc.) or more complex ones (other class instances,lambdas etc.).
Class instances can also have so called methods (defined by its class) for modifying its attributes.

There is a special method called ```__init__``` that a class can implement to be "creatable". It is called "constructor".
A minimal example of a class just containing that method can be seen here:

```python

class Example:
    def __init__(self):
        pass
```

Since methods are **belonging** to the respective class and change **its** attributes we need a mechanism to access the current object/context.
By convention the first parameter inside a method signature (in our case the **self** parameter) will be populated with the current object.
We use pass because the method body is currently empty to tell the interpreter that we closed the scope of the method ```__init__```.

To add a new property called ```a``` containing the value ```4``` we would do:

```python

class Example:
    def __init__(self):
        self.a = 4 
```

We can create and alter attributes on runtime or in the initphase when ```__init__``` is called.
We can access the attributes of the class instance via the dot-notation.
Meaning :

```python
instance.some_attribute
```


This is how to change a value at runtime using the dot-notation:

```python

class Example:
    def __init__(self):
        self.a = 4 


example = Example()
example.a = 10
print(example.a)
```

With classes you can have inheritance so you can keep your API code slimmer:

```python

class Parent:

    def some_nasty_method(self,a,b,c):  

class Sibling:
    def do_stuff(self):
        """This method will invoke some_nasty_method"""
        for i in range(100):
            self.some_nasty_method(i,i*2,i**2)
        
```
The lookup for a method uses the ```Method resolution order``` which you can query by looking into the output of the Class mro function:

```python

class Parent:

    def some_nasty_method(self,a,b,c):  

class Sibling:
    def do_stuff(self):
        """This method will invoke some_nasty_method"""
        for i in range(100):
            self.some_nasty_method(i,i*2,i**2)
print(Parent.mro())     
print(Sibling.mro())     
```