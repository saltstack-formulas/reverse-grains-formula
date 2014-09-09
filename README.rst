======================
reverse-grains-formula
======================

Formula to configure grains via pillar in a grain/hosts rather than host/grains manner.


.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``grains``
---------

Configure grains in /etc/salt/grains. Written with the py renderer. Utilizes
compound matches in the pillar to apply the grains and their values.
