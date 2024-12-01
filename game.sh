#!/bin/bash 

# Output Content-Type header
echo "Content-type: text/html"
echo ""

# Read POST request data
read POST_DATA

# Extract city and guess
CITY=$(echo "$POST_DATA" | sed -n 's/.*city=\([^&]*\).*/\1/p')
GUESS=$(echo "$POST_DATA" | sed -n 's/.*guess=\([^&]*\).*/\1/p')

# Fetch Latitude and Longitude using Nominatim API
GEO_RESPONSE=$(curl -s "https://nominatim.openstreetmap.org/search?q=$CITY&format=json&limit=1")
LATITUDE=$(echo "$GEO_RESPONSE" | jq -r '.[0].lat')
LONGITUDE=$(echo "$GEO_RESPONSE" | jq -r '.[0].lon')

# Fetch current temperature using Open-Meteo API
WEATHER_RESPONSE=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LATITUDE&longitude=$LONGITUDE&current_weather=true")
TEMPERATURE=$(echo "$WEATHER_RESPONSE" | jq -r '.current_weather.temperature')

# Compare user's guess with the actual temperature
DIFF=$(echo "$TEMPERATURE - $GUESS" | bc)  # Absolute difference
if (( $(echo "$DIFF <= 5" | bc -l) )); then
    RESULT="You Win! 🎉"
else
    RESULT="You Lose. 😔"
fi

# Load HTML template and replace placeholders
cat template.html \
    | sed "s/{{CITY}}/$CITY/g" \
    | sed "s/{{GUESS}}/$GUESS/g" \
    | sed "s/{{TEMPERATURE}}/$TEMPERATURE/g" \
    | sed "s/{{RESULT}}/$RESULT/g"