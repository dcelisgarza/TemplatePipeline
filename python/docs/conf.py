"""Sphinx configuration."""

from importlib.metadata import version as _version

project = "shapes-python"
release = _version("shapes-python")
extensions = ["sphinx.ext.autodoc", "sphinx.ext.napoleon", "sphinx.ext.viewcode"]
autodoc_member_order = "bysource"
html_theme = "furo"
html_title = f"{project} {release}"
