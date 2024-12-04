#!/bin/bash

#Read the difficulty level from POST data.
DIFFICULTY=$(echo "$POST_DATA" | sed 's/.*difficulty=\([^&]*\).*/\1/')

#Set tolerance based on difficulty.
if [ "$DIFFICULTY" == "easy" ]; then
    TOLERANCE=5
elif [ "$DIFFICULTY" == "medium" ]; then
    TOLERANCE=3
else
    TOLERANCE=1
fi
