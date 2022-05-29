from setuptools import setup
setup(
    install_requires=[
        "boto3",
        "urllib3"
    ],
    entry_points={
        'console_scripts': [
            'cloudflare-security-group-updater = updater.main:main'
        ]
    }
)
