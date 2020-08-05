from setuptools import setup

setup(
    name="lcr",
    version="1.0",
    author="James Bradbury",
    author_email="jamesbradbury93@gmail.com",
    description="Automatic loudness correction.",
    packages=["lcr"],
    entry_points={
        "console_scripts": [
            "lcr = lcr.main:main"
        ]
    }
)
