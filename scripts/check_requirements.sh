#!/bin/bash

# Check for python
if ! command -v python3 &> /dev/null
then
    echo "Python could not be found"
    exit 1
fi

# Check for iconv
if ! command -v iconv &> /dev/null
then
    echo "iconv could not be found"
    exit 1
fi

# Check for zip
if ! command -v zip &> /dev/null
then
    echo "zip could not be found"
    exit 1
fi

# Check for GEMINI_API_KEY
if [ -z "$GEMINI_API_KEY" ]; then
    echo "GEMINI_API_KEY is not set"
    echo "please type 'export GEMINI_API_KEY=<Your API key>' in your terminal"
    exit 1
fi

echo "All requirements are met."
echo
sleep 5s