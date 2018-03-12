---
layout: post
title:  "Python Tipp 1: How to write a context manager"
date:   2018-03-04 19:19:41 +0100
categories: python-tipp python contextmanager context manager

---

# Python Tipp 1 - Class based context managers

Sometimes you catch yourself writing code that is full of try and except blocks to deal with a component that has an open and close function.

Imagine you have this scenario:

```python

class ConnectionPool(BoilerPlateConnectionPool):

    def open(self, res: Resource) -> Connection:
        """
        Do some opening operation
        :param res:
        """
        con = None
      
        try:
            con  = self.get_con(res)
            con.open()
            self.connections[id(con)] = [con]
        except ConnectionException as err:
            self._open_error_handler(err)
        finally:
            return con

    def close(self, con: Connection):
        """
        Do some closing operation
        If not invoked we will get a memory leak
        :param con:
        """
        if con.is_closed():
            raise ConnectionException()
        
        self._look_up_closer(con).close()
        
    def handle(self, req: Request):
        """
        Using the opened connections handle the given request
        :param req: The request object which this pool should handle
        """
        # FIXME: add an implementation
        
pool = ConnectionPool(options)

con = pool.open(res)

do_things_with_con(con)
try:
    pool.close(con)

```
It doesn't look exactly elegant, right ?
We can fix that through using the stdlib API called "contextlib" / the python feature called Contextmanager.

This is not exactly the newest python feature, we can find it being referenced via the corresponding syntax sugar the with statement in [PEP-343](https://www.python.org/dev/peps/pep-0343/).

There are many ways to approach this:


## Class based context managers

Class based context managers work as follows (VAR is the context manager and EXPR the constructor/something which is analogue to one):


```python
VAR = EXPR
VAR.__enter__()
try:
    BLOCK
finally:
    VAR.__exit__()

```

The `CONTEXT_MANAGER.__enter__` dunder method is where you would call for instance your `ConnectonPool.open` or similiar initializing methods.
`BLOCK` is code that runs inside the "context" of `VAR`.
You are able to reference VAR inside the ``BLOCK`` scope and be sure that at the end of the the try block all resources are freed.
Under the assumpton you free the resources correctly in the ```CONTEXT_MANAGER.__exit__`` dunder method.
`
You would go about like this to actually implement a class based context manager

```python

class connection_pool():

    def __init__(self,options: ConnectionOptions, resources:typing.List[Resource]):
        self.connection_pool = ConnectionPool(options)
        self.resources = resources

    def __enter__(self):
        for res in self.resources:
            self.connection_pool.open(res)
    
        return self.connection_pool
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        try:
            for res in self.resources:
                self.connection_pool.close(res)
        except ConnectionException:
            # Silence the ConnectionException since the only cause
            #  can be an already closed Connection
            pass
            
```

We would use the contextmanager as such:

```python

options = _get_connection_options()
resources = _get_resources()
requests = _get_requests()

with connection_pool(options,resources) as pool:
    for req in requests:
        pool.handle(req)
```

