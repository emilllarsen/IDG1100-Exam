#!/bin/bash

# This is called Content-type header, it informs the client about the type of the returned data.
echo "Content-type: text/html"
echo ""

# Read POST request data, store it in variable.
read POST_DATA

# Extract city and guess, store it in variables.
CITY=$(echo "$POST_DATA" | sed 's/.*city=\([^&]*\).*/\1/')
GUESS=$(echo "$POST_DATA" | sed 's/.*guess=\([^&]*\).*/\1/')

# Fetch Latitude and Longitude using Nominatim API.
GEO_RESPONSE=$(curl -s "https://nominatim.openstreetmap.org/search?q=$CITY&format=json&limit=1")
LATITUDE=$(echo "$GEO_RESPONSE" | jq -r '.[0].lat')
LONGITUDE=$(echo "$GEO_RESPONSE" | jq -r '.[0].lon')

# Fetch current temperature using Open-Meteo API.
WEATHER_RESPONSE=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LATITUDE&longitude=$LONGITUDE&current_weather=true")
TEMPERATURE=$(echo "$WEATHER_RESPONSE" | jq -r '.current_weather.temperature')

# Compare user's guess with the actual temperature.
DIFF=$(echo "$TEMPERATURE - $GUESS" | bc)
DIFF=${DIFF#-}  # Get the absolute value
if (( $(echo "$DIFF <= 5" | bc -l) )); then # -l to calculate decimals.
    RESULT="You win!"
else
    RESULT="You lose."
fi

# Load HTML template and replace placeholders.
cat template.html \
    | sed "s/{{CITY}}/$CITY/g" \
    | sed "s/{{GUESS}}/$GUESS/g" \
    | sed "s/{{TEMPERATURE}}/$TEMPERATURE/g" \
    | sed "s/{{RESULT}}/$RESULT/g"