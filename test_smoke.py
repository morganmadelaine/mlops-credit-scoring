"""Smoke test: verify the package is importable."""

import credit_scoring


def test_package_imports() -> None:
    """The package should be importable from the installed environment."""
    assert credit_scoring is not None
