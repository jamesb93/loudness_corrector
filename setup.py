from setuptools import setup

setup(
    name="lcr",
    version="1.0",
    author="James Bradbury",
    author_email="jamesbradbury93@gmail.com",
    description="Automatic loudness correction.",
    entry_points={
        "console_scripts": [
            "lcr = correct.main"
        ]
    }
)
