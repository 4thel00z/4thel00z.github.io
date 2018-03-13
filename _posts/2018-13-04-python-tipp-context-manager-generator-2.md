---
layout: post
title:  "Python Tipp 2: How to write a generator based context manager"
date:   2018-04-13 19:19:41 +0100
categories: python-tipp python contextmanager context manager generator

---


Given the ConnectionPool example from the [Python Tipp 1: How to write a class based context manager](https://4thel00z.github.io/python-tipp-context-manager-class-1/),
wa want to proceed to write a generator based context manager.
Since we have already discussed the advantages of context manager vs. conventional resource handling we will just include the ConnectionPool example for brevity and prcoeed with the generator based example:

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
        
```

For this example we will need the stdlib API ```contextlib``` which provides tools to ease the creation of contextmanagers.
There is a dedicated decorater called ```contextlib.contextmanager``` which under the hood creates the needed ```__enter__``` and ```__exit__``` dunder methods on the given generator.
This is the actual implementation in CPython 3.6:

```python
def contextmanager(func):
    """@contextmanager decorator.

    Typical usage:

        @contextmanager
        def some_generator(<arguments>):
            <setup>
            try:
                yield <value>
            finally:
                <cleanup>

    This makes this:

        with some_generator(<arguments>) as <variable>:
            <body>

    equivalent to this:

        <setup>
        try:
            <variable> = <value>
            <body>
        finally:
            <cleanup>

    """
    @wraps(func)
    def helper(*args, **kwds):
        return _GeneratorContextManager(func, args, kwds)
    return helper
```

It comes as no big suprise that the _GeneratorContextManager listens to the ```StopIteration``` exception which is used internally with generators to know when a generator was consumed:

```python

class _GeneratorContextManager(ContextDecorator, AbstractContextManager):
    """Helper for @contextmanager decorator."""

    def __init__(self, func, args, kwds):
        self.gen = func(*args, **kwds)
        self.func, self.args, self.kwds = func, args, kwds
        # Issue 19330: ensure context manager instances have good docstrings
        doc = getattr(func, "__doc__", None)
        if doc is None:
            doc = type(self).__doc__
        self.__doc__ = doc
        # Unfortunately, this still doesn't provide good help output when
        # inspecting the created context manager instances, since pydoc
        # currently bypasses the instance docstring and shows the docstring
        # for the class instead.
        # See http://bugs.python.org/issue19404 for more details.

    def _recreate_cm(self):
        # _GCM instances are one-shot context managers, so the
        # CM must be recreated each time a decorated function is
        # called
        return self.__class__(self.func, self.args, self.kwds)

    def __enter__(self):
        try:
            return next(self.gen)
        except StopIteration:
            raise RuntimeError("generator didn't yield") from None

    def __exit__(self, type, value, traceback):
        if type is None:
            try:
                next(self.gen)
            except StopIteration:
                return False
            else:
                raise RuntimeError("generator didn't stop")
        else:
            if value is None:
                # Need to force instantiation so we can reliably
                # tell if we get the same exception back
                value = type()
            try:
                self.gen.throw(type, value, traceback)
            except StopIteration as exc:
                # Suppress StopIteration *unless* it's the same exception that
                # was passed to throw().  This prevents a StopIteration
                # raised inside the "with" statement from being suppressed.
                return exc is not value
            except RuntimeError as exc:
                # Don't re-raise the passed in exception. (issue27122)
                if exc is value:
                    return False
                # Likewise, avoid suppressing if a StopIteration exception
                # was passed to throw() and later wrapped into a RuntimeError
                # (see PEP 479).
                if type is StopIteration and exc.__cause__ is value:
                    return False
                raise
            except:
                # only re-raise if it's *not* the exception that was
                # passed to throw(), because __exit__() must not raise
                # an exception unless __exit__() itself failed.  But throw()
                # has to raise the exception to signal propagation, so this
                # fixes the impedance mismatch between the throw() protocol
                # and the __exit__() protocol.
                #
                if sys.exc_info()[1] is value:
                    return False
                raise
            raise RuntimeError("generator didn't stop after throw()")


```

Since we were shieleded from the hard parts which were thankfully abstracted away for us, creating a generator based contextmanager is a matter of these 17 lines:

```python

from contextlib import contextmanager

@contextmanager
def connection_pool(options: ConnectionOptions, resources:typing.List[Resource]):
    try:
        _connection_pool = ConnectionPool(options)
        for res in resources:
            connection_pool.open(res)
        yield _connection_pool
        
    finally:
        try:
            for res in resources:
                _connection_pool.close(res)
        except ConnectionException:
            # Silence the ConnectionException since the only cause
            #  can be an already closed Connection
            pass
         
```

