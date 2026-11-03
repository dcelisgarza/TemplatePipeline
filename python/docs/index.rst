shapes-python
=============

Area and perimeter of plane shapes. The package installs the library
``shapes`` and the program ``shapes-python``.

.. code-block:: python

   from shapes import make_shape

   shape = make_shape("triangle", [3, 4, 5])
   print(shape.area())  # 6.0

API
---

.. automodule:: shapes.core
   :members:
   :show-inheritance:

Command line
------------

.. automodule:: shapes.cli
   :members: main, interactive
